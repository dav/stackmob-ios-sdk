/*
 * Copyright 2012 StackMob
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

extern NSString *const SMIncrementalStoreType;
extern NSString *const SM_DataStoreKey;

/**
 `SMIncrementalStore` is the foundation used to integrate StackMob into Core Data.
 
 ## How it works ##
 
 `NSIncrementalStore` provides an abstract class to subclass and override methods which are called by Core Data's persistent store coordinator and managed object context throughout application execution.  This allows communication to a remote backend API rather than the standard SQLite database.
 
 Most methods involve contacting the remote backend, in this case StackMob, for information requested by Core Data.  This data is then used to decide whether to persist the in-memory version of an object to the remote backend or to discard it for what already exists.  Core Data still handles merge conflict resolution with the supplied `NSMergePolicy`.
 
 The primary methods that have been overridden are:
 
 * `loadMetadata:`
 * `executeRequest:withContext:error:`
 * `newValuesForObjectWithID:withContext:error:`
 * `newValueForRelationship:forObjectWithID:withContext:error:`
 * `obtainPermanentIDsForObjects:error:`
 
 For more information on each method and StackMob's implementation see `SMIncrementalStore.m`.
 
 ## References ##
 
 [Apple's NSIncrementalStore class reference](http://developer.apple.com/library/ios/documentation/CoreData/Reference/NSIncrementalStore_Class/Reference/NSIncrementalStore.html)
 
 @note You should never have to instantiate your own instance of `SMIncrementalStore`.  It is used when creating a persistent store coordinator in `SMCoreDataStore` so that `NSPersistentStore` methods divert to the overridden versions in this class. 
 */
@interface SMIncrementalStore : NSIncrementalStore

@end
