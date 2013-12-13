//
//  TPAuthorListCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorListCell.h"

@implementation TPAuthorListCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    CGFloat textWidth = b.size.width - 80;
    
    self.imageView.frame = CGRectMake(0, 0, 50, 50);
    self.textLabel.frame = CGRectMake(60, 15, textWidth, 20);
    //self.detailTextLabel.frame = CGRectMake(60, 27, b.size.width - 80, 20);
}
@end
