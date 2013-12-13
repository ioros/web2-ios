//
//  TPModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPModel;

@protocol  TPModelDelegate <NSObject>

@optional
- (void)modelDidFinish:(TPModel *)listModel;
- (void)model:(TPModel *)listModel didFailWithError:(NSError *)error;

@end

@interface TPModel : NSObject

@property (nonatomic, assign) id<TPModelDelegate> delegate;
@property (nonatomic, retain) id parameters;

- (void)loadForced:(BOOL)forced;
- (void)cancel;

- (void)sendFinished;
- (void)sendError:(NSError *)error;

- (id)initWithParameters:(id)parameters;

@end
