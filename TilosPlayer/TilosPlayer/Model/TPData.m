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
    if(objects == nil) return @[];
    
    NSMutableArray *datas = [NSMutableArray array];
    for(NSDictionary *object in objects)
    {
        id o = [self parseWithObject:object];
        if(o) [datas addObject:o];
    }
    return datas;
}


@end
