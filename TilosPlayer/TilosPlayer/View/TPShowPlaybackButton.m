//
//  TPShowPlaybackButton.m
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPShowPlaybackButton.h"

@interface TPShowPlaybackButton ()

@property (nonatomic, retain) UIImageView *customImageView;

@end

#pragma mark -

@implementation TPShowPlaybackButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        self.customImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.customImageView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setImage:[UIImage imageNamed:@"SmallPlayButton.png"] forState:UIControlStateNormal];
        [self addSubview:self.button];
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

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    self.customImageView.image = nil;
    [self.customImageView sd_setImageWithURL:[NSURL URLWithString:_imageURL]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    self.customImageView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, b.size.height, 0, 0));
    
    self.button.frame = CGRectMake(0, 0, b.size.height, b.size.height);
}

@end
