//
//  NSDictionary+TPModelAdditions.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "NSDictionary+TPModelAdditions.h"

#import <CoreText/CoreText.h>

@implementation NSDictionary (TPModelAdditions)

- (NSArray *)episodeContributorNicknames
{
    NSArray *contributors = [[self objectForKey:@"show"] objectForKey:@"contributors"];
    NSMutableArray *nicks = [NSMutableArray array];
    for(NSDictionary *contributor in contributors) [nicks addObject:[contributor objectForKey:@"nick"]];
    return nicks;
}

- (NSAttributedString *)episodeStartTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self objectForKey:@"plannedFrom"] integerValue]];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSString *timeLabel = [NSString stringWithFormat:@"%d%02d", components.hour, components.minute];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:timeLabel];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0,timeLabel.length-2)];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(timeLabel.length-2,2)];
    [string addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(timeLabel.length-2,2)];
    return string;
}

- (NSInteger)episodeNumberOfParts
{
    NSDate *startDate = [self episodePlannedFromDate];
    NSDate *endDate = [self episodePlannedToDate];
    
    NSTimeInterval diff = [endDate timeIntervalSinceDate:startDate];
    return diff / (30 * 60 * 60);
}

- (NSString *)episodeName
{
    return [[self objectForKey:@"show"] showName];
}
- (NSURL *)episodeBannerUrl
{
    return [[self objectForKey:@"show"] showBannerUrl];
}
- (NSString *)episodeDefinition
{
    return [[self objectForKey:@"show"] showDefinition];
}

- (NSDate *)episodePlannedFromDate
{
    NSTimeInterval interval = [[self objectForKey:@"plannedFrom"] integerValue];
    return [NSDate dateWithTimeIntervalSince1970:interval];
}
- (NSDate *)episodePlannedToDate
{
    NSTimeInterval interval = [[self objectForKey:@"plannedTo"] integerValue];
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (NSString *)showDefinition
{
    NSString *definition = [self objectForKeyOrNil:@"definition"];
    
    // TODO: remove this
    definition = [definition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([definition isEqualToString:@""]) definition = nil;
    return definition;
}

- (NSString *)showName
{
    return [self objectForKeyOrNil:@"name"];
}

- (NSURL *)showBannerUrl
{
    return [NSURL URLWithString:[self objectForKeyOrNil:@"banner"]];
}


@end
