//
//  TPPlayerViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerViewController.h"

#import "TPContinuousProgramModel.h"
#import "TPEpisodeData.h"

#import "UIImage+ImageEffects.h"
#import "TPPlayerManager.h"

#import "TPPlayButton.h"
#import "TPShowPlaybackButton.h"
#import "TPPlaybackTimeButton.h"

#import "TPCollectionView.h"
#import "TPEpisodeCollectionCell.h"
#import "TPTapeCollectionLayout.h"

#import "TPPlayerTopNavigationBar.h"

#import "TPTapeSeekViewController.h"



#pragma mark - Private

@interface TPPlayerViewController ()

@property (nonatomic, assign) BOOL opened;

@property (nonatomic, retain) TPTapeSeekViewController *tapeSeekViewController;

@property (nonatomic, retain) UIView *topBarLeftContainer;
@property (nonatomic, retain) UIView *topBarRightContainer;
@property (nonatomic, retain) TPShowPlaybackButton *playbackButton;
@property (nonatomic, retain) TPPlaybackTimeButton *playbackTimeView;

// small playback with banner
@property (nonatomic, retain) UIView *liveView;
@property (nonatomic, retain) UIButton *logoButton;
@property (nonatomic, retain) TPPlayButton *playButton;

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, assign) TPScrollState collectionState;
@property (nonatomic, assign) NSInteger collectionDragStartIndex;

@property (nonatomic, retain) TPContinuousProgramModel *model;

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
    [super viewDidLoad];
    
    self.opened = YES;
    self.collectionState = TPScrollStateNormal;
    
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
    [b.titleLabel setFont:kSubFont];
    b.frame = CGRectMake(0, 0, 80, 24);
    self.callButton = b;
    
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
    
    //[self.topView addSubview:self.topBarButtonView];

    
    // MIDDLE STUFF /////////////////////////////////////
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, 320, 220) collectionViewLayout:[[TPTapeCollectionLayout alloc] initWithItemSize:CGSizeMake(320, 220)]];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.collectionView registerClass:[TPEpisodeCollectionCell class] forCellWithReuseIdentifier:@"EpisodeCollectionCell"];
    [self.middleView addSubview:self.collectionView];
    
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
    self.collectionView.hidden = YES;
    self.playButton.hidden = YES;
    
    self.topBarButtonView.leftButton = self.gotoArchiveButton;
    self.topBarButtonView.rightButton = self.callButton;
    
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew context:&kPlayingContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playerLoading" options:NSKeyValueObservingOptionNew context:&kPlayerLoadingContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"currentEpisode" options:NSKeyValueObservingOptionNew context:&kCurrentEpisodeContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.model == nil)
    {
        self.model = [[TPPlayerManager sharedManager] model];
        [self.collectionView reloadData];
    }
    
    // initialize the layout
    [self doOpen:NO];
}

#pragma mark -

- (void)setModel:(TPContinuousProgramModel *)model
{
    if(_model)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TPContinuousProgramModelDidFinishNotification object:_model];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TPContinuousProgramModelDidInsertDataNotification object:_model];
    }
    
    _model = model;
    
    if(_model)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelDidFinish:) name:TPContinuousProgramModelDidFinishNotification object:_model];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelDidInsertData:) name:TPContinuousProgramModelDidInsertDataNotification object:_model];
    }
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
    NSString *url = @"tel:+3612153773";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
- (void)gotoArchive
{
}
- (void)gotoLive
{
    NSIndexPath *indexPath = [self.model indexPathForLiveData];
    [[TPPlayerManager sharedManager] cueEpisode:[self.model dataForIndexPath:indexPath]];
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

- (void)updateByCurrentEpisode
{
    TPEpisodeData *currentEpisode = [[TPPlayerManager sharedManager] currentEpisode];
    
    self.playbackButton.imageURL = currentEpisode.bannerURL;
    
    TPEpisodeDataState currentState = [currentEpisode currentState];
    switch (currentState) {
        case TPEpisodeDataStatePast:
            self.tapeSeekViewController.view.hidden = !_opened;
            self.liveView.hidden = YES;
            self.topBarButtonView.leftButton = nil;
            self.topBarButtonView.rightButton = self.gotoLiveButton;
            break;
        case TPEpisodeDataStateLive:
            self.liveView.hidden = !_opened;
            self.tapeSeekViewController.view.hidden = YES;
            self.topBarButtonView.leftButton = self.gotoArchiveButton;
            self.topBarButtonView.rightButton = self.callButton;
            break;
        case TPEpisodeDataStateUpcoming:
            self.liveView.hidden = YES;
            self.tapeSeekViewController.view.hidden = YES;
            self.topBarButtonView.leftButton = self.gotoLiveButton;
            self.topBarButtonView.rightButton = nil;
            break;
    }
    
    if(self.collectionView.hidden)
    {
        self.collectionView.hidden = NO;
        self.collectionView.alpha = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.collectionView.alpha = 1.0f;
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
    
    [self updateCollectionView:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAmbience" object:self userInfo:nil];
}

#pragma mark -

- (void)updatePlayButton
{
    self.playButton.playing = [[TPPlayerManager sharedManager] playing];
    self.playButton.loading = [[TPPlayerManager sharedManager] playerLoading];
    self.playbackTimeView.playing = [[TPPlayerManager sharedManager] playing];
}

- (void)updateCollectionView:(BOOL)animated
{
    TPEpisodeData *episode = [[TPPlayerManager sharedManager] currentEpisode];
    if(episode)
    {
        NSIndexPath *indexPath = [self.model indexPathForData:episode];
        if(indexPath)
        {
            [self scrollToIndexInCollectionView:indexPath.row animated:NO];
        }
        
        if(self.collectionView.alpha < 1.0f)
        {
            if(animated)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.collectionView.alpha = 1.0f;
                }];
            }
            else
            {
                self.collectionView.alpha = 1.0f;
            }
        }
        if(self.tapeSeekViewController.view.alpha < 1.0f)
        {
            if(animated)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.tapeSeekViewController.view.alpha = 1.0f;
                }];
            }
            else
            {
                self.tapeSeekViewController.view.alpha = 1.0f;
            }
        }
    }
    else
    {
        self.collectionView.alpha = 0.0;
        self.tapeSeekViewController.view.alpha = 0.0f;
    }
}

