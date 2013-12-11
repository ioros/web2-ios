//
//  TPTableViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPTableViewController.h"

@implementation TPTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    if(self.model)
    {
        [self.model loadForced:NO];
    }
}

- (void)setModel:(TPListModel *)model
{
    _model.delegate = nil;
    _model = model;
    _model.delegate = self;
    if(self.isViewLoaded)
    {
        [self.model loadForced:NO];
    }
}

#pragma mark -

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [self.tableView reloadData];
}
- (void)listModel:(TPListModel *)listModel didFailWithError:(NSError *)error
{
    NSLog(@"error %@", error);
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.model numberOfSections];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.model titleForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.model numberOfRowsInSection:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if([self.model respondsToSelector:@selector(sectionIndexTitles)])
    {
        return [self.model performSelector:@selector(sectionIndexTitles)];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    id data = [self.model dataForIndexPath:indexPath];
    cell.textLabel.text = [data description];
    
    return cell;
}

@end
