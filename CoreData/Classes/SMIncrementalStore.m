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

/*
 NOTE: Most of the comments on this page reference Apple's NSIncrementalStore Class Reference.
 */

#import "SMIncrementalStore.h"
#import "StackMob.h"


NSString *const SMIncrementalStoreType = @"SMIncrementalStore";
NSString *const SM_DataStoreKey = @"SM_DataStoreKey";

@interface SMIncrementalStore () {
    NSMutableDictionary *cache;
}

@property (nonatomic, strong) SMDataStore *smDataStore;

- (id)handleSaveRequest:(NSPersistentStoreRequest *)request 
            withContext:(NSManagedObjectContext *)context 
                  error:(NSError *__autoreleasing *)error;

- (id)handleFetchRequest:(NSPersistentStoreRequest *)request 
             withContext:(NSManagedObjectContext *)context 
                   error:(NSError *__autoreleasing *)error;

- (BOOL)relationshipsPresentInSerializedDict:(NSDictionary *)sm_dict object:(id)anObject;

- (NSDictionary *)sm_responseSerializationForDictionary:(NSDictionary *)theObject schemaEntityDescription:(NSEntityDescription *)entityDescription managedObjectContext:(NSManagedObjectContext *)context;

@end

@implementation SMIncrementalStore

@synthesize smDataStore = _smDataStore;


- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root configurationName:(NSString *)name URL:(NSURL *)url options:(NSDictionary *)options {
    
    self = [super initWithPersistentStoreCoordinator:root configurationName:name URL:url options:options];
    if (self) {
        cache = [NSMutableDictionary dictionary];
        _smDataStore = [options objectForKey:SM_DataStoreKey];
    }
    return self;
}

/*
Once a store has been created, the persistent store coordinator invokes loadMetadata: on it. In your implementation, if all goes well you should typically load the store metadata, call setMetadata: to store the metadata, and return YES. If an error occurs, however (if the store is invalid for some reason—for example, if the store URL is invalid, or the user doesn’t have read permission for the store URL), create an NSError object that describes the problem, assign it to the error parameter passed into the method, and return NO.

In the specific case where the store is new, you may choose not to generate metadata in loadMetadata:, but instead allow it to be automatically generated. In this case, the call to setMetadata: is not necessary.

If the metadata is generated automatically, the store identifier will set to a generated UUID. To override this automatic UUID generation, override identifierForNewStoreAtURL: to return an appropriate value. Store identifiers should either be persisted as part of the store metadata, or uniquely derivable in some way such that a given store will have the same identifier even if added to multiple persistent store coordinators. The identifier may be any type of object, although if you want object IDs created by your store to respond to URIRepresentation or for managedObjectIDForURIRepresentation: to be able to parse the generated URI representation, it should be an instance of NSString.
 
 Note: loadMetadata: should ignore any potential skew between the store and the model in use by the coordinator; this will bee handled automatically by the persistent store coordinator later. It is sufficient to return the version hashes that were saved in the store metadata the last time the store was saved (if the store is new the version hashes for the current model in use should be returned).
 
 In your implementation of this method, you must validate that the URL used to create the store is usable (the location exists and if necessary is writable, the schema is compatible, and so on) and return an error if there is an issue.
 
*/
- (BOOL)loadMetadata:(NSError *__autoreleasing *)error {
    DLog();
    NSString* uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    [self setMetadata:[NSDictionary dictionaryWithObjectsAndKeys:
                       SMIncrementalStoreType, NSStoreTypeKey, 
                       uuid, NSStoreUUIDKey, 
                       @"Something user defined", @"Some user defined key",
                       nil]];
    return YES;
}

/*
Return Value
A value as appropriate for request, or nil if the request cannot be completed

Discussion
The value to return depends on the result type (see resultType) of request:

You should implement this method conservatively, and expect that unknown request types may at some point be passed to the method. The correct behavior in these cases is to return nil and an error.
*/

