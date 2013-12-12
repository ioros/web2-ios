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
    
    
    self.title = NSLocalizedString(@"Episodes", nil);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpisodeListCell";
    return [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPEpisodeListCell *episodeCell = (TPEpisodeListCell *)cell;
    
    NSDictionary *data = [self.model dataForIndexPath:indexPath];
    episodeCell.textLabel.text = [[data objectForKey:@"show"] objectForKey:@"name"];
    
    NSArray *contributors = [[data objectForKey:@"show"] objectForKey:@"contributors"];
    NSMutableArray *nicks = [NSMutableArray array];
    for(NSDictionary *contributor in contributors) [nicks addObject:[contributor objectForKey:@"nick"]];
    episodeCell.detailTextLabel.text = [nicks componentsJoinedByString:@", "];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[data objectForKey:@"plannedFrom"] integerValue]];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    episodeCell.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", components.hour, components.minute];
}

@end
