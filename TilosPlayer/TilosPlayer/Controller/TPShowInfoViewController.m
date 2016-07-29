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
#import "TPTitleView.h"
#import "TPSmallEpisodeCell.h"
#import "TPBackButtonHandler.h"
#import "TPLabel.h"
#import "TPAuthorCollectionCell.h"
#import "TPContributorData.h"

#import "TPAuthorInfoViewController.h"

@interface TPShowInfoViewController ()

@property (nonatomic, retain) UIView *headerContainer;
@property (nonatomic, retain) TPShowInfoHeaderView *headerView;
@property (nonatomic, retain) TPLabel *emberekLabel;
@property (nonatomic, retain) TPLabel *episodesLabel;
@property (nonatomic, retain) TPLabel *introLabel;


@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) TPTitleView *titleView;
@property (nonatomic, retain) TPCollectionViewController *collectionViewController;
@property (nonatomic, retain) TPCollectionViewController *authorCollectionViewController;

@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) TPBackButtonHandler *backHandler;

@end

#pragma mark -

@implementation TPShowInfoViewController

- (void)loadView
{
    self.navigationController.navigationBarHidden = YES;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 180, 320.0, 480.0)];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    self.view = self.webView;
    
    
    ////////////////////////
    
    UIView *headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    headerContainer.backgroundColor = [UIColor whiteColor];
    self.headerContainer = headerContainer;

    self.headerView = [[TPShowInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.headerView.detailTextView.text = self.data.definition;
    self.headerView.textLabel.text = self.data.name;
//    self.headerView.contributorsTextLabel.text = @"---";
    [self.headerView sizeToFit];
    
    [self.headerContainer addSubview:self.headerView];

    CGFloat headerHeight = self.headerView.bounds.size.height;
    CGFloat collectionHeight = 120;
    CGFloat emberekLabelHeight = 60;
    CGFloat episodeLabelHeight = 60;
    CGFloat introLabelHeight = 60;
    CGFloat gapHeight = 30;
    CGFloat fullHeaderHeight = headerHeight + emberekLabelHeight + collectionHeight + episodeLabelHeight + collectionHeight + introLabelHeight;
    
    TPLabel *b = [[TPLabel alloc] initWithFrame:CGRectMake(40, 100, 100, 30)];
    b.font = kDescFont;
    b.backgroundImage = [[UIImage imageNamed:@"RoundButtonBlack.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    b.textAlignment = NSTextAlignmentCenter;
    b.text = NSLocalizedString(@"Authors", nil);
    CGSize s = [b sizeThatFits:CGSizeMake(200, 30)];
    b.frame = CGRectMake(0, 0, s.width + 20, s.height + 4);
    b.center = CGPointMake(160, headerHeight + gapHeight);
    [headerContainer addSubview:b];
    self.emberekLabel = b;

    b = [[TPLabel alloc] initWithFrame:CGRectMake(40, 100, 100, 30)];
    b.font = kDescFont;
    b.backgroundImage = [[UIImage imageNamed:@"RoundButtonBlack.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    b.textAlignment = NSTextAlignmentCenter;
    b.text = NSLocalizedString(@"ShowEpisodes", nil);
    s = [b sizeThatFits:CGSizeMake(200, 30)];
    b.frame = CGRectMake(0, 0, s.width + 20, s.height + 4);
    b.center = CGPointMake(160, headerHeight + emberekLabelHeight + collectionHeight + gapHeight);
    [headerContainer addSubview:b];
    self.episodesLabel = b;
    
    UICollectionViewFlowLayout *authorLayout = [UICollectionViewFlowLayout new];
    authorLayout.itemSize = CGSizeMake(280, 20);
    authorLayout.sectionInset = UIEdgeInsetsMake(10, 30, 10, 30);
    authorLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat authorCollectionHeight = 120;
    
    TPCollectionViewController *authorCollectionViewController = [[TPCollectionViewController alloc] initWithCellFactory:[TPAuthorCollectionCell new] layout:authorLayout];
    authorCollectionViewController.view.backgroundColor = [UIColor clearColor];
    authorCollectionViewController.delegate = self;
    self.authorCollectionViewController = authorCollectionViewController;
    self.authorCollectionViewController.view.frame = CGRectMake(0, headerHeight + emberekLabelHeight, 320, authorCollectionHeight);
    self.authorCollectionViewController.view.backgroundColor = [UIColor clearColor];
    self.authorCollectionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addChildViewController:authorCollectionViewController];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(80, 30);
    layout.sectionInset = UIEdgeInsetsMake(0, 30, 0, 30);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    TPCollectionViewController *collectionViewController = [[TPCollectionViewController alloc] initWithCellFactory:[TPSmallEpisodeCell new] layout:layout];
    collectionViewController.delegate = self;
    collectionViewController.view.backgroundColor = [UIColor clearColor];
    collectionViewController.view.frame = CGRectMake(0, headerHeight + emberekLabelHeight + collectionHeight + episodeLabelHeight, 320, collectionHeight);
    self.collectionViewController = collectionViewController;
    
    ////////////////
    
    [self addChildViewController:collectionViewController];
    
    b = [[TPLabel alloc] initWithFrame:CGRectMake(40, 100, 100, 30)];
    b.font = kDescFont;
    b.backgroundImage = [[UIImage imageNamed:@"RoundButtonBlack.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    b.textAlignment = NSTextAlignmentCenter;
    b.text = NSLocalizedString(@"ShowInfo", nil);
    s = [b sizeThatFits:CGSizeMake(200, 30)];
    b.frame = CGRectMake(0, 0, s.width + 20, s.height + 4);
    b.center = CGPointMake(160, headerHeight + emberekLabelHeight + collectionHeight + episodeLabelHeight + collectionHeight + gapHeight);
    [headerContainer addSubview:b];
    self.introLabel = b;
    
    self.episodesLabel.hidden = YES;
    self.introLabel.hidden = YES;

    headerContainer.frame = CGRectMake(0, -fullHeaderHeight, 320, fullHeaderHeight);
    [headerContainer addSubview:authorCollectionViewController.view];
    [headerContainer addSubview:collectionViewController.view];

    
    ///////////////
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0, 0, 70, 120);
    [self.view addSubview:self.backButton];
    [self.backButton addTarget:self action:@selector(backAnimated) forControlEvents:UIControlEventTouchUpInside];
    
    self.backHandler = [[TPBackButtonHandler alloc] initWithScrollView:self.webView.scrollView view:self.backButton];
    
    //////////////////////

    [self.webView.scrollView addSubview:headerContainer];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(fullHeaderHeight, 0, 0, 0);
    self.webView.scrollView.contentOffset = CGPointMake(0, -fullHeaderHeight);
    
    ///////////////////////
    
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

- (void)backAnimated
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self.webView loadHTMLString:model.introHTML baseURL:[NSURL URLWithString:@"https://tilos.hu/"]];
    
//    self.headerView.contributorsTextLabel.text = [model.show.contributorNicknames componentsJoinedByString:@", "];

    self.episodesLabel.hidden = NO;
    self.introLabel.hidden = !model.introAvailable;
    
    
    self.authorCollectionViewController.model = [[TPListModel alloc] initWithSections:model.sections2];
    self.collectionViewController.model = [[TPListModel alloc] initWithSections:model.sections];
}

#pragma mark -

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *showCellId = @"ShowEpisodeCell";
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:showCellId forIndexPath:indexPath];
//    TPEpisodeData *episode = [self.model dataForIndexPath:indexPath];
//    
//    NSDateFormatter *formatter = [NSDateFormatter new];
//    formatter.dateStyle = NSDateFormatterMediumStyle;
//    cell.textLabel.text = [formatter stringFromDate:episode.plannedFrom];
//    return cell;
//}

- (void)collectionViewController:(TPCollectionViewController *)collectionViewController didSelectData:(id)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playEpisode" object:self userInfo:@{@"episode":data}];
}

- (void)authorCollectionViewController:(TPCollectionViewController *)authorCollectionViewController didSelectData:(id)data
{
    NSLog(@"select %@", data);
    TPAuthorInfoViewController *vc = [[TPAuthorInfoViewController alloc] init];
    TPContributorData *contributor = data;
    TPAuthorData *author = [contributor author];
    vc.data = author;
    [self.navigationController pushViewController:vc animated:YES];
}



//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    NSDictionary *episode = [self.model dataForIndexPath:indexPath];
//}


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
