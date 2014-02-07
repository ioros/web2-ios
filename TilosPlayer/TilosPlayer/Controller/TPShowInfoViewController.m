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
#import <SDWebImage/UIImageView+WebCache.h>
#import "TPWebIntroductionCell.h"

static const CGFloat titleWidth = 200.0f;

typedef NS_ENUM(NSInteger, ShownInfoType){
    kInfoTypeWeb,
    kInfoTypeShows
};

@interface TPShowInfoViewController () <UIWebViewDelegate>

@end

@implementation TPShowInfoViewController{
    TPShowInfoHeaderView *_headerView;
    UIWebView *_infoWebView;
    ShownInfoType _shownInfoType;
    TPShowInfoModel *_model;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _headerView = [[TPShowInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.tableView.tableHeaderView = _headerView;
    [_headerView.segmentedControl addTarget:self action:@selector(headerViewSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [_headerView.segmentedControl setSelectedSegmentIndex:0];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleWidth, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.font = kTitleFont;
    self.navigationItem.titleView = label;
    
    _shownInfoType = kInfoTypeShows;
    
    _infoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 180, 320.0, 1.0)];

}

-(void)headerViewSegmentChanged:(UISegmentedControl*)segmentedControl{
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        _shownInfoType = kInfoTypeShows;
    }
    else{
        _shownInfoType = kInfoTypeWeb;
    }
    
    [self.tableView reloadData];
    
    
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_shownInfoType == kInfoTypeWeb) {
        return 1.0;
    }
    else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    /// try to size that label a little
    
    NSString *showName = [self.data showName];
    UIFont *font = kTitleFont;
    CGSize s = [showName sizeWithFont:font];
    if(s.width > titleWidth){
        font = kHalfTitleFont;
    }
    self.titleLabel.font = font;
    self.titleLabel.text = showName;
    
    /////////////////////////////////////
    
    self.headerView.detailTextView.text = [self.data showDefinition];
    [self.headerView sizeToFit];
    self.tableView.tableHeaderView = self.headerView;

    if(self.data && self.model == nil)
    {
        self.model = [[TPShowInfoModel alloc] initWithParameters:[self.data objectForKeyOrNil:@"id"]];
        self.model.delegate = self;
    }
    
    //TODO
}

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [super listModelDidFinish:listModel];
    _model = (TPShowInfoModel *)self.model;
    [self.headerView.imageView setImageWithURL:[_model.show showBannerUrl]];
    
    if(_model.htmlString) {
        [_infoWebView loadHTMLString:_model.htmlString baseURL:nil];
    }
    else{
        _headerView.segmentedControl.enabled = NO;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *showCellId = @"ShowEpisodeCell";
    static NSString *webViewCellId = @"IntroductionCell";
    
    if (_shownInfoType == kInfoTypeWeb) {
        TPWebIntroductionCell *cell = [tableView dequeueReusableCellWithIdentifier:webViewCellId forIndexPath:indexPath];
        
        [cell.introductionWebView loadHTMLString:_model.htmlString baseURL:nil];
        cell.introductionWebView.scrollView.scrollEnabled = NO;
        
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:showCellId forIndexPath:indexPath];
        NSDictionary *episode = [self.model dataForIndexPath:indexPath];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        cell.textLabel.text = [formatter stringFromDate:[episode episodePlannedFromDate]];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *episode = [self.model dataForIndexPath:indexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playEpisode" object:self userInfo:@{@"episode":episode}];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_shownInfoType == kInfoTypeWeb) {
        CGFloat height = [[_infoWebView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
        
        return height;
    }

    return 44;
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

#pragma mark - WebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_shownInfoType == kInfoTypeWeb) {
        [self.tableView reloadData];
    }
}


-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
            [[UIApplication sharedApplication] openURL:[inRequest URL]];
            return NO;
    }
    
    return YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}


@end
