//
//  TPContributionData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPContributionData.h"

#import "TPShowData.h"

@implementation TPContributionData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    TPContributionData *data = [TPContributionData new];
    
    id s = [object objectForKeyOrNil:@"show"];
    if([s isKindOfClass:[NSDictionary class]])
    {
        data.show = [TPShowData parseWithObject:[object objectForKeyOrNil:@"show"]];
    }
    else
    {
        data.show = nil;
    }
    
    data.nick = [object objectForKeyOrNil:@"nick"];
    
    return data;
}

@end