- (id)executeRequest:(NSPersistentStoreRequest *)request 
         withContext:(NSManagedObjectContext *)context 
               error:(NSError *__autoreleasing *)error {
    DLog();
    id result = nil;
    switch (request.requestType) {
        case NSSaveRequestType:
            result = [self handleSaveRequest:request withContext:context error:error];
            break;
        case NSFetchRequestType:
            result = [self handleFetchRequest:request withContext:context error:error];
            break;
        default:
            NSAssert(false, @"Unknown request type.");
            break;
    }
    
    //
    // Workaround for gnarly bug.
    //
    // I believe the issue is in NSManagedObjectContext -executeFetchRequest:error:, which seems to be releasing the error object.
    // We work around by manually incrementing the object's retain count.
    //
    // For details, see:
    //
    //   https://devforums.apple.com/message/560644#560644
    //   http://clang.llvm.org/docs/AutomaticReferenceCounting.html#objects.operands.casts
    //   http://developer.apple.com/library/ios/#releasenotes/ObjectiveC/RN-TransitioningToARC
    //
    
    if (result == nil) {
        *error = (__bridge id)(__bridge_retained CFTypeRef)*error;
    }
    
    return result;
}

/*
 If the request is a save request, you record the changes provided in the request’s insertedObjects, updatedObjects, and deletedObjects collections. Note there is also a lockedObjects collection; this collection contains objects which were marked as being tracked for optimistic locking (through the detectConflictsForObject:: method); you may choose to respect this or not.
 In the case of a save request containing objects which are to be inserted, executeRequest:withContext:error: is preceded by a call to obtainPermanentIDsForObjects:error:; Core Data will assign the results of this call as the objectIDs for the objects which are to be inserted. Once these IDs have been assigned, they cannot change. 
 
 Note that if an empty save request is received by the store, this must be treated as an explicit request to save the metadata, but that store metadata should always be saved if it has been changed since the store was loaded.

 If the request is a save request, the method should return an empty array.
 If the save request contains nil values for the inserted/updated/deleted/locked collections; you should treat it as a request to save the store metadata.
 
 @note: We are *IGNORING* locked objects. We are also not handling the metadata save requests, because AFAIK we don't need to generate any.
 */
- (id)handleSaveRequest:(NSPersistentStoreRequest *)request 
            withContext:(NSManagedObjectContext *)context 
                  error:(NSError *__autoreleasing *)error {
    DLog();
    NSSaveChangesRequest *saveRequest = [[NSSaveChangesRequest alloc] initWithInsertedObjects:[context insertedObjects] updatedObjects:[context updatedObjects] deletedObjects:[context deletedObjects] lockedObjects:nil];
    
    NSSet *insertedObjects = [saveRequest insertedObjects];
    if ([insertedObjects count] > 0) {
        BOOL insertSuccess = [self handleInsertedObjects:insertedObjects inContext:context error:error];
        if (!insertSuccess) {
            return nil;
        }
    }
    NSSet *updatedObjects = [saveRequest updatedObjects];
    if ([updatedObjects count] > 0) {
        BOOL updateSuccess = [self handleUpdatedObjects:updatedObjects inContext:context error:error];
        if (!updateSuccess) {
            return nil;
        }
    }
    NSSet *deletedObjects = [saveRequest deletedObjects];
    if ([deletedObjects count] > 0) {
        BOOL deleteSuccess = [self handleDeletedObjects:deletedObjects inContext:context error:error];
        if (!deleteSuccess) {
            return nil;
        }
    }
    
    return [NSArray array];
}

- (BOOL)handleInsertedObjects:(NSSet *)insertedObjects inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    DLog();
    __block BOOL success = NO;
    DLog(@"objects to be inserted are %@", insertedObjects);
    [insertedObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
            NSDictionary *objDict = [obj sm_dictionarySerialization];
            NSString *schemaName = [obj sm_schema];
            DLog(@"serialized object is %@", objDict);
            // add relationship headers if needed
            NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
            if ([self relationshipsPresentInSerializedDict:objDict object:obj]) {
                [headerDict setObject:[obj sm_relationshipHeader] forKey:@"X-StackMob-Relations"];
            }
            
            [self.smDataStore createObject:objDict inSchema:schemaName options:[SMRequestOptions optionsWithHeaders:headerDict] onSuccess:^(NSDictionary *theObject, NSString *schema) {
                DLog(@"SMIncrementalStore inserted object with id %@ on schema %@", theObject, schema);
                success = YES;
                // TO-DO OFFLINE-SUPPORT
                //[self cacheInsert:theObject forEntity:[obj entity] inContext:context];
                syncReturn(semaphore);
            } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                DLog(@"SMIncrementalStore failed to insert object with id %@ on schema %@", theObject, schema);
                DLog(@"the error userInfo is %@", [theError userInfo]);
                success = NO;
                *error = (__bridge id)(__bridge_retained CFTypeRef)theError;
                syncReturn(semaphore);
            }];
        });
        if (success == NO)
            *stop = YES;
    }];
    return success;
}

