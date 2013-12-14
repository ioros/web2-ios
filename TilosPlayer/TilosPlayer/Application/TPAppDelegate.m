//
//  TPAppDelegate.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAppDelegate.h"

@implementation TPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAudio];
    [self setupAppearance];
    
    if([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey])
    {
        [self handleURL:[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]];
    }
    
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
    self.window.tintColor = [UIColor blackColor];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName:kDescFont} forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor darkGrayColor]];
}

- (void)setupAudio
{
    /////////// setup audio ////////////////////
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    /* Pick any one of them */
    // 1. Overriding the output audio route
    //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    // 2. Changing the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
}
							
@end
