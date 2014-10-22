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
    if(object == nil) return nil;
    
    TPShowData *data = [TPShowData new];
    data.bannerURL = [object objectForKeyOrNil:@"banner"];
    
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
    
    return data;
}

#pragma mark -

@end
