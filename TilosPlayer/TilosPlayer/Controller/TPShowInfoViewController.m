//
//  TPShowInfoViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowInfoViewController.h"

#import "TPShowInfoModel.h"
#import "TPShowInfoHeaderView.h"

@interface TPShowInfoViewController ()

@end

@implementation TPShowInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[TPShowInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.headerView.textLabel.text = [self.data showName];
    self.headerView.detailTextView.text = [self.data showDefinition];
    [self.headerView.imageView setImageWithURL:[self.data episodeBannerUrl] placeholderImage:[UIImage imageNamed:@"DefaultBanner.png"]];

    if(self.data && self.model == nil)
    {
        self.model = [[TPShowInfoModel alloc] initWithParameters:[self.data objectForKeyOrNil:@"id"]];
        self.model.delegate = self;
    }
}

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [super listModelDidFinish:listModel];
   // TPShowInfoModel *model = (TPShowInfoModel *)self.model;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ShowEpisodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *episode = [self.model dataForIndexPath:indexPath];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    cell.textLabel.text = [formatter stringFromDate:[episode episodePlannedFromDate]];
}

#pragma mark -

- (TPShowInfoHeaderView *)headerView
{
    return (TPShowInfoHeaderView *)[self.tableView tableHeaderView];
}



@end
