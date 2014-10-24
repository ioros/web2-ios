//
//  TPPlayerViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerViewController.h"

#import "TPListModel.h"
#import "TPContinuousProgramModel.h"

#import "TPEpisodeCollectionCell.h"
#import "TPTapeCollectionCell.h"
#import "TPTapeCollectionLiveCell.h"

#import "TPTapeCollectionLayout.h"
#import "UIImage+ImageEffects.h"
#import "TPPlayerManager.h"

#import "TPEpisodeData.h"
#import "TPPlayButton.h"
#import "TPShowPlaybackButton.h"


typedef enum {
    TPScrollStateNormal,
    TPScrollStateDragging,
    TPScrollStateAnimating,
} TPScrollState;

@interface TPPlayerViewController ()

@property (nonatomic, assign) BOOL opened;

// small playback with banner
@property (nonatomic, retain) TPShowPlaybackButton *playbackButton;
@property (nonatomic, retain) UIButton *logoButton;
@property (nonatomic, retain) TPPlayButton *playButton;

@property (nonatomic, retain) UIView *redDotView;
@property (nonatomic, assign) BOOL redDotVisible;

@property (nonatomic, retain) UICollectionView *tapeCollectionView;
@property (nonatomic, assign) CGFloat tapeScrollAdjustment;
@property (nonatomic, assign) NSTimeInterval tapeStartTime;
@property (nonatomic, assign) NSInteger tapeCollectionRowCount;
@property (nonatomic, assign) TPScrollState tapeCollectionState;

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, assign) TPScrollState collectionState;
@property (nonatomic, assign) NSInteger collectionDragStartIndex;

@property (nonatomic, retain) TPEpisodeData *currentEpisode;

// we jump here after the load has been completed
@property (nonatomic, retain) NSDate *jumpDate;

@end

#pragma mark -

@implementation TPPlayerViewController

#define kAnimationDuration 0.7f

static int kGlobalTimeContext;
static int kPlayingContext;
static int kPlayerLoadingContext;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        self.jumpDate = [NSDate new];
    }
    return self;
}

- (void)loadView
{
    self.opened = YES;
    self.tapeScrollAdjustment = 160.0f;
    
    self.collectionState = TPScrollStateNormal;
    self.tapeCollectionState = TPScrollStateNormal;
    
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
    
    /*
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setBackgroundImage:[[UIImage imageNamed:@"RoundButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [b setTitle:[NSLocalizedString(@"Live", nil) uppercaseString] forState:UIControlStateNormal];
    b.frame = CGRectMake(10, 28, 100, 26);
    [b.titleLabel setFont:kDescFont];
    [topView addSubview:b];
     */
    
    TPShowPlaybackButton *playbackButton = [[TPShowPlaybackButton alloc] initWithFrame:CGRectMake(200, 30, 100, 24)];
    [topView addSubview:playbackButton];
    self.playbackButton = playbackButton;
    [playbackButton addTarget:self action:@selector(openHandler) forControlEvents:UIControlEventTouchUpInside];
    [playbackButton.button addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];



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
    
    TPTapeCollectionLayout *collectionViewLayout = [[TPTapeCollectionLayout alloc] initWithItemSize:CGSizeMake(150, 20)];
    self.tapeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 125, 320, 44) collectionViewLayout:collectionViewLayout];
    self.tapeCollectionView.backgroundColor = [UIColor clearColor];
    self.tapeCollectionView.delegate = self;
    self.tapeCollectionView.showsHorizontalScrollIndicator = NO;
    self.tapeCollectionView.dataSource = self;
    self.tapeCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 85);
    self.tapeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.tapeCollectionView registerClass:[TPTapeCollectionCell class] forCellWithReuseIdentifier:@"TapeCollectionCell"];
    [self.tapeCollectionView registerClass:[TPTapeCollectionLiveCell class] forCellWithReuseIdentifier:@"TapeCollectionLiveCell"];
    [self.topView addSubview:self.tapeCollectionView];
    
    
    //////////// red dot
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedDot.png"]];
    imageView.center = CGPointMake(160, 125 + 22);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.topView addSubview:imageView];
    self.redDotView = imageView;

    // init red dot
    self.redDotView.alpha = 0.0f;
    self.redDotVisible = NO;
    
    
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
    
    UIButton *button = nil;

    /////////////////////
    
    TPPlayButton *playButton = [[TPPlayButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    playButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    playButton.center = CGPointMake(160, 400);
    
    [self.view addSubview:playButton];
    self.playButton = playButton;
    
    [self.playButton addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];

    /////////////
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"logoAlpha.png"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 60, 60);
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    button.center = CGPointMake(160, 100);
    [button addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];
    self.logoButton = button;
    
    
    ///////// setup initial value
    NSDate *now = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:now];
    NSDate *pastDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    pastDate = [pastDate dateByAddingTimeInterval: -4 * 3600 * 24];
    self.tapeStartTime = [pastDate timeIntervalSince1970];
    
    NSTimeInterval difference = [now timeIntervalSinceDate:pastDate];
    self.tapeCollectionRowCount = floorf( difference / (5 * 60) );
    
    [self.tapeCollectionView reloadData];
    [self.tapeCollectionView setContentOffset:CGPointMake(self.tapeCollectionRowCount * 150.0f, 0)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"globalTime" options:NSKeyValueObservingOptionNew context:&kGlobalTimeContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&kPlayingContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playerLoading" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&kPlayerLoadingContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // initialize the layout
    [self doOpen:NO];
    
    if(self.model == nil)
    {
        self.model = [[TPContinuousProgramModel alloc] init];
        self.model.delegate = self;
    }
    
    
    [self jumpToDate:[NSDate date]];
    
    // initialize ambience
    [self updateAmbience];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == &kGlobalTimeContext)
    {
        if(self.tapeCollectionState == TPScrollStateNormal)
        {
            NSTimeInterval globalTime = [TPPlayerManager sharedManager].globalTime;
            NSTimeInterval timeDiff = globalTime - self.tapeStartTime;
            float timeDiffMinutes = timeDiff / 60.0f;
            CGFloat offset = timeDiffMinutes * 30.0f;

            //NSLog(@"UPDATING BY PLAYER POSITION %f %f", timeDiff, globalTime);

            [self.tapeCollectionView setContentOffset:CGPointMake(offset - _tapeScrollAdjustment, 0)];
        }
//        NSLog(@"offset %f %f %f", offset, globalTime, self.startTime);
    }
    else if(context == &kPlayingContext)
    {
        [self updatePlayButton];
    }
    else if(context == &kPlayerLoadingContext)
    {
        [self.playButton setLoading:[[TPPlayerManager sharedManager] playerLoading]];
    }
}

