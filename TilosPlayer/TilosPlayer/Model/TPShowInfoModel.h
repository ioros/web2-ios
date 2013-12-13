//
//  TPShowInfoModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPListModel.h"

@interface TPShowInfoModel : TPListModel

@property (nonatomic, retain) AFJSONRequestOperation *operation;

@property (nonatomic, retain) NSDictionary *show;

@end
