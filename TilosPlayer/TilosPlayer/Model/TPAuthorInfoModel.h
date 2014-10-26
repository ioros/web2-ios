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

@class TPAuthorData;

@interface TPAuthorInfoModel : TPListModel

@property (nonatomic, strong) AFHTTPRequestOperation *operation;

@property (nonatomic, strong) TPAuthorData *author;
@property (nonatomic, strong) NSString *introHTML;
@property (nonatomic, assign) BOOL introAvailable;

@end