#pragma mark -

- (void)modelDidFinish:(NSNotification*)notification
{
    [self.collectionView reloadData];
    [self updateCollectionView:YES];
    
}
- (void)modelDidInsertData:(NSNotification *)notification
{
    NSArray *indexPaths = [notification.userInfo objectForKey:@"indexPaths"];
    BOOL atEnd = [[notification.userInfo objectForKey:@"atEnd"] boolValue];
    
    CGFloat offsetX = self.collectionView.contentOffset.x;
    
    [UIView setAnimationsEnabled:NO];
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
    [UIView setAnimationsEnabled:YES];
    
    if(!atEnd)
    {
        CGFloat diff = atEnd ? 0 : indexPaths.count * self.collectionView.bounds.size.width;
        self.collectionView.contentOffset = CGPointMake(offsetX + diff, 0);
    }
}

#pragma mark - actions

- (IBAction)close:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)prev:(id)sender
{
    NSInteger selectedIndex = [self selectedIndexInCollectionView];
    if(selectedIndex > 0)
    {
        [self scrollToIndexInCollectionView:selectedIndex-1 animated:YES];
    }
}

- (IBAction)next:(id)sender
{
    NSInteger selectedIndex = [self selectedIndexInCollectionView];
    if(selectedIndex >= 0)
    {
        [self scrollToIndexInCollectionView:selectedIndex+1 animated:YES];
    }
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

- (void)layoutOpenState
{
    CGRect b = self.view.bounds;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    CGFloat topHeight = 170;
    if(screenBounds.size.height <= 480)
    {
        topHeight = 135;
    }
    CGFloat middleHeight = b.size.height - topHeight;
    CGFloat collectionHeight = 220;
    
    self.topBarLeftContainer.frame = CGRectMake(b.size.width/2-15, topHeight/2-15-5, 30, 30);
    self.topBarRightContainer.frame = CGRectMake(b.size.width/2-15, topHeight/2-15-5, 30, 30);
    self.topView.frame = CGRectMake(0, 0, b.size.width, topHeight);
    self.middleView.frame = CGRectMake(0, topHeight, b.size.width, middleHeight);
    self.fadeView.alpha = 1.0f;
    self.logoButton.frame = CGRectMake(b.size.width/2-30, topHeight/2-30 -5, 60, 60);
    self.playButton.frame = CGRectMake(b.size.width/2-30, collectionHeight + (middleHeight-collectionHeight-60)/2.0f, 60, 60);
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

#pragma mark - helpers

- (NSInteger)selectedIndexInCollectionView
{
    return (NSInteger)floorf(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
}

- (void)scrollToIndexInCollectionView:(NSInteger)index animated:(BOOL)animated
{
    [self.collectionView setContentOffset:CGPointMake(index * 320, 0) animated:animated];
}

#pragma mark -

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.collectionState = TPScrollStateNormal;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSInteger index = [self selectedIndexInCollectionView];
    self.collectionDragStartIndex = index;
    self.collectionState = TPScrollStateDragging;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(decelerate)
    {
        self.collectionState = TPScrollStateAnimating;
    }
    else
    {
        [self finishCollectionScrolling];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self finishCollectionScrolling];
}

- (void)finishCollectionScrolling
{
    self.collectionState = TPScrollStateNormal;
    
    NSInteger index = [self selectedIndexInCollectionView];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    if(index < 0 || index >= count) return;
    if(index == _collectionDragStartIndex) return;
    
    [[TPPlayerManager sharedManager] cueEpisode:[self.model dataForIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]];

    if(index < 3)
    {
        [self.model loadHead];
    }
    if(index > count-3)
    {
        [self.model loadTail];
    }
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.model numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.model numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EpisodeCollectionCell";
    TPEpisodeCollectionCell *cell = (TPEpisodeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.episode = (TPEpisodeData *)[self.model dataForIndexPath:indexPath];
    return cell;
}

@end
