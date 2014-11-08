//
//  TPTapeSeekViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPTapeSeekViewController.h"

#import "TPTapeCollectionCell.h"
#import "TPTapeCollectionLayout.h"
#import "TPCollectionView.h"
#import "TPEpisodeData.h"

#import "TPPlayerManager.h"

static int kGlobalTimeContext;
static int kCurrentEpisodeContext;

@interface TPTapeSeekViewController ()

@property (nonatomic, retain) UICollectionView *tapeCollectionView;
@property (nonatomic, assign) TPScrollState tapeCollectionState;

@property (nonatomic, assign) CGFloat tapeScrollAdjustment;
@property (nonatomic, assign) NSTimeInterval tapeStartTime;

@property (nonatomic, assign) NSInteger tapeCollectionRowCount;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;

@property (nonatomic, retain) UIView *redDotView;

@end

#define kTapeCellTime 300 // 5 minutes
#define kTapeCellWidth 150.0f
#define kTapePaddingCount 35 // how many cells to generate before and after

@implementation TPTapeSeekViewController

- (void)loadView
{
    self.startTime = NSIntegerMax;
    self.endTime = NSIntegerMin;
    self.tapeCollectionRowCount = 0;
    
    self.tapeScrollAdjustment = 160.0f - 30; // cell must start before
    self.tapeCollectionState = TPScrollStateNormal;
    
    ///////////////////////
    
    CGRect frame = CGRectMake(0, 0, 320, 44);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
    TPTapeCollectionLayout *collectionViewLayout = [[TPTapeCollectionLayout alloc] initWithItemSize:CGSizeMake(kTapeCellWidth, 22)];
    self.tapeCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
    self.tapeCollectionView.backgroundColor = [UIColor clearColor];
    self.tapeCollectionView.delegate = self;
    self.tapeCollectionView.showsHorizontalScrollIndicator = NO;
    self.tapeCollectionView.dataSource = self;
    self.tapeCollectionView.decelerationRate = 0.2;
    self.tapeCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 85);
    self.tapeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.tapeCollectionView registerClass:[TPTapeCollectionCell class] forCellWithReuseIdentifier:@"TapeCollectionCell"];
    [self.view addSubview:self.tapeCollectionView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedDot.png"]];
    imageView.center = CGPointMake(160, 28);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:imageView];
    self.redDotView = imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"globalTime" options:NSKeyValueObservingOptionNew context:&kGlobalTimeContext];
    [[TPPlayerManager sharedManager] addObserver:self forKeyPath:@"currentEpisode" options:NSKeyValueObservingOptionNew context:&kCurrentEpisodeContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tapeCollectionView reloadData];
}


#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == &kGlobalTimeContext)
    {
        if(self.tapeCollectionState == TPScrollStateNormal)
        {
            NSTimeInterval globalTime = [[TPPlayerManager sharedManager] globalTime];
            NSTimeInterval timeDiff = globalTime - self.tapeStartTime;

            CGFloat offset = timeDiff / kTapeCellTime * kTapeCellWidth;
            
            //NSLog(@"UPDATING BY PLAYER POSITION %f %f", timeDiff, globalTime);
            [self.tapeCollectionView setContentOffset:CGPointMake(offset - _tapeScrollAdjustment, 0)];
        }
        //        NSLog(@"offset %f %f %f", offset, globalTime, self.startTime);
    }
    else if(context == &kCurrentEpisodeContext)
    {
        TPEpisodeData *episode = [[TPPlayerManager sharedManager] currentEpisode];
        NSTimeInterval globalTime = [[TPPlayerManager sharedManager] globalTime];
        
        self.tapeCollectionView.hidden = NO;
        self.redDotView.hidden = NO;

        NSTimeInterval newStartTime = episode.plannedFrom.timeIntervalSince1970;
        NSTimeInterval newEndTime = episode.plannedTo.timeIntervalSince1970;
        
        ////////////////
        
        CGFloat currentOffset = self.tapeCollectionView.contentOffset.x;
        CGFloat convertedOffset = currentOffset + (self.startTime - newStartTime)/kTapeCellTime * kTapeCellWidth;

        
        self.startTime = newStartTime;
        self.endTime = newEndTime;
        
        //NSTimeInterval oldTapeStartTime = self.tapeStartTime;
        NSTimeInterval newTapeStartTime = self.startTime - kTapeCellTime * kTapePaddingCount;
        
        // add cells before and after
        self.tapeStartTime = newTapeStartTime;
        
        
        self.tapeCollectionRowCount = kTapePaddingCount + (NSInteger)((self.endTime - self.startTime) / kTapeCellTime) + kTapePaddingCount;
        [self.tapeCollectionView reloadData];
        [self.tapeCollectionView setContentOffset:CGPointMake(convertedOffset, 0)];
        [self updateActiveRange];
        
        CGFloat offsetX = (globalTime - self.tapeStartTime)/kTapeCellTime * kTapeCellWidth - _tapeScrollAdjustment;
        
        CGFloat diff = ABS(self.tapeCollectionView.contentOffset.x - offsetX);
        if(diff>2)
        {
            self.tapeCollectionState = TPScrollStateAnimating;
            [self.tapeCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        }
        else
        {
            NSLog(@"seek diisabled");
        }
    }
}

- (void)updateActiveRange
{
    NSArray *cells = [self.tapeCollectionView visibleCells];
    for(TPTapeCollectionCell *cell in cells)
    {
        NSIndexPath *indexPath = [self.tapeCollectionView indexPathForCell:cell];
        if(indexPath)
        {
            [self setupCellActivity:cell indexPath:indexPath];
        }
    }
}

#pragma mark -

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.tapeCollectionState = TPScrollStateNormal;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tapeCollectionState = TPScrollStateDragging;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self finishTapeScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
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

- (void)finishTapeScrolling
{
    self.tapeCollectionState = TPScrollStateNormal;
    
    CGFloat offsetX = self.tapeCollectionView.contentOffset.x + _tapeScrollAdjustment;
    
    NSTimeInterval time = self.tapeStartTime + (offsetX / kTapeCellWidth) * kTapeCellTime;

    TPEpisodeData *currentEpisode = [[TPPlayerManager sharedManager] currentEpisode];

    NSTimeInterval seconds = time - currentEpisode.plannedFrom.timeIntervalSince1970;
    [[TPPlayerManager sharedManager] playEpisode:currentEpisode atSeconds:seconds];
}

#pragma mark - DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tapeCollectionRowCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPTapeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TapeCollectionCell" forIndexPath:indexPath];
    [self setupCellActivity:cell indexPath:indexPath];
    return cell;
}

- (void)setupCellActivity:(TPTapeCollectionCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    NSTimeInterval globalTime = self.tapeStartTime + row * kTapeCellTime;

    if(globalTime >= self.startTime && globalTime <= self.endTime)
    {
        if(globalTime == self.startTime)
        {
            cell.type = TPTapeCollectionCellTypeStart;
        }
        else if(globalTime == self.endTime)
        {
            cell.type = TPTapeCollectionCellTypeEnd;
        }
        else
        {
            cell.type = TPTapeCollectionCellTypeActive;
        }

        NSTimeInterval diff = globalTime - self.startTime;
        NSString *label = [NSString stringWithFormat:@"%d:%02d", (int)(diff / 60.0f), ((int)diff % 60)];
        cell.activeText = label;
    }
    else
    {
        cell.type = TPTapeCollectionCellTypeInactive;
        cell.activeText = nil;
    }
}

#pragma mark -


@end
