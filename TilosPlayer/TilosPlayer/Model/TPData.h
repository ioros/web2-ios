//
//  TPData.h
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPData : NSObject

+ (instancetype)parseWithObject:(NSDictionary *)object;
+ (NSArray *)parseWithObjects:(NSArray *)objects;

@end
