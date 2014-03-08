//
//  TPData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPData.h"

@implementation TPData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    return nil;
}

+ (NSArray *)parseWithObjects:(NSArray *)objects
{
    NSMutableArray *datas = [NSMutableArray array];
    for(NSDictionary *object in objects)
    {
        [datas addObject:[self parseWithObject:object]];
    }
    return datas;
}


@end
