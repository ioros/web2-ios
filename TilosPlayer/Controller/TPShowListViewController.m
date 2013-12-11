//
//  TPSecondViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowListViewController.h"

#import "TPShowInfoViewController.h"

@interface TPShowListViewController ()

@end

@implementation TPShowListViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *data = [self.model dataForIndexPath:indexPath];
    cell.textLabel.text = [data objectForKey:@"name"];
    cell.detailTextLabel.text = [data objectForKey:@"definition"];
    
   // NSString *banner = [data objectForKeyOrNil:@"banner"];
   // NSString *url = [NSString stringWithFormat:@"http://tilos.anzix.net/upload/bio/%@", avatar];
   // [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"AuthorAvatarPlaceholder.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    id data = [self.model dataForIndexPath:indexPath];
    TPShowInfoViewController *viewController = [TPShowInfoViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}



@end
