//
//  TPEpisodeCollectionCell.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPEpisodeCollectionCell : UICollectionViewCell

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UITextView *detailTextView;

@end
