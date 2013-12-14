//
//  TPShowListModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPListModel.h"


typedef enum {
    TPShowListModelFilterAll,
    TPShowListModelFilterMusic,
    TPShowListModelFilterTalk
} TPShowListModelFilter;

@interface TPShowListModel : TPListModel

@property (nonatomic, retain) AFHTTPRequestOperation *operation;
@property (nonatomic, assign) TPShowListModelFilter filter;

@property (nonatomic, retain) id data;

@end
