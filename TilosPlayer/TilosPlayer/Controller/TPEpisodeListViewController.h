//
//  TPEpisodeListViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPTableViewController.h"

#import "TPListModel.h"

@interface TPEpisodeListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TPListModelDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) TPListModel *model;

@end
