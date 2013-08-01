//
//  SerializedDataStorage.m
//  SerializedDataStorage
//
//  Created by Hirohisa Kawasaki on 13/07/31.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "SerializedDataStorage.h"

@implementation SSData
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self dictionary] forKey:@"dictionary"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSDictionary *dictionary = [decoder decodeObjectForKey:@"dictionary"];
    return [self initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.identifier = [dictionary objectForKey:@"id"];
    }
    return self;
}

- (NSDictionary *)dictionary
{
    return @{
             @"id":self.identifier
             };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionary]];
}
@end


@interface SerializedDataStorage ()
@property (nonatomic, readonly) NSMutableArray *records;
@property (nonatomic, readonly) NSString *directoryPath;
@property (nonatomic, readonly) NSString *filePath;
@end

@implementation SerializedDataStorage
+ (SerializedDataStorage *)sharedStorage
{
    static dispatch_once_t onceToken;
    __strong static SerializedDataStorage *_shared = nil;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.maxRecords = 50;
        _records = @[].mutableCopy;
        if ([self existsOrCreatePath]) {
            [self setup];
        }
    }
    return self;
}

- (NSString *)directoryPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/%@", path, NSStringFromClass([self class])];
}

- (NSString *)filePath
{
    return [NSString stringWithFormat:@"%@/%@", self.directoryPath, NSStringFromClass([self class])];
}

- (BOOL)existsOrCreatePath {
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if (![fileManager fileExistsAtPath:self.directoryPath]) {
        return [fileManager createDirectoryAtPath:self.directoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return YES;
}

- (void)setup
{
    if ([self existsOrCreatePath]) {
        NSArray *records = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath];
        if (records) {
            _records = records.mutableCopy;
        }
    }
}

#pragma mark - public
- (void)stackRecord:(SSData *)record
{
    [self removeRecordByIdentifier:record.identifier];
    [self.records insertObject:record atIndex:0];
    [self performSelectorInBackground:@selector(save) withObject:nil];
}

- (void)save
{
    NSInteger length = ([self.records count] < self.maxRecords)?[self.records count]:self.maxRecords;
    NSArray *records = [self.records subarrayWithRange:NSMakeRange(0, length)];
    [NSKeyedArchiver archiveRootObject:records toFile:self.filePath];
}

- (void)removeRecordByIdentifier:(id)identifier
{
    id result = [self fetchResultByIdentifier:identifier];
    if (result) {
        [self.records removeObject:result];
        [self performSelectorInBackground:@selector(save) withObject:nil];
    }
}

- (id)fetchResultByIdentifier:(id)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    NSArray *results = [self fetchResultsByPredicate:predicate];
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)fetchResultsByPredicate:(NSPredicate *)predicate
{
    NSArray *results = [self.records filteredArrayUsingPredicate:predicate];
    if ([results count] > 0) {
        return results;
    }
    return @[];
}

- (NSArray *)fetchAll
{
    return self.records.copy;
}
@end