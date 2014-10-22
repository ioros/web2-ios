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
    
    if (description.length > 0)
    {
        self.htmlString = [NSString stringWithFormat:@"<html><head></head><body><div id = \"content\" style=\"font-family:Avenir-Light; font-size:15px\">%@</div></body></html>", description];
    }
    
    NSArray *episodes = self.show.episodes;
    self.sections = @[[TPListSection sectionWithTitle:nil items:episodes]];
    
    [self sendFinished];
}

#pragma mark -


@end
