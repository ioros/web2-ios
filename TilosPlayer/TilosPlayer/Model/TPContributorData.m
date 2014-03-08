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
    data.author = [TPAuthorData parseWithObject:[object objectForKey:@"author"]];
    data.nick = [object objectForKey:@"nick"];
    
    return data;
}

@end
