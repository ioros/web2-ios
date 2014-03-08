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
    data.show = [TPShowData parseWithObject:[object objectForKey:@"show"]];
    data.nick = [object objectForKey:@"nick"];
    
    return data;
}

@end
