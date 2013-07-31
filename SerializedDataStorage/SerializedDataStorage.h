//
//  SerializedDataStorage.h
//  SerializedDataStorage
//
//  Created by Hirohisa Kawasaki on 13/07/31.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSData : NSObject <NSCoding>
@property (nonatomic) id identifier;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;
@end

@interface SerializedDataStorage : NSObject
@property (nonatomic) NSInteger maxRecords;
+ (SerializedDataStorage *)sharedStorage;

- (void)stackRecord:(SSData *)record;
- (void)removeRecordByIdentifier:(id)identifier;
- (id)fetchResultByIdentifier:(id)identifier;
- (NSArray *)fetchResultsByPredicate:(NSPredicate *)predicate;
- (NSArray *)fetchAll;
@end