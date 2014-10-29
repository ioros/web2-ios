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

#import "TPTapeSeekViewController.h"


@interface TPPlayerViewController ()

@property (nonatomic, assign) BOOL opened;

@property (nonatomic, retain) TPTapeSeekViewController *tapeSeekViewController;

@property (nonatomic, retain) UIView *topBarLeftContainer;
@property (nonatomic, retain) UIView *topBarRightContainer;
@property (nonatomic, retain) TPShowPlaybackButton *playbackButton;
@property (nonatomic, retain) TPPlaybackTimeButton *playbackTimeView;

// small playback with banner
@property (nonatomic, retain) UIButton *liveButton;
@property (nonatomic, retain) UIButton *logoButton;
@property (nonatomic, retain) TPPlayButton *playButton;

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, assign) TPScrollState collectionState;
@property (nonatomic, assign) NSInteger collectionDragStartIndex;

@property (nonatomic, retain) TPContinuousProgramModel *model;

@end

#pragma mark -

@implementation TPPlayerViewController

#define kAnimationDuration 0.7f

static int kPlayingContext;
static int kPlayerLoadingContext;
static int kCurrentEpisodeContext;

#pragma mark -

- (void)loadView
{
    self.opened = YES;
    
    self.collectionState = TPScrollStateNormal;
    
    /////////////////////////////////

    CGRect frame = CGRectMake(0, 0, 320, 480);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.clipsToBounds = YES;
    v.backgroundColor = [UIColor clearColor];
    self.view = v;

    /////////////////////////////
    
    UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 320, 340)];
    fadeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.fadeView = fadeView;
    [self.view addSubview:self.fadeView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 170)];
    topView.backgroundColor = [UIColor clearColor];
    topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topView = topView;
    
    
    self.tapeSeekViewController = [[TPTapeSeekViewController alloc] init];
    self.tapeSeekViewController.view.frame = CGRectMake(0, 120, 320, 45);
    self.tapeSeekViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [topView addSubview:self.tapeSeekViewController.view];
    
    [self addChildViewController:self.tapeSeekViewController];
    
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setBackgroundImage:[[UIImage imageNamed:@"RoundButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [b setTitle:[NSLocalizedString(@"Live", nil) uppercaseString] forState:UIControlStateNormal];
    [b.titleLabel setFont:kSubFont];
    b.frame = CGRectMake(0, 0, 40, 20);
    b.center = CGPointMake(160, 145);
    [topView addSubview:b];
    self.liveButton = b;
    
    ///////////////////
    
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
    self.playbackTimeView = playbackTimeView;
    [topBarLeftContainer addSubview:self.playbackTimeView];

    
    //////////////////


    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 170, 320, 230)];
    middleView.backgroundColor = [UIColor clearColor];
    middleView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.middleView = middleView;

    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 170, 320, 230)];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.contentMode = UIViewContentModeTop;
    backgroundView.clipsToBounds = YES;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.backgroundView = backgroundView;

    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.middleView];
    [self.view addSubview:self.topView];
    
    ///////////////////////////
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 15, 320, 220) collectionViewLayout:[[TPTapeCollectionLayout alloc] initWithItemSize:CGSizeMake(320, 220)]];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.collectionView registerClass:[TPEpisodeCollectionCell class] forCellWithReuseIdentifier:@"EpisodeCollectionCell"];
    [self.middleView addSubview:self.collectionView];
    
    ////////////////
    
    TPPlayButton *playButton = [[TPPlayButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    playButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    playButton.center = CGPointMake(160, 400);
    
    [self.view addSubview:playButton];
    self.playButton = playButton;
    
    [self.playButton addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];

    /////////////
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setImage:[UIImage imageNamed:@"logoAlpha.png"] forState:UIControlStateNormal];
    logoButton.frame = CGRectMake(0, 0, 60, 60);
    logoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    logoButton.center = CGPointMake(160, 100);
    [logoButton addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoButton];
    self.logoButton = logoButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tapeSeekViewController.view.hidden = YES;
    self.liveButton.hidden = YES;
    self.collectionView.hidden = YES;
    self.playButton.hidden = YES;
    
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&kPlayingContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playerLoading" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&kPlayerLoadingContext];
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
        TPEpisodeData *currentEpisode = [[TPPlayerManager sharedManager] currentEpisode];
        
        self.playbackButton.imageURL = currentEpisode.bannerURL;
        
        TPEpisodeDataState currentState = [currentEpisode currentState];
        switch (currentState) {
            case TPEpisodeDataStatePast:
                self.tapeSeekViewController.view.hidden = NO;
                self.liveButton.hidden = YES;
                break;
            case TPEpisodeDataStateLive:
                self.liveButton.hidden = NO;
                self.tapeSeekViewController.view.hidden = YES;
                break;
            case TPEpisodeDataStateUpcoming:
                self.liveButton.hidden = YES;
                self.tapeSeekViewController.view.hidden = YES;
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
        
        [self setCollectionDragStartIndex:[[self.model indexPathForData:currentEpisode] row]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAmbience" object:self userInfo:nil];
    }
}

- (void)updatePlayButton
{
    self.playButton.playing = [[TPPlayerManager sharedManager] playing];
    self.playButton.loading = [[TPPlayerManager sharedManager] playerLoading];
    self.playbackTimeView.playing = [[TPPlayerManager sharedManager] playing];
}

#pragma mark -

- (void)modelDidFinish:(NSNotification*)notification
{
    [self.collectionView reloadData];
    
    TPEpisodeData *episode = [[TPPlayerManager sharedManager] currentEpisode];
    if(episode)
    {
        NSIndexPath *indexPath = [self.model indexPathForData:episode];
        if(indexPath)
        {
            [self scrollToIndexInCollectionView:indexPath.row animated:NO];
        }
    }
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

#pragma mark -

- (void)openHandler
{
    [self doOpen:YES];
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
    
    CGRect topTargetRect = CGRectMake(0, 0, 320, 64);
    CGRect middleTargetRect = CGRectMake(0, -250, 320, 260);
    CGFloat fadeTargetAlpha = 0.0f;
    CGRect logoButtonTargetRect = CGRectMake(140, 20, 40, 40);
    CGRect playButtonTargetRect = CGRectMake(140, 20, 40, 40);
    CGRect backgroundTargetRect = CGRectMake(0, 0, 320, 64);
    CGRect topBarLeftContainerTargetRect = CGRectMake(160-145, 27, 145, 30);
    CGRect topBarRightContainerTargetRect = CGRectMake(160, 27, 145, 30);
    
    _opened = NO;

    self.tapeSeekViewController.view.hidden = YES;

    if(animated)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.topBarLeftContainer.frame = topBarLeftContainerTargetRect;
                             self.topBarRightContainer.frame = topBarRightContainerTargetRect;
                             self.topView.frame = topTargetRect;
                             self.middleView.frame = middleTargetRect;
                             self.fadeView.alpha = fadeTargetAlpha;
                             self.logoButton.frame = logoButtonTargetRect;
                             self.playButton.frame = playButtonTargetRect;
                             self.backgroundView.frame = backgroundTargetRect;
        } completion:^(BOOL finished) {
            if([_delegate respondsToSelector:@selector(playerViewControllerDidClose:)])
            {
                [_delegate performSelector:@selector(playerViewControllerDidClose:) withObject:self];
            }
        }];
    }
    else
    {
        self.topBarLeftContainer.frame = topBarLeftContainerTargetRect;
        self.topBarRightContainer.frame = topBarRightContainerTargetRect;
        self.topView.frame = topTargetRect;
        self.middleView.frame = middleTargetRect;
        self.fadeView.alpha = fadeTargetAlpha;
        self.logoButton.frame = logoButtonTargetRect;
        self.playButton.frame = playButtonTargetRect;
        self.backgroundView.frame = backgroundTargetRect;
        
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
    
    CGRect topTargetRect = CGRectMake(0, 0, 320, 170);
    CGRect middleTargetRect = CGRectMake(0, 170, 320, self.view.bounds.size.height - 170);
    CGFloat fadeTargetAlpha = 1.0f;
    CGRect logoButtonTargetRect = CGRectMake(130, 50, 60, 60);
    CGRect playButtonTargetRect = CGRectMake(130, 430, 60, 60);
    CGRect backgroundTargetRect = CGRectMake(0, 0, 320, self.view.bounds.size.height);
    CGRect topBarLeftContainerTargetRect = CGRectMake(160-15, 65, 30, 30);
    CGRect topBarRightContainerTargetRect = CGRectMake(160-15, 65, 30, 30);

    _opened = YES;
    
    TPEpisodeDataState state = [[[TPPlayerManager sharedManager] currentEpisode] currentState];
    self.tapeSeekViewController.view.hidden = (state == TPEpisodeDataStatePast);

    if(animated)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.topBarLeftContainer.frame = topBarLeftContainerTargetRect;
                             self.topBarRightContainer.frame = topBarRightContainerTargetRect;
                             self.topView.frame = topTargetRect;
                             self.middleView.frame = middleTargetRect;
                             self.fadeView.alpha = fadeTargetAlpha;
                             self.logoButton.frame = logoButtonTargetRect;
                             self.playButton.frame = playButtonTargetRect;
                             self.backgroundView.frame = backgroundTargetRect;

        } completion:nil];
    }
    else
    {
        self.topBarLeftContainer.frame = topBarLeftContainerTargetRect;
        self.topBarRightContainer.frame = topBarRightContainerTargetRect;
        self.topView.frame = topTargetRect;
        self.middleView.frame = middleTargetRect;
        self.fadeView.alpha = fadeTargetAlpha;
        self.logoButton.frame = logoButtonTargetRect;
        self.playButton.frame = playButtonTargetRect;
        self.backgroundView.frame = backgroundTargetRect;
    }

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
