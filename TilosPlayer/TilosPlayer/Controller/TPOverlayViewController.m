//
//  TPOverlayViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPOverlayViewController.h"
#import "TPPlayerViewController.h"

#define kTabbarHeight 48.0f

@interface TPOverlayViewController ()

@end

@implementation TPOverlayViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"tabbarController"];
        self.rootViewController = vc;
        
        TPPlayerViewController *playerViewController = [TPPlayerViewController new];
        playerViewController.delegate = self;
        self.overlayViewController = playerViewController;
    }
    return self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [(TPPlayerViewController*)[self overlayViewController] closeAnimated:YES];
}


- (id)initWithRootViewController:(UIViewController *)viewController
{
    self = [super init];
    if(self)
    {
        self.rootViewController = viewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.rootViewController)
    {
        self.rootViewController.view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(64, 0, 0, 0));
        [self addChildViewController:self.rootViewController];
        [self.view addSubview:self.rootViewController.view];

        UITabBarController *tabbarController = (UITabBarController *)_rootViewController;
        tabbarController.delegate = self;
        tabbarController.selectedIndex = -1;
    }
    
    if(self.overlayViewController)
    {
        UIViewController *viewController = self.overlayViewController;
        UIView *view = viewController.view;
        
        view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, kTabbarHeight, 0));
        [self addChildViewController:viewController];
        [self.view addSubview:view];
    }
}

#pragma mark -

- (void)playerViewControllerWillOpen:(TPPlayerViewController *)playerViewController
{
    self.overlayViewController.view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, kTabbarHeight, 0));
}
- (void)playerViewControllerDidClose:(TPPlayerViewController *)playerViewController
{
    self.overlayViewController.view.frame = CGRectMake(0, 0, 320, 64);
}

#pragma mark -

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return YES;
}
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

@end
