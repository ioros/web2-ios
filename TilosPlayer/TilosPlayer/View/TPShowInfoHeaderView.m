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
        
//        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
//        self.imageView.backgroundColor = [UIColor lightGrayColor];
//        self.imageView.layer.cornerRadius = 5.0f;
//        self.imageView.clipsToBounds = YES;
//        [self addSubview:self.imageView];
        
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
        
        self.contributorsTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.contributorsTextLabel.textAlignment = NSTextAlignmentCenter;
        self.contributorsTextLabel.font = kDescFont;
        self.contributorsTextLabel.numberOfLines = 0;
        self.contributorsTextLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contributorsTextLabel];

        self.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    CGFloat w = b.size.width;
//    CGFloat imageWidth = b.size.width - 140;
//    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);
//    
//    self.imageView.frame = CGRectMake((w-imageWidth)/2.0f, 35, imageWidth, imageHeight);
    
//    CGFloat offset = 35 + imageHeight + 20;
    CGFloat offset = 35 + 0 + 20;
    
    CGSize s = [self.textLabel sizeThatFits:CGSizeMake(w-20, 400)];
    self.textLabel.frame = CGRectMake(10, offset, w-20, s.height);
    offset += s.height;
    
    s = [self.detailTextView sizeThatFits:CGSizeMake(w-20, 1000)];
    self.detailTextView.frame = CGRectMake(10, offset, w-20, s.height);
    
    offset += s.height;
    
    self.contributorsTextLabel.frame = CGRectMake(10, offset, w-20, 3* (b.size.height-offset));
    
    offset += b.size.height-offset;
}

- (void)sizeToFit
{
    CGRect frame = self.frame;

//    CGRect b = self.bounds;
    CGFloat w = frame.size.width;
//    CGFloat imageWidth = b.size.width - 140;
//    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);

    CGSize titleSize = [self.textLabel sizeThatFits:CGSizeMake(w-20, 200)];
    CGSize detailSize = [self.detailTextView sizeThatFits:CGSizeMake(w-20, 1000)];
    CGSize contributorSize = [self.contributorsTextLabel sizeThatFits:CGSizeMake(w-20, 500)];
//    CGFloat h = 35 + imageHeight + 20 + titleSize.height + detailSize.height + 5;
    CGFloat h = 35 + 0 + 20 + titleSize.height + detailSize.height + 3* contributorSize.height + 5;
    
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, w, h);
}



@end
