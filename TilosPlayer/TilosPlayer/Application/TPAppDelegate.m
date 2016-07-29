//
//  TPAppDelegate.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAppDelegate.h"
#import "TPPlayerManager.h"

@implementation TPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearance];
    
    if([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey])
    {
        [self handleURL:[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]];
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self handleURL:url];
}

- (BOOL)handleURL:(NSURL *)url
{
    if([self.window.rootViewController respondsToSelector:@selector(openURL:)])
    {
        [self.window.rootViewController performSelector:@selector(openURL:) withObject:url];
        return YES;
    }
    return NO;
}

#pragma mark -

- (void)setupAppearance
{
    [[UINavigationBar appearance] setShadowImage:nil];
    
    self.window.tintColor = [UIColor blackColor];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName:kSubSubFont} forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor darkGrayColor]];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    [[TPPlayerManager sharedManager] remoteControlReceivedWithEvent:receivedEvent];
}

@end
