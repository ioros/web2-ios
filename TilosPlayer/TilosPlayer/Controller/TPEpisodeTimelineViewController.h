//
//  TPEpisodeTimelineViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 08/11/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPContinuousProgramModel.h"

@interface TPEpisodeTimelineViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, TPContinuousProgramModelDelegate>

@end
