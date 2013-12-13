//
//  TPFlipLabelView.h
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TPFlipLabelView : UIView

@property (nonatomic, retain) UILabel *label;

- (void)setText:(NSString *)text;
- (void)setText:(NSString *)text fromTop:(BOOL)fromTop;

@end
