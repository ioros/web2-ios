//
//  TPPlayerViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPListModel.h"

@interface TPPlayerViewController : UIViewController <TPListModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) IBOutlet UICollectionView *tapeCollectionView;
@property (nonatomic, retain) TPListModel *model;

- (IBAction)close:(id)sender;

@end
