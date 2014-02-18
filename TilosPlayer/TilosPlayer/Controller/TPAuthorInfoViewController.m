//
//  TPAuthorInfoViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorInfoViewController.h"
#import "NSDictionary+TPAdditions.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TPAuthorInfoModel.h"
#import "TPListModel.h"
#import "TPWebIntroductionCell.h"
#import "TPAuthorListCell.h"
#import "TPShowListCell.h"


@interface TPAuthorInfoViewController () <TPListModelDelegate, UITableViewDelegate, UIWebViewDelegate>

@end

@implementation TPAuthorInfoViewController{
    TPAuthorInfoModel *_infoModel;
    UIWebView *_authorInfoWebView;
    UITableView *_contributionsTableView;
    BOOL *_contentDownloaded;
    NSDictionary *_boldAttributes;
    NSDictionary *_normalAttributes;
    NSMutableAttributedString *_nickString;
}

-(void)viewDidLoad{
    [super viewDidLoad];
        
    self.navigationItem.title = [self.authorBasicInfo authorName];
    
    self.authorModel = [[TPAuthorInfoModel alloc] initWithParameters:[self.authorBasicInfo objectForKeyOrNil:@"id"]];
    self.authorModel.delegate = self;
    _authorInfoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 2.0f)];
    _authorInfoWebView.scrollView.scrollEnabled = NO;
    _authorInfoWebView.delegate = self;
    
    _nickString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Alias %@", [self.authorBasicInfo objectForKey:@"alias"]]];
    
    _boldAttributes = @{NSFontAttributeName : kBoldFont};
    _normalAttributes = @{NSFontAttributeName : kListFont};
    
    [_nickString setAttributes:_normalAttributes range:NSMakeRange(0, 6)];
    [_nickString setAttributes:_boldAttributes range:NSMakeRange(6, _nickString.length-6)];
    
    [self.authorModel loadForced:NO];
    
}

#pragma mark - TableView Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    switch (self.authorModel.awailableInfo) {
        case kContributionsAndIntroduction: {
            return 3;
            break;
        }
        case kIntroductionOnly: {
            return 2;
            break;
        }
        case kContributionsOnly:{
            return 2;
            break;
        }
        case kNoInfoAwailable:{
            return 1;
            break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0: {
            return 1;
            break;
        }
        case 1: {
            if (self.authorModel.awailableInfo == kIntroductionOnly) {
                return 1;;
            }
            else{
                return self.authorModel.contributions.count;
            }
            break;
        }
        case 2: {
            return 1;
            break;
        }
        default:
            break;
    }
    return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0: {
            return NSLocalizedString(@"Műsorszerkesztő", @"Author Info");
            break;
        }
        case 1: {
            
            if (self.authorModel.awailableInfo == kIntroductionOnly) {
                return NSLocalizedString(@"Bemutatkozás", @"Introduction");
            }
            else{
                return NSLocalizedString(@"Műsorai", @"Contributions");
            }
            break;
        }
        case 2: {
            return NSLocalizedString(@"Bemutatkozás", @"Introduction");

            break;
        }
        default:
            break;
    }
    return @"No titlte error";
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *authorCellIdentifier = @"AuthorCell";
    static NSString *showCellIdentifier = @"ShowCell";
    static NSString *introductionCellIdentifier = @"IntroductionCell";
    
    switch (indexPath.section) {
        case 0:{
            
            TPAuthorListCell *cell = [tableView dequeueReusableCellWithIdentifier:authorCellIdentifier];
            [cell.imageView setImageWithURL:[self.authorBasicInfo objectForKey:@"avatar"] placeholderImage:[UIImage imageNamed:@"AuthorAvatarPlaceholder.png"]];
            

            cell.textLabel.attributedText = _nickString;
            
            return cell;
            break;
        }
        case 1:{
            
            if (self.authorModel.awailableInfo == kIntroductionOnly) {
                TPWebIntroductionCell *iCell = (TPWebIntroductionCell*)[tableView dequeueReusableCellWithIdentifier:introductionCellIdentifier];
                [iCell.introductionWebView loadHTMLString:self.authorModel.htmlString  baseURL:nil];
                iCell.introductionWebView.scrollView.scrollEnabled = NO;
                iCell.introductionWebView.scrollView.bounces = NO;
                iCell.introductionWebView.delegate = self;
                
                NSLog(@"%@",[_infoModel.author objectForKey:@"introduction"]);
                
                return iCell;
                break;
            }
            else{
                
                TPShowListCell *cell = (TPShowListCell *) [tableView dequeueReusableCellWithIdentifier:showCellIdentifier];
                
                NSDictionary *contribution = self.authorModel.contributions[indexPath.row];
                NSDictionary *show = [contribution objectForKey:@"show"];
                
                cell.textLabel.text = [show objectForKey:@"name"];
                cell.detailTextLabel.text = [show objectForKey:@"definition"];
                return cell;
                break;
            }
            
            break;
        }
        case 2:{
            TPWebIntroductionCell *iCell = (TPWebIntroductionCell*)[tableView dequeueReusableCellWithIdentifier:introductionCellIdentifier];
            [iCell.introductionWebView loadHTMLString:self.authorModel.htmlString  baseURL:nil];
            iCell.introductionWebView.scrollView.scrollEnabled = NO;
            iCell.introductionWebView.scrollView.bounces = NO;
            iCell.introductionWebView.delegate = self;
            return iCell;

            break;
        }

        default:{
            return nil;
            break;
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1 && self.authorModel.awailableInfo == kIntroductionOnly) || indexPath.section == 2) {
        
        CGFloat height = [[_authorInfoWebView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];

        return height;
    }

    return 44;
}


#pragma mark - List Model Delegate

- (void)listModelDidFinish:(TPListModel *)listModel
{
    self.authorModel =  (TPAuthorInfoModel*)listModel;    
    
    [_authorInfoWebView loadHTMLString:self.authorModel.htmlString baseURL:nil];
}

- (void)listModel:(TPListModel *)listModel didFailWithError:(NSError *)error
{
    NSLog(@"error %@", error);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.tableView reloadData];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    if (![inWeb isEqual:_authorInfoWebView]) {
        if ( inType == UIWebViewNavigationTypeLinkClicked ) {
            [[UIApplication sharedApplication] openURL:[inRequest URL]];
            return NO;
        }
        
    }


    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *contribution = self.authorModel.contributions[indexPath.row];
    id data = [contribution objectForKey:@"show"];
    
    UIViewController *destination = segue.destinationViewController;
    if([destination respondsToSelector:@selector(setData:)])
    {
        [destination performSelector:@selector(setData:) withObject:data];
    }
}


@end
