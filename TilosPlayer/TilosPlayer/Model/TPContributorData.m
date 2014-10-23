//
//  TPContributorData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPContributorData.h"

#import "TPAuthorData.h"

@implementation TPContributorData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    TPContributorData *data = [TPContributorData new];
    data.author = [TPAuthorData parseWithObject:[object objectForKeyOrNil:@"author"]];
    
    // TODO: remove this if server is fixed
    NSString *nick = [object objectForKeyOrNil:@"nick"];
    nick = [nick stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    data.nick = nick;
    
    return data;
}

@end
