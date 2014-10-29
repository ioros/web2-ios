//
//  TPPlaybackTimeView.h
//  TilosPlayer
//
//  Created by Daniel Langh on 29/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPPlaybackTimeButton : UIControl

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIImageView *typeView;
@property (nonatomic, retain) UILabel *label;

@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL isMusic;

@end
