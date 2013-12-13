//
//  TPEpisodeListViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPEpisodeListViewController.h"
#import "TPEpisodeListCell.h"
#import <CoreText/CoreText.h>

@implementation TPEpisodeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    self.tableView.rowHeight = 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self.model dataForIndexPath:indexPath];
    CGFloat height = [TPEpisodeListCell estimatedHeightWithTitle:[data episodeName] description:[data episodeDefinition] authors:[[data episodeContributorNicknames] componentsJoinedByString:@", "] forWidth:320];
    
    return height;
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
    episodeCell.textLabel.text = [data episodeName];
    episodeCell.authorLabel.text = [[data episodeContributorNicknames] componentsJoinedByString:@", "];
    episodeCell.detailTextLabel.text = [data episodeDefinition];
    episodeCell.timeLabel.attributedText = [data episodeStartTime];
}

@end
