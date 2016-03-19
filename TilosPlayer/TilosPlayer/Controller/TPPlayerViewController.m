//
//  TPPlayerViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerViewController.h"

#import "UIImage+ImageEffects.h"
#import "TPPlayerManager.h"

#import "TPPlayButton.h"
#import "TPShowPlaybackButton.h"
#import "TPPlaybackTimeButton.h"

#import "TPPlayerTopNavigationBar.h"

#import "TPTapeSeekViewController.h"
#import "TPEpisodeTimelineViewController.h"

#import "TPEpisodeData.h"

#import "TPContinuousProgramModel.h"

#pragma mark - Private

@interface TPPlayerViewController ()

@property (nonatomic, assign) BOOL opened;

@property (nonatomic, retain) TPTapeSeekViewController *tapeSeekViewController;
@property (nonatomic, retain) TPEpisodeTimelineViewController *episodeTimelineViewController;

@property (nonatomic, retain) UIView *topBarLeftContainer;
@property (nonatomic, retain) UIView *topBarRightContainer;
@property (nonatomic, retain) TPShowPlaybackButton *playbackButton;
@property (nonatomic, retain) TPPlaybackTimeButton *playbackTimeView;

// small playback with banner
@property (nonatomic, retain) UIView *liveView;
@property (nonatomic, retain) UIButton *logoButton;
@property (nonatomic, retain) TPPlayButton *playButton;

@property (nonatomic, retain) TPPlayerTopNavigationBar *topBarButtonView;
@property (nonatomic, retain) UIButton *gotoArchiveButton;
@property (nonatomic, retain) UIButton *gotoLiveButton;
@property (nonatomic, retain) UIButton *callButton;

@end

#pragma mark -

@implementation TPPlayerViewController

#define kAnimationDuration 0.7f

static int kPlayingContext;
static int kPlayerLoadingContext;
static int kCurrentEpisodeContext;

#pragma mark -

