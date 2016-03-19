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
    
    // TODO: remove this if server is fixed
    NSString *name = [object objectForKeyOrNil:@"name"];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    TPAuthorData *data = [TPAuthorData new];
    data.name = name;
    data.identifier = [object objectForKey:@"id"];
    data.avatarURL = [NSString stringWithFormat:@"http://tilos.hu/upload/%@",[object objectForKey:@"avatar"]];
//    data.photoURL = [object objectForKey:@"photo"];
    data.alias = [object objectForKey:@"alias"];
    
    NSString *introduction = [object objectForKeyOrNil:@"introduction"];
    if([introduction isEqualToString:@""]) introduction = nil;
    data.introduction = introduction;
    
    data.contributions = [TPContributionData parseWithObjects:[object objectForKeyOrNil:@"contributions"]];
    
    return data;
}

#pragma mark -

- (NSArray *)nickNames
{
    NSMutableDictionary *nickNames = [NSMutableDictionary dictionary];
    
    for(TPContributionData *contribution in self.contributions)
    {
        [nickNames setObject:[NSNumber numberWithBool:YES] forKey:contribution.nick];
    }
    return nickNames.allKeys;
}

@end
