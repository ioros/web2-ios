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
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.font = kSubSubFont;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.dateLabel];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
//    self.imageView.layer.cornerRadius = 5.0f;
//    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.backgroundColor = [UIColor clearColor];
    self.detailLabel.font = kDescFont;
    self.detailLabel.numberOfLines = -1;
    self.detailLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.detailLabel];
    
    /*
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
    */
    self.contentView.layer.cornerRadius = 10.0;
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
}

#pragma mark -

- (void)setEpisode:(TPEpisodeData *)episode
{
    _episode = episode;
    
    /*
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:episode.name attributes:nil];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:-10];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragrahStyle, U} range:NSMakeRange(0, attributedString.length)];
    
    self.textLabel.attributedText = attributedString;
    */
    
    self.textLabel.text = episode.name;
    
    NSArray *nicknames = [episode.show contributorNicknames];
    self.authorLabel.text = [nicknames componentsJoinedByString:@", "];
    
    self.detailLabel.text = episode.definition;
    
    NSDate *startDate = episode.plannedFrom;
    NSDate *endDate = episode.plannedTo;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startComponents = [calendar components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:startDate];
    NSDateComponents *endComponents = [calendar components:(NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:endDate];

    NSDateFormatter *startFormatter = [NSDateFormatter new];
    startFormatter.dateFormat = @"MMM dd. HH:mm";
    NSDateFormatter *endFormatter = [NSDateFormatter new];
    endFormatter.dateFormat = @"HH:mm";
    
    NSString *label = nil;
    if(startComponents.year == endComponents.year && startComponents.month == endComponents.month && startComponents.day == endComponents.day)
    {
        label = [NSString stringWithFormat:@"%@ - %@", [startFormatter stringFromDate:startDate], [endFormatter stringFromDate:endDate]];
    }
    else
    {
        label = [NSString stringWithFormat:@"%@ - %@", [startFormatter stringFromDate:startDate], [startFormatter stringFromDate:endDate]];
    }
    self.dateLabel.text = label;
    
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

    CGFloat titleMarginTop = 5;
    CGFloat dateMarginTop = 3;
    CGFloat authorMarginTop = 0;
    CGFloat detailMarginTop = 7;
    CGFloat bottomMargin = 4;

    ////////////
    
    self.contentView.frame = CGRectInset(self.bounds, 20, 0);

    CGRect b = self.contentView.bounds;
    CGFloat w = b.size.width;
    CGFloat imageWidth = w;
    CGFloat imageHeight = floorf(imageWidth/ 210.0f * 60.f);

    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    CGFloat offset = imageHeight + titleMarginTop;

    self.textLabel.font = kTitleFont;
    
    /////////////////////////
    
    CGSize titleSize = [self.textLabel sizeThatFits:CGSizeMake(w - 40, 1000)];
    CGSize dateSize = [self.dateLabel sizeThatFits:CGSizeMake(w-40, 20)];
    CGSize authorSize = [self.authorLabel sizeThatFits:CGSizeMake(w-20, 20)];
    CGSize detailSize = [self.detailLabel sizeThatFits:CGSizeMake(w-20, 1000)];
    
    
    CGFloat fullHeight = titleSize.height + dateMarginTop + dateSize.height + authorMarginTop + authorSize.height + detailSize.height + detailMarginTop + bottomMargin;
    CGFloat remainingHeight = b.size.height - offset;
    
    if(remainingHeight < fullHeight)
    {
        // title must shrink
        self.textLabel.font = kDownSizedTitleFont;
        titleSize = [self.textLabel sizeThatFits:CGSizeMake(w - 40, 1000)];
    }
    fullHeight = titleSize.height + dateMarginTop + dateSize.height + authorMarginTop + authorSize.height + detailSize.height + detailMarginTop + bottomMargin;

    // center vertically
    offset += ((b.size.height -offset) - MIN(fullHeight, remainingHeight) )/2.0f;
    
    // nothing to do
    self.textLabel.frame = CGRectMake(20, offset, w-40, titleSize.height);
    offset += titleSize.height;
    
    self.dateLabel.frame = CGRectMake(20, offset, w-40, dateSize.height);
    offset += dateSize.height;
    
    self.authorLabel.frame = CGRectMake(10, offset, w-20, authorSize.height);
    offset += authorSize.height + detailMarginTop;
    
    self.detailLabel.frame = CGRectMake(10, offset, w-20, MIN(b.size.height - offset, detailSize.height));
}

@end
