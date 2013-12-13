//
//  TPShowInfoModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowInfoModel.h"

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
    
    NSString *url = [NSString stringWithFormat:@"http://tilos.anzix.net/api/show/%@", showId];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    __block TPShowInfoModel *weakSelf = self;
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
    self.show = JSON;

    NSArray *episodes = [self.show objectForKeyOrNil:@"episodes"];
    self.sections = @[[TPListSection sectionWithTitle:nil items:episodes]];
    
    [self sendFinished];
}

#pragma mark -


@end
