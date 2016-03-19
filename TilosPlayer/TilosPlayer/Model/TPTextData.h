//
//  TPTextData.h
//  TilosPlayer
//
//  Created by Oros Imre on 2016. 03. 13..
//  Copyright © 2016. rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPData.h"

@interface TPTextData : TPData

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *format;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *formatted;

@end