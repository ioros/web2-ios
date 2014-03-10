//
//  TPEpisodeData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPEpisodeData.h"

#import "TPShowData.h"
#import "TPContributorData.h"

@implementation TPEpisodeData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    TPEpisodeData *data = [TPEpisodeData new];
    data.plannedFrom = [NSDate dateWithTimeIntervalSince1970:[[object objectForKey:@"plannedFrom"] integerValue]];
    data.plannedTo = [NSDate dateWithTimeIntervalSince1970:[[object objectForKey:@"plannedTo"] integerValue]];
    data.show = [TPShowData parseWithObject:[object objectForKey:@"show"]];
    data.m3uURL = [object objectForKey:@"m3uUrl"];
    data.URL = [object objectForKey:@"url"];
    
    return data;
}

#pragma mark -

- (NSArray *)contributorNicknames
{
    NSArray *contributors = self.show.contributors;
    NSMutableArray *nicks = [NSMutableArray array];
    for(TPContributorData *contributor in contributors) [nicks addObject:contributor.nick];
    return nicks;
}

- (NSInteger)startSeconds
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.plannedFrom];
    return (components.hour * 60 * 60 + components.minute * 60 + components.second);
}

- (NSInteger)episodeNumberOfParts
{
    NSDate *startDate = self.plannedFrom;
    NSDate *endDate = self.plannedTo;
    
    NSTimeInterval diff = [endDate timeIntervalSinceDate:startDate];
    return diff / (30 * 60 * 60);
}

- (NSString *)name
{
    return self.show.name;
}
- (NSString *)bannerURL
{
    return self.show.bannerURL;
}
- (NSString *)definition
{
    return self.show.definition;
}

- (NSDate *)dayDate
{
    return [self.plannedFrom dayDate];
}

- (BOOL)isRunningEpisode
{
    NSDate *now = [NSDate date];
    return (now.timeIntervalSince1970 >= self.plannedFrom.timeIntervalSince1970 && now.timeIntervalSince1970 < self.plannedTo.timeIntervalSince1970);
}


#pragma mark -

- (NSString *)description
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy.MM.dd. HH:mm:ss";
    
    return [NSString stringWithFormat:@"%@ %@ %@ %@", [super description], self.name, [formatter stringFromDate:self.plannedFrom], [formatter stringFromDate:self.plannedTo]];
}



@end
