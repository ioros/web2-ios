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
#import "TPSmallEpisodeCell.h"

@interface TPShowInfoViewController ()

@property (nonatomic, retain) TPShowInfoHeaderView *headerView;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) TPTitleView *titleView;
@property (nonatomic, retain) TPCollectionViewController *collectionViewController;

@end

#pragma mark -

@implementation TPShowInfoViewController

- (void)loadView
{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 180, 320.0, 480.0)];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    self.view = self.webView;

    self.headerView = [[TPShowInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.headerView.detailTextView.text = self.data.definition;
    self.headerView.textLabel.text = self.data.name;
    [self.headerView sizeToFit];

    CGFloat headerHeight = self.headerView.bounds.size.height;
    
    CGFloat fullHeaderHeight = headerHeight + 70;

    
    ///////////////
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 30);
    layout.sectionInset = UIEdgeInsetsMake(0, 30, 0, 30);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
//    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
  //  layout.itemSize = CGSizeMake(80, 30);
   // layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
   // layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    TPCollectionViewController *collectionViewController = [[TPCollectionViewController alloc] initWithCellFactory:[TPSmallEpisodeCell new] layout:layout];
    collectionViewController.delegate = self;
    collectionViewController.view.backgroundColor = [UIColor clearColor];
    collectionViewController.view.frame = CGRectMake(0, headerHeight, 320, 70);
    self.collectionViewController = collectionViewController;
    
    ////////////////
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    header.frame = CGRectMake(0, -fullHeaderHeight, 320, fullHeaderHeight);
    [header addSubview:self.headerView];
    [header addSubview:collectionViewController.view];
    
    [self addChildViewController:collectionViewController];

    [self.webView.scrollView addSubview:header];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(fullHeaderHeight, 0, 0, 0);
    self.webView.scrollView.contentOffset = CGPointMake(0, -fullHeaderHeight);
    
    
    TPTitleView *titleView = [[TPTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.titleView = titleView;
    self.title = @"";
    self.titleView.text = self.data.name;
    [self.titleView sizeToFit];
    self.navigationItem.titleView = self.titleView;
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

- (void)listModelDidFinish:(TPListModel *)listModel
{
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
    
    self.collectionViewController.model = [[TPListModel alloc] initWithSections:model.sections];
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

- (void)collectionViewController:(TPCollectionViewController *)collectionViewController didSelectData:(id)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playEpisode" object:self userInfo:@{@"episode":data}];
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *episode = [self.model dataForIndexPath:indexPath];
}*/


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
