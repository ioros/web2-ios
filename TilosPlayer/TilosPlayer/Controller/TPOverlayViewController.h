//
//  TPOverlayViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPPlayerViewController.h"

@class TPPlayerViewController;
@class TPTabBar;

@interface TPOverlayViewController : UIViewController <UITabBarControllerDelegate, TPPlayerViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UIViewController *overlayViewController;

@property (nonatomic, readonly) TPPlayerViewController *playerViewController;
@property (nonatomic, readonly) UITabBarController *tilosTabbarController;
@property (nonatomic, readonly) TPTabBar *tabbar;

@property (nonatomic, retain) NSURL *urlToOpen;

- (id)initWithRootViewController:(UIViewController *)viewController;

@end
