//
//  TPEpisodeListCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListCell.h"

#import "TPTimestampView.h"

static const CGFloat kTextGap = 6.0f;
//static const CGFloat kTitleGap = 6.0f;
static const float kTitleGap = 6.0f;
//static const CGFloat kTopGap = 10.0f;
static const float kTopGap = 10.0f;
static const CGFloat kBottomGap = 9.0f;

@implementation TPEpisodeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
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
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
//    self.textLabel.font = kTitleFont;
    self.textLabel.font = kBoldFont;

    self.detailTextLabel.numberOfLines = 0;
//    self.detailTextLabel.font = kDescFont;
    self.detailTextLabel.font = kSubSubFont;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;

    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.authorLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
    self.authorLabel.backgroundColor = [UIColor whiteColor];
    self.authorLabel.numberOfLines = 0;
    self.authorLabel.font = kSubFont;
    [self.contentView addSubview:self.authorLabel];
    
    self.timestampView = [[TPTimestampView alloc] initWithFrame:CGRectMake(7, 10, 50, 50)];
    [self.contentView addSubview:self.timestampView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    CGFloat offset = kTopGap;
    CGSize s;
    CGFloat textWidth = b.size.width - 80;
    
    s = [self.textLabel sizeThatFits:CGSizeMake(textWidth, 200)];
//    self.textLabel.frame = CGRectMake(60, offset + 26 - s.height/2, textWidth, s.height);
    self.textLabel.frame = CGRectMake(60, offset, textWidth, s.height);
    offset += ceilf(s.height);

    if(![self.detailTextLabel.text  isEqual: @""])
    {
        offset += kTitleGap;
        s = [self.detailTextLabel sizeThatFits:CGSizeMake(textWidth, 200)];
        self.detailTextLabel.frame = CGRectMake(60, offset, textWidth, s.height);
        offset += ceilf(s.height);
    }
    if(self.authorLabel.text)
    {
        offset += kTextGap;
        s = [self.authorLabel sizeThatFits:CGSizeMake(textWidth, 200)];
        self.authorLabel.frame = CGRectMake(60, offset, textWidth, s.height);
    }
}

+ (CGFloat)estimatedHeightWithTitle:(NSString *)title description:(NSString *)description authors:(NSString *)authors forWidth:(CGFloat)width
{
    CGFloat offset = kTopGap;
//    float offset = kTopGap;
//    CGSize s;
    CGRect s;
    NSStringDrawingOptions options;
    NSDictionary *attributDict;

    CGFloat textWidth = width - 80;
    
//    s = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(textWidth, 200) lineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
//    offset += ceilf(s.height);
    options = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
//    attributDict = @{NSFontAttributeName: kTitleFont};
    attributDict = @{NSFontAttributeName: kBoldFont};
    s = [title boundingRectWithSize:CGSizeMake(textWidth, 200) options:options attributes:attributDict context:nil];
    offset += ceilf(s.size.height);
    
    
    if(![description isEqual:@""])
    {
        offset += kTitleGap;
        
//        s = [description sizeWithFont:kDescFont constrainedToSize:CGSizeMake(textWidth, 200) lineBreakMode:NSLineBreakByWordWrapping |NSLineBreakByTruncatingTail];
//        offset += ceilf(s.height);
//        attributDict = @{NSFontAttributeName: kDescFont};
        attributDict = @{NSFontAttributeName: kSubSubFont};
        s = [description boundingRectWithSize:CGSizeMake(textWidth, 200) options:options attributes:attributDict context:nil];
        offset += ceilf(s.size.height);
        
    }

    if(authors)
    {
        offset += kTextGap;
        
//        s = [authors sizeWithFont:kSubFont constrainedToSize:CGSizeMake(textWidth, 200) lineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
        attributDict = @{NSFontAttributeName: kSubFont};
        s = [authors boundingRectWithSize:CGSizeMake(textWidth, 200) options:options attributes:attributDict context:nil];
        offset += ceilf(s.size.height);
    }

    offset += kBottomGap;
    
    return offset;
}

@end