- (void)viewDidLoad
{
    NSLog(@"TPPlayerViewController");
    [super viewDidLoad];
    
    self.opened = YES;
    
    CGRect bounds = self.view.bounds;
    CGFloat topHeight = 170;
    CGFloat middleHeight = bounds.size.height-topHeight;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    /////////////////////////////////

    UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    fadeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.fadeView = fadeView;
    [self.view addSubview:self.fadeView];
    
    
    // CONTAINERS
    
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, topHeight)];
    topView.backgroundColor = [UIColor clearColor];
    topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topView = topView;
    
    
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight, width, middleHeight)];
    middleView.backgroundColor = [UIColor clearColor];
    middleView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.middleView = middleView;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, topHeight, width, height)];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.contentMode = UIViewContentModeTop;
    backgroundView.clipsToBounds = YES;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView = backgroundView;
    
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.middleView];
    [self.view addSubview:self.topView];
    
    
    
    /// TOP STUFF
    
    
    self.tapeSeekViewController = [[TPTapeSeekViewController alloc] init];
    self.tapeSeekViewController.view.frame = CGRectMake(0, topHeight-45, width, 45);
    self.tapeSeekViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.tapeSeekViewController.view.alpha = 0.0f;
    [topView addSubview:self.tapeSeekViewController.view];
    
    [self addChildViewController:self.tapeSeekViewController];

    //
    
    UIView *liveView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight-30, width, 30)];
    liveView.backgroundColor = [UIColor clearColor];
    liveView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.liveView = liveView;
    [self.topView addSubview:self.liveView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 140, 1)];
    line.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    [self.liveView addSubview:line];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setBackgroundImage:[[UIImage imageNamed:@"RoundButton.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [b setTitle:[NSLocalizedString(@"Live", nil) uppercaseString] forState:UIControlStateNormal];
    [b.titleLabel setFont:kSubFont];
    b.frame = CGRectMake(0, 0, 40, 30);
    b.enabled = NO;
    b.center = CGPointMake(160, 15);
    [self.liveView addSubview:b];
    
    //
    
    b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setBackgroundImage:[[UIImage imageNamed:@"RounderButton.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [b setTitle:[NSLocalizedString(@"Call", nil) uppercaseString] forState:UIControlStateNormal];
    [b.titleLabel setFont:kSubSubSubFont];
    b.frame = CGRectMake(0, 0, 80, 24);
    self.callButton = b;
    [self.callButton addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];
    
    [self.gotoArchiveButton addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];

    b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setBackgroundImage:[[UIImage imageNamed:@"RounderButton.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [b setTitle:[NSLocalizedString(@"Archive", nil) uppercaseString] forState:UIControlStateNormal];
    [b.titleLabel setFont:kSubFont];
    b.frame = CGRectMake(0, 0, 80, 24);
    self.gotoArchiveButton = b;
    
    [self.gotoArchiveButton addTarget:self action:@selector(gotoArchive) forControlEvents:UIControlEventTouchUpInside];

    b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setBackgroundImage:[[UIImage imageNamed:@"RounderButton.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [b setTitle:[NSLocalizedString(@"Live", nil) uppercaseString] forState:UIControlStateNormal];
    [b.titleLabel setFont:kSubFont];
    b.frame = CGRectMake(0, 0, 80, 24);
    self.gotoLiveButton = b;

    [self.gotoLiveButton addTarget:self action:@selector(gotoLive) forControlEvents:UIControlEventTouchUpInside];
    
    //
    
    UIView *topBarLeftContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    topBarLeftContainer.backgroundColor = [UIColor clearColor];
    topBarLeftContainer.clipsToBounds = YES;
    self.topBarLeftContainer = topBarLeftContainer;
    [self.topView addSubview:self.topBarLeftContainer];

    UIView *topBarRightContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    topBarRightContainer.backgroundColor = [UIColor clearColor];
    topBarRightContainer.clipsToBounds = YES;
    self.topBarRightContainer = topBarRightContainer;
    [self.topView addSubview:self.topBarRightContainer];

    TPShowPlaybackButton *playbackButton = [[TPShowPlaybackButton alloc] initWithFrame:UIEdgeInsetsInsetRect(topBarRightContainer.bounds, UIEdgeInsetsMake(3, 0, 3, 0))];
    playbackButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.playbackButton = playbackButton;
    [playbackButton addTarget:self action:@selector(openHandler) forControlEvents:UIControlEventTouchUpInside];
    [topBarRightContainer addSubview:playbackButton];
    
    TPPlaybackTimeButton *playbackTimeView = [[TPPlaybackTimeButton alloc] initWithFrame:UIEdgeInsetsInsetRect(topBarLeftContainer.bounds, UIEdgeInsetsMake(3, 0, 3, 0))];
    playbackTimeView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [playbackTimeView addTarget:self action:@selector(openHandler) forControlEvents:UIControlEventTouchUpInside];
    self.playbackTimeView = playbackTimeView;
    [topBarLeftContainer addSubview:self.playbackTimeView];
    
    
    //
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setImage:[UIImage imageNamed:@"logoAlpha.png"] forState:UIControlStateNormal];
    logoButton.frame = CGRectMake(0, 0, 60, 60);
    logoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    logoButton.center = CGPointMake(width/2, topHeight/2);
    [logoButton addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:logoButton];
    self.logoButton = logoButton;
    
    
    TPPlayerTopNavigationBar *topBarButtonView = [[TPPlayerTopNavigationBar alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
    self.topBarButtonView = topBarButtonView;
    
    [self.topView addSubview:self.topBarButtonView];

    
    // MIDDLE STUFF /////////////////////////////////////
    
    self.episodeTimelineViewController = [[TPEpisodeTimelineViewController alloc] init];
    UIView *episodeView = self.episodeTimelineViewController.view;
    episodeView.frame = CGRectMake(0, 5, width, 220);
    episodeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.middleView addSubview:episodeView];
    
    //
    
    TPPlayButton *playButton = [[TPPlayButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    playButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    playButton.center = CGPointMake(width/2, middleHeight-40);
    
    [self.middleView addSubview:playButton];
    self.playButton = playButton;
    
    [self.playButton addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];

    //////////////////

    
    // INITIAL STATE //////////////////////////////////
    
    self.tapeSeekViewController.view.hidden = YES;
    self.liveView.hidden = YES;
    self.episodeTimelineViewController.view.hidden = YES;
    self.playButton.hidden = YES;
    
//    self.topBarButtonView.leftButton = self.gotoArchiveButton;
    self.topBarButtonView.leftButton = nil;
    self.topBarButtonView.rightButton = self.callButton;
    
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew context:&kPlayingContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playerLoading" options:NSKeyValueObservingOptionNew context:&kPlayerLoadingContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"currentEpisode" options:NSKeyValueObservingOptionNew context:&kCurrentEpisodeContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self doOpen:NO];
}

#pragma mark -

- (void)openSettings
{
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings)
    {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)call
{
    NSLog(@"Telefon hívás");
    NSString *url = @"telprompt://+3612153773";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
- (void)gotoArchive
{
}
- (void)gotoLive
{
    [[TPPlayerManager sharedManager].model jumpToDate:[NSDate date]];
//    NSIndexPath *indexLivePath = [[TPPlayerManager sharedManager].model indexPathForLiveData];
//    [[TPPlayerManager sharedManager] cueEpisode:[[TPPlayerManager sharedManager].model dataForIndexPath:indexLivePath]];
    ////
    NSLog(@"LIVE");
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == &kPlayingContext)
    {
        [self updatePlayButton];
    }
    else if(context == &kPlayerLoadingContext)
    {
        [self.playButton setLoading:[[TPPlayerManager sharedManager] playerLoading]];
    }
    else if(context == &kCurrentEpisodeContext)
    {
        [self updateByCurrentEpisode];
    }
}

#pragma mark -

- (void)updateByCurrentEpisode
{
    TPEpisodeData *currentEpisode = [[TPPlayerManager sharedManager] currentEpisode];

    if(currentEpisode)
    {
        self.playbackButton.imageURL = currentEpisode.bannerURL;
        
        TPEpisodeDataState currentState = [currentEpisode currentState];
        switch (currentState) {
            case TPEpisodeDataStatePast:
                [self setTapeVisible:_opened animated:YES];
                self.liveView.hidden = YES;
                self.topBarButtonView.leftButton = self.gotoLiveButton;
                self.topBarButtonView.rightButton = nil;
                break;
            case TPEpisodeDataStateLive:
                self.liveView.hidden = !_opened;
                [self setTapeVisible:NO animated:YES];
//                self.topBarButtonView.leftButton = self.gotoArchiveButton;
                self.topBarButtonView.leftButton = nil;
                self.topBarButtonView.rightButton = self.callButton;
                break;
            case TPEpisodeDataStateUpcoming:
                self.liveView.hidden = YES;
                [self setTapeVisible:NO animated:YES];
                self.topBarButtonView.leftButton = self.gotoLiveButton;
                self.topBarButtonView.rightButton = nil;
                break;
        }
        
        if(self.episodeTimelineViewController.view.hidden)
        {
            self.episodeTimelineViewController.view.hidden = NO;
            self.episodeTimelineViewController.view.alpha = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.episodeTimelineViewController.view.alpha = 1.0f;
            }];
        }
        
        if(self.playButton.hidden)
        {
            self.playButton.hidden = NO;
            self.playButton.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                self.playButton.alpha = 1.0f;
            }];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAmbience" object:self userInfo:nil];
    }
    
}

- (void)setTapeVisible:(BOOL)visible animated:(BOOL)animated
{
    UIView *tapeView = self.tapeSeekViewController.view;
    
    if(visible && tapeView.hidden)
    {
        tapeView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            tapeView.alpha = 1.0f;
        }];
    }
    else if(!visible && !tapeView.hidden)
    {
        [UIView animateWithDuration:0.3 animations:^{
            tapeView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            tapeView.hidden = YES;
        }];
    }
}

#pragma mark -

- (void)updatePlayButton
{
    self.playButton.playing = [[TPPlayerManager sharedManager] playing];
    self.playButton.loading = [[TPPlayerManager sharedManager] playerLoading];
    self.playbackTimeView.playing = [[TPPlayerManager sharedManager] playing];
}

#pragma mark - actions

- (IBAction)close:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)togglePlay:(id)sender
{
    if([[TPPlayerManager sharedManager] playing])
    {
        [[TPPlayerManager sharedManager] pause];
    }
    else
    {
        [[TPPlayerManager sharedManager] play];
    }
}

#pragma mark - Opening/ closing

- (void)openHandler
{
    [self doOpen:YES];
}

- (void)toggleAnimated:(BOOL)animated
{
    if(_opened) [self closeAnimated:animated];
    else [self openAnimated:animated];
}

- (void)toggle:(id)sender
{
    [self toggleAnimated:YES];
}

- (void)openAnimated:(BOOL)animated
{
    if(_opened) return;
    
    [self doOpen:animated];
}
- (void)closeAnimated:(BOOL)animated
{
    if(!_opened) return;
    
    [self doClose:animated];
}
- (void)doClose:(BOOL)animated
{
    if([_delegate respondsToSelector:@selector(playerViewControllerWillClose:)])
    {
        [_delegate performSelector:@selector(playerViewControllerWillClose:) withObject:self];
    }
    
    _opened = NO;
    
    [self updateByCurrentEpisode];

    self.topBarButtonView.hidden = YES;

    if(animated)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self layoutClosedState];
        } completion:^(BOOL finished)
        {
            if([_delegate respondsToSelector:@selector(playerViewControllerDidClose:)])
            {
                [_delegate performSelector:@selector(playerViewControllerDidClose:) withObject:self];
            }
        }];
    }
    else
    {
        [self layoutClosedState];
        
        if([_delegate respondsToSelector:@selector(playerViewControllerDidClose:)])
        {
            [_delegate performSelector:@selector(playerViewControllerDidClose:) withObject:self];
        }
    }
}
- (void)doOpen:(BOOL)animated
{
    if([_delegate respondsToSelector:@selector(playerViewControllerWillOpen:)])
    {
        [_delegate performSelector:@selector(playerViewControllerWillOpen:) withObject:self];
    }
    
    _opened = YES;

    [self updateByCurrentEpisode];
    self.topBarButtonView.hidden = NO;

    if(animated)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self layoutOpenState];
        } completion:nil];
    }
    else
    {
        [self layoutOpenState];
    }
}

