//
//  TPListModel.h
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPListModel;



@interface TPListSection : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) NSArray *items;

- (id)initWithTitle:(NSString *)title items:(NSArray *)items;
+ (id)sectionWithTitle:(NSString *)title items:(NSArray *)items;

@end


#pragma mark -

@protocol  TPListModelDelegate <NSObject>

@optional
- (void)listModelDidFinish:(TPListModel *)listModel;
- (void)listModel:(TPListModel *)listModel didFailWithError:(NSError *)error;

@end

@interface TPListModel : NSObject

@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSArray *sections2;
@property (nonatomic, retain) NSArray *indexTitles;
@property (nonatomic, retain) id<TPListModelDelegate> delegate;
@property (nonatomic, retain) id parameters;

- (void)loadForced:(BOOL)forced;
- (void)cancel;
- (void)clear;

- (void)sendFinished;
- (void)sendError:(NSError *)error;

- (id)initWithParameters:(id)parameters;
- (id)initWithSections:(NSArray *)sections;

- (id)dataForRow:(NSInteger)row section:(NSInteger)section;
- (id)dataForIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;

@end
