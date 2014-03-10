//
//  TPContinuousProgramModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 18/02/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPContinuousProgramModel.h"

#import "TPEpisodeData.h"

@interface TPContinuousProgramModel ()

@property (nonatomic, retain) AFHTTPRequestOperation *tailOperation;
@property (nonatomic, retain) AFHTTPRequestOperation *headOperation;
@property (nonatomic, retain) AFHTTPRequestOperation *initialOperation;

@end

#pragma mark -

@implementation TPContinuousProgramModel

- (void)dealloc
{
    [_tailOperation cancel];
    _tailOperation = nil;
    [_headOperation cancel];
    _headOperation = nil;
}

- (void)jumpToDate:(NSDate *)date
{
    __block TPContinuousProgramModel *weakSelf = self;
    
    NSDate *startOfDay = [date dayDate];
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:24 * 60 * 60];
    
    NSString *queryString = [NSString stringWithFormat:@"start=%d&end=%d", (int)[startOfDay timeIntervalSince1970], (int)[endOfDay timeIntervalSince1970]];
    NSString *url  =[NSString stringWithFormat:@"%@/episode?%@", kAPIBase, queryString];
    
    NSLog(@"initial url %@", url);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
     
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
         if(weakSelf == nil) return;
         [self finishOperation:operation response:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if(weakSelf == nil) return;
         [weakSelf finishOperation:operation error:error];
    }];
    [operation start];

    self.initialOperation = operation;
}

- (void)loadTail
{
    if(_tailOperation) return;
    if(_episodes == nil || _episodes.count == 0) return;
    
    TPEpisodeData *lastEpisode = [self.episodes lastObject];
    NSDate *plannedTo = [lastEpisode plannedTo];
    
    // add an hour to get to the next day // hack?
    NSDate *date = [plannedTo dateByAddingTimeInterval:3600];
    
    // get the day boundings
    NSDate *startOfDay = [date dayDate];
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:24 * 60 * 60];
    
    NSString *queryString = [NSString stringWithFormat:@"start=%d&end=%d", (int)[startOfDay timeIntervalSince1970], (int)[endOfDay timeIntervalSince1970]];
    NSString *url  =[NSString stringWithFormat:@"%@/episode?%@", kAPIBase, queryString];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __block TPContinuousProgramModel *weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(weakSelf == nil) return;
        [self finishOperation:operation response:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf == nil) return;
        [weakSelf finishOperation:operation error:error];
    }];
    [operation start];
    
    self.tailOperation = operation;
}

- (void)loadHead
{
    if(_headOperation) return;
    if(_episodes == nil || _episodes.count == 0) return;

    
    TPEpisodeData *firstEpisode = [self.episodes firstObject];
    NSDate *plannedFrom = [firstEpisode plannedFrom];
    
    // subtract an hour to get to the next day // hack?
    NSDate *date = [plannedFrom dateByAddingTimeInterval:-3600];
    
    // get the day boundings
    NSDate *startOfDay = [date dayDate];
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:24 * 60 * 60];
    
    NSString *queryString = [NSString stringWithFormat:@"start=%d&end=%d", (int)[startOfDay timeIntervalSince1970], (int)[endOfDay timeIntervalSince1970]];
    NSString *url  =[NSString stringWithFormat:@"%@/episode?%@", kAPIBase, queryString];
    
    NSLog(@"head url %@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __block TPContinuousProgramModel *weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(weakSelf == nil) return;
        [self finishOperation:operation response:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf == nil) return;
        [weakSelf finishOperation:operation error:error];
    }];
    [operation start];
    
    self.headOperation = operation;
}

#pragma mark -

- (void)finishOperation:(AFHTTPRequestOperation *)operation response:(id)JSON
{
    if(operation == self.initialOperation)
    {
        NSLog(@"data %@", JSON);
        
        NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
        self.episodes = [episodes mutableCopy];
        
        self.initialOperation = nil;
        
        [self sendItilialLoaded];
    }
    else if(operation == self.tailOperation)
    {
        NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
        NSInteger startIndex = episodes.count;
        NSInteger count = episodes.count;
        self.episodes = [[self.episodes arrayByAddingObjectsFromArray:episodes] mutableCopy];
        self.tailOperation = nil;

        NSMutableArray *indexPaths = [NSMutableArray array];
        for(int i =0; i<count; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:startIndex + i inSection:0]];
        }
        [self sendDataInserts:indexPaths atEnd:YES];
    }
    else if(operation == self.headOperation)
    {
        NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
        NSInteger count = episodes.count;
        self.episodes = [[episodes arrayByAddingObjectsFromArray:self.episodes] mutableCopy];
        self.headOperation = nil;
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for(int i =0; i<count; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self sendDataInserts:indexPaths atEnd:NO];
    }
}

- (void)finishOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    if(operation == _initialOperation)
    {
        self.initialOperation = nil;
    }
    else if(operation == _tailOperation)
    {
        self.tailOperation = nil;
    }
    else if(operation == _headOperation)
    {
        self.headOperation = nil;
    }
}

#pragma mark -

- (NSInteger)numberOfSections
{
    return _episodes ? 1 : 0;
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return _episodes.count;
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self dataForRow:indexPath.row section:indexPath.section];
}
- (id)dataForRow:(NSInteger)row section:(NSInteger)section
{
    return [_episodes objectAtIndex:row];
}

#pragma mark -

- (void)sendItilialLoaded
{
    if([_delegate respondsToSelector:@selector(continuousProgramModelDidLoadInitial:)])
    {
        [_delegate performSelector:@selector(continuousProgramModelDidLoadInitial:) withObject:self];
    }
}

- (void)sendDataInserts:(NSArray *)indexPaths atEnd:(BOOL)atEnd
{
    if([_delegate respondsToSelector:@selector(continuousProgramModel:didInsertDataAtIndexPaths:atEnd:)])
    {
        [_delegate continuousProgramModel:self didInsertDataAtIndexPaths:indexPaths atEnd:atEnd];
    }
}

@end
