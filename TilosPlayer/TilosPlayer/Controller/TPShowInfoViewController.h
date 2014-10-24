//
//  TPShowInfoViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPListModel.h"

@class TPEpisodeData;
@class TPShowData;

@interface TPShowInfoViewController : UIViewController <TPListModelDelegate, UIWebViewDelegate>

@property (nonatomic, retain) TPShowData *data;
@property (nonatomic, retain) TPListModel *model;

@end
