//
//  TPSmallEpisodeCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPSmallEpisodeCell.h"

#import "TPEpisodeData.h"

@interface TPSmallEpisodeCell ()

@end

@implementation TPSmallEpisodeCell

static NSString *cellID = @"TPSmallEpisodeCell";

- (void)registerClasses:(UICollectionView *)collectionView
{
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:cellID];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath data:(id)data
{
    TPEpisodeData *episode = data;
    
    TPSmallEpisodeCell *cell = (TPSmallEpisodeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMM dd.";
    cell.label.text = [formatter stringFromDate:episode.plannedFrom];
    return cell;
}

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.text = @"test";
        label.font = kDescFont;
        label.frame = self.contentView.bounds;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:label];
        
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.7f];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.clipsToBounds = YES;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.layer.cornerRadius = 5;
        backgroundView.clipsToBounds = YES;
        backgroundView.backgroundColor = [UIColor lightGrayColor];
        self.selectedBackgroundView = backgroundView;
        
        self.label = label;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.frame = CGRectInset(self.bounds, 10, 5);
}

@end
