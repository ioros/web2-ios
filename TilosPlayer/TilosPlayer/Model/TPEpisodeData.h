//
//  TPEpisodeData.h
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPData.h"

typedef enum {
    TPEpisodeDataStatePast,
    TPEpisodeDataStateLive,
    TPEpisodeDataStateUpcoming
} TPEpisodeDataState;

@class TPShowData;

@interface TPEpisodeData : TPData;

@property (nonatomic, retain) NSDate *plannedFrom;
@property (nonatomic, retain) NSDate *plannedTo;
@property (nonatomic, retain) TPShowData *show;
@property (nonatomic, retain) NSString *m3uURL;
@property (nonatomic, retain) NSString *URL;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *bannerURL;
@property (nonatomic, readonly) NSString *definition;
@property (nonatomic, readonly) NSArray *contributorNicknames;
@property (nonatomic, readonly) NSInteger startSeconds;

@property (nonatomic, readonly) NSDate *dayDate;

@property (nonatomic, readonly) NSUInteger duration;

@property (nonatomic, readonly) TPEpisodeDataState currentState;

@end
