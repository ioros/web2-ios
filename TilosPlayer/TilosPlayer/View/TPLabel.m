//
//  TPLabel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 26/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPLabel.h"

@implementation TPLabel


- (void)drawRect:(CGRect)rect
{
    [self.backgroundImage drawInRect:rect];
    [super drawRect:rect];
}

@end
