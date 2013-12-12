//
//  TPEpisodeCollectionCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeCollectionCell.h"
#import "AFNetworking.h"

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
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.numberOfLines = -1;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:26];
    [self.contentView addSubview:self.textLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.imageView];
    
    self.detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    self.detailTextView.textAlignment = NSTextAlignmentCenter;
    self.detailTextView.font = [UIFont systemFontOfSize:13];
    self.detailTextView.backgroundColor = [UIColor clearColor];
    self.detailTextView.editable = NO;
    [self.contentView addSubview:self.detailTextView];
}

#pragma mark -

- (void)setData:(NSDictionary *)data
{
    _data = data;
    
    self.textLabel.text = [[data objectForKey:@"show"] objectForKey:@"name"];
    self.detailTextView.text = [[data objectForKey:@"show"] objectForKey:@"definition"];

    NSString *banner = [[data objectForKeyOrNil:@"show"] objectForKeyOrNil:@"banner"];
    NSString *url = [NSString stringWithFormat:@"http://tilos.anzix.net/upload/musorok/%@", banner];
    [self.imageView setImageWithURL:[NSURL URLWithString:url]];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect b = self.bounds;
    CGFloat w = b.size.width;
    CGFloat imageHeight = floorf(w/ 210.0f * 60.f);

    self.imageView.frame = CGRectMake(0, 0, w, imageHeight);
    
    CGSize s = [self.textLabel sizeThatFits:CGSizeMake(w - 40, 1000)];
    self.textLabel.frame = CGRectMake(20, 100, w-40, s.height);
    
    CGFloat offset = 100 + s.height;
    self.detailTextView.frame = CGRectMake(10, offset, w-20, b.size.height-offset);
}

@end
