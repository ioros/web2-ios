//
//  TPLogoView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPLogoView.h"

@interface TPLogoView ()

@property (nonatomic, retain) UIDynamicAnimator *animator;

@end

@implementation TPLogoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    if(self.bounds.size.height > 100)
    {
        //self.button.frame = CGRectMake(0, 0, 60, 60);
        self.button.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-55);
    }
    else
    {
        //self.button.frame = CGRectMake(0, 0, 40, 40);
        self.button.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height-15);
    }
}

@end
