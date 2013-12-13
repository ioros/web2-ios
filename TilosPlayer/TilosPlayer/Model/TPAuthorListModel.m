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
    self.operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(weakSelf == nil) return;
        [self parseContent:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(weakSelf == nil) return;
        [weakSelf sendError:error];
    }];
    
    [self.operation start];
}

- (void)parseContent:(id)JSON
{
    NSDictionary *indexes = [(NSArray *)JSON indexesWithSortingKey:@"name" ascending:YES];
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
