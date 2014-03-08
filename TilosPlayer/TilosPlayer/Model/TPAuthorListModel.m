//
//  TPAuthorListModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorListModel.h"

#import "AFNetworking.h"
#import "NSArray+TPIndexedSorting.h"
#import "TPAuthorData.h"
#import "TPContributionData.h"

@implementation TPAuthorListModel

- (void)dealloc
{
    [self.operation cancel];
    self.operation = nil;
}

- (void)cancel
{
    [self.operation cancel];
    self.operation = nil;
}

- (void)loadForced:(BOOL)forced
{
    
    [self.operation cancel];
    self.operation = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kAPIBase, @"author"]]];
    
    __block TPAuthorListModel *weakSelf = self;
    
    
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.operation = operation;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(weakSelf == nil) return;
        [self parseContent:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf == nil) return;
        [weakSelf sendError:error];
    }];
    [operation start];
}

- (void)parseContent:(id)JSON
{
    NSArray *authors = [TPAuthorData parseWithObjects:JSON];
    
    //self.sections = @[ [TPListSection sectionWithTitle:nil items:authors] ];
    //[self sendFinished];
    //return;
    
    // get all nick objects and add the name to each
    NSMutableArray *nicks = [NSMutableArray array];
    for (TPAuthorData *author in authors)
    {
        NSArray *contributions = author.contributions;
        
        for(TPContributionData *contribution in contributions)
        {
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setValue:author.name forKey:@"name"];
            [item setValue:author.avatarURL forKey:@"avatarURL"];
            [item setValue:author.photoURL forKey:@"photoURL"];
            [item setValue:author.identifier forKey:@"id"];
            [item setValue:contribution.nick forKey:@"nick"];
            [item setValue:author forKey:@"author"];
            
            [nicks addObject:item];
        }
    }
    
    NSDictionary *indexes = [nicks indexesWithSortingKey:@"nick" ascending:YES];
    NSArray *sortedKeys = [indexes.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableArray *sections = [NSMutableArray array];
    for(NSString *key in sortedKeys)
    {
        TPListSection *section = [TPListSection sectionWithTitle:key items:[indexes objectForKey:key]];
        [sections addObject:section];
    }
    
    self.indexTitles = sortedKeys;
    self.sections = sections;
    [self sendFinished];
}

@end
