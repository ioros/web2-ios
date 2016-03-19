//
//  TPFlipLabelView.m
//  TilosPlayer
//
//  Created by Daniel Langh on 13/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPFlipLabelView.h"

#import <QuartzCore/QuartzCore.h>

#define kFlipLabelAnimationDuration 0.33f

@interface TPFlipLabelView ()

@property (nonatomic, retain) UIImageView *pagerView;

@end

@implementation TPFlipLabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.font = kBoldFont;
        self.label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.label];
        
        self.pagerView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.pagerView.opaque = NO;
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    self.label.text = text;
}
- (void)setText:(NSString *)text fromTop:(BOOL)fromTop
{
    [self updateScreenshot];
    
    self.label.text = text;
    
    [self animatePaging:fromTop];
}

#pragma mark -

- (void)updateScreenshot
{
    CGRect b = self.label.bounds;
    
	if(&UIGraphicsBeginImageContextWithOptions != NULL)
	{
		UIGraphicsBeginImageContextWithOptions(b.size, NO, 0.0);
	}
	else
	{
		UIGraphicsBeginImageContext(b.size);
	}
	[self.label.layer renderInContext:UIGraphicsGetCurrentContext()];
    
	_pagerView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)animatePaging:(BOOL)forward
{
    _pagerView.frame = self.label.bounds;
    
    if(forward)
    {
        self.label.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 1.5f);
    }
    else
    {
        self.label.center = CGPointMake(self.bounds.size.width * 0.5, -self.bounds.size.height * 0.5f);
    }
    
    [self addSubview:_pagerView];
    
    [UIView animateWithDuration:kFlipLabelAnimationDuration animations:^{
        self.label.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5f);
        if(forward)
        {
            _pagerView.center = CGPointMake(self.bounds.size.width * 0.5, -self.bounds.size.height * 0.5f);
        }
        else
        {
            _pagerView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 1.5f);
        }
    }];
}



@end
