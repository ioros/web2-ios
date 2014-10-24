//
//  TPAuthorInfoHeaderView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 22/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPAuthorInfoHeaderView.h"

@implementation TPAuthorInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        self.imageView.backgroundColor = [UIColor lightGrayColor];
        self.imageView.layer.cornerRadius = 40.0f;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        self.detailTextView.textAlignment = NSTextAlignmentCenter;
        self.detailTextView.font = kTitleFont;
        self.detailTextView.contentInset = UIEdgeInsetsZero;
        self.detailTextView.editable = NO;
        self.detailTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.detailTextView];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    CGFloat w = b.size.width;
    
    self.imageView.center = CGPointMake(w/2, 60);
    
    CGFloat offset = 100;
    self.detailTextView.frame = CGRectMake(10, offset, w-20, b.size.height - offset);
}

- (void)sizeToFit
{
    CGRect frame = self.frame;
    
    CGFloat w = frame.size.width;
    CGFloat imageHeight = 100;
    
    CGSize s = [self.detailTextView sizeThatFits:CGSizeMake(w-20, 1000)];
    
    CGFloat h = 10 + imageHeight + 10 + s.height + 5;
    
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, w, h);
}


@end
