//
//  NSDate+TPAdditions.h
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TPAdditions)

- (NSString *)dayName;
- (NSDate *)archiveSegmentStartDate;
- (NSDate *)dayDate;


@end
