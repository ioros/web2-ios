//
//  TPCollectionCellFactory.h
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TPCollectionCellFactory <NSObject>

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath data:(id)data;
- (void)registerClasses:(UICollectionView *)collectionView;

@end
