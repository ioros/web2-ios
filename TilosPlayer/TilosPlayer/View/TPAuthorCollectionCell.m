//
//  TPAuthorCollectionCell.m
//  TilosPlayer
//
//  Created by Imre Oros on 08/06/16.
//  Copyright (c) 2016 Oros Imre. All rights reserved.
//

#import "TPAuthorCollectionCell.h"

#import "TPAuthorData.h"
#import "TPContributorData.h"

@implementation TPAuthorCollectionCell

static NSString *cellID = @"TPAuthorCollectionCell";

- (void)registerClasses:(UICollectionView *)collectionView
{
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:cellID];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath data:(id)data
{
    TPContributorData *ember = data;
    
    TPAuthorCollectionCell *cell = (TPAuthorCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    cell.label.text = ember.nick;
    cell.imageView.image = nil;
    
    NSString *url = ember.author.avatarURL;
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
        label.font = kDescFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = self.contentView.bounds;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, 20, 20))];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.layer.cornerRadius = 5;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = backgroundView;
        
        self.label = label;
        self.imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect b = self.bounds;
    self.imageView.frame = CGRectMake((b.size.width - 180)/2.0f, 0, 180, 50);
    self.label.frame = CGRectMake(0, b.size.height - 20, b.size.width, 20);
}

@end
