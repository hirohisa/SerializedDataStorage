SerializedDataStorage
==================
SerializedDataStorage is a simple caching class. It uses NSKeyedArchiver, dont use Core Data library.

### Example Usage

insert object
```objective-c
    NSDictionary *dictionary = @{@"id":@(1)};
    SSData *record = [[SSData alloc] initWithDictionary:dictionary];
    [[SerializedDataStorage sharedStorage] stackRecord:record];
```

select all of objects
```objective-c
    - (NSArray *)fetchAll;
```

select objects with conditions
```objective-c
    - (NSArray *)fetchResultsByPredicate:(NSPredicate *)predicate;
```

select object with identifier 
```objective-c
    - (id)fetchResultByIdentifier:(id)identifier;
```

### Features
* UnitTest
* bugfix Demo.project

### License

SerializedDataStorage is available under the MIT license.
