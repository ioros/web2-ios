//
//  TPEpisodeTimelineViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 08/11/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPEpisodeTimelineViewController.h"

#import "TPContinuousProgramModel.h"
#import "TPEpisodeData.h"
#import "TPCollectionView.h"
#import "TPTapeCollectionLayout.h"
#import "TPEpisodeCollectionCell.h"
#import "TPPlayerManager.h"

@interface TPEpisodeTimelineViewController ()

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, assign) TPScrollState collectionState;
@property (nonatomic, assign) NSInteger collectionDragStartIndex;

@property (nonatomic, retain) TPContinuousProgramModel *model;

@end

#pragma mark -

static int kCurrentEpisodeContext;

@implementation TPEpisodeTimelineViewController

- (void)viewDidLoad
{
    NSLog(@"TPEpisodeTimelineViewController");
    [super viewDidLoad];
    
    self.collectionState = TPScrollStateNormal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, 320, 220) collectionViewLayout:[[TPTapeCollectionLayout alloc] initWithItemSize:CGSizeMake(320, 220)]];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.collectionView registerClass:[TPEpisodeCollectionCell class] forCellWithReuseIdentifier:@"EpisodeCollectionCell"];
    [self.view addSubview:self.collectionView];
    
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
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == &kCurrentEpisodeContext)
    {
        [self updateCollectionView:YES];
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

#pragma mark -

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
    }
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

#pragma mark - helpers

- (NSInteger)selectedIndexInCollectionView
{
    return (NSInteger)floorf(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width);
}

- (void)scrollToIndexInCollectionView:(NSInteger)index animated:(BOOL)animated
{
    [self.collectionView setContentOffset:CGPointMake(index * 320, 0) animated:animated];
}

@end