- (void)updatePlayButton
{
    self.playButton.playing = [[TPPlayerManager sharedManager] playing];
    self.playButton.loading = [[TPPlayerManager sharedManager] playerLoading];
    
    self.playbackButton.playing = [[TPPlayerManager sharedManager] playing];
}

- (void)updateAmbience
{
    NSInteger index = roundf(self.collectionView.contentOffset.x / 320.0f);

    TPEpisodeCollectionCell *cell = (TPEpisodeCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if(cell.imageView.image)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAmbience" object:self userInfo:@{@"image":cell.imageView.image}];
    }
}

#pragma mark -

- (void)continuousProgramModelDidFinish:(TPContinuousProgramModel *)continuousProgramModel
{
    [self.collectionView reloadData];
    [self.tapeCollectionView reloadData];
    
    [self checkLoadMore];
    
    if(self.jumpDate)
    {
        NSIndexPath *indexPath = [self.model indexPathForDate:self.jumpDate];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.jumpDate = nil;
        
        self.currentEpisode = [self.model dataForIndexPath:indexPath];
    }
}
- (void)continuousProgramModel:(TPContinuousProgramModel *)continuousProgramModel didInsertDataAtIndexPaths:(NSArray *)indexPaths atEnd:(BOOL)atEnd
{
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

#pragma mark -

- (void)checkLoadMore
{
    if([self.model numberOfSections] == 0 || [self.model numberOfItemsInSection:0] == 0) return;
    
    CGFloat offsetX = self.collectionView.contentOffset.x;
    CGFloat collectionWidth = self.collectionView.bounds.size.width;
    CGFloat contentWidth = [self.model numberOfItemsInSection:0] * collectionWidth;
    
    if(contentWidth == 0) return;

    CGFloat threshold = 300.0f;
    if(offsetX < threshold)
    {
        [self.model loadHead];
    }
    if(offsetX > (contentWidth - threshold - collectionWidth))
    {
        [self.model loadTail];
    }
}

- (void)updateRedDot
{
    CGFloat offsetX = self.tapeCollectionView.contentOffset.x;
    CGFloat contentWidth = self.tapeCollectionRowCount * 150;
    
    CGFloat diff = contentWidth - offsetX;
    BOOL shouldRedDotBeVisible = diff > 310;
    
    if(shouldRedDotBeVisible != self.redDotVisible)
    {
        self.redDotVisible = shouldRedDotBeVisible;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.redDotView.alpha = shouldRedDotBeVisible ? 1.0f : 0.0f;
        }];
    }
}

#pragma mark -

