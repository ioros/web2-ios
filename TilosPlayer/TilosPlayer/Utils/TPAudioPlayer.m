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

@property (nonatomic, retain) id playerObserver;

@property (nonatomic, retain) AVPlayerItem *playerItem;
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVURLAsset *asset;
@property (nonatomic, retain) AVAudioMix *avAudioMix;
@property (nonatomic, retain) id playerStartObserver;

@property (nonatomic, retain) NSString *url;

@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL validTime;
@property (nonatomic, assign) BOOL loading;

- (void)setCurrentTime:(int)value;

@end


#pragma mark -

static int kPlayerStatusContext;
static int kPlayerItemStatusContext;
static int kPlayerItemPlaybackBufferEmptyContext;


@implementation TPAudioPlayer

SYNTHESIZE_SINGLETON_FOR_CLASS(Player, TPAudioPlayer);

- (id)init
{
    self = [super init];
    if (self) {
        _playing = NO;
        _loading = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player pause];
    self.playerItem = nil;
    self.player = nil;
	self.playerObserver = nil;
}

#pragma mark - time observers

- (void)addPlayerStartObserver
{
    __block TPAudioPlayer *weakSelf = self;
    self.playerStartObserver = [_player addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:CMTimeMake(1, 10)]]
                                                                  queue:NULL
                                                             usingBlock:^{
                                                                 [weakSelf playbackStarted];
                                                                 [weakSelf removePlayerStartObserver];
                                                             }];
}

- (void)removePlayerStartObserver
{
    [_player removeTimeObserver:_playerStartObserver];
}

- (void)addPlayerTimeObserver
{
    _validTime = YES;
    
    __block TPAudioPlayer *weakSelf = self;
    
    self.playerObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(100, 100) queue:NULL usingBlock:^(CMTime time){
        if(weakSelf.validTime)
        {
            double interval = time.value / time.timescale;
            int newTime = (int)interval;
            weakSelf.currentTime = newTime;
        }
    }];
}

- (void)removePlayerTimeObserver
{
    [_player removeTimeObserver:_playerObserver];
    self.playerObserver = nil;
    _validTime = NO;
}

#pragma mark - cue media

-(void)cueUrl:(NSString *)url
{
    [self cueUrl:url atPosition:0];
}

- (void)cueUrl:(NSString *)url atPosition:(NSUInteger)position
{
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
    
    self.currentTime = position;
	_playing = YES;
    _validTime = NO;

    self.playerItem = nil;
    self.player = nil;

    ////////////////////////////////

    self.url = url;
    self.loading = YES;
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
    [self createPlayerWithItem:item];
    
    /*
    
    self.asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:nil];
    
	NSString *tracksKey = @"tracks";
    [_asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:
     ^{
		 dispatch_async(dispatch_get_main_queue(),
						^{
							NSError *error = nil;
							AVKeyValueStatus status = [_asset statusOfValueForKey:tracksKey error:&error];
							
							if (status == AVKeyValueStatusLoaded)
							{
                                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_asset];

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
     */
}

#pragma mark -

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if(_playerItem)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];

        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:&kPlayerItemPlaybackBufferEmptyContext];
        [_playerItem removeObserver:self forKeyPath:@"status" context:&kPlayerItemStatusContext];
    }
    
    _playerItem = playerItem;
    
    if(_playerItem)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_playerItem];
        
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:&kPlayerItemPlaybackBufferEmptyContext];
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&kPlayerItemStatusContext];
    }
}

- (void)setPlayer:(AVPlayer *)player
{
    if(_player)
    {
        [self removePlayerTimeObserver];
        [self removePlayerStartObserver];
        
        [_player removeObserver:self forKeyPath:@"status" context:&kPlayerStatusContext];
        [_player pause];
    }
    
    _player = player;
    
    if(_player)
    {
        [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&kPlayerStatusContext];
        [self addPlayerStartObserver];
    }
}

- (void)createPlayerWithItem:(AVPlayerItem*)item
{
    self.playerItem = nil;
    self.player = nil;
    
    /////////////////////////
    
    self.playerItem = item;
    self.player = [AVPlayer playerWithPlayerItem:item];
}

- (void)playbackStarted
{
    self.loading = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == &kPlayerStatusContext || context == &kPlayerItemStatusContext)
    {
        AVPlayerStatus playerStatus = [self.player status];
        AVPlayerItemStatus playerItemStatus = [self.playerItem status];
        
        //NSLog(@"STATUSES: %@ %@", [self stringForPlayerStatus:playerStatus], [self stringForPlayerItemStatus:playerItemStatus]);
        
        if(playerStatus == AVPlayerStatusReadyToPlay && playerItemStatus == AVPlayerItemStatusReadyToPlay)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(_currentTime != 0)
                {
                    [_player seekToTime:CMTimeMake(_currentTime*100, 100) completionHandler:^(BOOL finished) {
                        
                        self.loading = NO;
                        if(finished)
                        {
                            [self addPlayerTimeObserver];
                        }
                    }];
                }
                else
                {
                    [self addPlayerTimeObserver];
                }
                
                _playing = YES;
                [_player play];
            });
        }
    }
    else if(context == &kPlayerItemPlaybackBufferEmptyContext)
    {
        NSLog(@"playbackbufferempty");
    }
}

- (void)setCurrentTime:(int)value
{
    _currentTime = value;
}

-(NSUInteger)currentPosition
{
	return _currentTime;
}

#pragma mark -

-(void)setVolume:(float)v atTime:(double)time
{
	if(_playerItem != nil)
	{
		NSArray *params = [[_playerItem audioMix] inputParameters];
		AVMutableAudioMixInputParameters *p = [params objectAtIndex:0];
		[p setVolume:v atTime:CMTimeMake((int)((time)*100), 100)];
	}
}

#pragma mark - playback actions

-(void)stop
{}

- (void)togglePlayPause
{
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

#pragma mark -

- (NSString *)stringForPlayerStatus:(AVPlayerStatus)status
{
    switch (status) {
        case AVPlayerStatusUnknown:
            return @"AVPlayerStatusUnknown";
            break;
        case AVPlayerStatusFailed:
            return @"AVPlayerStatusFailed";
            break;
        case AVPlayerStatusReadyToPlay:
            return @"AVPlayerStatusReadyToPlay";
            break;
    }
}
- (NSString *)stringForPlayerItemStatus:(AVPlayerItemStatus)status
{
    switch (status) {
        case AVPlayerItemStatusUnknown:
            return @"AVPlayerItemStatusUnknown";
            break;
        case AVPlayerItemStatusFailed:
            return @"AVPlayerItemStatusFailed";
            break;
        case AVPlayerItemStatusReadyToPlay:
            return @"AVPlayerItemStatusReadyToPlay";
            break;
    }
}

@end
