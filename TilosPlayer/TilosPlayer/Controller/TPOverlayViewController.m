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

@interface TPOverlayViewController ()

@property (nonatomic, retain) UIImageView *ambienceImageView;

@end

#pragma mark -

@implementation TPOverlayViewController

- (id)initWithRootViewController:(UIViewController *)viewController
{
    self = [super init];
    if(self)
    {
        self.rootViewController = viewController;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.ambienceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
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

- (void)viewDidLoad
{
    NSLog(@"TPOverlayViewController");
    [super viewDidLoad];
    
    if(self.rootViewController)
    {
        UIViewController *viewController = self.rootViewController;
        UIView *view = viewController.view;
        view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(kTopbarHeight, 0, 0, 0));
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
        [self addChildViewController:viewController];
        
        self.tilosTabbarController.delegate = self;
        [self.tabbar deselectItems];
    }
    
    if(self.overlayViewController)
    {
        UIViewController *viewController = self.overlayViewController;
        UIView *view = viewController.view;
        
        view.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, kTabbarHeight, 0));
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:view];
        [self addChildViewController:viewController];
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

#pragma mark - url handling

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
        [self.tilosTabbarController setSelectedIndex:2];
        [self.tabbar setSelectedIndex:2];
        [self.playerViewController closeAnimated:YES];
    }
    else if([host isEqualToString:@"episode"])
    {
        [self.tilosTabbarController setSelectedIndex:0];
        [self.tabbar setSelectedIndex:0];
        [self.playerViewController closeAnimated:YES];
    }
    else if([host isEqualToString:@"show"])
    {
        [self.tilosTabbarController setSelectedIndex:1];
        [self.tabbar setSelectedIndex:1];
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
    [self.tabbar deselectItems];
    
    [[TPPlayerManager sharedManager] playEpisode:episode];
}

#pragma mark -

- (void)updateAmbience:(NSNotification *)n
{
    TPEpisodeData *episode = [[TPPlayerManager sharedManager] currentEpisode];

    [self.ambienceImageView sd_setImageWithURL:[NSURL URLWithString:episode.bannerURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [self generateAmbience];
        
    }];
}

- (void)generateAmbience
{
    UIImage *image = [self.ambienceImageView image];
    if(image == nil) return;
    
    __block UIImage *bannerImage = image;
    __block CGSize viewSize = self.view.bounds.size;
    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // generate images
        
        UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        UIImage *blurredImage = [bannerImage applyBlurWithRadius:5 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
        
        CGSize size = viewSize;
        CGFloat scale = MAX(size.width / blurredImage.size.width, size.height / blurredImage.size.height);
        CGSize scaledSize = CGSizeMake(blurredImage.size.width * scale, blurredImage.size.height * scale);
        
        
        if(&UIGraphicsBeginImageContextWithOptions != NULL) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
        [blurredImage drawInRect:CGRectMake( (size.width - scaledSize.width)/2, (size.height - scaledSize.height)/2, scaledSize.width, scaledSize.height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //This is neccesesary for each UIGraphicsBeginImageContext
        //From stackoverflow: "It's also super important to call UIGraphicsEndImageContext() or things start to get wacky with the CPU"
        //I digged deeper: in our situation after a short period of time (10 secs or so) the system tries to clean the Graphics Context on another thread, but the context is locked and it causes an infinite loop of cleaning which makes 100% CPU usage. Each time this method is called another 100% CPU user thread is spawned, although one can drain the battery really well, but if you have 3-4 or even more that's the best.
        
        UIGraphicsEndImageContext();
        
        size = CGSizeMake(320, 50);

        
        if(&UIGraphicsBeginImageContextWithOptions != NULL) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
        [scaledImage drawInRect:CGRectMake(0, -480.0f + size.height, size.width, 480.0f)];
        
        UIGraphicsEndImageContext();

        UIImage *tabbarImage = UIGraphicsGetImageFromCurrentImageContext();
        
        dispatch_async( dispatch_get_main_queue(), ^{

            UIImageView *imageView = nil;
            
            imageView = [self.tabbar coverView];
            [UIView transitionWithView:imageView
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                imageView.image = tabbarImage;
                            } completion:NULL];
            
            
            imageView = [self.playerViewController backgroundView];
            [UIView transitionWithView:imageView
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                imageView.image = scaledImage;
                            } completion:NULL];
        });
    });
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
