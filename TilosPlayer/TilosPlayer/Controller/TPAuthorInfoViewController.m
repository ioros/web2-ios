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
#import "TPCollectionViewController.h"
#import "TPShowCollectionCell.h"
#import "TPBackButtonHandler.h"
#import "TPLabel.h"

#import "TPShowInfoViewController.h"


@interface TPAuthorInfoViewController ()

@property (nonatomic, retain) UIWebView *webView;

@property (nonatomic, retain) UIView *headerContainer;
@property (nonatomic, retain) TPAuthorInfoHeaderView *headerView;
@property (nonatomic, retain) TPLabel *showLabel;
@property (nonatomic, retain) TPLabel *introLabel;

@property (nonatomic, readonly) TPAuthorInfoModel *authorInfoModel;
@property (nonatomic, retain) TPTitleView *titleView;
@property (nonatomic, retain) TPCollectionViewController *collectionViewController;

@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) TPBackButtonHandler *backHandler;

@end

#pragma mark -

@implementation TPAuthorInfoViewController

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
    webView.delegate = self;
    webView.backgroundColor = [UIColor whiteColor];
    self.webView = webView;
    
    self.view = self.webView;
    
    /////////////////////////////////
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0, 0, 70, 120);
    [self.view addSubview:self.backButton];
    [self.backButton addTarget:self action:@selector(backAnimated) forControlEvents:UIControlEventTouchUpInside];

    self.backHandler = [[TPBackButtonHandler alloc] initWithScrollView:self.webView.scrollView view:self.backButton];
    
    UIView *headerContainer = [[UIView alloc] init];
    headerContainer.backgroundColor = [UIColor whiteColor];
    headerContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.headerContainer = headerContainer;

    TPAuthorInfoHeaderView *headerView = [[TPAuthorInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 100) items:@[NSLocalizedString(@"AuthorInfo", nil), NSLocalizedString(@"AuthorShows", nil)]];
    headerView.detailTextView.text = [[self.data nickNames] componentsJoinedByString:@", "];
    [headerView.imageView sd_setImageWithURL:[NSURL URLWithString:self.data.avatarURL]];
    [headerView sizeToFit];
    self.headerView = headerView;
    [headerContainer addSubview:self.headerView];
    
    CGFloat headerHeight = headerView.frame.size.height;

    /////////////////////////
    
    TPLabel *b = [[TPLabel alloc] initWithFrame:CGRectMake(40, 100, 100, 30)];
    b.font = kDescFont;
    b.backgroundImage = [[UIImage imageNamed:@"RoundButtonBlack.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    b.textAlignment = NSTextAlignmentCenter;
    b.text = NSLocalizedString(@"AuthorShows", nil);
    CGSize s = [b sizeThatFits:CGSizeMake(200, 30)];
    b.frame = CGRectMake(0, 0, s.width + 20, s.height + 4);
    b.center = CGPointMake(160, headerHeight + 25);
    [headerContainer addSubview:b];
    self.showLabel = b;

    b = [[TPLabel alloc] initWithFrame:CGRectMake(40, 100, 100, 30)];
    b.font = kDescFont;
    b.backgroundImage = [[UIImage imageNamed:@"RoundButtonBlack.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    b.textAlignment = NSTextAlignmentCenter;
    b.text = NSLocalizedString(@"AuthorInfo", nil);
    s = [b sizeThatFits:CGSizeMake(200, 30)];
    b.frame = CGRectMake(0, 0, s.width + 20, s.height + 4);
    b.center = CGPointMake(160, headerHeight + 25);
    [headerContainer addSubview:b];
    self.introLabel = b;
    
    self.showLabel.hidden = YES;
    self.introLabel.hidden = YES;

    

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(280, 20);
    layout.sectionInset = UIEdgeInsetsMake(10, 30, 10, 30);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGFloat collectionHeight = 0;
    
    TPCollectionViewController *collectionViewController = [[TPCollectionViewController alloc] initWithCellFactory:[TPShowCollectionCell new] layout:layout];
    collectionViewController.view.backgroundColor = [UIColor clearColor];
    collectionViewController.delegate = self;
    self.collectionViewController = collectionViewController;
    
    self.collectionViewController.view.frame = CGRectMake(0, headerHeight + 30, 320, collectionHeight);
    self.collectionViewController.view.backgroundColor = [UIColor clearColor];
    self.collectionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [headerContainer addSubview:self.collectionViewController.view];

    CGFloat fullHeaderHeight = headerHeight + collectionHeight + 30;
    headerContainer.frame = CGRectMake(0, -fullHeaderHeight, 320, fullHeaderHeight);

    [self.webView.scrollView addSubview:headerContainer];

    ////////////////////////////
    
    TPTitleView *titleView = [[TPTitleView alloc] initWithFrame:CGRectMake(0, 0, 240, 30)];
    self.titleView = titleView;
    self.title = @"";
    self.titleView.text = self.data.name;
    [self.titleView sizeToFit];
    self.navigationItem.titleView = self.titleView;
}

- (void)viewDidLoad
{
    NSLog(@"TPAuthorInfoViewController");
    [super viewDidLoad];
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat headerHeight = self.headerContainer.bounds.size.height;
    CGFloat topInset = self.topLayoutGuide.length;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerHeight + topInset, 0, 0, 0);
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, 0, 0);
    self.webView.scrollView.contentOffset = CGPointMake(0, -headerHeight-topInset);
}

#pragma mark -

- (void)backAnimated
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - List Model Delegate

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
    TPAuthorInfoModel *authorInfoModel = self.authorInfoModel;
    
    if(self.authorInfoModel.introHTML)
    {
        [self.webView loadHTMLString:self.authorInfoModel.introHTML baseURL:[NSURL URLWithString:@"https://tilos.hu"]];
    }
    
    NSInteger itemCount = [self.model numberOfRowsInSection:0];
    
    CGFloat headerHeight = self.headerView.bounds.size.height;
    CGFloat showLabelHeight = 40;
    CGFloat introLabelHeight = authorInfoModel.introAvailable ? 40 : 0;
    
    CGFloat collectionHeight =  itemCount * 20 + (itemCount -1) * 10 + 20;
    self.collectionViewController.view.frame = CGRectMake(0, headerHeight + showLabelHeight, 320, collectionHeight);
    self.collectionViewController.model = [[TPListModel alloc] initWithSections:self.model.sections];

    self.showLabel.hidden = NO;
    self.introLabel.center = CGPointMake(160, headerHeight + showLabelHeight + collectionHeight + 25);
    self.introLabel.hidden = !authorInfoModel.introAvailable;
    
    CGFloat fullHeaderHeight = headerHeight + showLabelHeight + collectionHeight + introLabelHeight;
    self.headerContainer.frame = CGRectMake(0, -fullHeaderHeight, 320, fullHeaderHeight);
    
    [self.view setNeedsLayout];
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

- (void)collectionViewController:(TPCollectionViewController *)collectionViewController didSelectData:(id)data
{
    NSLog(@"select %@", data);
    TPShowInfoViewController *vc = [[TPShowInfoViewController alloc] init];
    TPContributionData *contribution = data;
    TPShowData *show = [contribution show];
    vc.data = show;
    [self.navigationController pushViewController:vc animated:YES];
}
/*
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
}*/

#pragma mark -

- (TPAuthorInfoModel *)authorInfoModel
{
    return (TPAuthorInfoModel *)[self model];
}


@end
