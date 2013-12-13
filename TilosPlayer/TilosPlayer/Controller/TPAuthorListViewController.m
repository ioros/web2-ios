//
//  TPFirstViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorListViewController.h"
#import "AFNetworking.h"

@implementation TPAuthorListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // fake the title with a uilabel
    // this way we can get only the chevron for the back button
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
    label.font = kTitleFont;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"Authors", nil);
    self.navigationItem.titleView = label;
    
    self.title = @"";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AuthorListCell";
    return [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self.model dataForIndexPath:indexPath];
    cell.textLabel.text = [data objectForKey:@"name"];
    
    NSString *avatarUrl = [data objectForKeyOrNil:@"avatar"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"AuthorAvatarPlaceholder.png"]];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    id data = [self.model dataForIndexPath:indexPath];
    
    UIViewController *destination = segue.destinationViewController;
    if([destination respondsToSelector:@selector(setData:)])
    {
        [destination performSelector:@selector(setData:) withObject:data];
    }
}

@end
