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

@dynamic indexTitles;

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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/author", kAPIBase]]];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.operation = operation;
    
    __block TPAuthorListModel *weakSelf = self;
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
    
//    self.sections = @[ [TPListSection sectionWithTitle:nil items:authors] ];
//    [self sendFinished];
//    return;
    
    // get all nick objects and add the name to each
//    NSMutableArray *nicks = [NSMutableArray array];
    NSMutableDictionary *nicksDictionary = [NSMutableDictionary dictionary];
    
    for (TPAuthorData *author in authors)
    {
        NSArray *contributions = author.contributions;
        
        for(TPContributionData *contribution in contributions)
        {
            NSString *nick = contribution.nick;
            NSString *name = author.name;
                        
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setValue:name forKey:@"name"];
            [item setValue:author.avatarURL forKey:@"avatarURL"];
//            [item setValue:author.photoURL forKey:@"photoURL"];
            [item setValue:author.identifier forKey:@"id"];
            [item setValue:nick forKey:@"nick"];
            [item setValue:author forKey:@"author"];
            
            [nicksDictionary setObject:item forKey:[NSString stringWithFormat:@"%@-%@", nick, name]];
        }
    }
    
    NSDictionary *indexes = [nicksDictionary.allValues indexesWithSortingKey:@"nick" ascending:YES];
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
