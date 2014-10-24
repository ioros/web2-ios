//
//  TPAuthorInfoHeaderView.h
//  TilosPlayer
//
//  Created by Daniel Langh on 22/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPAuthorInfoHeaderView : UIView

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UITextView *detailTextView;

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;

@end
