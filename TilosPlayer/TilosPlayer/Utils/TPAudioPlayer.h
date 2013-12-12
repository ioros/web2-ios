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
{
	AVPlayer *_player;
	BOOL _playing;
    
	AVURLAsset *_asset;
	AVAudioMix *_avAudioMix;
	
    NSString *_url;
    
    BOOL validTime;
}

+ (TPAudioPlayer *)sharedPlayer;

-(void)cueUrl:(NSString*)url;
-(void)cueUrl:(NSString*)url atPosition:(NSUInteger)position;
-(void)play;
-(void)stop;
-(void)pause;
-(void)togglePlayPause;
-(NSUInteger)currentPosition;

@property (nonatomic, retain) id playerObserver;
@property (nonatomic, retain) AVPlayerItem *playerItem;

@property (nonatomic, readonly) int currentTime;

@end