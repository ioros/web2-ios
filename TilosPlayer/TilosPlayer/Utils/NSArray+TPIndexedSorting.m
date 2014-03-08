//
//  NSArray+TPIndexedSorting.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "NSArray+TPIndexedSorting.h"

@implementation NSArray (TPIndexedSorting)

- (NSDictionary *)indexesWithSortingKey:(NSString *)key ascending:(BOOL)ascending
{
    NSArray *authors = [self sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending selector:@selector(caseInsensitiveCompare:)]]];
    
    NSMutableDictionary *sections = [NSMutableDictionary dictionary];
    
    NSString *lastLabel = nil;
    NSMutableArray *lastSectionItems = nil;
    
    for(NSDictionary *author in authors)
    {
        NSString *name = [[author valueForKey:key] uppercaseString];
        NSString *firstLetter = name.length > 0 ? [name substringToIndex:1] : @"-";
        if(![lastLabel isEqualToString:firstLetter])
        {
            lastSectionItems = [NSMutableArray array];
            [sections setObject:lastSectionItems forKey:firstLetter];
            lastLabel = firstLetter;
        }
        [lastSectionItems addObject:author];
    }
    
    return sections;
}

@end
