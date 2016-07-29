//
//  TPAuthorCollectionCell.h
//  TilosPlayer
//
//  Created by Imre Oros on 08/06/16.
//  Copyright (c) 2016 Oros Imre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPCollectionCellFactory.h"

@interface TPAuthorCollectionCell : UICollectionViewCell <TPCollectionCellFactory>

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *label;

@end
