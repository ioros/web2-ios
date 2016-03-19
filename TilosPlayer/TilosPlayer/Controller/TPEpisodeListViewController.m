//
//  TPEpisodeListViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListViewController.h"
#import "TPEpisodeListCell.h"
#import <CoreText/CoreText.h>
#import "TPEpisodeListModel.h"
#import "TPFlipLabelView.h"
#import "NSDate+TPAdditions.h"
#import "TPTimestampView.h"
#import "TPEpisodeData.h"

@interface TPEpisodeListViewController ()

@property (nonatomic, retain) UIImageView *pagerView;
@property (nonatomic, assign) BOOL scrollToEndWhenLoaded;

@end

#pragma mark -


static const CGFloat PULL_OFFSET = 60.0f;
static const int DAY_SECONDS = 60 * 60 * 24;


@implementation TPEpisodeListViewController

- (void)loadView
{
    CGRect frame = CGRectMake(0, 0, 320, 480);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.contentInset = UIEdgeInsetsMake(7, 0, 0, 0);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[TPEpisodeListCell class] forCellReuseIdentifier:@"EpisodeListCell"];
    self.tableView = tableView;
    
    [self.view addSubview:self.tableView];
    
    self.pagerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.pagerView.opaque = YES;
        
    self.scrollToEndWhenLoaded = NO;
}

- (void)viewDidLoad
{
    NSLog(@"TPEpisodeListViewController");
    [super viewDidLoad];
    
//    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 22)];
//    textField.text = @"dátum";
//    textField.font = [UIFont boldSystemFontOfSize:19];
//    textField.textAlignment = NSTextAlignmentCenter;
//    self.navigationItem.titleView = textField;
    
    self.navigationItem.titleView = [[TPFlipLabelView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    self.tableView.rowHeight = 100;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

    if(self.model == nil)
    {
        self.model = [[TPEpisodeListModel alloc] initWithParameters:[NSDate date]];
    }
    
    [self.flipLabelView setText:[self.episodeListModel.date dayName]];

    [self.model loadForced:NO];
}

#pragma mark -

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
    
    // update position in tableview
    if(_scrollToEndWhenLoaded)
    {
        _scrollToEndWhenLoaded = NO;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_model numberOfRowsInSection:0]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    else
    {
        if([self.model numberOfSections] > 0 && [self.model numberOfRowsInSection:0] > 0)
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}
- (void)listModel:(TPListModel *)listModel didFailWithError:(NSError *)error
{
    // TODO: handle this case
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.model numberOfRowsInSection:section];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.model numberOfSections];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPEpisodeData *episode = [self.model dataForIndexPath:indexPath];
//    CGFloat height = [TPEpisodeListCell estimatedHeightWithTitle:episode.name description:episode.definition authors:[episode.contributorNicknames componentsJoinedByString:@", "] forWidth:320];
    CGFloat height = [TPEpisodeListCell estimatedHeightWithTitle:episode.name description:episode.title authors:[episode.contributorNicknames componentsJoinedByString:@", "] forWidth:320];
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpisodeListCell";
    return [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPEpisodeListCell *episodeCell = (TPEpisodeListCell *)cell;
    
    TPEpisodeData *episode = [self.model dataForIndexPath:indexPath];
    episodeCell.textLabel.text = episode.name;
    episodeCell.authorLabel.text = [episode.contributorNicknames componentsJoinedByString:@", "];
//    episodeCell.detailTextLabel.text = episode.definition;
    episodeCell.detailTextLabel.text = episode.title;
    episodeCell.timestampView.seconds = episode.startSeconds;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"playepisode");
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TPEpisodeData *episode = [self.model dataForIndexPath:indexPath];
    NSLog(@"%@",episode);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playEpisode" object:self userInfo:@{@"episode":episode}];
}

#pragma mark -

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat scrollHeight = scrollView.frame.size.height;
    if(offset < -PULL_OFFSET)
    {
        [self prevDay];
    }
    else if(offset > (contentHeight - scrollHeight + PULL_OFFSET))
    {
        [self nextDay];
    }
}

#pragma mark -

- (void)prevDay
{
    [self updateScreenshot];
    
    NSDate *d = [self.episodeListModel.date dateByAddingTimeInterval:-DAY_SECONDS];
    
    _scrollToEndWhenLoaded = YES;
    
    [self.model clear];
    [self.tableView reloadData];
    [(TPEpisodeListModel *)[self model] loadWithDate:d];
    [self.flipLabelView setText:[d dayName] fromTop:NO];
    
    [self animatePaging:NO];
}
- (void)nextDay
{
    [self updateScreenshot];
    
    NSDate *d = [self.episodeListModel.date dateByAddingTimeInterval:DAY_SECONDS];
    
    _scrollToEndWhenLoaded = NO;
    
    [self.model clear];
    [self.tableView reloadData];
    [(TPEpisodeListModel *)self.model loadWithDate:d];
    [self.flipLabelView setText:[d dayName] fromTop:YES];
    
    [self animatePaging:YES];
}

- (void)updateScreenshot
{
    CGRect b = self.tableView.bounds;
    
	if(&UIGraphicsBeginImageContextWithOptions != NULL)
	{
		UIGraphicsBeginImageContextWithOptions(b.size, YES, 0.0);
	}
	else
	{
		UIGraphicsBeginImageContext(b.size);
	}
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
	_pagerView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)animatePaging:(BOOL)forward
{
    _pagerView.frame = self.view.bounds;
    self.tableView.contentOffset = CGPointMake(0, 0);
    
    if(forward)
    {
        self.tableView.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 1.5f);
    }
    else
    {
        self.tableView.center = CGPointMake(self.view.bounds.size.width * 0.5, -self.view.bounds.size.height * 0.5f);
    }
    
    [self.view addSubview:_pagerView];
    [UIView beginAnimations:@"paging" context:nil];
    [UIView setAnimationDuration:0.5];
    self.tableView.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5f);
    if(forward)
    {
        _pagerView.center = CGPointMake(self.view.bounds.size.width * 0.5, -self.view.bounds.size.height * 0.5f);
    }
    else
    {
        _pagerView.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 1.5f);
    }
    [UIView commitAnimations];
}

#pragma mark -

- (TPFlipLabelView *)flipLabelView
{
    return (TPFlipLabelView *)[self.navigationItem titleView];
}

- (TPEpisodeListModel *)episodeListModel
{
    return (TPEpisodeListModel *)[self model];
}

@end
