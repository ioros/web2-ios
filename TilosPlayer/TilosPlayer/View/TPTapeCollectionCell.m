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
    self.opaque = NO;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat smallDot = 3.0f;
    const CGFloat bigDot = 5.0f;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [[UIColor clearColor] set];
    CGContextFillRect(ctx, rect);
    
    [[UIColor whiteColor] set];

    CGContextFillRect(ctx, CGRectMake(0, floorf(rect.size.height/2), rect.size.width, 0.5));

    CGContextFillEllipseInRect(ctx, CGRectMake(-bigDot/2, rect.size.height/2-bigDot/2, bigDot, bigDot));
    CGContextFillEllipseInRect(ctx, CGRectMake(rect.size.width-bigDot/2, rect.size.height/2-bigDot/2, bigDot, bigDot));
    
    for(int i=1; i<5; i++)
    {
        CGContextFillEllipseInRect(ctx, CGRectMake(i*30-smallDot/2, rect.size.height/2-smallDot/2, smallDot, smallDot));
    }
}

@end
