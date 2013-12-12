//
//  TPOverlayViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPOverlayViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIViewController *rootViewController;

- (id)initWithRootViewController:(UIViewController *)viewController;

@end