- (BOOL)handleUpdatedObjects:(NSSet *)updatedObjects inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    DLog();
    __block BOOL success = NO;
    DLog(@"objects to be updated are %@", updatedObjects);
    [updatedObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
            
            NSDictionary *objDict = [obj sm_dictionarySerialization];
            NSString *schemaName = [obj sm_schema];
            DLog(@"serialized object is %@", objDict);
            // if there are relationships present in the update, send as a POST
            if ([self relationshipsPresentInSerializedDict:objDict object:obj]) {
                NSDictionary *headerDict = [NSDictionary dictionaryWithObject:[obj sm_relationshipHeader] forKey:@"X-StackMob-Relations"];
                [self.smDataStore createObject:objDict inSchema:schemaName options:[SMRequestOptions optionsWithHeaders:headerDict] onSuccess:^(NSDictionary *theObject, NSString *schema) {
                    DLog(@"SMIncrementalStore inserted object with id %@ on schema %@", theObject, schema);
                    success = YES;
                    // TO-DO OFFLINE-SUPPORT
                    //[self cacheInsert:theObject forEntity:[obj entity] inContext:context];
                    syncReturn(semaphore);
                } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                    DLog(@"SMIncrementalStore failed to insert object with id %@ on schema %@", theObject, schema);
                    DLog(@"the error userInfo is %@", [theError userInfo]);
                    success = NO;
                    *error = (__bridge id)(__bridge_retained CFTypeRef)theError;
                    syncReturn(semaphore);
                }];
            } else {
                [self.smDataStore updateObjectWithId:[obj sm_objectId] inSchema:schemaName update:objDict onSuccess:^(NSDictionary *theObject, NSString *schema) {
                    DLog(@"SMIncrementalStore updated object with id %@ on schema %@", theObject, schema);
                    success = YES;
                    // TO-DO OFFLINE-SUPPORT
                    //[self cacheInsert:theObject forEntity:[obj entity] inContext:context];
                    syncReturn(semaphore);
                } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                    DLog(@"SMIncrementalStore failed to update object with id %@ on schema %@", theObject, schema);
                    DLog(@"the error userInfo is %@", [theError userInfo]);
                    success = NO;
                    *error = (__bridge id)(__bridge_retained CFTypeRef)theError;
                    syncReturn(semaphore);
                }];
            }
            
        });
        if (success == NO)
            *stop = YES;
    }];
    return success;
}

- (BOOL)handleDeletedObjects:(NSSet *)deletedObjects inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    DLog();
    __block BOOL success = NO;
    DLog(@"objects to be deleted are %@", deletedObjects);
    [deletedObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {        
        syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
            NSString *schemaName = [obj sm_schema];
            NSString *uuid = [obj sm_objectId];
            [self.smDataStore deleteObjectId:uuid inSchema:schemaName onSuccess:^(NSString *theObjectId, NSString *schema) {
                DLog(@"SMIncrementalStore deleted object with id %@ on schema %@", theObjectId, schema);
                success = YES;
                syncReturn(semaphore);
            } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                DLog(@"SMIncrementalStore failed to delete object with id %@ on schema %@", theObjectId, schema);
                DLog(@"the error userInfo is %@", [theError userInfo]);
                success = NO;
                *error = (__bridge id)(__bridge_retained CFTypeRef)theError;
                syncReturn(semaphore);
            }];
            if (success) {
                // TO-DO OFFLINE-SUPPORT
                //[self cachePurge:[obj objectID]];
            }
        });
        if (success == NO)
            *stop = YES;
    }];
    return success;
}

