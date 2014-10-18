//
//  TPPlayerViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPListModel.h"
#import "TPContinuousProgramModel.h"

@class TPPlayerViewController;
@class TPContinuousProgramModel;
@class TPPlayButton;

@protocol TPPlayerViewControllerDelegate <NSObject>

@optional
- (void)playerViewControllerWillClose:(TPPlayerViewController *)playerViewController;
- (void)playerViewControllerDidClose:(TPPlayerViewController *)playerViewController;
- (void)playerViewControllerWillOpen:(TPPlayerViewController *)playerViewController;

@end

#pragma mark -

@interface TPPlayerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, TPContinuousProgramModelDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) IBOutlet UICollectionView *tapeCollectionView;

@property (nonatomic, retain) UIButton *logoButton;
@property (nonatomic, retain) TPPlayButton *playButton;

@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *middleView;
@property (nonatomic, retain) UIImageView *backgroundView;

@property (nonatomic, retain) UIView *fadeView;

@property (nonatomic, retain) TPContinuousProgramModel *model;

@property (nonatomic, assign) id<TPPlayerViewControllerDelegate> delegate;

- (IBAction)close:(id)sender;

- (void)closeAnimated:(BOOL)animated;
- (void)openAnimated:(BOOL)animated;
- (void)toggleAnimated:(BOOL)animated;

- (void)jumpToDate:(NSDate *)date;

@end
