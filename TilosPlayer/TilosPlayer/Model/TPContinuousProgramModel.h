//
//  TPContinuousProgramModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 18/02/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPContinuousProgramModel : NSObject

@property (nonatomic, retain) NSMutableArray *episodes;
@property (nonatomic, assign) id delegate;

- (void)loadTail;
- (void)loadHead;

- (void)jumpToDate:(NSDate *)date;


@end
