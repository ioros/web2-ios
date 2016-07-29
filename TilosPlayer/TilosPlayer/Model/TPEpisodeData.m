//
//  TPEpisodeData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPEpisodeData.h"

#import "TPShowData.h"
#import "TPTextData.h"
#import "TPContributorData.h"

@implementation TPEpisodeData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    TPEpisodeData *data = [TPEpisodeData new];
    data.plannedFrom = [NSDate dateWithTimeIntervalSince1970:[[object objectForKey:@"plannedFrom"] longLongValue]/1000];
    data.plannedTo = [NSDate dateWithTimeIntervalSince1970:[[object objectForKey:@"plannedTo"] longLongValue]/1000];
    data.show = [TPShowData parseWithObject:[object objectForKey:@"show"]];
    data.leiras = [TPTextData parseWithObject:[object objectForKey:@"text"]];
    data.m3uURL = [object objectForKey:@"m3uUrl"];
    data.URL = [object objectForKey:@"url"];
    return data;
}

#pragma mark -

- (NSArray *)contributorNicknames
{
    NSArray *contributors = self.show.contributors;
    NSMutableArray *nicks = [NSMutableArray array];
//    for(TPContributorData *contributor in contributors) [nicks addObject:contributor.nick];
    for(TPContributorData *contributor in contributors) [nicks addObject:contributor.alias];
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
- (NSString *)type
{
    if ([self.show.type isEqual:@"SPEECH"]) {
        return NSLocalizedString(@"Talk", nil);
    }
    if ([self.show.type isEqual:@"MUSIC"]) {
        return NSLocalizedString(@"Music", nil);
    }
    return @"";
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

- (NSString *)title
{
    return self.leiras.title;
}

- (BOOL)isEqual:(id)other
{
    if([other isKindOfClass:[TPEpisodeData class]])
    {
        return [self.plannedFrom isEqual:[(TPEpisodeData *)other plannedFrom]];
    }
    return NO;
}

- (TPEpisodeDataState)currentState
{
    NSDate *now = [NSDate date];
    BOOL isPast = now.timeIntervalSince1970 > self.plannedTo.timeIntervalSince1970;
    if(isPast) return TPEpisodeDataStatePast;
    
    BOOL isUpcoming = now.timeIntervalSince1970 < self.plannedFrom.timeIntervalSince1970;
    if(isUpcoming) return TPEpisodeDataStateUpcoming;
    
    return TPEpisodeDataStateLive;
}

- (NSUInteger)duration
{
    return (NSUInteger)[self.plannedTo timeIntervalSinceDate:self.plannedFrom];
}


#pragma mark -

- (NSString *)description
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy.MM.dd. HH:mm:ss";
    
    return [NSString stringWithFormat:@"%@ %@ %@ %@", [super description], self.name, [formatter stringFromDate:self.plannedFrom], [formatter stringFromDate:self.plannedTo]];
}



@end
