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
#import "TPEpisodeData.h"
#import "TPShowData.h"
#import "TPShowInfoHeaderView.h"
#import "TPTitleView.h"


typedef enum {
    TPShowInfoViewTypeInfo,
    TPShowInfoViewTypeEpisodes
} TPShowInfoViewType;


@interface TPShowInfoViewController ()

@property (nonatomic, retain) TPShowInfoHeaderView *headerView;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) TPTitleView *titleView;
@property (nonatomic, assign) TPShowInfoViewType currentType;

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
    self.headerView.detailTextView.text = self.data.definition;
    [self.headerView sizeToFit];
    
    TPTitleView *titleView = [[TPTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.titleView = titleView;
    self.title = @"";
    self.titleView.text = self.data.name;
    [self.titleView sizeToFit];
    self.navigationItem.titleView = self.titleView;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 180, 320.0, 1.0)];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    // setup the tab
    NSInteger selectedIndex = 0;
    NSNumber *tabIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"showInfoPreferredTabIndex"];
    if(tabIndex) selectedIndex = tabIndex.integerValue;
    [self.headerView.segmentedControl setSelectedSegmentIndex:selectedIndex];
    [self updateView:selectedIndex == 0 ? TPShowInfoViewTypeInfo : TPShowInfoViewTypeEpisodes];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    NSString *url = model.show.bannerURL;
    if(url)
    {
        [self.headerView.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    else{
        self.headerView.imageView.image = [UIImage imageNamed:@"DefaultBanner.png"];
    }
    
    if(model.htmlString)
    {
        [self.webView loadHTMLString:model.htmlString baseURL:[NSURL URLWithString:@"http://tilos.hu/"]];
    }
}

#pragma mark -

- (void)headerViewSegmentChanged:(UISegmentedControl*)segmentedControl
{
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:selectedIndex] forKey:@"showInfoPreferredTabIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateView: selectedIndex == 0 ? TPShowInfoViewTypeInfo : TPShowInfoViewTypeEpisodes];
}


- (void)updateView:(TPShowInfoViewType)type
{
    CGFloat topInset = self.topLayoutGuide.length;
    
    self.currentType = type;

    if(type == TPShowInfoViewTypeEpisodes)
    {
        self.tableView.scrollEnabled = YES;
        self.tableView.tableHeaderView = self.headerView;
        self.tableView.contentOffset = CGPointMake(0, -topInset);
    }
    else
    {
        self.tableView.scrollEnabled = NO;
        self.tableView.contentOffset = CGPointMake(0, -topInset);
        self.tableView.tableHeaderView = nil;
        
        CGFloat headerHeight = self.headerView.bounds.size.height;
        
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        CGRect headerRect = self.headerView.frame;
        headerRect.origin.x = 0;
        headerRect.origin.y = -headerHeight;
        self.headerView.frame = headerRect;
        
        self.webView.frame = self.tableView.bounds;
        [self.webView.scrollView addSubview:self.headerView];
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        self.webView.scrollView.contentOffset = CGPointMake(0, -headerHeight);
        
        self.tableView.tableHeaderView = self.webView;
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
