//
//  TPTableViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPListModel.h"

@interface TPTableViewController : UITableViewController <TPListModelDelegate>

@property (nonatomic, retain) IBOutlet TPListModel *model;

@end
