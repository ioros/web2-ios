//
//  TPAuthorInfoViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPTableViewController.h"

@class TPAuthorInfoModel;
@class TPAuthorData;

@interface TPAuthorInfoViewController : TPTableViewController

@property (nonatomic, strong) TPAuthorData *author;
@property (nonatomic, strong) TPAuthorInfoModel *authorModel;

@end
