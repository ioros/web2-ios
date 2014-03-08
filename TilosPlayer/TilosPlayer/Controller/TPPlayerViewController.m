//
//  TPPlayerViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerViewController.h"

#import "TPListModel.h"
#import "TPEpisodeCollectionCell.h"
#import "TPTapeCollectionCell.h"
#import "TPTapeCollectionLayout.h"
#import "UIImage+ImageEffects.h"
#import "TPPlayerManager.h"

#import "TPContinuousProgramModel.h"

@interface TPPlayerViewController ()

@property (nonatomic, assign) BOOL opened;
@property (nonatomic, assign) NSTimeInterval startTime;

@end

#pragma mark -

@implementation TPPlayerViewController

#define kAnimationDuration 0.7f
#define kTapeArchiveSectionCount 5000

static int kGlobalTimeContext;
static int kPlayingContext;

- (void)loadView
{
    self.opened = YES;
    
    CGRect frame = CGRectMake(0, 0, 320, 480);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.clipsToBounds = YES;
    v.backgroundColor = [UIColor clearColor];
    self.view = v;
    
    UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 320, 340)];
    fadeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.fadeView = fadeView;
    [self.view addSubview:self.fadeView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 170)];
    topView.backgroundColor = [UIColor clearColor];
    topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topView = topView;
    

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
    self.tapeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.tapeCollectionView registerClass:[TPTapeCollectionCell class] forCellWithReuseIdentifier:@"TapeCollectionCell"];
    [self.topView addSubview:self.tapeCollectionView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedDot.png"]];
    imageView.center = CGPointMake(160, 125 + 22);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.topView addSubview:imageView];
    
    
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
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 60, 60);
    button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    button.center = CGPointMake(160, 400);
    
    [self.view addSubview:button];
    self.playButton = button;
    
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"globalTime" options:NSKeyValueObservingOptionNew context:&kGlobalTimeContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"playing" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&kPlayingContext];
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
    
    if(self.model)
    {
        [self.model jumpToDate:[NSDate date]];
    }
    
    // TODO: handle this thing properly
    
    // setup the starttime, we cheat for now and place the startTime to 10 days in the past
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    NSDate *pastDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    pastDate = [pastDate dateByAddingTimeInterval:-10 * 24 * 60 * 60];
    self.startTime = [pastDate timeIntervalSince1970];
    
    // seek to something reasonable
    [self.tapeCollectionView setContentOffset:CGPointMake(kTapeArchiveSectionCount / 2 * 150.0f, 0)];
    NSLog(@"initial tape offset %f", self.tapeCollectionView.contentOffset.x);
    
    // initialize ambience
    [self updateAmbience];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == &kGlobalTimeContext)
    {
        NSTimeInterval globalTime = [TPPlayerManager sharedManager].globalTime;
        NSTimeInterval timeDiff = globalTime - self.startTime;
        float timeDiffMinutes = timeDiff / 60.0f;
        CGFloat offset = timeDiffMinutes * 30.0f;
        
        [self.tapeCollectionView setContentOffset:CGPointMake(offset, 0)];
//        NSLog(@"offset %f %f %f", offset, globalTime, self.startTime);
    }
    else if(context == &kPlayingContext)
    {
        [self updatePlayButton];
    }
}

- (void)updatePlayButton
{
    BOOL playing = [[TPPlayerManager sharedManager] playing];
    if(playing)
    {
        [self.playButton setImage:[UIImage imageNamed:@"PauseButton.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
    }
}

- (void)updateAmbience
{
    NSArray *visibleCells = self.collectionView.visibleCells;
    if(visibleCells.count == 0) return;
    
    TPEpisodeCollectionCell *cell = [visibleCells objectAtIndex:0];
    if(cell.imageView.image)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAmbience" object:self userInfo:@{@"image":cell.imageView.image}];
    }
}

#pragma mark -

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [self.collectionView reloadData];
    [self.tapeCollectionView reloadData];
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
    [[TPPlayerManager sharedManager] togglePlay];
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
- (void)openAnimated:(BOOL)animated
{
    if(_opened) return;
    
    [self doOpen:animated];
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
        
//        [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
 //       } completion:nil];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.tapeCollectionView == scrollView)
    {
        if(!decelerate) [self finishTapeScrolling];
    }
    else if(self.collectionView == scrollView)
    {
        if(!decelerate) [self finishCollectionScrolling];
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
    NSArray *visibleCells = self.collectionView.visibleCells;
    if(visibleCells.count == 0) return;

    TPEpisodeCollectionCell *cell = [visibleCells objectAtIndex:0];

    //NSDictionary *episode = [self.model dataForIndexPath:[self.collectionView indexPathForCell:cell]];
    
    //[[TPPlayerManager sharedManager] cueEpisode:episode];
    
    [self updateAmbience];
}

- (void)finishTapeScrolling
{
    CGPoint offset = self.tapeCollectionView.contentOffset;

    // TODO: adjust to the center coordinate
    CGFloat horizontalOffset = offset.x;
    
    NSTimeInterval time = self.startTime + (horizontalOffset / 30.0f) * 60.0f;

//    [[TPPlayerManager sharedManager] playAtTime:time];
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if(collectionView == self.collectionView)
    {
        return 0;
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
        return 0;
    }
    else
    {
        return kTapeArchiveSectionCount;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionView)
    {
        static NSString *cellIdentifier = @"EpisodeCollectionCell";
        TPEpisodeCollectionCell *cell = (TPEpisodeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
//        cell.data = [self.model dataForIndexPath:indexPath];
        return cell;
    }
    else
    {
        static NSString *tapeCellIdentifier = @"TapeCollectionCell";
        TPTapeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:tapeCellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

@end
