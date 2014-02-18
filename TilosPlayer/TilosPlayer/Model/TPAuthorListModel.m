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
    NSArray *authors = JSON;
    
    
    // get all nick objects and add the name to each
    NSMutableArray *nicks = [NSMutableArray array];
    for (NSDictionary *author in authors)
    {
        NSArray *contributions = [author objectForKey:@"contributions"];
        
        for(NSDictionary *contribution in contributions)
        {
            NSDictionary *item = [contribution mutableCopy];
            [item setValue:[author objectForKey:@"name"] forKey:@"name"];
            [item setValue:[author objectForKey:@"avatar"] forKey:@"avatar"];
            [item setValue:[author objectForKey:@"photo"] forKey:@"photo"];
            [item setValue:[author objectForKey:@"id"] forKey:@"id"];
            
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
