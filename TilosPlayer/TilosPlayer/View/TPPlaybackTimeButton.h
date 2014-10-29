//
//  TPPlaybackTimeView.h
//  TilosPlayer
//
//  Created by Daniel Langh on 29/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPPlaybackTimeButton : UIControl

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *label;

@property (nonatomic, assign) BOOL playing;

@end
