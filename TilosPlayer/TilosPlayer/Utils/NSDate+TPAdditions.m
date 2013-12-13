//
//  NSDate+TPAdditions.m
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "NSDate+TPAdditions.h"

@implementation NSDate (TPAdditions)

- (NSString *)dayName
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat =@"EEEE";
    NSString *dayName = [formatter stringFromDate:self];
    return dayName;
}

@end