/*
 If it is NSCountResultType, the method should return an array containing an NSNumber whose value is the count of of all objects in the store matching the request.
 
 You must support the following properties of NSFetchRequest: entity, predicate, sortDescriptors, fetchLimit, resultType, includesSubentities, returnsDistinctResults (in the case of NSDictionaryResultType), propertiesToFetch (in the case of NSDictionaryResultType), fetchOffset, fetchBatchSize, shouldRefreshFetchedObjects, propertiesToGroupBy, and havingPredicate. If a store does not have underlying support for a feature (propertiesToGroupBy, havingPredicate), it should either emulate the feature in memory or return an error. Note that these are the properties that directly affect the contents of the array to be returned.
 
 You may optionally ignore the following properties of NSFetchRequest: includesPropertyValues, returnsObjectsAsFaults, relationshipKeyPathsForPrefetching, and includesPendingChanges (this is handled by the managed object context). (These are properties that allow for optimization of I/O and do not affect the results array contents directly.)
*/
- (id)handleFetchRequest:(NSPersistentStoreRequest *)request 
             withContext:(NSManagedObjectContext *)context 
                   error:(NSError * __autoreleasing *)error {
    DLog();
    NSFetchRequest *fetchRequest = (NSFetchRequest *)request;
    switch (fetchRequest.resultType) {
        case NSManagedObjectResultType:
            return [self fetchObjects:fetchRequest withContext:context error:error];
            break;
        case NSManagedObjectIDResultType:
            return [self fetchObjectIDs:fetchRequest withContext:context error:error];
            break;
        case NSDictionaryResultType:
            NSAssert(false, @"Unimplemented result type requested."); 
            break;
        case NSCountResultType:
            NSAssert(false, @"Unimplemented result type requested."); 
            break;
        default:
            NSAssert(false, @"Unknown result type requested."); 
            break;
    }
    return nil;
}

// Returns NSArray<NSManagedObject>

- (id)fetchObjects:(NSFetchRequest *)fetchRequest withContext:(NSManagedObjectContext *)context error:(NSError * __autoreleasing *)error {
    DLog();
    SMQuery *query = [SMIncrementalStore queryForFetchRequest:fetchRequest error:error];

    if (query == nil) {
        return nil;
    }
    
    __block id resultsWithoutOID;
    synchronousQuery(self.smDataStore, query, ^(NSArray *results) {
        resultsWithoutOID = results;
    }, ^(NSError *theError) {
        *error = (__bridge id)(__bridge_retained CFTypeRef)theError;
    });

    return [resultsWithoutOID map:^(id item) {
        // TO-DO OFFLINE-SUPPORT
        //NSManagedObjectID *oid = [self cacheInsert:item forEntity:fetchRequest.entity inContext:context];
        
        
        NSString *primaryKeyField = [fetchRequest.entity sm_primaryKeyField];
        id remoteID = [item objectForKey:primaryKeyField];
        if (!remoteID) {
            [NSException raise:SMExceptionIncompatibleObject format:@"No key for remote name"];
        }
        NSManagedObjectID *oid = [self newObjectIDForEntity:fetchRequest.entity referenceObject:remoteID];
        return [context objectWithID:oid];
    }];
}

// Returns NSArray<NSManagedObjectID>

- (id)fetchObjectIDs:(NSFetchRequest *)fetchRequest withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
    DLog();
    NSArray *objects = [self fetchObjects:fetchRequest withContext:context error:error];
    return [objects map:^(id item) {
        return [item objectID];
    }];
}

/*
 Returns an incremental store node encapsulating the persistent external values of the object with a given object ID.
 Return Value
   An incremental store node encapsulating the persistent external values of the object with object ID objectID, or nil if the corresponding object cannot be found.
 
 Discussion
 The returned node should include all attributes values and may include to-one relationship values as instances of NSManagedObjectID.
 
 If an object with object ID objectID cannot be found, the method should return nil and—if error is not NULL—create and return an appropriate error object in error.
 */

// NOTE:
// Basically, this resolves a fault into the actual materialized object.

/*
 * Returns an incremental store node encapsulating the persistent external values of the object with a given object ID.
 The returned node should include all attributes values and may include to-one relationship values as instances of NSManagedObjectID.
    
 */
- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context 
                                               error:(NSError *__autoreleasing *)error {
    
    DLog(@"new values for object with id %@", [context objectWithID:objectID]);
    // TO DO OFFLINE SUPPORT
    // NSDictionary *objectFields = [cache objectForKey:objectID];
    // Make a GET call to SM and return the properties for the entity
    __block NSManagedObject *theObj = [context objectWithID:objectID];
    __block NSEntityDescription *objEntity = [theObj entity];
    __block NSString *schemaName = [[objEntity name] lowercaseString];
    __block NSString *objStringId = [self referenceObjectForObjectID:objectID];
    __block BOOL success = NO;
    __block NSDictionary *objectFields;
    
    
    
    syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
        [self.smDataStore readObjectWithId:objStringId inSchema:schemaName onSuccess:^(NSDictionary *theObject, NSString *schema) {
            objectFields = [self sm_responseSerializationForDictionary:theObject schemaEntityDescription:objEntity managedObjectContext:context];
            success = YES;
            syncReturn(semaphore);
        } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
            DLog(@"Could not read the object with objectId %@ and error userInfo %@", theObjectId, [theError userInfo]);
            success = NO;
            if (nil != error) {
                // TO DO provide sm specific error
                *error = [[NSError alloc] initWithDomain:[theError domain] code:[theError code] userInfo:[theError userInfo]];
            }
            syncReturn(semaphore);
        }];
    });
    
    if (!success) {
        return nil;
    }

    NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:objectFields version:1];
    
    return node;
}

/*
 Return Value
 The value of the relationship specified relationship of the object with object ID objectID, or nil if an error occurs.
 
 Discussion
 If the relationship is a to-one, the method should return an NSManagedObjectID instance that identifies the destination, or an instance of NSNull if the relationship value is nil.
 
 If the relationship is a to-many, the method should return a collection object containing NSManagedObjectID instances to identify the related objects. Using an NSArray instance is preferred because it will be the most efficient. A store may also return an instance of NSSet or NSOrderedSet; an instance of NSDictionary is not acceptable.
 
 If an object with object ID objectID cannot be found, the method should return nil and—if error is not NULL—create and return an appropriate error object in error.
 */
- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID 
                  withContext:(NSManagedObjectContext *)context 
                        error:(NSError *__autoreleasing *)error {
    DLog(@"new value for relationship %@ for object with id %@", relationship, objectID);
    
    __block NSManagedObject *theObj = [context objectWithID:objectID];
    __block NSEntityDescription *objEntity = [theObj entity];
    __block NSString *schemaName = [[objEntity name] lowercaseString];
    __block NSString *objStringId = [self referenceObjectForObjectID:objectID];
    __block BOOL success = NO;
    __block NSDictionary *objDict;

    syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
        [self.smDataStore readObjectWithId:objStringId inSchema:schemaName onSuccess:^(NSDictionary *theObject, NSString *schema) {
            objDict = theObject;
            success = YES;
            syncReturn(semaphore);
        } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
            DLog(@"Could not read the object with objectId %@ and error userInfo %@", theObjectId, [theError userInfo]);
            success = NO;
            if (nil != error) {
                // TO DO provide sm specific error
                *error = [[NSError alloc] initWithDomain:[theError domain] code:[theError code] userInfo:[theError userInfo]];
            }
            syncReturn(semaphore);
        }];
    });
    
    if (!success) {
        return nil;
    }
    
    id relationshipContents = [objDict valueForKey:[relationship name]];
    if (relationshipContents) {
        if ([relationship isToMany]) {
            NSAssert([relationshipContents isKindOfClass:[NSArray class]], @"Relationship contents should be an array for a to-many relationship");
            NSMutableArray *arrayToReturn = [NSMutableArray array];
            [(NSSet *)relationshipContents enumerateObjectsUsingBlock:^(id stringIdReference, BOOL *stop) {
                NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:[relationship destinationEntity] referenceObject:stringIdReference];
                [arrayToReturn addObject:relationshipObjectID];
            }];
            return arrayToReturn;
            
        } else {
            NSAssert([relationshipContents isKindOfClass:[NSString class]], @"Relationship contents should be a string for a to-one relationship");
            NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:[relationship destinationEntity] referenceObject:relationshipContents];
            return relationshipObjectID;
        }

    } else {
        return [NSNull null];
    }
        
    // TO DO OFFLINE SUPPORT
    /*
    id theObject = [cache objectForKey:objectID];
    if (!theObject) {
        // add an error here if needed
        return nil;
    }
    if ([relationship isToMany]) {

        NSArray *relationshipInstances = [theObject valueForKey:[relationship name]];
        
        return relationshipInstances != nil ? relationshipInstances : [NSArray array];
        
    } else {
        // to-one relationship
        id relationshipInstance = [theObject valueForKey:[relationship name]];
        
        if (relationshipInstance == nil) {
            return [NSNull null];
        } else {
            return relationshipInstance;
        }
    }
     */

}

