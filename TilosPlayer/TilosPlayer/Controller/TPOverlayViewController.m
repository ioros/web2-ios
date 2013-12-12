//
//  TPOverlayViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPOverlayViewController.h"

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
    }
    return self;
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
        self.rootViewController.view.frame = self.view.bounds;
        [self addChildViewController:self.rootViewController];
        [self.view addSubview:self.rootViewController.view];
    }
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
