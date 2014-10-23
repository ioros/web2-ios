//
//  TPEpisodeCollectionCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeCollectionCell.h"
#import "UIImage+ImageEffects.h"
#import "TPEpisodeData.h"
#import "TPShowData.h"

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

    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.authorLabel.backgroundColor = [UIColor clearColor];
    self.authorLabel.numberOfLines = -1;
    self.authorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.authorLabel.textAlignment = NSTextAlignmentCenter;
    self.authorLabel.font = kSubSubFont;
    self.authorLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.authorLabel];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
//    self.imageView.layer.cornerRadius = 5.0f;
//    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    self.detailTextView.textAlignment = NSTextAlignmentCenter;
    self.detailTextView.font = kDescFont;
    self.detailTextView.textColor = [UIColor whiteColor];
//    self.detailTextView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.detailTextView.backgroundColor = [UIColor clearColor];
    self.detailTextView.editable = NO;
    self.detailTextView.selectable = NO;
    self.detailTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -6);
    self.detailTextView.contentInset = UIEdgeInsetsMake(-3, 0, 0, 0);
    [self.contentView addSubview:self.detailTextView];
    
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
}

#pragma mark -

- (void)setEpisode:(TPEpisodeData *)episode
{
    _episode = episode;
    
    self.textLabel.text = episode.name;

    NSArray *nicknames = [episode.show contributorNicknames];
    self.authorLabel.text = [nicknames componentsJoinedByString:@", "];
    
    self.detailTextView.text = episode.definition;
    
    NSString *url = episode.bannerURL;
    if(url != nil)
    {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    else {
        [self.imageView setImage:[UIImage imageNamed:@"DefaultBanner.png"]];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = CGRectInset(self.bounds, 20, 0);

    CGRect b = self.contentView.bounds;
    CGFloat w = b.size.width;
    CGFloat imageWidth = w;
    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);

    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    CGFloat offset = imageHeight + 9;

    self.textLabel.font = kTitleFont;
    
    CGSize titleSize = [self.textLabel sizeThatFits:CGSizeMake(w - 40, 1000)];
    CGSize authorSize = [self.authorLabel sizeThatFits:CGSizeMake(w-20, 20)];
    CGSize detailSize = [self.detailTextView sizeThatFits:CGSizeMake(w-20, 1000)];
    
    // we dont allow too much height or 3 rows for the title either
    CGFloat addedHeight = (detailSize.height + titleSize.height);
    BOOL downSizeTitle = (addedHeight > 130.0f || (titleSize.height > 85));
    if(downSizeTitle)
    {
        // title must shrink
        self.textLabel.font = kDownSizedTitleFont;
        titleSize = [self.textLabel sizeThatFits:CGSizeMake(w - 40, 1000)];
    }
    
    self.textLabel.frame = CGRectMake(20, offset, w-40, titleSize.height);
    offset += titleSize.height;
    if(downSizeTitle) offset -= 2;
    
    self.authorLabel.frame = CGRectMake(10, offset, w-20, authorSize.height);
    offset += authorSize.height + 5;
    
    CGFloat remainingSize = (b.size.height - offset);
    CGFloat paddingSum = (remainingSize - detailSize.height);
    CGFloat topAdjustment = 0.0f;
    if(paddingSum < 30)
    {
        // center
        topAdjustment = (remainingSize - detailSize.height) / 2.0f;
    }

    CGFloat h = MIN(b.size.height-offset, detailSize.height);
    self.detailTextView.frame = CGRectMake(7, offset + topAdjustment, w-14, h);
}

@end
