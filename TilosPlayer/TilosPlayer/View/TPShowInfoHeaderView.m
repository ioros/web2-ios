//
//  TPShowInfoHeaderView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowInfoHeaderView.h"

@implementation TPShowInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        self.imageView.backgroundColor = [UIColor lightGrayColor];
        self.imageView.layer.cornerRadius = 5.0f;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        self.detailTextView.textAlignment = NSTextAlignmentCenter;
        self.detailTextView.font = kDescFont;
        self.detailTextView.contentInset = UIEdgeInsetsZero;
        self.detailTextView.editable = NO;
        self.detailTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.detailTextView];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = kTitleFont;
        self.textLabel.numberOfLines = 0;
        [self addSubview:self.textLabel];
        
        self.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    CGFloat w = b.size.width;
    CGFloat imageWidth = 200;
    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);
    
    self.imageView.frame = CGRectMake((w-imageWidth)/2.0f, 10, imageWidth, imageHeight);
    
    CGFloat offset = imageHeight + 15;
    
    CGSize s = [self.textLabel sizeThatFits:CGSizeMake(w-20, 200)];
    self.textLabel.frame = CGRectMake(10, offset, w-20, s.height);
    offset += s.height;
    
    self.detailTextView.frame = CGRectMake(10, offset, w-20, b.size.height-offset);
}

- (void)sizeToFit
{
    CGRect frame = self.frame;

    CGFloat w = frame.size.width;
    CGFloat imageWidth = 200;
    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);

    CGSize titleSize = [self.textLabel sizeThatFits:CGSizeMake(w-20, 200)];
    CGSize detailSize = [self.detailTextView sizeThatFits:CGSizeMake(w-20, 1000)];

    CGFloat h = 10 + imageHeight + 5 + titleSize.height + detailSize.height + 5;
    
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, w, h);
}



@end
