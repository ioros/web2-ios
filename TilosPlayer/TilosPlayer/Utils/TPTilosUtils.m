//
//  TPTilosUtils.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPTilosUtils.h"

@implementation TPTilosUtils

+ (NSString *)urlForArchiveSegmentAtDate:(NSDate *)date
{
    // http://archive.tilos.hu/online/2013/12/11/tilosradio-20131211-0000.mp3
        
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger year = components.year;
    NSInteger month = components.month;
    NSInteger day = components.day;
    NSInteger hour = components.hour;
    NSInteger minutes = components.minute;
    
    NSLog(@"mintes %d", minutes);
    
    // round minutes to 0 or 30
    minutes = (NSInteger)floorf(((float)minutes / 30.0f)) * 30;
    
    NSString *url = [NSString stringWithFormat:@"http://archive.tilos.hu/online/%04d/%02d/%02d/tilosradio-%04d%02d%02d-%02d%02d.mp3", year, month, day, year, month, day, hour, minutes];
    
    return url;
}

@end
