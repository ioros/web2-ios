//
//  TPAudioPlayer.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAudioPlayer.h"

#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

#import "SynthesizeSingleton.h"

@interface TPAudioPlayer ()

- (void)setCurrentTime:(int)value;
- (void)addTimeObserver;

- (void)createPlayerWithItem:(AVPlayerItem*)item;
- (void)destroyPlayer;

@end

@implementation TPAudioPlayer

SYNTHESIZE_SINGLETON_FOR_CLASS(Player, TPAudioPlayer);

@synthesize playerItem;
@synthesize playerObserver;

@synthesize currentTime = _currentTime;


- (id)init
{
    self = [super init];
    if (self) {
        _playing = NO;
    }
    return self;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.playerItem = nil;
    
    [_asset release]; _asset = nil;
    [_player pause];
    [_player release]; _player = nil;
	self.playerObserver = nil;
    [super dealloc];
}


-(void)cueUrl:(NSString *)url
{
    [self cueUrl:url atPosition:0];
}

- (void)addTimeObserver
{
    validTime = YES;
    self.playerObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(100, 100) queue:NULL usingBlock:^(CMTime time){
        if(validTime)
        {
            double interval = time.value / time.timescale;
            int newTime = (int)interval;
            self.currentTime = newTime;
        }
    }];
}

- (void)removeTimeObserver
{
    [_player removeTimeObserver:playerObserver];
    self.playerObserver = nil;
    validTime = NO;
}

- (void)cueUrl:(NSString *)url atPosition:(NSUInteger)position
{
	NSLog(@"========cuemedia at %d, url %@", position, url);

    /*
    if([url isEqualToString:_url])
    {
        [self removeTimeObserver];
		[_player seekToTime:CMTimeMake(position * 100, 100) completionHandler:^(BOOL finished) {
            if(finished)
            {
                [self addTimeObserver];
            }
        }];
        return;
    }*/
    
    [_url release];
    _url = [url retain];
    
    self.currentTime = position;
	_playing = YES;
    validTime = NO;
    
	
    [_asset release]; _asset = nil;
	_asset = [[AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:nil] retain];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.playerItem = nil;
    
    [self removeTimeObserver];
    [self destroyPlayer];
    
	NSString *tracksKey = @"tracks";
    [_asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:
     ^{
		 dispatch_async(dispatch_get_main_queue(),
						^{
							NSError *error = nil;
							AVKeyValueStatus status = [_asset statusOfValueForKey:tracksKey error:&error];
							
							if (status == AVKeyValueStatusLoaded)
							{
								self.playerItem = [AVPlayerItem playerItemWithAsset:_asset];
                                //								[playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
								[[NSNotificationCenter defaultCenter] addObserver:self
																		 selector:@selector(playerItemDidReachEnd:)
																			 name:AVPlayerItemDidPlayToEndTimeNotification
																		   object:playerItem];
                                
                                //								AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
                                //								AVMutableAudioMixInputParameters *params = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:[[asset tracks] objectAtIndex:0]];
                                //								[params setVolume:0.0 atTime:CMTimeMake((int)((0)*100), 100)];
                                //								[params setVolume:1.0 atTime:CMTimeMake((int)((3)*100), 100)];
								
								//NSNumber *number = [mediaItem valueForProperty: MPMediaItemPropertyPlaybackDuration];
								//NSUInteger duration = floor(number.floatValue);
                                //								NSUInteger duration = [media duration];
								
								//[params setVolume:1.0 atTime:CMTimeMake((int)((duration-5)*100), 100)];
								//[params setVolume:0.0 atTime:CMTimeMake((int)((duration)*100), 100)];
								//[audioMix setInputParameters:[NSArray arrayWithObject:params]];
								//[playerItem setAudioMix:audioMix];
								
                                [self createPlayerWithItem:playerItem];
							}
							else {
								// You should deal with the error appropriately.
								NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
							}
						});
     }];
	
	//_playing = NO;
}

- (void)destroyPlayer
{
    [_player removeObserver:self forKeyPath:@"status"];
    [_player pause];
	[_player release]; _player = nil;
}

- (void)createPlayerWithItem:(AVPlayerItem*)item
{
    _player = [[AVPlayer playerWithPlayerItem:playerItem] retain];
    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionInitial context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"status"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if(_currentTime != 0)
            {
                [_player seekToTime:CMTimeMake(_currentTime*100, 100) completionHandler:^(BOOL finished) {
                    if(finished)
                    {
                        [self addTimeObserver];
                    }
                }];
            }
            else
            {
                [self addTimeObserver];
            }
            
            _playing = YES;
            [_player play];
            
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
}

- (void)setCurrentTime:(int)value
{
    _currentTime = value;
}

-(void)stop
{}

-(NSUInteger)currentPosition
{
	return _currentTime;
}

-(void)setVolume:(float)v atTime:(double)time
{
	if(playerItem != nil)
	{
		NSArray *params = [[playerItem audioMix] inputParameters];
		AVMutableAudioMixInputParameters *p = [params objectAtIndex:0];
		[p setVolume:v atTime:CMTimeMake((int)((time)*100), 100)];
	}
}

- (void)togglePlayPause
{
    NSLog(@"toggle %@", _player);
    if(!_playing)
    {
        [_player play];
        _playing = YES;
    }
    else
    {
        _playing = NO;
        [_player pause];
    }
}

-(void)play
{
    if(!_playing)
    {
        [_player play];
        _playing = YES;
    }
}

-(void)pause
{
    if(_playing)
    {
        _playing = NO;
        [_player pause];
    }
}

-(BOOL)playing
{
	return _playing;
}

#pragma mark -

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ended" object:self userInfo:nil];
}


#pragma mark - remote events

- (void)remoteControlReceivedWithEvent:(UIEvent*)event
{
    NSLog(@"remote event %@", event);
    if(event.type != UIEventTypeRemoteControl) return;
    
    switch (event.subtype)
    {
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [self togglePlayPause];
            break;
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            NSLog(@"UIEventSubtypeRemoteControlBeginSeekingBackward");
            break;
        case UIEventSubtypeRemoteControlBeginSeekingForward:
            NSLog(@"UIEventSubtypeRemoteControlBeginSeekingForward");
            break;
        case UIEventSubtypeRemoteControlEndSeekingBackward:
            NSLog(@"UIEventSubtypeRemoteControlEndSeekingBackward");
            break;
        case UIEventSubtypeRemoteControlEndSeekingForward:
            NSLog(@"UIEventSubtypeRemoteControlEndSeekingForward");
            break;
        case UIEventSubtypeRemoteControlStop:
            NSLog(@"stop");
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            NSLog(@"next");
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            NSLog(@"prev");
            break;
        default:
            break;
    }
}

@end
