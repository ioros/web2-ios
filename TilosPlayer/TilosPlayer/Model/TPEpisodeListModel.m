//
//  TPEpisodeListModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListModel.h"
#import "AFNetworking.h"
#import "TPEpisodeData.h"

@implementation TPEpisodeListModel

- (id)init
{
    self = [super init];
    if (self) {
        self.date = [NSDate date];
    }
    return self;
}

- (id)initWithParameters:(id)parameters
{
    self = [super initWithParameters:parameters];
    if(self)
    {
        self.date = parameters;
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

- (void)loadWithDate:(NSDate *)date
{
    self.date = date;
    [self loadForced:YES];
}

- (void)loadForced:(BOOL)forced
{
    if(self.date == nil) return;
    
    [self.operation cancel];
    self.operation = nil;
    
    NSDate *startOfDay = [self.date dayDate];
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:24 * 60 * 60];
    
    NSString *queryString = [NSString stringWithFormat:@"start=%lld&end=%lld", 1000*(long long)[startOfDay timeIntervalSince1970], 1000*(long long)[endOfDay timeIntervalSince1970]];
    NSString *url  =[NSString stringWithFormat:@"%@/episode?%@", kAPIBase, queryString];
    NSLog(@"tplistepisodemodel %@",url);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    __block TPEpisodeListModel *weakSelf = self;
    
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
    NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
    self.sections = @[[TPListSection sectionWithTitle:nil items:episodes]];
    [self sendFinished];
}

@end