/*
 Returns an array containing the object IDs for a given array of newly-inserted objects.
 This method is called before executeRequest:withContext:error: with a save request, to assign permanent IDs to newly-inserted objects.
 */
- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array 
                                    error:(NSError *__autoreleasing *)error {
    DLog(@"obtain permanent ids for objects: %@", array);
    // check if array is null, return empty array if so
    if (array == nil) {
        return [NSArray array];
    }
    
    if (*error) { 
        DLog(@"error with obtaining perm ids is %@", *error);
        *error = (__bridge id)(__bridge_retained CFTypeRef)*error;
    }
    
    return [array map:^id(id item) {
        NSString *itemId = [item sm_objectId];
        if (!itemId) {
            [NSException raise:SMExceptionIncompatibleObject format:@"Item not previously assigned an object ID for it's primary key field, which is used to obtain a permanent ID for the Core Data object.  Before a call to save on the managedObjectContext, be sure to assign an object ID.  This looks something like [newManagedObject setValue:[newManagedObject sm_assignObjectId] forKey:[newManagedObject sm_primaryKeyField]].  The item in question is %@", item];
        } 
        
        NSManagedObjectID *returnId = [self newObjectIDForEntity:[item entity] referenceObject:itemId];
        DLog(@"Permanent ID assigned is %@", returnId);
        
        return returnId;
    }];
}
     
#pragma mark - Object store
/*
 To be used for offline support.  This method takes a dictionary object from a StackMob response and places it in a dictionary cache, where the key is the returned NSManagedObjectID.  All primary key and relationship fields have their string ID representations casted to instances of NSManagedObjectID so Core Data can reference the corresponding objects.
 */
- (NSManagedObjectID *)cacheInsert:(NSDictionary *)values forEntity:(NSEntityDescription *)entityDescription inContext:(NSManagedObjectContext *)context {
    DLog();
    
    // TO-DO: GET THE PRIMARY FIELD KEY VS REMOTE KEY
    
    NSString *remoteKey = [self remoteKeyForEntityName:entityDescription.name];
    id remoteID = [values objectForKey:remoteKey];
    
    // Get an object ID from NSIncrementalStore
    NSManagedObjectID *objectID = [self newObjectIDForEntity:entityDescription referenceObject:remoteID];
    
    // if the object exists in the cache already, remove it and insert the new version from the server
    if ([cache objectForKey:objectID] != nil) {
        [self cachePurge:objectID];
    }
    __block NSMutableDictionary *mutableValues = [NSMutableDictionary dictionary];;
    [entityDescription.propertiesByName enumerateKeysAndObjectsUsingBlock:^(id propertyName, id property, BOOL *stop) {
        if ([property isKindOfClass:[NSAttributeDescription class]]) {
            NSAttributeDescription *attributeDescription = (NSAttributeDescription *)property;
            if (attributeDescription.attributeType != NSUndefinedAttributeType) {
                id value = [values valueForKey:(NSString *)propertyName];
                [mutableValues setObject:value forKey:propertyName];
            }
        }
        else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
            NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
            
            // get the relationship contents for the property
            id relationshipContents = [values valueForKey:propertyName];
            if (relationshipContents) {
                if ([relationship isToMany]) {
                    NSMutableArray *relationshipIds = [NSMutableArray array];
                    [(NSSet *)relationshipContents enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        
                        // if obj is string (reference to id), cast to NSManagedObjectId
                        if ([obj isKindOfClass:[NSString class]]) {
                            NSEntityDescription *entityDescriptionForRelationship = [NSEntityDescription entityForName:[[relationship destinationEntity] name] inManagedObjectContext:context];
                            NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:entityDescriptionForRelationship referenceObject:obj];
                            [relationshipIds addObject:relationshipObjectID];
                        }
                        // else create the NSMangedObjectId from the primary key field
                        else {
                            NSEntityDescription *entityDescriptionForRelationship = [NSEntityDescription entityForName:[[obj entity] name] inManagedObjectContext:context];
                            NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:entityDescriptionForRelationship referenceObject:[obj valueForKey:[obj sm_primaryKeyField]]];
                            [relationshipIds addObject:relationshipObjectID];
                        }
                    }];
                    [mutableValues setObject:relationshipIds forKey:propertyName];
                } else {
                    NSEntityDescription *entityDescriptionForRelationship = [NSEntityDescription entityForName:[[property destinationEntity] name] inManagedObjectContext:context];
                    
                    // if relationshipContents is string (reference to id), cast to NSManagedObjectId
                    if ([relationshipContents isKindOfClass:[NSString class]]) {
                        NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:entityDescriptionForRelationship referenceObject:relationshipContents];
                        [mutableValues setObject:relationshipObjectID forKey:propertyName];
                    }
                    // else create the NSMangedObjectId from the primary key field
                    else {
                        NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:entityDescriptionForRelationship referenceObject:[relationshipContents objectForKey:[self remoteKeyForEntityName:propertyName]]];
                        [mutableValues setObject:relationshipObjectID forKey:propertyName];
                    }
                }
            }
            
        }
    }];
    
    [cache setObject:mutableValues forKey:objectID];
    return objectID;
}

