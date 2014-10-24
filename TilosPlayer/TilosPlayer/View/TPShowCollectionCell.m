//
//  TPShowCollectionCell.m
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPShowCollectionCell.h"

#import "TPShowData.h"
#import "TPContributionData.h"

@implementation TPShowCollectionCell

static NSString *cellID = @"TPShowCollectionCell";

- (void)registerClasses:(UICollectionView *)collectionView
{
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:cellID];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath data:(id)data
{
    TPContributionData *contribution = data;
    
    TPShowCollectionCell *cell = (TPShowCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    cell.label.text = contribution.show.name;
    cell.imageView.image = nil;
    
    NSString *url = contribution.show.bannerURL;
    if(url != nil)
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    else {
        [cell.imageView setImage:[UIImage imageNamed:@"DefaultBanner.png"]];
    }
    
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
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = self.contentView.bounds;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, 20, 0))];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
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
    
    CGRect b = self.bounds;
    self.label.frame = CGRectMake(0, b.size.height - 20, b.size.width, 20);
}

@end
