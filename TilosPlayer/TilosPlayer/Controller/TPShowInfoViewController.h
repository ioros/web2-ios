//
//  TPShowInfoViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPTableViewController.h"


@class TPEpisodeData;
@class TPShowData;

@interface TPShowInfoViewController : TPTableViewController <UIWebViewDelegate>

@property (nonatomic, retain) TPShowData *data;

@end
