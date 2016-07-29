//
//  TPShowInfoModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowInfoModel.h"
#import "TPShowData.h"
#import "TPEpisodeData.h"

@implementation TPShowInfoModel

- (void)dealloc
{
    [_operation cancel];
    _operation = nil;
    [_operation2 cancel];
    _operation2 = nil;
}

- (void)cancel
{
    [_operation cancel];
    _operation = nil;
    [_operation2 cancel];
    _operation2 = nil;
}

- (void)loadForced:(BOOL)forced
{
    [self.operation cancel];
    self.operation = nil;
    [self.operation2 cancel];
    self.operation2 = nil;
    
    NSString *showId = self.parameters;
    
    NSString *url = [NSString stringWithFormat:@"%@/show/%@", kAPIBase, showId];
    
    NSLog(@"%@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    self.operation = operation;

    __block TPShowInfoModel *weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        if(weakSelf == nil) return;
        [self parseContent:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf == nil) return;
        [weakSelf sendError:error];
    }];
    [operation start];

    NSDate *now = [NSDate date];
    NSDate *start = [now dateByAddingTimeInterval:-60*60*24*30*12];
    
    NSString *url2 = [NSString stringWithFormat:@"%@/show/%@/episodes?start=%lld&end=%lld", kAPIBase, showId, 1000*(long long)[start timeIntervalSince1970], 1000*(long long)[now timeIntervalSince1970]];
//    NSString *url2 = [NSString stringWithFormat:@"%@/show/%@/episodes?start=1&end=%lld", kAPIBase, showId, 1000*(long long)[now timeIntervalSince1970]];
    
    NSLog(@"%@",url2);
    
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:url2]];
    
    
    
    AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc]
                                             initWithRequest:request2];
    operation2.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.operation2 = operation2;
    
    __block TPShowInfoModel *weakSelf2 = self;
    [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation2, id responseObject2) {
    
        if(weakSelf2 == nil) return;
        [self parseContent2:responseObject2];
    
    } failure:^(AFHTTPRequestOperation *operation2, NSError *error) {
        if(weakSelf2 == nil) return;
        [weakSelf2 sendError:error];
    }];
    [operation2 start];
    
}

- (void)parseContent:(id)JSON
{
    self.show = [TPShowData parseWithObject:JSON];
    
    NSString *description = self.show.infoHTML;
    
    self.introAvailable = description.length > 0;
    
    if (self.introAvailable)
    {
        NSString *file = [[NSBundle mainBundle] pathForResource:@"showinfo" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        
        if(html)
        {
            self.introHTML = [NSString stringWithFormat:html, description];
        }
    }
    else
    {
        self.introHTML = @"";
    }
    
    
    NSArray *contributors = self.show.contributors;
    self.sections2 = @[[TPListSection sectionWithTitle:nil items:contributors]];
    
    [self sendFinished];
}
- (void)parseContent2:(id)JSON
{
    
    NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
    self.sections = @[[TPListSection sectionWithTitle:nil items:episodes]];
    [self sendFinished];
    
//    NSMutableArray *epizodok = [[NSMutableArray alloc] init];
//    NSArray *episodes = [TPEpisodeData parseWithObjects:JSON];
//    for (TPEpisodeData *episode in episodes)
//    {
//        [epizodok addObject:episode.description];
//        NSLog(@"%@",episode.description);
//    }
//    self.sections = @[[TPListSection sectionWithTitle:nil items:epizodok]];
//    [self sendFinished];
}

#pragma mark -



@end
