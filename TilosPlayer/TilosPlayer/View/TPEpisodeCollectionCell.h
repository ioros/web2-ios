//
//  TPEpisodeCollectionCell.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPEpisodeData;

@interface TPEpisodeCollectionCell : UICollectionViewCell

@property (nonatomic, retain) TPEpisodeData *episode;

@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UITextView *detailTextView;

@property (nonatomic, retain) AFHTTPRequestOperation *operation;

@end
