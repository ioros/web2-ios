//
//  TPShowInfoHeaderView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowInfoHeaderView.h"

@implementation TPShowInfoHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        self.imageView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.imageView];
        
        self.detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        self.detailTextView.textAlignment = NSTextAlignmentCenter;
        self.detailTextView.font = kDescFont;
        self.detailTextView.backgroundColor = [UIColor clearColor];
        self.detailTextView.editable = NO;
        [self addSubview:self.detailTextView];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    CGFloat w = b.size.width;
    CGFloat imageWidth = w;
    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);
    
    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    CGFloat offset = imageHeight;
    self.detailTextView.frame = CGRectMake(10, offset, w-20, b.size.height-offset);
}



@end
