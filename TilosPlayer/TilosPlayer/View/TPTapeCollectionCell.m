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
    _type = TPTapeCollectionCellTypeInactive;
    self.opaque = NO;
}

- (void)setActiveText:(NSString *)activeText
{
    _activeText = activeText;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat smallDot = 3.0f;
    const CGFloat bigDot = 5.0f;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [[UIColor clearColor] set];
    CGContextFillRect(ctx, rect);

    [[UIColor whiteColor] set];
    CGFloat lineOffset = self.bounds.size.height - 5;

    // draw line
    
    if(_type == TPTapeCollectionCellTypeEnd || _type == TPTapeCollectionCellTypeActive)
    {
        [[UIColor whiteColor] set];
    }
    else
    {
        [[UIColor colorWithWhite:1.0 alpha:0.3] set];
    }
    CGContextFillRect(ctx, CGRectMake(0, lineOffset, 30, 0.5));
    
    if(_type == TPTapeCollectionCellTypeStart || _type == TPTapeCollectionCellTypeActive)
    {
        [[UIColor whiteColor] set];
    }
    else
    {
        [[UIColor colorWithWhite:1.0 alpha:0.3] set];
    }
    CGContextFillRect(ctx, CGRectMake(30, lineOffset, rect.size.width, 0.5));
    
    
    
    
    
    
    
    ////////////////////////
    

    if(_type != TPTapeCollectionCellTypeInactive)
    {
        [[UIColor whiteColor] set];
        CGSize s = [_activeText sizeWithFont:kSubFont];
        [_activeText drawAtPoint:CGPointMake(30 - s.width/2, self.bounds.size.height-24) withFont:kSubSubFont];
//        CGSize s = [_activeText sizeWithAttributes:@{NSFontAttributeName: kSubSubFont}];
//        [_activeText drawAtPoint:CGPointMake(30 - s.width/2, self.bounds.size.height-24) withAttributes: @{NSFontAttributeName:kSubSubFont}];
    }

    // draw first dot
    
    if(_type == TPTapeCollectionCellTypeEnd || _type == TPTapeCollectionCellTypeActive)
    {
        [[UIColor whiteColor] set];
    }
    else
    {
        [[UIColor colorWithWhite:1.0 alpha:0.3] set];
    }
    CGContextFillEllipseInRect(ctx, CGRectMake(-smallDot/2, lineOffset-smallDot/2, smallDot, smallDot));
    
    
    // draw big dot
    if(_type != TPTapeCollectionCellTypeInactive)
    {
        [[UIColor whiteColor] set];
    }
    else
    {
        [[UIColor colorWithWhite:1.0 alpha:0.3] set];
    }
    CGContextFillEllipseInRect(ctx, CGRectMake(1*30-bigDot/2, lineOffset-bigDot/2, bigDot, bigDot));
    
    // draw rest

    if(_type == TPTapeCollectionCellTypeStart || _type == TPTapeCollectionCellTypeActive)
    {
        [[UIColor whiteColor] set];
    }
    else
    {
        [[UIColor colorWithWhite:1.0 alpha:0.3] set];
    }

    for(int i=2; i<6; i++)
    {
        CGContextFillEllipseInRect(ctx, CGRectMake(i*30-smallDot/2, lineOffset-smallDot/2, smallDot, smallDot));
    }
}

@end
