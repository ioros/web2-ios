//
//  TPPlayerTopNavigationBar.m
//  TilosPlayer
//
//  Created by Daniel Langh on 08/11/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPPlayerTopNavigationBar.h"

@implementation TPPlayerTopNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setLeftButton:(UIButton *)leftButton
{
    [_leftButton removeFromSuperview];
    _leftButton = leftButton;
    [self addSubview:_leftButton];
    
    [self setNeedsLayout];
}
- (void)setRightButton:(UIButton *)rightButton
{
    [_rightButton removeFromSuperview];
    _rightButton = rightButton;
    [self addSubview:_rightButton];

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect b = self.bounds;
    
    self.leftButton.center = CGPointMake(b.size.width/4 - 20, b.size.height/2);
    self.rightButton.center = CGPointMake(b.size.width/4*3 + 20, b.size.height/2);
}

@end
