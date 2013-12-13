//
//  TPModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPModel.h"

@implementation TPModel

- (void)loadForced:(BOOL)forced
{
    [self sendFinished];
}
- (void)cancel
{
}

- (id)initWithParameters:(id)parameters
{
    self = [super init];
    if(self)
    {
        self.parameters = parameters;
    }
    return self;
}


#pragma mark - delegate helpers

- (void)sendFinished
{
    if([_delegate respondsToSelector:@selector(modelDidFinish:)])
    {
        [_delegate performSelector:@selector(modelDidFinish:) withObject:self];
    }
}
- (void)sendError:(NSError *)error
{
    if([_delegate respondsToSelector:@selector(model:didFailWithError:)])
    {
        [_delegate performSelector:@selector(model:didFailWithError:) withObject:self withObject:error];
    }
}

@end
