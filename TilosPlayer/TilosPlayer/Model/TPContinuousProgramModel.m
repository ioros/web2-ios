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
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:date];
    NSDate *startOfDay = [calendar dateFromComponents:components];
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:24 * 60 * 60];
    
    NSString *queryString = [NSString stringWithFormat:@"start=%d&end=%d", (int)[startOfDay timeIntervalSince1970], (int)[endOfDay timeIntervalSince1970]];
    NSString *url  =[NSString stringWithFormat:@"%@/episode?%@", kAPIBase, queryString];
    
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
    
    __block TPContinuousProgramModel *weakSelf = self;
    
    /*
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(weakSelf == nil) return;
        [self finishOperation:operation response:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf == nil) return;
        [weakSelf finishOperation:operation error:error];
    }];
    [operation start];
    
    self.tailOperation = operation;
     */
}

- (void)loadHead
{
    if(_headOperation) return;
}

#pragma mark -

- (void)finishOperation:(AFHTTPRequestOperation *)operation response:(id)JSON
{
    if(operation == self.initialOperation)
    {
        NSLog(@"data %@", JSON);
        
        NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
        
        
        self.initialOperation = nil;
    }
}

- (void)finishOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    
}



@end
