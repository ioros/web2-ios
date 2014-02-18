//
//  NSDictionary+TPModelAdditions.h
//  TilosPlayer
//
//  Created by Daniel Langh on 12/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TPModelAdditions)

- (NSArray *)episodeContributorNicknames;
- (NSInteger)episodeStartSeconds;
- (NSString *)episodeName;
- (NSString *)episodeDefinition;
- (NSURL *)episodeBannerUrl;
- (NSDate *)episodePlannedFromDate;

- (NSString *)showName;
- (NSURL *)showBannerUrl;
- (NSString *)showDefinition;

- (NSString *)authorName;
- (NSString *)authorNick;
- (NSURL *)authorAvatar;
- (NSURL *)authorPhoto;

@end
