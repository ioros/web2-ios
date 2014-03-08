//
//  TPShowInfoModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPListModel.h"

@class TPShowData;

@interface TPShowInfoModel : TPListModel


@property (nonatomic, retain) AFHTTPRequestOperation *operation;

@property (nonatomic, retain) TPShowData *show;
@property (nonatomic, retain) NSString *htmlString;

@end
