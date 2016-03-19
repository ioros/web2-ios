//
//  TPTextData.m
//  TilosPlayer
//
//  Created by Oros Imre on 2016. 03. 13..
//  Copyright © 2016. rumori. All rights reserved.
//

#import "TPTextData.h"
#import "TPEpisodeData.h"

@implementation TPTextData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    TPTextData *data = [TPTextData new];
    if([object isKindOfClass:[NSNull class]]) {
        data.title = @"";
        data.type = @"";
        data.format = @"";
        data.content = @"";
        data.formatted = @"";
    } else {
        data.title = [object objectForKeyOrNil:@"title"];
        data.type = [object objectForKeyOrNil:@"type"];
        data.format = [object objectForKeyOrNil:@"format"];
        data.content = [object objectForKeyOrNil:@"content"];
        data.formatted = [object objectForKeyOrNil:@"formatted"];
    }
    return data;
}


@end
