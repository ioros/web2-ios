//
//  TPShowListModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPListModel.h"

@class AFJSONRequestOperation;

@interface TPShowListModel : TPListModel

@property (nonatomic, retain) AFJSONRequestOperation *operation;

@end