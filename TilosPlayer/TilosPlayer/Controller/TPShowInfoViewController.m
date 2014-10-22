//
//  TPShowInfoViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowInfoViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "TPShowInfoModel.h"
#import "TPShowInfoHeaderView.h"
#import "TPEpisodeData.h"
#import "TPShowData.h"
#import "TPShowInfoHeaderView.h"

static const CGFloat titleWidth = 200.0f;

@interface TPShowInfoViewController ()

@property (nonatomic, retain) TPShowInfoHeaderView *headerView;
@property (nonatomic, retain) UIWebView *webView;

@end

#pragma mark -

@implementation TPShowInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.headerView = [[TPShowInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.tableView.tableHeaderView = self.headerView;
    [_headerView.segmentedControl addTarget:self action:@selector(headerViewSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [_headerView.segmentedControl setSelectedSegmentIndex:0];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleWidth, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.font = kTitleFont;
    self.navigationItem.titleView = label;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 180, 320.0, 1.0)];
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    /// try to size that label a little
    
    NSString *showName = self.data.name;
    UIFont *font = kTitleFont;
    CGSize s = [showName sizeWithFont:font];
    if(s.width > titleWidth){
        font = kHalfTitleFont;
    }
    self.titleLabel.font = font;
    self.titleLabel.text = showName;
    
    /////////////////////////////////////
    
    self.headerView.detailTextView.text = self.data.definition;
    [self.headerView sizeToFit];
    self.tableView.tableHeaderView = self.headerView;
    
    //////////////////////////////////////

    if(self.data && self.model == nil)
    {
        self.model = [[TPShowInfoModel alloc] initWithParameters:self.data.identifier];
        self.model.delegate = self;
    }
}

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [super listModelDidFinish:listModel];

    TPShowInfoModel *model = (TPShowInfoModel *)self.model;
    [self.headerView.imageView setImageWithURL:[NSURL URLWithString:model.show.bannerURL]];
    
    if(model.htmlString)
    {
        [self.webView loadHTMLString:model.htmlString baseURL:[NSURL URLWithString:@"http://tilos.hu/"]];
    }
}

#pragma mark -

- (void)headerViewSegmentChanged:(UISegmentedControl*)segmentedControl
{
    if(segmentedControl.selectedSegmentIndex == 0)
    {
        self.tableView.scrollEnabled = YES;
        self.tableView.tableHeaderView = self.headerView;
        [self.webView removeFromSuperview];
    }
    else
    {
        self.tableView.scrollEnabled = NO;
        self.tableView.contentOffset = CGPointZero;
        self.tableView.tableHeaderView = nil;
        
        CGFloat headerHeight = self.headerView.bounds.size.height;
        
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        CGRect headerRect = self.headerView.frame;
        headerRect.origin.x = 0;
        headerRect.origin.y = -headerHeight;
        self.headerView.frame = headerRect;
        
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerHeight + self.topLayoutGuide.length, 0, 0, 0);
        self.webView.scrollView.contentOffset = CGPointMake(0, -headerHeight - self.topLayoutGuide.length);
        [self.webView.scrollView addSubview:self.headerView];
        self.webView.frame = self.tableView.bounds;
        [self.tableView addSubview:self.webView];
    }
}


#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *showCellId = @"ShowEpisodeCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:showCellId forIndexPath:indexPath];
    TPEpisodeData *episode = [self.model dataForIndexPath:indexPath];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    cell.textLabel.text = [formatter stringFromDate:episode.plannedFrom];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *episode = [self.model dataForIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playEpisode" object:self userInfo:@{@"episode":episode}];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


#pragma mark -

- (UILabel *)titleLabel
{
    return (UILabel *)[self.navigationItem titleView];
}

#pragma mark - WebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
            [[UIApplication sharedApplication] openURL:[inRequest URL]];
            return NO;
    }
    
    return YES;
}

@end
