//
//  TPAudioPlayer.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TPAudioPlayer : NSObject

@property (nonatomic, readonly) BOOL loading;
@property (nonatomic, readonly) int currentTime;
@property (nonatomic, readonly) NSUInteger currentPosition;

+ (TPAudioPlayer *)sharedPlayer;

-(void)cueUrl:(NSString*)url;
-(void)cueUrl:(NSString*)url atPosition:(NSUInteger)position;
-(void)play;
-(void)stop;
-(void)pause;
-(void)togglePlayPause;

@end