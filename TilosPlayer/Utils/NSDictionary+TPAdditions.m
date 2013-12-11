//
//  NSDictionary+TPAdditions.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "NSDictionary+TPAdditions.h"

@implementation NSDictionary (TPAdditions)

- (id)objectForKeyOrNil:(id)aKey
{
    id object = [self objectForKey:aKey];
    if([object isKindOfClass:[NSNull class]]) object = nil;
    return object;
}

@end
