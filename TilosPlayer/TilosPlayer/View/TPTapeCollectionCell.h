//
//  TPTapeCollectionCell.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TPTapeCollectionCellTypeInactive,
    TPTapeCollectionCellTypeStart,
    TPTapeCollectionCellTypeEnd,
    TPTapeCollectionCellTypeActive
} TPTapeCollectionCellType;

@interface TPTapeCollectionCell : UICollectionViewCell

@property (nonatomic, retain) NSString *activeText;
@property (nonatomic, assign) TPTapeCollectionCellType type;

@end
