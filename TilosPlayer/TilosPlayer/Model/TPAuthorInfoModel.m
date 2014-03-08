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
    
    self.contributions = self.author.contributions;
    
    [self sendFinished];
}

-(AwailableInfoType)awailableInfo{
    
    //NSLog(@"%@", [self.author objectForKey:@"introduction"]);
    NSString *introductionString = self.author.introduction;
    
    if (self.contributions.count > 0 && introductionString.length>0) {
        return kContributionsAndIntroduction;
    }
    else if (self.contributions.count > 0 && !(introductionString.length>0)){
        return kContributionsOnly;
    }
    else if (self.contributions.count == 0 && introductionString.length>0){
        return kIntroductionOnly;
    }
    else return kNoInfoAwailable;
}

-(void)setAuthor:(TPAuthorData *)author
{
    _author = author;
    
    self.htmlString = [NSString stringWithFormat:@"<html><head></head><body><div id = \"content\" style=\"font-family:Avenir-Light; font-size:15px\">%@</div></body></html>", author.introduction];
}

@end
