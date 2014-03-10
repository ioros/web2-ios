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
#import "TPPlayerManager.h"
#import "TPEpisodeData.h"

#define kTabbarHeight 49.0f
#define kTopbarHeight 64.0f

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEpisode:) name:@"playEpisode" object:nil];
        
        self.rootViewController = vc;
        
        TPPlayerViewController *playerViewController = [TPPlayerViewController new];
        playerViewController.delegate = self;
        self.overlayViewController = playerViewController;
    }
    return self;
}

#pragma mark -

- (void)openURL:(NSURL *)url
{
    if(self.isViewLoaded)
    {
        [self handleURL:url];
    }
    else
    {
        self.urlToOpen = url;
    }
}

- (void)handleURL:(NSURL *)url
{
    NSString *host = url.host;
    
    if([host isEqualToString:@"author"])
    {
        [self.tilosTabbarController setSelectedIndex:0];
        [self.tabbar setSelectedIndex:0];
        [self.playerViewController closeAnimated:YES];
    }
    else if([host isEqualToString:@"episode"])
    {
        [self.tilosTabbarController setSelectedIndex:1];
        [self.tabbar setSelectedIndex:1];
        [self.playerViewController closeAnimated:YES];
    }
    else if([host isEqualToString:@"show"])
    {
        [self.tilosTabbarController setSelectedIndex:2];
        [self.tabbar setSelectedIndex:2];
        [self.playerViewController closeAnimated:YES];
    }
}

#pragma mark -

- (void)tabSelected:(NSNotification *)n
{
    NSInteger index = [[n.userInfo objectForKey:@"index"] integerValue];
    self.tilosTabbarController.selectedIndex = index;
    [self.playerViewController closeAnimated:YES];
}

- (void)tabDeselected:(NSNotification *)n
{
    [self.playerViewController openAnimated:YES];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self.playerViewController closeAnimated:YES];
}

#pragma mark -

- (void)playEpisode:(NSNotification *)n
{
    TPEpisodeData *episode = [n.userInfo objectForKey:@"episode"];
    
    [self.playerViewController openAnimated:YES];
    [self.playerViewController jumpToDate:episode.plannedFrom];
    [self.tabbar deselectItems];
    
    [[TPPlayerManager sharedManager] playEpisode:episode];
}

#pragma mark -


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

        self.tilosTabbarController.delegate = self;
        [self.tabbar deselectItems];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAmbience:) name:@"updateAmbience" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self tabbar] deselectItems];
    
    if(self.urlToOpen)
    {
        [self handleURL:self.urlToOpen];
        self.urlToOpen = nil;
    }
}

#pragma mark -

- (void)updateAmbience:(NSNotification *)n
{
    UIImage *image = [n.userInfo objectForKey:@"image"];
    UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    image = [image applyBlurWithRadius:7 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    
    CGSize size = self.view.frame.size;
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
    
    UIImageView *view = nil;
    
    view = [self.tabbar coverView];
    [UIView transitionWithView:view
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        view.image = tabbarImage;
                    } completion:NULL];

    
    view = [self.playerViewController backgroundView];
    [UIView transitionWithView:view
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        view.image = scaledImage;
                    } completion:NULL];
}

#pragma mark -

- (void)playerViewControllerWillOpen:(TPPlayerViewController *)playerViewController
{
    self.overlayViewController.view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, kTabbarHeight, 0));
    [self.tabbar deselectItems];
}
- (void)playerViewControllerDidClose:(TPPlayerViewController *)playerViewController
{
    self.overlayViewController.view.frame = CGRectMake(0, 0, 320, kTopbarHeight);
}
- (void)playerViewControllerWillClose:(TPPlayerViewController *)playerViewController
{
    [self.tabbar setSelectedIndex:self.tilosTabbarController.selectedIndex];
}

#pragma mark -

- (TPTabBar *)tabbar
{
    return (TPTabBar *)[self.tilosTabbarController tabBar];
}

- (UITabBarController *)tilosTabbarController
{
    return (UITabBarController *)_rootViewController;
}

- (TPPlayerViewController *)playerViewController
{
    return (TPPlayerViewController *)_overlayViewController;
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
