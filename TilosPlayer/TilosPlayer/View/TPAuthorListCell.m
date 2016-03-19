//
//  TPAuthorListCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorListCell.h"

@implementation TPAuthorListCell

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
    self.textLabel.font = kListFont;
    self.imageView.layer.cornerRadius = 20.0f;
    self.imageView.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    
    CGFloat imageWidth = b.size.height - 10;
    CGFloat textWidth = b.size.width - imageWidth - 25;
    
    self.imageView.frame = CGRectMake(5, 5, imageWidth, imageWidth);
    
//    self.textLabel.frame = CGRectMake(imageWidth + 15, (b.size.height-20)/2.0f, textWidth, 20);
    
    self.textLabel.frame = CGRectMake(imageWidth + 10, 7, textWidth, 20);
    self.detailTextLabel.frame = CGRectMake(imageWidth + 10, 27, textWidth, 20);
}
@end
