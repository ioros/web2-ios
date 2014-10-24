//
//  TPShowCollectionCell.h
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPCollectionCellFactory.h"

@interface TPShowCollectionCell : UICollectionViewCell <TPCollectionCellFactory>

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *label;

@end
