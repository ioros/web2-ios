//
//  TPShowData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPShowData.h"

#import "TPContributorData.h"

@implementation TPShowData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    TPShowData *data = [TPShowData new];
    data.bannerURL = [object objectForKey:@"banner"];
    
    NSString *definition = [object objectForKey:@"definition"];
    // TODO: remove this
    definition = [definition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([definition isEqualToString:@""]) definition = nil;

    data.definition = definition;
    data.alias = [object objectForKey:@"alias"];
    data.identifier = [object objectForKey:@"id"];
    data.name = [object objectForKey:@"name"];
    data.status = [object objectForKey:@"status"];
    data.type = [object objectForKey:@"type"];
    
    data.contributors = [TPContributorData parseWithObjects:[object objectForKey:@"contributors"]];
    
    return data;
}

#pragma mark -

@end
