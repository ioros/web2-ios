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
        _isMusic = YES;
        
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setImage:[UIImage imageNamed:@"SmallPlayButton.png"] forState:UIControlStateNormal];
        [self addSubview:self.button];

        self.typeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmallOpenButton.png"]];
        self.typeView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.typeView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kSubFont;
        label.textColor = [UIColor whiteColor];
        label.text = @"35:00 / 120:00";
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
        [self.button setImage:[UIImage imageNamed:@"SmallPauseButton.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.button setImage:[UIImage imageNamed:@"SmallPlayButton.png"] forState:UIControlStateNormal];
    }
}


- (void)layoutSubviews
{
    CGRect b = self.bounds;
    self.button.frame = CGRectMake(-5, -5, b.size.height+10, b.size.height+10);
    self.label.frame = CGRectMake(b.size.height, 0, b.size.width - 2 * b.size.height, b.size.height);
    self.typeView.frame = CGRectMake(b.size.width-b.size.height, 0, b.size.height, b.size.height);
}


@end
