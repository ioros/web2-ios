//
//  TPPlayButton.m
//  TilosPlayer
//
//  Created by Daniel Langh on 18/10/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPPlayButton.h"

@interface TPPlayButton ()

@property (nonatomic, retain) UIImageView *circleView;
@property (nonatomic, retain) UIImageView *loadingView;
@property (nonatomic, retain) UIImageView *buttonView;

@property (nonatomic, assign) BOOL rotating;

@end

#pragma mark -

@implementation TPPlayButton



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.circleView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.circleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.circleView];

        self.loadingView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.loadingView];

        self.buttonView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.buttonView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.buttonView];
        
        _playing = NO;
        _loading = NO;
        _rotating = NO;
        
        self.circleView.image = [UIImage imageNamed:@"PlayCircle.png"];
        self.loadingView.image = [UIImage imageNamed:@"PlayLoading.png"];
        
        self.loadingView.hidden = YES;
        
        [self updateButtonAnimated:NO];
    }
    return self;
}

- (void)updateButtonAnimated:(BOOL)animated
{
    self.buttonView.image = _playing ? [UIImage imageNamed:@"PauseButton.png"] : [UIImage imageNamed:@"PlayButton.png"];
    
    if(_loading)
    {
        self.loadingView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.circleView.alpha = 0.0f;
            self.loadingView.alpha = 1.0f;
        }];
        [self animateOneRound];
    }
    else
    {
        if(!self.loadingView.hidden)
        {
            [UIView animateWithDuration:0.2f
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.circleView.alpha = 1.0f;
                                 self.loadingView.alpha = 0.0f;
                             } completion:^(BOOL finished) {
                                 self.loadingView.hidden = YES;
                             }];
        }
    }
}


#pragma mark -

- (void)animateOneRound
{
    if(_rotating) return;
    
    _rotating = YES;
    [UIView animateWithDuration:1.5 animations:^{
        CABasicAnimation *fullRotation;
        fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
        fullRotation.duration = 1.0f;
        fullRotation.repeatCount = 0;
        fullRotation.delegate = self;
        [self.loadingView.layer addAnimation:fullRotation forKey:@"360"];
    }];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    _rotating = NO;
    if(_loading)
    {
        [self animateOneRound];
    }
}

#pragma mark -

- (void)setLoading:(BOOL)loading
{
    if(_loading == loading) return;
    _loading = loading;
    [self updateButtonAnimated:YES];
}
- (void)setPlaying:(BOOL)playing
{
    if(_playing == playing) return;
    _playing = playing;
    [self updateButtonAnimated:YES];
}

@end
