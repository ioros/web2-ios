//
//  TPAuthorInfoViewController.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPListModel.h"
#import "TPCollectionViewController.h"

@class TPAuthorInfoModel;
@class TPAuthorData;

@interface TPAuthorInfoViewController : UIViewController <UIWebViewDelegate, TPListModelDelegate, TPCollectionViewControllerDelegate>

@property (nonatomic, strong) TPAuthorData *data;
@property (nonatomic, retain) TPListModel *model;

@end
