//
//  TPShowInfoHeaderView.h
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPShowInfoHeaderView : UIView

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UITextView *detailTextView;

@property (nonatomic, retain) UISegmentedControl *segmentedControl;

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end