#pragma mark - layout helpers

- (void)layoutOpenState
{
    CGRect b = self.view.bounds;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    CGFloat topHeight = 170;
    if(screenBounds.size.height <= 480)
    {
        topHeight = 125;
    }
    CGFloat middleHeight = b.size.height - topHeight;
    CGFloat collectionHeight = 220;
    
    self.topBarLeftContainer.frame = CGRectMake(b.size.width/2-15, topHeight/2-15-5, 30, 30);
    self.topBarRightContainer.frame = CGRectMake(b.size.width/2-15, topHeight/2-15-5, 30, 30);
    self.topView.frame = CGRectMake(0, 0, b.size.width, topHeight);
    self.middleView.frame = CGRectMake(0, topHeight, b.size.width, middleHeight);
    self.fadeView.alpha = 1.0f;
    self.logoButton.frame = CGRectMake(b.size.width/2-30, topHeight/2-30 -5, 60, 60);
    self.playButton.frame = CGRectMake(b.size.width/2-30, collectionHeight + 10 + (middleHeight-collectionHeight-10-60)/2.0f, 60, 60);
    self.backgroundView.frame = CGRectMake(0, 0, b.size.width, self.view.bounds.size.height);
    self.topBarButtonView.frame = CGRectMake(20, 68, b.size.width-40, 24);
}

- (void)layoutClosedState
{
    CGRect b = self.view.bounds;
    
    self.topView.frame = CGRectMake(0, 0, b.size.width, 64);
    self.middleView.frame = CGRectMake(0, -250, b.size.width, 260);
    self.topBarLeftContainer.frame = CGRectMake(b.size.width/2-145, 27, 145, 30);
    self.topBarRightContainer.frame = CGRectMake(b.size.width/2, 27, 145, 30);
    self.logoButton.frame = CGRectMake(b.size.width/2 - 20, 20, 40, 40);
    self.fadeView.alpha = 0.0f;
    self.backgroundView.frame = CGRectMake(0, 0, b.size.width, 64);
    self.topBarButtonView.frame = CGRectMake(20, 23, b.size.width-40, 24);
}

@end
