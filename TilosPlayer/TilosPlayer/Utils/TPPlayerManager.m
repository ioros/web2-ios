//
//  TPPlayerManager.m
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerManager.h"

#import "SynthesizeSingleton.h"

@implementation TPPlayerManager

SYNTHESIZE_SINGLETON_FOR_CLASS(Manager, TPPlayerManager);

- (void)playShow:(NSDictionary *)show
{
    [self playShow:show atSeconds:0];
}
- (void)playShow:(NSDictionary *)show atSeconds:(NSTimeInterval)seconds
{
    
}

- (void)playAtTime:(NSTimeInterval)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *url = [TPTilosUtils urlForArchiveSegmentAtDate:date];
  
    NSLog(@"url %@", url);
//    NSInteger partIndex = (NSInteger)floorf((minuteOffset / 30.0f));
//    NSInteger secondOffset = (minuteOffset - 30 * partIndex) * 60;
}


@end
