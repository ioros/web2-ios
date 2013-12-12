//
//  UIColor+Additions.h
//  PlanViewer
//
//  Created by rumori on 1/10/12.
//  Copyright (c) 2012 RMRI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (UIColor *)colorWithHexRGB:(int)value;
+ (UIColor *)colorWithHexRGB:(int)value alpha:(CGFloat)alpha;

+ (UIColor *)randomGrey;
- (UIColor *)scaleColor:(CGFloat)scale;

@end
