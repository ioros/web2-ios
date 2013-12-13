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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    
    CGFloat imageWidth = b.size.height;
    CGFloat textWidth = b.size.width - imageWidth - 25;
    
    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageWidth);
    self.textLabel.frame = CGRectMake(imageWidth + 10, (b.size.height - 17)/2, textWidth, 20);
    //self.detailTextLabel.frame = CGRectMake(60, 27, b.size.width - 80, 20);
}
@end