- (void)jumpToDate:(NSDate *)date
{
    self.currentEpisode = nil;
    self.jumpDate = date;
    [self.model jumpToDate:date];
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
        if(self.currentEpisode)
        {
            [[TPPlayerManager sharedManager] playEpisode:self.currentEpisode];
        }
    }
}

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

    _opened = NO;

    self.tapeCollectionView.hidden = YES;
    self.playbackButton.hidden = NO;

    if(animated)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
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

    _opened = YES;
    
    self.tapeCollectionView.hidden = NO;
    self.playbackButton.hidden = YES;


    if(animated)
    {
        [UIView animateWithDuration:kAnimationDuration delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
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
    return (NSInteger)floorf(self.collectionView.contentOffset.x / 320);
}

- (void)scrollToIndexInCollectionView:(NSInteger)index animated:(BOOL)animated
{
    [self.collectionView setContentOffset:CGPointMake(index * 320, 0) animated:animated];
}


#pragma mark -

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(scrollView == self.tapeCollectionView)
    {
        self.tapeCollectionState = TPScrollStateNormal;
    }
    else if(scrollView == self.collectionView)
    {
        self.collectionState = TPScrollStateNormal;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == self.tapeCollectionView)
    {
        self.tapeCollectionState = TPScrollStateDragging;
    }
    else if(scrollView == self.collectionView)
    {
        NSInteger index = roundf(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
        self.collectionDragStartIndex = index;
        self.collectionState = TPScrollStateDragging;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.tapeCollectionView)
    {
        [self updateRedDot];
    }
    else if(scrollView == self.collectionView)
    {
        // check the model loading
        [self checkLoadMore];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.tapeCollectionView == scrollView)
    {
        if(decelerate)
        {
            self.tapeCollectionState = TPScrollStateAnimating;
        }
        else
        {
            [self finishTapeScrolling];
        }
    }
    else if(self.collectionView == scrollView)
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
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.tapeCollectionView == scrollView)
    {
        [self finishTapeScrolling];
    }
    else if(self.collectionView == scrollView)
    {
        [self finishCollectionScrolling];
    }
}

- (void)finishCollectionScrolling
{
    self.collectionState = TPScrollStateNormal;
    
    NSInteger index = roundf(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
    if(index < 0 || index >= [self.model numberOfItemsInSection:0]) return;
    if(index == _collectionDragStartIndex) return;
    
    TPEpisodeData *episode = [self.model dataForRow:index section:0];
    self.currentEpisode = episode;
    
    
    self.playbackButton.imageURL = self.currentEpisode.bannerURL;

    if([episode isRunningEpisode])
    {
        CGFloat offsetX = (self.tapeCollectionRowCount-1) * 150.0f;
        offsetX -= 160 - 75;

        self.tapeCollectionState = TPScrollStateAnimating;
        [self.tapeCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    else
    {
        NSDate *plannedFrom = episode.plannedFrom;
        NSTimeInterval difference = plannedFrom.timeIntervalSince1970 - self.tapeStartTime;
        
        CGFloat offsetX = difference / (5 * 60) * 150.0f;
        
        self.tapeCollectionState = TPScrollStateAnimating;
        [self.tapeCollectionView setContentOffset:CGPointMake(offsetX - _tapeScrollAdjustment, 0) animated:YES];
    }
    
    [[TPPlayerManager sharedManager] cueEpisode:episode];
    
    [self updateAmbience];
}

- (void)finishTapeScrolling
{
    self.tapeCollectionState = TPScrollStateNormal;
    
    CGFloat offsetX = self.tapeCollectionView.contentOffset.x + _tapeScrollAdjustment;

    NSTimeInterval time = self.tapeStartTime + (offsetX / 30.0f) * 60.0f;
    
    if(time < self.currentEpisode.plannedFrom.timeIntervalSince1970 || time >= self.currentEpisode.plannedTo.timeIntervalSince1970)
    {
        NSIndexPath *indexPath = [self.model indexPathForDate:[NSDate dateWithTimeIntervalSince1970:time]];
        self.currentEpisode = [self.model dataForIndexPath:indexPath];
    }

    NSTimeInterval seconds = time - self.currentEpisode.plannedFrom.timeIntervalSince1970;
    [[TPPlayerManager sharedManager] playEpisode:self.currentEpisode atSeconds:seconds];
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if(collectionView == self.collectionView)
    {
        return [self.model numberOfSections];
    }
    else
    {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == self.collectionView)
    {
        return [self.model numberOfItemsInSection:section];
    }
    else
    {
        return self.tapeCollectionRowCount;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionView)
    {
        static NSString *cellIdentifier = @"EpisodeCollectionCell";
        TPEpisodeCollectionCell *cell = (TPEpisodeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        cell.episode = (TPEpisodeData *)[self.model dataForIndexPath:indexPath];
        return cell;
    }
    else
    {
        //NSDate *date = [NSDate new];
        //NSTimeInterval timeDifference = date.timeIntervalSince1970 - self.tapeStartTime;
        
        BOOL isEnd = (indexPath.row == self.tapeCollectionRowCount-1);
        if(!isEnd)
        {
            TPTapeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TapeCollectionCell" forIndexPath:indexPath];
            return cell;
        }
        else
        {
            TPTapeCollectionLiveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TapeCollectionLiveCell" forIndexPath:indexPath];
            return cell;
        }
    }
}

@end
