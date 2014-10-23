//
//  TPTabBar.m
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPTabBar.h"

#import "UIColor+Additions.h"

@interface TPTabBar ()

@property (nonatomic, retain) NSArray *buttons;

@end

@implementation TPTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIImageView *imageView;
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeTop;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [super addSubview:imageView];
    
    ////////////////////
    
    
    self.coverView = imageView;
    
    self.selectedIndex = -1;
}

- (void)setItems:(NSArray *)items
{
    super.items = items;
    [self updateButtons];
}
- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    [super setItems:items animated:animated];
    [self updateButtons];
}

#pragma mark -

- (void)updateButtons
{
    NSArray *items = self.items;
    
    [self bringSubviewToFront:self.coverView];
    
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    CGFloat part = self.bounds.size.width / items.count;
    
    int counter = 0;
    
    NSArray *images = @[
                        [UIImage imageNamed:@"ClockTab.png"],
                        [UIImage imageNamed:@"ShowTab.png"],
                        [UIImage imageNamed:@"ProfileTab.png"]
                        ];
    NSArray *imagesSelected = @[
                                [UIImage imageNamed:@"ClockTabSelected.png"],
                                [UIImage imageNamed:@"ShowTabSelected.png"],
                                [UIImage imageNamed:@"ProfileTabSelected.png"]
                                ];
    
    for(UITabBarItem *item in items)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[images objectAtIndex:counter] forState:UIControlStateNormal];
        [button setImage:[imagesSelected objectAtIndex:counter] forState:UIControlStateSelected];
        //[button setTitle:item.title forState:UIControlStateNormal];
        //button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(part * counter, 0, part, self.bounds.size.height);
        button.tag = counter;
        [button addTarget:self action:@selector(tabSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        [super addSubview:button];
        [buttons addObject:button];
        
        counter++;
    }
    
    self.buttons = buttons;
}

- (void)addSubview:(UIView *)view
{
    [super insertSubview:view atIndex:0];
}

- (void)bringSubviewToFront:(UIView *)view
{
    [super bringSubviewToFront:view];
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem
{
    [super setSelectedItem:selectedItem];
    
    NSInteger index = [self.items indexOfObject:selectedItem];
    [self setSelectedButtonIndex:index];
}

- (void)setSelectedButtonIndex:(NSInteger)index
{
    if(_selectedIndex == index) return;
    
    if(0 <= _selectedIndex && _selectedIndex < self.buttons.count)
    {
        [[self.buttons objectAtIndex:_selectedIndex] setSelected:NO];
    }
    _selectedIndex = index;
    if(0 <= _selectedIndex && _selectedIndex < self.buttons.count)
    {
        [[self.buttons objectAtIndex:_selectedIndex] setSelected:YES];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self setSelectedButtonIndex:selectedIndex];
}

- (void)deselectItems
{
    [self setSelectedButtonIndex:-1];
}

- (void)tabSelected:(UIButton *)sender
{
    NSInteger index = sender.tag;
    
    if(_selectedIndex == index)
    {
        [self setSelectedButtonIndex:-1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"itemDeselected" object:self userInfo:@{@"index":[NSNumber numberWithInteger:index]}];
    }
    else
    {
        [self setSelectedButtonIndex:index];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"itemSelected" object:self userInfo:@{@"index":[NSNumber numberWithInteger:index]}];
    }
}

@end
