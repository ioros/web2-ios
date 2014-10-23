//
//  TPTitleView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 23/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPTitleView.h"

#define kTitleViewMaxWidth 240.0f

@implementation TPTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        self.numberOfLines = 0;
        self.font = kTitleFont;
    }
    return self;
}

- (void)sizeToFit
{
    NSString *text = self.text;
    
    UIFont *font = kTitleFont;
    CGSize s = [text sizeWithFont:font];
    if(s.width > kTitleViewMaxWidth)
    {
        font = kHalfTitleFont;
    }
    self.font = font;
    
    [super sizeToFit];
}


@end
