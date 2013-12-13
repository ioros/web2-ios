//
//  TPShowListModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowListModel.h"

#import "AFNetworking.h"
#import "NSArray+TPIndexedSorting.h"

@implementation TPShowListModel

- (id)init
{
    self = [super init];
    if (self) {
        self.filter = TPShowListModelFilterAll;
    }
    return self;
}

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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tilos.anzix.net/api/show"]];
    
    __block TPShowListModel *weakSelf = self;
    self.operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(weakSelf == nil) return;
        [self parseContent:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(weakSelf == nil) return;
        [weakSelf sendError:error];
    }];
    
    [self.operation start];
}

- (void)setFilter:(TPShowListModelFilter)filter
{
    _filter = filter;
    
    if(self.data)
    {
        [self updateWithFilter:_filter];
    }
    [self sendFinished];
}

- (void)parseContent:(id)JSON
{
    self.data = JSON;
    [self updateWithFilter:self.filter];
    [self sendFinished];
}

- (void)updateWithFilter:(TPShowListModelFilter)filter
{
    NSArray *data = self.data;
    
    if(filter == TPShowListModelFilterMusic)
    {
        data = [data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", 0]];
    }
    else if(filter == TPShowListModelFilterTalk)
    {
        data = [data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", 1]];
    }
    
    NSDictionary *indexes = [data indexesWithSortingKey:@"name" ascending:YES];
    NSArray *sortedKeys = [indexes.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSMutableArray *sections = [NSMutableArray array];
    for(NSString *key in sortedKeys)
    {
        TPListSection *section = [TPListSection sectionWithTitle:key items:[indexes objectForKey:key]];
        [sections addObject:section];
    }
    
    self.indexTitles = sortedKeys;
    self.sections = sections;
}

@end
