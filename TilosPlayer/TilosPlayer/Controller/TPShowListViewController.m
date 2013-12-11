//
//  TPSecondViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPShowListViewController.h"

@implementation TPShowListViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShowListCell";
    return [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self.model dataForIndexPath:indexPath];
    cell.textLabel.text = [data objectForKey:@"name"];
    cell.detailTextLabel.text = [data objectForKey:@"definition"];
    
    // NSString *banner = [data objectForKeyOrNil:@"banner"];
    // NSString *url = [NSString stringWithFormat:@"http://tilos.anzix.net/upload/bio/%@", avatar];
    // [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"AuthorAvatarPlaceholder.png"]];
}

@end
