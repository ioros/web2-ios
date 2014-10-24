//
//  TPCollectionViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPListModel.h"
#import "TPCollectionCellFactory.h"

@class TPCollectionViewController;

@protocol TPCollectionViewControllerDelegate <NSObject>

@optional
- (void)collectionViewController:(TPCollectionViewController *)collectionViewController didSelectData:(id)data;

@end

@interface TPCollectionViewController : UIViewController <TPListModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) TPListModel *model;
@property (nonatomic, assign) id<TPCollectionViewControllerDelegate> delegate;

- (instancetype)initWithCellFactory:(id<TPCollectionCellFactory>)cellFactory layout:(UICollectionViewLayout *)layout;

@end
