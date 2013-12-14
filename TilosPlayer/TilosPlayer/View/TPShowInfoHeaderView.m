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
        self.detailTextView.contentInset = UIEdgeInsetsZero;
        self.detailTextView.editable = NO;
        self.detailTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.detailTextView];
        
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Info", nil), NSLocalizedString(@"Episodes", nil)]];
        [self.segmentedControl sizeToFit];
        [self addSubview:self.segmentedControl];
        
        [self.segmentedControl setSelectedSegmentIndex:1];
        
        self.backgroundColor = [UIColor whiteColor];

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
    
    self.segmentedControl.center = CGPointMake(w/2, b.size.height - 17);
}

- (void)sizeToFit
{
    CGRect frame = self.frame;

    CGFloat w = frame.size.width;
    CGFloat imageWidth = w;
    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);

    CGSize s = [self.detailTextView sizeThatFits:CGSizeMake(w-20, 1000)];
    
    CGFloat h = s.height + imageHeight + 35;
    
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, w, h);
}



@end
