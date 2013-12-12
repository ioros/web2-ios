//
//  TPTapeCollectionLayout.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPTapeCollectionLayout.h"

@interface TPTapeCollectionLayout ()

@property (nonatomic, assign) CGSize itemSize;
@property (strong, nonatomic) NSMutableArray *itemAttributes;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation TPTapeCollectionLayout

- (id)initWithItemSize:(CGSize)itemSize
{
    self = [super init];
    if(self)
    {
        self.itemSize = itemSize;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(150, 30);
    }
    return self;
}

-(void)prepareLayout
{
    [self setItemAttributes:nil];
    _itemAttributes = [[NSMutableArray alloc] init];
    
    if([self.collectionView numberOfSections] == 0) return;
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];

    CGFloat itemWidth = _itemSize.width;
    CGFloat itemHeight = _itemSize.height;
    
    CGFloat verticalOffset = floorf((self.collectionView.bounds.size.height - itemHeight)/2.0f);
    
    for(int i = 0; i<numberOfItems; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectIntegral(CGRectMake(i*itemWidth, verticalOffset, itemWidth, itemHeight));
        [_itemAttributes addObject:attributes];
    }
    
    _contentSize = CGSizeMake(itemWidth * numberOfItems, itemHeight);
}

-(CGSize)collectionViewContentSize
{
    return _contentSize;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_itemAttributes objectAtIndex:indexPath.row];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *items = [_itemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        CGRect frame = evaluatedObject.frame;
        BOOL intersect = CGRectIntersectsRect(rect, frame);
        return intersect;
    }]];
    return items;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
