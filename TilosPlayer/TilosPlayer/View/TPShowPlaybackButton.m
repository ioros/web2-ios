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
        self.customImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.customImageView];
        
        self.chevronView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmallRecord.png"]];
        self.chevronView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.chevronView];
    }
    return self;
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
    self.chevronView.frame = CGRectMake(b.size.width-b.size.height, 0, b.size.height, b.size.height);
    self.customImageView.frame = CGRectMake(0, 0, b.size.width-b.size.height, b.size.height);
}

@end
