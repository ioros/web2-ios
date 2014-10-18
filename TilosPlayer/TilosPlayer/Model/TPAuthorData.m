//
//  TPAuthorData.m
//  TilosPlayer
//
//  Created by Daniel Langh on 07/03/14.
//  Copyright (c) 2014 rumori. All rights reserved.
//

#import "TPAuthorData.h"

#import "TPContributionData.h"

@implementation TPAuthorData

+ (instancetype)parseWithObject:(NSDictionary *)object
{
    if(object == nil) return nil;
    
    TPAuthorData *data = [TPAuthorData new];
    data.identifier = [object objectForKey:@"id"];
    data.avatarURL = [object objectForKey:@"avatar"];
    data.photoURL = [object objectForKey:@"photo"];
    data.name = [object objectForKey:@"name"];
    data.alias = [object objectForKey:@"alias"];
    
    data.contributions = [TPContributionData parseWithObjects:[object objectForKeyOrNil:@"contributions"]];
    
    return data;
}

#pragma mark -


@end
