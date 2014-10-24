//
//  TPSecondViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowListViewController.h"

#import "TPShowListModel.h"
#import "TPShowData.h"

#pragma mark -

@implementation TPShowListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    self.title = @"";
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"All", nil), NSLocalizedString(@"Music", nil), NSLocalizedString(@"Talk", nil)]];
    segmentedControl.frame = CGRectMake(0, 0, 200, 25);
    segmentedControl.selectedSegmentIndex = 0;
    
    [segmentedControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
}

#pragma mark -

- (void)segmentSelected:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    if(index < 0) return;
    
    TPShowListModelFilter filter = TPShowListModelFilterAll;
    if(index == 1) filter = TPShowListModelFilterMusic;
    else if(index == 2) filter = TPShowListModelFilterTalk;
    
    [(TPShowListModel *)[self model] setFilter:filter];
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShowListCell";
    return [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPShowData *data = [self.model dataForIndexPath:indexPath];
    cell.textLabel.text = data.name;
    cell.detailTextLabel.text = data.definition;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    id data = [self.model dataForIndexPath:indexPath];
    
    UIViewController *destination = segue.destinationViewController;
    if([destination respondsToSelector:@selector(setData:)])
    {
        [destination performSelector:@selector(setData:) withObject:data];
    }
}

@end
