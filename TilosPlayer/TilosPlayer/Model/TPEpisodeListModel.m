//
//  TPEpisodeListModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListModel.h"
#import "AFNetworking.h"

@implementation TPEpisodeListModel

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
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:now];
    NSDate *startOfDay = [calendar dateFromComponents:components];
    NSDate *endOfDay = [startOfDay dateByAddingTimeInterval:24 * 60 * 60];
    
    
    NSString *queryString = [NSString stringWithFormat:@"start=%d&end=%d", (int)[startOfDay timeIntervalSince1970], (int)[endOfDay timeIntervalSince1970]];
    NSString *url  =[NSString stringWithFormat:@"http://tilos.anzix.net/api/episode?%@", queryString];

    NSLog(@"now %@ %@ %@", now, startOfDay, url);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    __block TPEpisodeListModel *weakSelf = self;
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
    self.sections = @[[TPListSection sectionWithTitle:nil items:(NSArray *)JSON]];
    [self sendFinished];
}

@end

