//
//  TPEpisodeListCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListCell.h"

#define kTitleFont [UIFont systemFontOfSize:20]
#define kTextFont [UIFont systemFontOfSize:13]
#define kAuthorFont [UIFont boldSystemFontOfSize:11]

#define kTextGap 6.0f
#define kTitleGap 6.0f
#define kBottomGap 9.0f
#define kTopGap 9.0f


@implementation TPEpisodeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    self.textLabel.font = kTitleFont;

    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.font = kTextFont;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;

    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.timeLabel.backgroundColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.timeLabel];

    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.authorLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
    self.authorLabel.backgroundColor = [UIColor whiteColor];
    self.authorLabel.numberOfLines = 0;
    self.authorLabel.font = kAuthorFont;
    [self.contentView addSubview:self.authorLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    CGFloat offset = kTopGap;
    CGSize s;
    CGFloat textWidth = b.size.width - 80;
    
    s = [self.timeLabel sizeThatFits:CGSizeMake(55, 100)];
    self.timeLabel.frame = CGRectMake(0, kTopGap -3, 55, s.height);

    s = [self.textLabel sizeThatFits:CGSizeMake(textWidth, 100)];
    self.textLabel.frame = CGRectMake(60, offset, textWidth, s.height);
    offset += ceilf(s.height);

    if(self.detailTextLabel.text)
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
    CGSize s;
    CGFloat textWidth = width - 80;
    
    s = [title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(textWidth, 200) lineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
    offset += ceilf(s.height);
    
    if(description)
    {
        offset += kTitleGap;
        
        s = [description sizeWithFont:kTextFont constrainedToSize:CGSizeMake(textWidth, 200) lineBreakMode:NSLineBreakByWordWrapping |NSLineBreakByTruncatingTail];
        offset += ceilf(s.height);
    }

    if(authors)
    {
        offset += kTextGap;
        
        s = [authors sizeWithFont:kAuthorFont constrainedToSize:CGSizeMake(textWidth, 200) lineBreakMode:NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail];
        offset += ceilf(s.height);
    }

    offset += kBottomGap;
    
    return offset;
}

@end
