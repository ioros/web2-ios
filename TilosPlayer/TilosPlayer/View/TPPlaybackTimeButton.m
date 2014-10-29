//
//  TPPlaybackTimeView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 29/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPPlaybackTimeButton.h"

@implementation TPPlaybackTimeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _playing = NO;
        
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmallPlayButton.png"]];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kSubFont;
        label.textColor = [UIColor whiteColor];
        label.text = @"0:00 / 95:00";
        self.label = label;
        
        [self addSubview:self.label];
    }
    return self;
}

- (void)setPlaying:(BOOL)playing
{
    _playing = playing;
    if(_playing)
    {
        [self.imageView setImage:[UIImage imageNamed:@"SmallPauseButton.png"]];
    }
    else
    {
        [self.imageView setImage:[UIImage imageNamed:@"SmallPlayButton.png"]];
    }
}


- (void)layoutSubviews
{
    CGRect b = self.bounds;
    self.imageView.frame = CGRectMake(0, 0, b.size.height, b.size.height);
    self.label.frame = CGRectMake(b.size.height, 0, 80, b.size.height);
}


@end
