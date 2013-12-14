//
//  TPEpisodeListCell.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPTimestampView;

@interface TPEpisodeListCell : UITableViewCell

@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) TPTimestampView *timestampView;

+ (CGFloat)estimatedHeightWithTitle:(NSString *)title
                        description:(NSString *)description
                            authors:(NSString *)authors
                           forWidth:(CGFloat)width;

@end
