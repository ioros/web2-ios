//
//  TPEpisodeListModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPListModel.h"

@interface TPEpisodeListModel : TPListModel

@property (nonatomic, retain) AFHTTPRequestOperation *operation;

@property (nonatomic, retain) NSDate *date;
- (void)loadWithDate:(NSDate *)date;

@end
