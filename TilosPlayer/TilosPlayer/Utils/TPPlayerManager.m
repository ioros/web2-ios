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
#import "Reachability.h"

@interface TPPlayerManager()

@property (nonatomic, retain) TPEpisodeData *jumpToEpisode;

@end

#pragma mark -

@implementation TPPlayerManager

SYNTHESIZE_SINGLETON_FOR_CLASS(Manager, TPPlayerManager);


- (id)init
{
    self = [super init];
    if (self)
    {
        self.model = [TPContinuousProgramModel new];
        self.model.delegate = self;
        
        self.playerLoading = NO;
        
        [[TPAudioPlayer sharedPlayer] addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionInitial context:nil];
        [[TPAudioPlayer sharedPlayer] addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.model jumpToDate:[NSDate date]];
    }
    return self;
}

#pragma mark -

- (void)continuousProgramModelDidFinish:(TPContinuousProgramModel *)continuousProgramModel
{
    if(self.jumpToEpisode)
    {
        NSIndexPath *indexPath = [self.model indexPathForData:self.jumpToEpisode];
        if(indexPath)
        {
            [self playEpisode:[self.model dataForIndexPath:indexPath]];
        }
        self.jumpToEpisode = nil;
    }
    else
    {
        // select the live episode
        NSIndexPath *indexPath = [self.model indexPathForLiveData];
        if(indexPath)
        {
            [self cueEpisode:[self.model dataForIndexPath:indexPath]];
        }
    }
}
- (void)continuousProgramModel:(TPContinuousProgramModel *)continuousProgramModel didInsertDataAtIndexPaths:(NSArray *)indexPaths atEnd:(BOOL)atEnd
{
    
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentTime"])
    {
        NSTimeInterval playerTime = [TPAudioPlayer sharedPlayer].currentTime;
        //NSLog(@"PLAYER TIME %f", playerTime);
        NSDate *date = [self.segmentStartDate dateByAddingTimeInterval:playerTime];
        
        self.globalTime = [date timeIntervalSince1970];
    }
    else if([keyPath isEqualToString:@"loading"])
    {
        self.playerLoading = [[TPAudioPlayer sharedPlayer] loading];
    }
}

- (void)cueEpisode:(TPEpisodeData *)episode
{
    _globalTime = episode.plannedFrom.timeIntervalSince1970;
    
    if(![self.currentEpisode isEqual:episode])
    {
        self.currentEpisode = episode;
        if(_playing)
        {
            [self playEpisode:self.currentEpisode];
        }
    }
    else
    {
        if(_playing)
        {
            NSTimeInterval offset = self.currentEpisode.plannedFrom.timeIntervalSince1970 - _globalTime;
            [self playEpisode:self.currentEpisode atSeconds:offset];
        }
    }
    
}

- (void)playEpisode:(TPEpisodeData *)episode
{
    [self playEpisode:episode atSeconds:0];
}
- (void)playEpisode:(TPEpisodeData *)episode atSeconds:(NSTimeInterval)seconds
{
    NSIndexPath *indexPath = [self.model indexPathForData:episode];
    if(indexPath == nil)
    {
        self.jumpToEpisode = episode;
        self.currentEpisode = nil;
        // wait for loading
        [self.model jumpToDate:episode.plannedFrom];
        return;
    }
    else
    {
        // nothing?
    }
    
    ///////////////////////////////
    
    // TODO: handle seconds
    
    NSDate *startDate = episode.plannedFrom;
    //NSDate *dayDate = [startDate dayDate];
    //NSDate *segmentDate = [startDate archiveSegmentStartDate];

    _globalTime = episode.plannedFrom.timeIntervalSince1970 + seconds;
    
    // prevent duplicated setting
    if(_currentEpisode != episode)
        self.currentEpisode = episode;

    NSDate *date = [startDate dateByAddingTimeInterval:seconds];
    NSDate *segmentStartDate = [date archiveSegmentStartDate];
    
    self.segmentStartDate = segmentStartDate;
    NSDate *now = [NSDate date];
    NSString *url;
    if ([episode.plannedTo timeIntervalSinceDate:now] > 0) {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status == NotReachable)
        {
            url = @"";
        }
        else if (status == ReachableViaWiFi)
        {
            url = @"http://tilos.hu/api/v1/m3u/lastweek?stream=/tilos";
        }
        else if (status == ReachableViaWWAN) 
        {
            url = @"http://tilos.hu/api/v1/m3u/lastweek?stream=/tilos_128.mp3";
        }
        
    } else {
        url = [self urlForArchiveSegmentAtDate:date];
    }
    NSLog(@"%@",url);
    self.playing = YES;
    
    
    //////////////////
    
    
    NSError *sessionError = nil;
//    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    
    NSTimeInterval segmentSeconds = [date timeIntervalSinceDate:segmentStartDate];
    [[TPAudioPlayer sharedPlayer] cueUrl:url atPosition:segmentSeconds];
    
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
        
        NSTimeInterval offset = _globalTime - self.currentEpisode.plannedFrom.timeIntervalSince1970;
        offset = MAX(0, offset);
        [self playEpisode:self.currentEpisode atSeconds:offset];
    }
}

- (void)pause
{
    if(!_playing) return;

    self.playerLoading = NO;
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
