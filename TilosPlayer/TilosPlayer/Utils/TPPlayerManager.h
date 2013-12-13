//
//  TPPlayerManager.h
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPPlayerManager : NSObject

+ (TPPlayerManager *)sharedManager;

- (void)playShow:(NSDictionary *)show;
- (void)playShow:(NSDictionary *)show atSeconds:(NSTimeInterval)seconds;

- (void)playAtTime:(NSTimeInterval)time;

@end
