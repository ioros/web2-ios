//
//  TPBackButtonHandler.m
//  TilosPlayer
//
//  Created by Daniel Langh on 24/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPBackButtonHandler.h"

@interface TPBackButtonHandler ()

@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) UIView *view;

@property (nonatomic, assign) BOOL backButtonHidden;
@property (nonatomic, assign) CGFloat lastOffset;

@end

@implementation TPBackButtonHandler

- (instancetype)initWithScrollView:(UIScrollView *)scrollView view:(UIView *)view
{
    self = [super init];
    if(self)
    {
        self.backButtonHidden = NO;
        self.view = view;
        self.scrollView = scrollView;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        CGFloat offset = _scrollView.contentOffset.y;
        CGFloat contentHeight = _scrollView.contentSize.height;
        CGFloat webHeight = _scrollView.frame.size.height;
        
        if((offset < _lastOffset) || offset < -240)
        {
            if(self.backButtonHidden)
            {
                self.backButtonHidden = NO;
                
                self.view.hidden = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.alpha = 1.0f;
                }];
            }
            _lastOffset = offset;
        }
        else if(offset > _lastOffset + 20 && offset < (contentHeight - webHeight))
        {
            if(!self.backButtonHidden)
            {
                self.backButtonHidden = YES;
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.view.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    self.view.hidden = YES;
                }];
            }
            _lastOffset = offset;
        }
    }
}


@end
