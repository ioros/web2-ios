//
//  TPPlayerManager.h
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPPlayerManager : NSObject

@property (nonatomic, retain) NSDictionary *currentEpisode;
@property (nonatomic, assign) NSTimeInterval globalTime;
@property (nonatomic, assign) BOOL playerLoading;
@property (nonatomic, assign) BOOL playing;

@property (nonatomic, retain) NSMutableDictionary *cachedDays;

+ (TPPlayerManager *)sharedManager;

- (void)playEpisode:(NSDictionary *)episode;
- (void)playEpisode:(NSDictionary *)episode atSeconds:(NSTimeInterval)seconds;

- (void)playAtTime:(NSTimeInterval)time;

- (void)togglePlay;

@end
