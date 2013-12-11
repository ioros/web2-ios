//
//  TPEpisodeListCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListCell.h"

@implementation TPEpisodeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.timeLabel.backgroundColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    self.timeLabel.frame = CGRectMake(0, 0, 55, b.size.height);
    self.textLabel.frame = CGRectMake(60, 7, b.size.width - 80, 20);
    self.detailTextLabel.frame = CGRectMake(60, 27, b.size.width - 80, 20);
}

@end
