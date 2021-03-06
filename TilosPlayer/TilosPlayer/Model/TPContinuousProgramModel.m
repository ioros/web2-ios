//
//  TPContinuousProgramModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 18/02/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPContinuousProgramModel.h"

#import "TPEpisodeData.h"
#import "TPShowData.h"


NSString *const TPContinuousProgramModelDidFinishNotification = @"TPContinuousProgramModelDidFinishNotification";
NSString *const TPContinuousProgramModelDidInsertDataNotification = @"TPContinuousProgramModelDidInsertDataNotification";

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
    NSLog(@"%@",date);
    __block TPContinuousProgramModel *weakSelf = self;
    
    if(self.episodes.count > 0)
    {
        TPEpisodeData *firstEpisode = [self.episodes firstObject];
        NSLog(@"%@",firstEpisode.name);
        TPEpisodeData *lastEpisode = [self.episodes lastObject];
        NSLog(@"%@",lastEpisode.name);
        if(1000*(long long)date.timeIntervalSince1970 >= 1000*(long long)firstEpisode.plannedFrom.timeIntervalSince1970 && 1000*(long long)date.timeIntervalSince1970 < 1000*(long long)lastEpisode.plannedTo.timeIntervalSince1970)
        {
            // we already have the data
            NSLog(@"no need to load episodes.");
            return;
        }
    }
    
    NSDate *startOfDay = date;
//    NSDate *startOfDay = [date dayDate];
//    NSDate *startOfDay = [now dateByAddingTimeInterval:-0.5 * 60 * 60];
    NSLog(@"%@",startOfDay);
//    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:24 * 60 * 60];
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:0.1 * 60 * 60];
    NSLog(@"%@",endOfDay);
    
    NSString *queryString = [NSString stringWithFormat:@"start=%lld&end=%lld", 1000*(long long)[startOfDay timeIntervalSince1970], 1000*(long long)[endOfDay timeIntervalSince1970]];
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
    
    NSString *queryString = [NSString stringWithFormat:@"start=%lld&end=%lld", 1000*(long long)[startOfDay timeIntervalSince1970], 1000*(long long)[endOfDay timeIntervalSince1970]];
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
    
    NSString *queryString = [NSString stringWithFormat:@"start=%lld&end=%lld", 1000*(long long)[startOfDay timeIntervalSince1970], 1000*(long long)[endOfDay timeIntervalSince1970]];
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
        //NSLog(@"data %@", JSON);
        
        NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
        self.episodes = [episodes mutableCopy];
        
        self.initialOperation = nil;
        
        [self sendFinished];
    }
    else if(operation == self.tailOperation)
    {
        NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
        

        NSArray *oldEpisodes = self.episodes;
        if(oldEpisodes.count > 0 && episodes.count > 0)
        {
            // check for connection
            TPEpisodeData *firstEpisode = [episodes firstObject];
            TPEpisodeData *lastEpisode = [oldEpisodes lastObject];
            
            if([firstEpisode.show.identifier isEqual:lastEpisode.show.identifier])
            {
                // same episode
                
                // TODO: update this when server is fixed with real plannedFrom, plannedTo timestamps
                
                lastEpisode.plannedTo = firstEpisode.plannedTo;
                NSMutableArray *newEpisodes = [episodes mutableCopy];
                [newEpisodes removeObjectAtIndex:0];
                episodes = newEpisodes;
            }
        }

        // save the real startindex
        NSInteger startIndex = self.episodes.count;
        
        self.episodes = [[self.episodes arrayByAddingObjectsFromArray:episodes] mutableCopy];
        self.tailOperation = nil;
        
        // generate indexPaths

        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger count = episodes.count;
        for(int i =0; i<count; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:startIndex + i inSection:0]];
        }
        [self sendDataInserts:indexPaths atEnd:YES];
    }
    else if(operation == self.headOperation)
    {
        NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
        
        NSArray *oldEpisodes = self.episodes;
        if(oldEpisodes.count > 0 && episodes.count > 0)
        {
            // check for connection
            TPEpisodeData *firstEpisode = [oldEpisodes firstObject];
            TPEpisodeData *lastEpisode = [episodes lastObject];
            
            if([firstEpisode.show.identifier isEqual:lastEpisode.show.identifier])
            {
                // same episode
                
                // TODO: update this when server is fixed with real plannedFrom, plannedTo timestamps

                firstEpisode.plannedFrom = lastEpisode.plannedFrom;
                NSMutableArray *newEpisodes = [episodes mutableCopy];
                [newEpisodes removeLastObject];
                episodes = newEpisodes;
            }
        }
        
        self.episodes = [[episodes arrayByAddingObjectsFromArray:self.episodes] mutableCopy];
        self.headOperation = nil;

        // generate indexpaths
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger count = episodes.count;
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

- (id)dataForIndexPath:(NSIndexPath *)indexPath
{
    return [self dataForRow:indexPath.row section:indexPath.section];
}
- (id)dataForRow:(NSInteger)row section:(NSInteger)section
{
    return [_episodes objectAtIndex:row];
}

#pragma mark -

- (void)sendFinished
{
    if([_delegate respondsToSelector:@selector(continuousProgramModelDidFinish:)])
    {
        [_delegate performSelector:@selector(continuousProgramModelDidFinish:) withObject:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TPContinuousProgramModelDidFinishNotification object:self];
}

- (void)sendDataInserts:(NSArray *)indexPaths atEnd:(BOOL)atEnd
{
    if([_delegate respondsToSelector:@selector(continuousProgramModel:didInsertDataAtIndexPaths:atEnd:)])
    {
        [_delegate continuousProgramModel:self didInsertDataAtIndexPaths:indexPaths atEnd:atEnd];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TPContinuousProgramModelDidInsertDataNotification object:self userInfo:@{@"indexPaths":indexPaths, @"atEnd":[NSNumber numberWithBool:atEnd]}];
}

#pragma mark -

- (NSIndexPath *)indexPathForData:(id)data
{
    NSUInteger index = [self.episodes indexOfObject:data];
    if(index != NSNotFound)
    {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    return nil;
}

- (NSIndexPath *)indexPathForLiveData
{
    // select the live episode
    NSDate *now = [NSDate date];
    NSInteger count = self.episodes.count;
    
    for(int i=0; i<count; i++)
    {
        TPEpisodeData *episode = [self.episodes objectAtIndex:i];
        TPEpisodeData *nextEpisode = nil;
        
        // TODO: remove this when server is fixd
        if(i < (count -1))
        {
            nextEpisode = [self.episodes objectAtIndex:i+1];
        }
        
        if(nextEpisode)
        {
            if([episode.plannedFrom timeIntervalSinceDate:now] < 0 && [nextEpisode.plannedFrom timeIntervalSinceDate:now] > 0)
            {
                return [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
        }
        else
        {
            if([episode.plannedFrom timeIntervalSinceDate:now] < 0 && [episode.plannedTo timeIntervalSinceDate:now] > 0)
            {
                return [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
        }
    }
    return nil;
}

@end
