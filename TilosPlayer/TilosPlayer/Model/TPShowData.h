//
//  TPShowData.h
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPData.h"

@interface TPShowData : TPData

@property (nonatomic, retain) NSNumber *identifier;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *alias;
@property (nonatomic, retain) NSString *bannerURL;
@property (nonatomic, retain) NSString *definition;
@property (nonatomic, retain) NSString *infoHTML;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *status;

@property (nonatomic, retain) NSArray *contributors;
@property (nonatomic, retain) NSArray *episodes;

@end
