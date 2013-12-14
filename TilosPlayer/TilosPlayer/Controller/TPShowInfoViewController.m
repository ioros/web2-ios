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

static const CGFloat titleWidth = 200.0f;

@implementation TPShowInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableHeaderView = [[TPShowInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleWidth, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.font = kTitleFont;
    self.navigationItem.titleView = label;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *showName = [self.data showName];
    UIFont *font = kTitleFont;
    CGSize s = [showName sizeWithFont:font];
    if(s.width > titleWidth){
        font = kHalfTitleFont;
    }
    
    self.titleLabel.font = font;
    self.titleLabel.text = showName;
    
    self.headerView.detailTextView.text = [self.data showDefinition];

    if(self.data && self.model == nil)
    {
        self.model = [[TPShowInfoModel alloc] initWithParameters:[self.data objectForKeyOrNil:@"id"]];
        self.model.delegate = self;
    }
}

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [super listModelDidFinish:listModel];
    TPShowInfoModel *model = (TPShowInfoModel *)self.model;
    [self.headerView.imageView setImageWithURL:[model.show showBannerUrl]];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *episode = [self.model dataForIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playEpisode" object:self userInfo:@{@"episode":episode}];
}

#pragma mark -

- (TPShowInfoHeaderView *)headerView
{
    return (TPShowInfoHeaderView *)[self.tableView tableHeaderView];
}
- (UILabel *)titleLabel
{
    return (UILabel *)[self.navigationItem titleView];
}



@end
