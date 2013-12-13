//
//  TPOverlayViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPOverlayViewController.h"
#import "TPPlayerViewController.h"
#import "TPTabBar.h"

#define kTabbarHeight 48.0f
#define kTopbarHeight 64.0f

@interface TPOverlayViewController ()

@end

@implementation TPOverlayViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UITabBarController *vc = (UITabBarController *)[sb instantiateViewControllerWithIdentifier:@"tabbarController"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelected:) name:@"itemSelected" object:vc.tabBar];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabDeselected:) name:@"itemDeselected" object:vc.tabBar];
        
        self.rootViewController = vc;
        
        TPPlayerViewController *playerViewController = [TPPlayerViewController new];
        playerViewController.delegate = self;
        self.overlayViewController = playerViewController;
    }
    return self;
}

- (void)tabSelected:(NSNotification *)n
{
    NSInteger index = [[n.userInfo objectForKey:@"index"] integerValue];
    [(UITabBarController *)[self rootViewController] setSelectedIndex:index];
    [(TPPlayerViewController*)[self overlayViewController] closeAnimated:YES];
}

- (void)tabDeselected:(NSNotification *)n
{
    [(TPPlayerViewController*)[self overlayViewController] openAnimated:YES];
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
        UIViewController *viewController = self.rootViewController;
        UIView *view = viewController.view;
        view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(kTopbarHeight, 0, 0, 0));
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:viewController];
        [self.view addSubview:view];

        UITabBarController *tabbarController = (UITabBarController *)_rootViewController;
        tabbarController.delegate = self;
        [(TPTabBar *)tabbarController.tabBar deselectItems];
    }
    
    if(self.overlayViewController)
    {
        UIViewController *viewController = self.overlayViewController;
        UIView *view = viewController.view;
        
        view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, kTabbarHeight, 0));
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addChildViewController:viewController];
        [self.view addSubview:view];
    }
    
    ///
    
    UIImage *image = [UIImage imageNamed:@"DefaultBanner.png"];
    UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    image = [image applyBlurWithRadius:7 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];

    CGSize size = CGSizeMake(320.0f, 568.0f);
    CGFloat scale = MAX(size.width / image.size.width, size.height / image.size.height);
    CGSize scaledSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    if(UIGraphicsBeginImageContextWithOptions != NULL)
	{
		UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
	}
	else
	{
		UIGraphicsBeginImageContext(size);
	}
    [image drawInRect:CGRectMake( (size.width - scaledSize.width)/2, (size.height - scaledSize.height)/2, scaledSize.width, scaledSize.height)];
    
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    
    
    size = CGSizeMake(320, 50);
    
    if(UIGraphicsBeginImageContextWithOptions != NULL)
	{
		UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
	}
	else
	{
		UIGraphicsBeginImageContext(size);
	}
    [scaledImage drawInRect:CGRectMake(0, -568.0f + size.height, size.width, 568.0f)];
    
	UIImage *tabbarImage = UIGraphicsGetImageFromCurrentImageContext();
    
    ////////////
    
    UITabBarController *tabbarController = (UITabBarController *)_rootViewController;
    [[(TPTabBar *)[tabbarController tabBar] coverView] setImage:tabbarImage];
    
    [[(TPPlayerViewController *)[self overlayViewController] backgroundView] setImage:scaledImage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITabBarController *tabbarController = (UITabBarController *)_rootViewController;
    [(TPTabBar *)tabbarController.tabBar deselectItems];
}

#pragma mark -

- (void)playerViewControllerWillOpen:(TPPlayerViewController *)playerViewController
{
    self.overlayViewController.view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, kTabbarHeight, 0));
}
- (void)playerViewControllerDidClose:(TPPlayerViewController *)playerViewController
{
    self.overlayViewController.view.frame = CGRectMake(0, 0, 320, kTopbarHeight);
}

#pragma mark -

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return YES;
}
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

@end
