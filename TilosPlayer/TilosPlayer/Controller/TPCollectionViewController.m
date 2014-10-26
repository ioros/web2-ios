//
//  TPCollectionViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPCollectionViewController.h"

#import "TPCollectionCellFactory.h"
#import "TPSmallEpisodeCell.h"

@interface TPCollectionViewController ()

@property (nonatomic, retain) id<TPCollectionCellFactory> cellFactory;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) UICollectionViewLayout *layout;

@end

#pragma mark -

@implementation TPCollectionViewController

- (instancetype)initWithCellFactory:(id<TPCollectionCellFactory>)cellFactory layout:(UICollectionViewLayout *)layout
{
    self = [super init];
    if(self)
    {
        self.cellFactory = cellFactory;
        self.layout = layout;
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.pagingEnabled = YES;
    
    [self.cellFactory registerClasses:collectionView];

    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

- (void)setModel:(TPListModel *)model
{
    [_model cancel];
    _model.delegate = nil;
    
    _model = model;
    
    if(_model)
    {
        _model.delegate = self;
        if(self.isViewLoaded)
        {
            [_model loadForced:NO];
        }
    }
}

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.model numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.model numberOfRowsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellFactory collectionView:collectionView cellForItemAtIndexPath:indexPath data:[self.model dataForIndexPath:indexPath]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if([_delegate respondsToSelector:@selector(collectionViewController:didSelectData:)])
    {
        [_delegate collectionViewController:self didSelectData:[self.model dataForIndexPath:indexPath]];
    }
}


@end
