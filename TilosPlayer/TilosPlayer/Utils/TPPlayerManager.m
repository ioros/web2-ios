//
//  TPPlayerManager.m
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerManager.h"

#import "SynthesizeSingleton.h"
#import "TPAudioPlayer.h"
#import "TPEpisodeData.h"
#import "TPShowData.h"

@implementation TPPlayerManager

SYNTHESIZE_SINGLETON_FOR_CLASS(Manager, TPPlayerManager);


- (id)init
{
    self = [super init];
    if (self) {
        self.cachedDays = [NSMutableDictionary dictionary];
        self.playerLoading = NO;
        
        [[TPAudioPlayer sharedPlayer] addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionInitial context:nil];
        [[TPAudioPlayer sharedPlayer] addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentTime"])
    {
//        NSLog(@"time %@", change);
        NSDate *date = [self.segmentStartDate dateByAddingTimeInterval:[TPAudioPlayer sharedPlayer].currentTime];
        self.globalTime = [date timeIntervalSince1970];
    }
    else if([keyPath isEqualToString:@"loading"])
    {
        self.playerLoading = [[TPAudioPlayer sharedPlayer] loading];
    }
}

- (void)cueEpisode:(TPEpisodeData *)episode
{
    self.currentEpisode = episode;
    if(_playing)
    {
        [self playEpisode:self.currentEpisode];
    }
}

- (void)playEpisode:(TPEpisodeData *)episode
{
    [self playEpisode:episode atSeconds:0];
}
- (void)playEpisode:(TPEpisodeData *)episode atSeconds:(NSTimeInterval)seconds
{
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error]; 

    
    /// setup control center //////////////////////////////////////////
    
    
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPSkipIntervalCommand *skipBackwardIntervalCommand = [rcc skipBackwardCommand];
    [skipBackwardIntervalCommand setEnabled:YES];
    [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
    skipBackwardIntervalCommand.preferredIntervals = @[@(30)];  // Set your own interval
    
    MPSkipIntervalCommand *skipForwardIntervalCommand = [rcc skipForwardCommand];
    skipForwardIntervalCommand.preferredIntervals = @[@(30)];  // Max 99
    [skipForwardIntervalCommand setEnabled:YES];
    [skipForwardIntervalCommand addTarget:self action:@selector(skipForwardEvent:)];
    
    MPRemoteCommand *pauseCommand = [rcc pauseCommand];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTarget:self action:@selector(playOrPauseEvent:)];
    //
    MPRemoteCommand *playCommand = [rcc playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTarget:self action:@selector(playOrPauseEvent:)];
    /*
    MPFeedbackCommand *likeCommand = [rcc likeCommand];
    [likeCommand setEnabled:YES];
    [likeCommand setLocalizedTitle:@"I love it"];  // can leave this out for default
    [likeCommand addTarget:self action:@selector(likeEvent:)];
     */
    
    
    ///////////////////////////////
    
    // TODO: handle seconds
    
    NSDate *startDate = episode.plannedFrom;
    //NSDate *dayDate = [startDate dayDate];
    //NSDate *segmentDate = [startDate archiveSegmentStartDate];
    
    self.currentEpisode = episode;

    NSDate *date = [startDate dateByAddingTimeInterval:seconds];
    NSDate *segmentStartDate = [date archiveSegmentStartDate];
    
    self.segmentStartDate = segmentStartDate;
    
    NSString *url = [self urlForArchiveSegmentAtDate:date];
    
    NSTimeInterval segmentSeconds = [date timeIntervalSinceDate:segmentStartDate];
    [[TPAudioPlayer sharedPlayer] cueUrl:url atPosition:segmentSeconds];

    self.playing = YES;

    
    //////////////////////////////////////
    
    // setup controls
    NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionary];
    
    if(episode.name)
    {
        [nowPlayingInfo setObject:episode.name forKey:MPMediaItemPropertyTitle];
    }
    NSArray *nicknames = [episode.show contributorNicknames];
    if(nicknames)
    {
        [nowPlayingInfo setObject:[nicknames componentsJoinedByString:@", "] forKey:MPMediaItemPropertyArtist];
    }
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:episode.bannerURL];
    if(image)
    {
        [nowPlayingInfo setObject:[[MPMediaItemArtwork alloc] initWithImage:image] forKey:MPMediaItemPropertyArtwork];
    }
    [nowPlayingInfo setObject:[NSNumber numberWithInteger:episode.duration] forKey:MPMediaItemPropertyPlaybackDuration];

    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
}

- (void)skipBackwardEvent:(MPSkipIntervalCommandEvent *)event
{
    NSLog(@"skip backward");
}
- (void)skipForwardEvent:(MPSkipIntervalCommandEvent *)event
{
    NSLog(@"skip forward");
}
- (void)playOrPauseEvent:(id)event
{
    NSLog(@"play pause");
}
- (void)likeEvent:(id)event
{
    NSLog(@"like");
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    switch (receivedEvent.subtype)
    {
        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [self togglePlay];
            break;
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            NSLog(@"UIEventSubtypeRemoteControlBeginSeekingBackward");
            break;
        case UIEventSubtypeRemoteControlEndSeekingBackward:
            NSLog(@"UIEventSubtypeRemoteControlEndSeekingBackward");
            break;
        case UIEventSubtypeRemoteControlBeginSeekingForward:
            NSLog(@"UIEventSubtypeRemoteControlBeginSeekingForward");
            break;
        case UIEventSubtypeRemoteControlEndSeekingForward:
            NSLog(@"UIEventSubtypeRemoteControlEndSeekingForward");
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            NSLog(@"UIEventSubtypeRemoteControlNextTrack");
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            NSLog(@"UIEventSubtypeRemoteControlPreviousTrack");
            break;
        default:
            NSLog(@"Unhandled remote event");
            break;
    }
}

#pragma mark -

- (void)togglePlay
{
    if(_playing)
    {
        [self pause];
    }
    else
    {
        [self play];
    }
}

- (void)play
{
    if(_playing) return;
    
    if(self.currentEpisode)
    {
        self.playing = YES;
        [self playEpisode:self.currentEpisode];
    }
}

- (void)pause
{
    if(!_playing) return;

    self.playing = NO;
    [[TPAudioPlayer sharedPlayer] pause];
}

#pragma mark -

- (NSString *)urlForArchiveSegmentAtDate:(NSDate *)date
{
    // http://archive.tilos.hu/online/2013/12/11/tilosradio-20131211-0000.mp3
    
    NSDate *segmentStartDate = [date archiveSegmentStartDate];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:segmentStartDate];
    NSInteger year = components.year;
    NSInteger month = components.month;
    NSInteger day = components.day;
    NSInteger hour = components.hour;
    NSInteger minutes = components.minute;
    NSString *url = [NSString stringWithFormat:@"http://archive.tilos.hu/online/%04d/%02d/%02d/tilosradio-%04d%02d%02d-%02d%02d.mp3", (int)year, (int)month, (int)day, (int)year, (int)month, (int)day, (int)hour, (int)minutes];
    
    return url;
}

@end
