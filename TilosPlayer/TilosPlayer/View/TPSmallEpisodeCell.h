//
//  TPSmallEpisodeCell.h
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPCollectionCellFactory.h"

@interface TPSmallEpisodeCell : UICollectionViewCell <TPCollectionCellFactory>

@property (nonatomic, retain) UILabel *label;

@end
