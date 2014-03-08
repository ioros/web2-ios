//
//  TPContributionData.h
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPData.h"

@class TPShowData;

@interface TPContributionData : TPData

@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) TPShowData *show;

@end
