//
//  TPAuthorInfoModel.h
//  TilosPlayer
//
//  Created by Tibor Kántor on 14/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPListModel.h"

/**
 *  Description: Encapsulates
 */

typedef NS_ENUM(NSInteger, AwailableInfoType){
    kContributionsOnly,
    kContributionsAndIntroduction,
    kIntroductionOnly,
    kNoInfoAwailable
};

@class TPAuthorData;

@interface TPAuthorInfoModel : TPListModel

@property (nonatomic, strong) AFHTTPRequestOperation *operation;

@property (nonatomic, strong) TPAuthorData *author;
@property (nonatomic, strong) NSArray *contributions;
@property (nonatomic, strong) NSString *htmlString;

-(AwailableInfoType)awailableInfo;

@end
