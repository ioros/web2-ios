//
//  TPShowData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPShowData.h"

#import "TPContributorData.h"
#import "TPEpisodeData.h"

@implementation TPShowData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    if(object == nil) return nil;
    
    TPShowData *data = [TPShowData new];
    data.bannerURL = [object objectForKeyOrNil:@"banner"];
    
    // TODO: remove this when server is fixed
    if(data.bannerURL == nil || [data.bannerURL isEqualToString:@"http://tilos.hu/upload/"])
    {
        data.bannerURL = nil;
    }
    
    NSString *definition = [object objectForKeyOrNil:@"definition"];
    // TODO: remove this
    definition = [definition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([definition isEqualToString:@""]) definition = nil;

    data.definition = definition;
    data.alias = [object objectForKeyOrNil:@"alias"];
    data.identifier = [object objectForKeyOrNil:@"id"];
    data.name = [object objectForKeyOrNil:@"name"];
    data.status = [object objectForKeyOrNil:@"status"];
    data.type = [object objectForKeyOrNil:@"type"];
    data.infoHTML = [object objectForKey:@"description"];

    data.contributors = [TPContributorData parseWithObjects:[object objectForKeyOrNil:@"contributors"]];
    data.episodes = [TPEpisodeData parseWithObjects:[object objectForKeyOrNil:@"episodes"]];
    
    return data;
}

#pragma mark -

- (NSArray *)contributorNicknames
{
    NSMutableArray *nicknames = [NSMutableArray array];
    for(TPContributorData *contributor in self.contributors)
    {
        if(contributor.nick) [nicknames addObject:contributor.nick];
    }
    NSLog(@"nicknames: %@",[nicknames componentsJoinedByString:@", "]);
    return nicknames;
}

@end
