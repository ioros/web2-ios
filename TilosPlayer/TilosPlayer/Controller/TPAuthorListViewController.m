//
//  TPFirstViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPAuthorListViewController.h"
#import "AFNetworking.h"
#import "TPAuthorListCell.h"
#import "TPAuthorInfoViewController.h"

@implementation TPAuthorListViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TPAuthorListCell *cell = (TPAuthorListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[TPAuthorListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *data = [self.model dataForIndexPath:indexPath];
    cell.textLabel.text = [data objectForKey:@"name"];
    
    NSString *avatar = [data objectForKeyOrNil:@"avatar"];
    NSString *url = [NSString stringWithFormat:@"http://tilos.anzix.net/upload/bio/%@", avatar];
    [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"AuthorAvatarPlaceholder.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    id data = [self.model dataForIndexPath:indexPath];
    TPAuthorInfoViewController *viewController = [TPAuthorInfoViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
