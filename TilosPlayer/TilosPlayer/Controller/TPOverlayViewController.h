//
//  TPOverlayViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPPlayerViewController.h"

@class TPTabBar;

@interface TPOverlayViewController : UIViewController <UITabBarControllerDelegate, TPPlayerViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UIViewController *overlayViewController;

@property (nonatomic, readonly) UITabBarController *tilosTabbarController;
@property (nonatomic, readonly) TPTabBar *tabbar;

- (id)initWithRootViewController:(UIViewController *)viewController;

@end
