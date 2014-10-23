//
//  TPTapeCollectionLiveCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 10/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPTapeCollectionLiveCell.h"

@implementation TPTapeCollectionLiveCell

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
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    //const CGFloat smallDot = 3.0f;
    const CGFloat bigDot = 5.0f;
    
    [[UIColor clearColor] set];
    CGContextFillRect(ctx, rect);
    
    [[UIColor whiteColor] set];
    CGContextFillRect(ctx, CGRectMake(0, floorf(rect.size.height/2), 100, 0.5));
    [[UIColor redColor] set];
    CGContextFillRect(ctx, CGRectMake(50, 0, 50, rect.size.height));

    [[UIColor whiteColor] set];
    CGContextFillEllipseInRect(ctx, CGRectMake(-bigDot/2, rect.size.height/2-bigDot/2, bigDot, bigDot));

    [NSLocalizedString(@"LIVE", nil) drawInRect:rect withFont:[UIFont systemFontOfSize:15] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}

@end
