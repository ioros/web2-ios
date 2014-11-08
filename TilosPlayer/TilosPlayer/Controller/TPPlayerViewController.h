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
- (void)playerViewControllerDidOpen:(TPPlayerViewController *)playerViewController;

@end

#pragma mark -

@interface TPPlayerViewController : UIViewController

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
