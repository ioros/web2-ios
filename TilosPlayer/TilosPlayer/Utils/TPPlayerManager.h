//
//  TPPlayerManager.h
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MediaPlayer/MediaPlayer.h>

@class TPEpisodeData;

@interface TPPlayerManager : NSObject

@property (nonatomic, retain) TPEpisodeData *currentEpisode;
@property (nonatomic, retain) NSDate *segmentStartDate;

@property (nonatomic, assign) NSTimeInterval globalTime;
@property (nonatomic, assign) BOOL playerLoading;
@property (nonatomic, assign) BOOL playing;

@property (nonatomic, retain) NSMutableDictionary *cachedDays;

+ (TPPlayerManager *)sharedManager;

- (void)cueEpisode:(TPEpisodeData *)episode;
- (void)playEpisode:(TPEpisodeData *)episode;
- (void)playEpisode:(TPEpisodeData *)episode atSeconds:(NSTimeInterval)seconds;
- (void)pause;
- (void)play;

- (void)togglePlay;

- (void)setup;

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;

@end
