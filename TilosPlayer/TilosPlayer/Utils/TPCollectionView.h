//
//  TPCollectionView.h
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    TPScrollStateNormal,
    TPScrollStateDragging,
    TPScrollStateAnimating,
} TPScrollState;

@interface TPCollectionView : UICollectionView

@end
