//
//  TPShowInfoViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPTableViewController.h"


@class TPShowInfoHeaderView;

@interface TPShowInfoViewController : TPTableViewController

@property (nonatomic, retain) id data;
@property (nonatomic, readonly) TPShowInfoHeaderView *headerView;

@property (nonatomic, readonly) UILabel *titleLabel;

@end
