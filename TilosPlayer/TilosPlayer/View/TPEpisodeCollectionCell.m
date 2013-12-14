//
//  TPEpisodeCollectionCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeCollectionCell.h"
#import "AFNetworking.h"
#import "UIImage+ImageEffects.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TPEpisodeCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.numberOfLines = -1;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = kTitleFont;
    self.textLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.textLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
//    self.imageView.layer.cornerRadius = 5.0f;
//    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    self.detailTextView.textAlignment = NSTextAlignmentCenter;
    self.detailTextView.font = kDescFont;
    self.detailTextView.textColor = [UIColor whiteColor];
    self.detailTextView.backgroundColor = [UIColor clearColor];
    self.detailTextView.editable = NO;
    [self.contentView addSubview:self.detailTextView];
    
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
}

#pragma mark -

- (void)setData:(NSDictionary *)data
{
    _data = data;
    
    self.textLabel.text = [data episodeName];
    self.detailTextView.text = [data episodeDefinition];
    
    [self.imageView setImageWithURL:[data episodeBannerUrl]];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = CGRectInset(self.bounds, 40, 0);

    CGRect b = self.contentView.bounds;
    CGFloat w = b.size.width;
    CGFloat imageWidth = w;
    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);

    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    CGFloat offset = imageHeight + 9;
    
    CGSize s = [self.textLabel sizeThatFits:CGSizeMake(w - 40, 1000)];
    self.textLabel.frame = CGRectMake(20, offset, w-40, s.height);
    offset += s.height;
    
    self.detailTextView.frame = CGRectMake(10, offset - 2, w-20, b.size.height-offset);
}

@end
