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
        
        self.opaque = NO;
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

    [[UIColor clearColor] set];
    CGContextFillRect(ctx, rect);
    
    [[UIColor whiteColor] set];
    CGContextFillEllipseInRect(ctx, CGRectMake(-3, rect.size.height/2-3, 6, 6));
    CGContextFillEllipseInRect(ctx, CGRectMake(rect.size.width-3, rect.size.height/2-3, 6, 6));
    CGContextFillRect(ctx, CGRectMake(0, floorf(rect.size.height/2), rect.size.width, 0.5));
    
    for(int i=1; i<5; i++)
    {
        CGContextFillEllipseInRect(ctx, CGRectMake(i*30, rect.size.height/2-2, 4, 4));
    }
}

@end
