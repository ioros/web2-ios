//
//  TPPlayerViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPListModel.h"

@class TPPlayerViewController;

@protocol TPPlayerViewControllerDelegate <NSObject>

@optional
- (void)playerViewControllerDidClose:(TPPlayerViewController *)playerViewController;
- (void)playerViewControllerWillOpen:(TPPlayerViewController *)playerViewController;

@end


@interface TPPlayerViewController : UIViewController <TPListModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) IBOutlet UICollectionView *tapeCollectionView;
@property (nonatomic, retain) TPListModel *model;

@property (nonatomic, retain) UIButton *logoButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;

@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *middleView;
@property (nonatomic, retain) UIImageView *backgroundView;

@property (nonatomic, retain) UIView *fadeView;


@property (nonatomic, assign) id<TPPlayerViewControllerDelegate> delegate;

- (IBAction)close:(id)sender;

- (void)closeAnimated:(BOOL)animated;
- (void)openAnimated:(BOOL)animated;
- (void)toggleAnimated:(BOOL)animated;

@end
