//
//  TPAppDelegate.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TPAppDelegate : UIResponder <UIApplicationDelegate, AVAudioSessionDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
