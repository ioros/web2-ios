//
//  TPAuthorInfoModel.m
//  TilosPlayer
//
//  Created by Tibor Kántor on 14/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorInfoModel.h"

#import "TPAuthorData.h"

@implementation TPAuthorInfoModel

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
    
    NSString *authorId = self.parameters;
    
    NSString *url = [NSString stringWithFormat:@"%@/author/%@", kAPIBase, authorId];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    self.operation = operation;
    
    __block TPAuthorInfoModel *weakSelf = self;
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
    self.author = [TPAuthorData parseWithObject:JSON];
    self.sections = @[[TPListSection sectionWithTitle:nil items:self.author.contributions]];
    
    [self sendFinished];
}

-(void)setAuthor:(TPAuthorData *)author
{
    _author = author;
    
    if(author.introduction)
    {
        self.htmlString = [NSString stringWithFormat:@"<html><head></head><body><div id = \"content\" style=\"font-family:Avenir-Light; font-size:15px\">%@</div></body></html>", author.introduction];
    }
    else
    {
        self.htmlString = nil;
    }
    
}

@end
