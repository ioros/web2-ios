//
//  TPContributorData.h
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPData.h"

@class TPAuthorData;

@interface TPContributorData : TPData

@property (nonatomic, retain) TPAuthorData *author;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *alias;

@end
