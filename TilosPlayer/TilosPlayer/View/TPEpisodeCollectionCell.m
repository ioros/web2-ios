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
    UIView *v = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
    v.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0f];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:v];

    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.numberOfLines = 0;
    self.textLabel.font = [UIFont systemFontOfSize:26];
    [self.contentView addSubview:self.textLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.imageView];
    
    self.detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    self.detailTextView.backgroundColor = [UIColor clearColor];
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
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect b = self.bounds;
    CGFloat w = b.size.width - 20;
    CGFloat imageHeight = floorf(w/ 210.0f * 60.f);

    /*
    self.imageView.frame = CGRectMake(0, 0, b.size.width, imageHeight);
    CGSize s = [self.textLabel sizeThatFits:CGSizeMake(b.size.width - 30, 1000)];
    self.textLabel.frame = CGRectMake(0, imageHeight, b.size.width-30, s.height);
    self.detailTextView.frame = CGRectMake(12, imageHeight + s.height, b.size.width-24, b.size.height-135);
*/

    self.imageView.frame = CGRectMake(10, 10, w, imageHeight);
    CGSize s = [self.textLabel sizeThatFits:CGSizeMake(w -10, 1000)];
    self.textLabel.frame = CGRectMake(15, 100, w-10, s.height);
    self.detailTextView.frame = CGRectMake(12, 130, w-4, b.size.height-135);
}

@end
