//
//  TPAuthorData.h
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPData.h"

@interface TPAuthorData : TPData

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *alias;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *photoURL;
@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) NSString *introduction;
@property (nonatomic, retain) NSArray *contributions;

@property (nonatomic, readonly) NSArray *nickNames;

@end
