//
//  UIColor+Additions.m
//  PlanViewer
//
//  Created by rumori on 1/10/12.
//  Copyright (c) 2012 RMRI. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)


+ (UIColor *)colorWithHexRGB:(int)value
{
    int r = (value >> 16) & 0xff;
    int g = (value >> 8) & 0xff;
    int b = value & 0xff;
    
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1.0f];
}
+ (UIColor *)colorWithHexRGB:(int)value alpha:(CGFloat)alpha
{
    int r = (value >> 16) & 0xff;
    int g = (value >> 8) & 0xff;
    int b = value & 0xff;
    
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:alpha];
}

+ (UIColor *)randomGrey
{
    int rand = arc4random() % 255;
    
    return [UIColor colorWithWhite:(float)rand/255.0f alpha:1.0f];
}

- (UIColor *)scaleColor:(CGFloat)scale
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    r *= scale;
    g *= scale;
    b *= scale;
    
    r = MAX( MIN(1.0f, r), 0.0f);
    g = MAX( MIN(1.0f, g), 0.0f);
    b = MAX( MIN(1.0f, b), 0.0f);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
}

@end
