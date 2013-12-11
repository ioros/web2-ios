//
//  TPEpisodeListViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListViewController.h"
#import "TPEpisodeListCell.h"

@implementation TPEpisodeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TPEpisodeListCell *cell = (TPEpisodeListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[TPEpisodeListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *data = [self.model dataForIndexPath:indexPath];
    cell.textLabel.text = [[data objectForKey:@"show"] objectForKey:@"name"];
    cell.detailTextLabel.text = [[data objectForKey:@"show"] objectForKey:@"definition"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"plannedFrom"] integerValue]];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    cell.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", components.hour, components.minute];
    
    return cell;
}

@end
