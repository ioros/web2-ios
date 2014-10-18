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
        
        self.buttonView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.buttonView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.buttonView];
        
        _playing = NO;
        _loading = NO;
        _rotating = NO;
        
        [self updateButton];
    }
    return self;
}

- (void)updateButton
{
    self.buttonView.image = _playing ? [UIImage imageNamed:@"PauseButton.png"] : [UIImage imageNamed:@"PlayButton.png"];
    self.circleView.image = _loading ? [UIImage imageNamed:@"PlayLoading.png"] : [UIImage imageNamed:@"PlayCircle.png"];
    
    if(_loading)
    {
        [self animateOneRound];
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
        [self.circleView.layer addAnimation:fullRotation forKey:@"360"];
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
    _loading = loading;
    [self updateButton];
}
- (void)setPlaying:(BOOL)playing
{
    _playing = playing;
    [self updateButton];
}

@end
