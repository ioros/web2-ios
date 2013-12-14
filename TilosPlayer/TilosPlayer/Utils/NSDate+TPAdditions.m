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

- (NSDate *)archiveSegmentStartDate
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self];
    // round minutes to 0 or 30
    components.minute = (NSInteger)floorf(((float)components.minute / 30.0f)) * 30;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)dayDate
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}


@end
