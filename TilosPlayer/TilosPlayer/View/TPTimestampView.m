//
//  TPTimestampView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 14/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPTimestampView.h"

@interface TPTimestampView ()

@property (nonatomic, retain) NSString *hourText;
@property (nonatomic, retain) NSString *minuteText;

@end

@implementation TPTimestampView

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
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark -

- (void)setSeconds:(NSTimeInterval)seconds
{
    _seconds = seconds;
    
    NSInteger minutes = (NSInteger)floorf((float)seconds / 60.0f);
    
    self.hourText = [NSString stringWithFormat:@"%d", (int)(minutes / 60)];
    self.minuteText = [NSString stringWithFormat:@"%02d", (int)(minutes % 60)];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
 
    [self.backgroundColor set];
    CGContextFillRect(ctx, rect);
    
    [[UIColor blackColor] set];
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(rect, 1, 1));
    
    UIFont *font = kTitleFont;
    CGSize s = [self.hourText sizeWithAttributes:@{NSFontAttributeName: kTitleFont}];
    CGRect hourRect = CGRectMake(rect.size.width/2+7-s.width, (rect.size.height - s.height)/2.0f + 1, s.width, s.height);
    [self.hourText drawAtPoint:hourRect.origin withAttributes:@{NSFontAttributeName: font}];
    
    font = [UIFont fontWithName:@"Avenir-Medium" size:10];
    [self.minuteText drawAtPoint:CGPointMake(CGRectGetMaxX(hourRect), 14) withAttributes:@{NSFontAttributeName: font}];
}

@end
