//
//  TPPlayerViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerViewController.h"

#import "TPListModel.h"
#import "TPEpisodeListModel.h"
#import "TPEpisodeCollectionCell.h"
#import "TPTapeCollectionCell.h"
#import "TPTapeCollectionLayout.h"
#import "UIImage+ImageEffects.h"

#import "TPAudioPlayer.h"


@interface TPPlayerViewController ()

@property (nonatomic, assign) BOOL opened;

@end

#pragma mark -

@implementation TPPlayerViewController

#define kAnimationDuration 0.7f

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
    backgroundView.backgroundColor = [UIColor whiteColor];
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
    
    [self.playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self doOpen:NO];
    
    if(self.model == nil)
    {
        self.model = [[TPEpisodeListModel alloc] initWithParameters:[NSDate date]];
        self.model.delegate = self;
    }
    
    if(self.model)
    {
        [self.model loadForced:NO];
    }
}

#pragma mark -

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [self.collectionView reloadData];
    [self.tapeCollectionView reloadData];
}

#pragma mark -

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

- (IBAction)play:(id)sender
{
}

- (void)closeAnimated:(BOOL)animated
{
    if(!_opened) return;
    
    [self doClose:animated];
}
- (void)doClose:(BOOL)animated
{
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
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.tapeCollectionView == scrollView)
    {
        [self finishTapeScrolling];
    }
}

- (void)finishTapeScrolling
{
    CGPoint offset = self.tapeCollectionView.contentOffset;
    CGFloat horizontalOffset = offset.x ;//+ self.tapeCollectionView.bounds.size.width / 2;
    
//    NSLog(@"finish tape scrolling %f %d %f", horizontalOffset, partIndex, partOffset);

    CGFloat minuteOffset = horizontalOffset / 30.0f;

    // get a date trimmed to current half an hour
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
    components.minute = (NSInteger)floorf(((float)[components minute] / 30.0f)) * 30;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    // go back a week
    date = [date dateByAddingTimeInterval:-24 * 60 * 60 * 7];
    
    // add the offset to it
    date = [date dateByAddingTimeInterval:minuteOffset * 60];
    
    NSString *url = [TPTilosUtils urlForArchiveSegmentAtDate:date];

    NSInteger partIndex = (NSInteger)floorf((minuteOffset / 30.0f));
    NSInteger secondOffset = (minuteOffset - 30 * partIndex) * 60;
    
    [[TPAudioPlayer sharedPlayer] cueUrl:url atPosition:secondOffset];
    [[TPAudioPlayer sharedPlayer] play];
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
        return [self.model numberOfRowsInSection:section];
    }
    else
    {
        return 100;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionView)
    {
        static NSString *cellIdentifier = @"EpisodeCollectionCell";
        TPEpisodeCollectionCell *cell = (TPEpisodeCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        cell.data = [self.model dataForIndexPath:indexPath];
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
