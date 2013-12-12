//
//  TPTapeCollectionCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPTapeCollectionCell.h"

@implementation TPTapeCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [self.backgroundColor set];
    CGContextFillRect(ctx, rect);
    
    [[UIColor redColor] set];
    CGContextFillRect(ctx, CGRectInset(rect, 3, 3));
}

@end
