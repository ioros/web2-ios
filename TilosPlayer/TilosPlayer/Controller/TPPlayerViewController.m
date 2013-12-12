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

@implementation TPPlayerViewController


#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TPTapeCollectionLayout *collectionViewLayout = [[TPTapeCollectionLayout alloc] initWithItemSize:CGSizeMake(150, 30)];
    self.tapeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, 320, 60) collectionViewLayout:collectionViewLayout];
    self.tapeCollectionView.backgroundColor = [UIColor lightGrayColor];
    self.tapeCollectionView.delegate = self;
    self.tapeCollectionView.dataSource = self;
    self.tapeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.tapeCollectionView registerClass:[TPTapeCollectionCell class] forCellWithReuseIdentifier:@"TapeCollectionCell"];
    [self.view addSubview:self.tapeCollectionView];

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 124, 320, 220) collectionViewLayout:[[TPTapeCollectionLayout alloc] initWithItemSize:CGSizeMake(320, 220)]];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.collectionView registerClass:[TPEpisodeCollectionCell class] forCellWithReuseIdentifier:@"EpisodeCollectionCell"];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.model == nil)
    {
        self.model = [TPEpisodeListModel new];
        self.model.delegate = self;
    }
    
    if(self.model)
    {
        [self.model loadForced:NO];
    }
    // http://archive.tilos.hu/online/2013/12/11/tilosradio-20131211-0000.mp3
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
