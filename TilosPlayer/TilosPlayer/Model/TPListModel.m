//
//  TPListModel.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPListModel.h"

@implementation TPListSection

+ (id)sectionWithTitle:(NSString *)title items:(NSArray *)items
{
    return [[TPListSection alloc] initWithTitle:title items:items];
}

- (id)initWithTitle:(NSString *)title items:(NSArray *)items
{
    self = [super init];
    if(self)
    {
        self.title = title;
        self.items = items;
    }
    return self;
}

@end


@implementation TPListModel


#pragma mark -

- (id)initWithParameters:(id)parameters
{
    self = [super init];
    if(self)
    {
        self.parameters = parameters;
    }
    return self;
}

- (void)loadForced:(BOOL)forced
{
    [self sendFinished];
}
- (void)cancel
{
    // override this
}

- (void)clear
{
    [self cancel];
    self.sections = nil;
}

#pragma mark -

- (id)dataForIndexPath:(NSIndexPath *)indexPath
{
    return [self dataForRow:indexPath.row section:indexPath.section];
}

- (id)dataForRow:(NSInteger)row section:(NSInteger)section
{
    return [[(TPListSection *)[self.sections objectAtIndex:section] items] objectAtIndex:row];
}

- (NSInteger)numberOfSections
{
    return self.sections.count;
}
- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    TPListSection *s = [self.sections objectAtIndex:section];
    return s.items.count;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    TPListSection *s = [self.sections objectAtIndex:section];
    return s.title;
}

- (NSArray *)sectionIndexTitles
{
    return self.indexTitles;
}

#pragma mark - delegate helpers

- (void)sendFinished
{
    if([_delegate respondsToSelector:@selector(listModelDidFinish:)])
    {
        [_delegate performSelector:@selector(listModelDidFinish:) withObject:self];
    }
}
- (void)sendError:(NSError *)error
{
    if([_delegate respondsToSelector:@selector(listModel:didFailWithError:)])
    {
        [_delegate performSelector:@selector(listModel:didFailWithError:) withObject:self withObject:error];
    }
}

@end