/*
 Removes an object from the cache.
 */
- (void)cachePurge:(NSManagedObjectID *)objectID {
    [cache removeObjectForKey:objectID];
}

- (NSString *)remoteKeyForEntityName:(NSString *)entityName {
    return [[entityName lowercaseString] stringByAppendingString:@"_id"];
}

/*
 Returns whether relationship references are present in the StackMob dictionary representation of a Core Data NSManagedObject.
 */
- (BOOL)relationshipsPresentInSerializedDict:(NSDictionary *)sm_dict object:(id)anObject
{
    NSEntityDescription *objectEntityDescription = [anObject entity];
    if ([[objectEntityDescription relationshipsByName] count] > 0) {
        
        // check if the relationships are non-nil and we should add headers
        __block NSArray *sm_dictAllKeys = [sm_dict allKeys];
        for (NSString *relationshipName in [[objectEntityDescription relationshipsByName] allKeys]) {
            if ([sm_dictAllKeys indexOfObject:relationshipName] != NSNotFound) {
                return YES;
            }
        }
    }
    return NO;
}

/*
 Returns a dictionary that has extra fields from StackMob that aren't present as attributes or relationships in the Core Data representation stripped out.  Examples may be StackMob added createddate or lastmoddate.
 
 Used for newValuesForObjectWithID:.
 */
- (NSDictionary *)sm_responseSerializationForDictionary:(NSDictionary *)theObject schemaEntityDescription:(NSEntityDescription *)entityDescription managedObjectContext:(NSManagedObjectContext *)context
{
    __block NSMutableDictionary *serializedDictionary = [NSMutableDictionary dictionary];
    
    [entityDescription.propertiesByName enumerateKeysAndObjectsUsingBlock:^(id propertyName, id property, BOOL *stop) {
        if ([property isKindOfClass:[NSAttributeDescription class]]) {
            NSAttributeDescription *attributeDescription = (NSAttributeDescription *)property;
            if (attributeDescription.attributeType != NSUndefinedAttributeType) {
                id value = [theObject valueForKey:(NSString *)propertyName];
                if (value != nil) {
                    [serializedDictionary setObject:value forKey:propertyName];
                }
            }
        }
        else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
            NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
            // get the relationship contents for the property
            id relationshipContents = [theObject valueForKey:propertyName];
            if (relationshipContents) {
                if (![relationship isToMany]) {
                    NSEntityDescription *entityDescriptionForRelationship = [NSEntityDescription entityForName:[[property destinationEntity] name] inManagedObjectContext:context];
                    if ([relationshipContents isKindOfClass:[NSString class]]) {
                        NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:entityDescriptionForRelationship referenceObject:relationshipContents];
                        [serializedDictionary setObject:relationshipObjectID forKey:propertyName];
                    }
                }
            }
            
        }        
    }];
    
    return serializedDictionary;
}

@end
