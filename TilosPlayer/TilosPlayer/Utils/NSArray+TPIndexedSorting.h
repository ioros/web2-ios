//
//  NSArray+TPIndexedSorting.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TPIndexedSorting)

- (NSDictionary *)indexesWithSortingKey:(NSString *)key ascending:(BOOL)ascending;

@end
