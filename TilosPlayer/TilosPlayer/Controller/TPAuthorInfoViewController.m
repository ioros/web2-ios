//
//  TPAuthorInfoViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorInfoViewController.h"
#import "NSDictionary+TPAdditions.h"
#import "TPAuthorInfoModel.h"
#import "TPListModel.h"
#import "TPAuthorListCell.h"
#import "TPShowListCell.h"
#import "TPAuthorData.h"
#import "TPContributionData.h"
#import "TPShowData.h"
#import "TPAuthorInfoHeaderView.h"
#import "TPTitleView.h"


typedef enum {
    TPAuthorInfoViewInfo,
    TPAuthorInfoViewShows
} TPAuthorInfoViewType;

@interface TPAuthorInfoViewController ()

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) TPAuthorInfoHeaderView *headerView;
@property (nonatomic, readonly) TPAuthorInfoModel *authorInfoModel;
@property (nonatomic, retain) TPTitleView *titleView;
@property (nonatomic, assign) TPAuthorInfoViewType currentType;

@end

#pragma mark -

@implementation TPAuthorInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TPAuthorInfoHeaderView *headerView = [[TPAuthorInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 100) items:@[NSLocalizedString(@"AuthorInfo", nil), NSLocalizedString(@"AuthorShows", nil)]];
    headerView.detailTextView.text = [[self.data nickNames] componentsJoinedByString:@", "];
    [headerView.imageView sd_setImageWithURL:[NSURL URLWithString:self.data.avatarURL]];
    [headerView sizeToFit];
    [headerView.segmentedControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
    self.headerView = headerView;
    
    TPTitleView *titleView = [[TPTitleView alloc] initWithFrame:CGRectMake(0, 0, 240, 30)];
    self.titleView = titleView;
    self.title = @"";
    self.titleView.text = self.data.name;
    [self.titleView sizeToFit];
    self.navigationItem.titleView = self.titleView;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
    webView.delegate = self;
    webView.backgroundColor = [UIColor whiteColor];
    self.webView = webView;
    
    // setup the tab
    NSInteger selectedIndex = 0;
    NSNumber *tabIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"authorInfoPreferredTabIndex"];
    if(tabIndex) selectedIndex = tabIndex.integerValue;
    [self.headerView.segmentedControl setSelectedSegmentIndex:selectedIndex];
    [self updateView:selectedIndex == 0 ? TPAuthorInfoViewInfo : TPAuthorInfoViewShows];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


    if(self.data && self.model == nil)
    {
        self.model = [[TPAuthorInfoModel alloc] initWithParameters:self.data.identifier];
        self.model.delegate = self;
    }
}

#pragma mark -

- (void)changed:(UISegmentedControl *)segmentedControl
{
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:selectedIndex] forKey:@"authorInfoPreferredTabIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateView:selectedIndex == 0 ? TPAuthorInfoViewInfo : TPAuthorInfoViewShows];
}

- (void)updateView:(TPAuthorInfoViewType)type
{
    CGFloat topInset = self.topLayoutGuide.length;
    
    self.currentType = type;
    
    if(type == TPAuthorInfoViewInfo)
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
        
        [self.webView.scrollView addSubview:self.headerView];
        self.webView.frame = self.tableView.bounds;
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        self.webView.scrollView.contentOffset = CGPointMake(0, -headerHeight);

        self.tableView.tableHeaderView = self.webView;
    }
    else
    {
        self.tableView.scrollEnabled = YES;
        self.tableView.tableHeaderView = self.headerView;
    }
}

#pragma mark - TableView Delegates

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *showCellIdentifier = @"ShowCell";

    TPShowListCell *cell = (TPShowListCell *) [tableView dequeueReusableCellWithIdentifier:showCellIdentifier];
    
    TPContributionData *contribution = [self.authorInfoModel dataForIndexPath:indexPath];
    TPShowData *show = [contribution show];
    
    cell.textLabel.text = show.name;
    cell.detailTextLabel.text = show.definition;
    return cell;
}

#pragma mark - List Model Delegate

- (void)listModelDidFinish:(TPListModel *)listModel
{
    [super listModelDidFinish:listModel];
    
    if(self.authorInfoModel.htmlString)
    {
        [self.webView loadHTMLString:self.authorInfoModel.htmlString baseURL:[NSURL URLWithString:@"http://tilos.hu"]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    TPContributionData *contribution = [self.model dataForIndexPath:indexPath];
    TPShowData *show = [contribution show];
    
    UIViewController *destination = segue.destinationViewController;
    if([destination respondsToSelector:@selector(setData:)])
    {
        [destination performSelector:@selector(setData:) withObject:show];
    }
}

#pragma mark -

- (TPAuthorInfoModel *)authorInfoModel
{
    return (TPAuthorInfoModel *)[self model];
}


@end
