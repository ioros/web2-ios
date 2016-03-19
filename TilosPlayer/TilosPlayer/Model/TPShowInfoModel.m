//
//  TPShowInfoModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowInfoModel.h"

#import "TPShowData.h"

@implementation TPShowInfoModel

- (void)dealloc
{
    [_operation cancel];
    _operation = nil;
}

- (void)cancel
{
    [_operation cancel];
    _operation = nil;
}

- (void)loadForced:(BOOL)forced
{
    [self.operation cancel];
    self.operation = nil;
    
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
    
    
    NSArray *episodes = self.show.episodes;
    self.sections = @[[TPListSection sectionWithTitle:nil items:episodes]];
    
    [self sendFinished];
}

#pragma mark -


@end
