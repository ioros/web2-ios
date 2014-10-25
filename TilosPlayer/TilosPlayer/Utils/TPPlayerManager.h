//
//  TPPlayerManager.h
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "TPContinuousProgramModel.h"

@class TPEpisodeData;

@interface TPPlayerManager : NSObject <TPContinuousProgramModelDelegate, AVAudioSessionDelegate>

@property (nonatomic, retain) TPContinuousProgramModel *model;

@property (nonatomic, retain) TPEpisodeData *currentEpisode;
@property (nonatomic, retain) NSDate *segmentStartDate;

@property (nonatomic, assign) NSTimeInterval globalTime;
@property (nonatomic, assign) BOOL playerLoading;
@property (nonatomic, assign) BOOL playing;

+ (TPPlayerManager *)sharedManager;

- (void)cueEpisode:(TPEpisodeData *)episode;
- (void)playEpisode:(TPEpisodeData *)episode;
- (void)playEpisode:(TPEpisodeData *)episode atSeconds:(NSTimeInterval)seconds;
- (void)pause;
- (void)play;

- (void)togglePlay;

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;

@end
