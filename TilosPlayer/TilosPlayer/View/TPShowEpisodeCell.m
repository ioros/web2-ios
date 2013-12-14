//
//  TPShowEpisodeCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 14/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowEpisodeCell.h"

@implementation TPShowEpisodeCell

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
    self.textLabel.font = kDescFont;
}

@end
