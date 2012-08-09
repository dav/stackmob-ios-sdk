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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SMClient.h"
#import "SMQuery.h"
@class SMUserSession;
@class SMRequestOptions;

/* SMDataStoreSuccessBlock
 
 @param theObject An updated dictionary representation of the requested object.
 @param schema The schema to which the object belongs.
 */
typedef void (^SMDataStoreSuccessBlock)(NSDictionary* theObject, NSString *schema);

/* SMDataStoreObjectIdSuccessBlock
 
 @param theObjectId The object id used in this operation.
 @param schema The schema to which the object belongs.
 */
typedef void (^SMDataStoreObjectIdSuccessBlock)(NSString* theObjectId, NSString *schema);

/* SMDataStoreFailureBlock
 
 @param theError An error object describing the failure.
 @param theObject The dictionary representation of the object sent as part of the failed operation.
 @param schema The schema to which the object belongs.
 */
typedef void (^SMDataStoreFailureBlock)(NSError *theError, NSDictionary* theObject, NSString *schema);

/* SMDataStoreObjectIdFailureBlock
 
 @param theError An error object describing the failure.
 @param theObjectId The object id sent as part of the failed operation.
 @param schema The schema to which the object belongs.
 */
typedef void (^SMDataStoreObjectIdFailureBlock)(NSError *theError, NSString* theObjectId, NSString *schema);

/* SMCountSuccessBlock
 
 @param count The number of objects returned by the query.
 */
typedef void (^SMCountSuccessBlock)(NSNumber *count);

/**
 `SMDataStore` exposes an interface for performing CRUD operations on known StackMob objects and for executing a SMQuery.
 
 As a direct interface to StackMob, `SMDataStore` uses StackMob's terminology:
 - Operations are performed against a specific _schema_ (usually also the name of a model class or of an entity in a managed object model).
 - Objects sent via the API are expressed as a dictionary of _fields_.
 */
@interface SMDataStore : NSObject

@property(nonatomic, readonly, copy) NSString *apiVersion;
@property(nonatomic, readwrite, strong) SMUserSession *session;

///-------------------------------
/// @name Initialize
///-------------------------------

/**
 Initialize a data store.
 
 @param apiVersion The API version of your StackMob application which this `SMDataStore` instance should use.
 @param session An instance of SMUserSession configured with the proper credentials.  This is used to properly authenticate requests.
 
 @return An instance of `SMDataStore` configured with the supplied apiVersion and session.
 */
- (id)initWithAPIVersion:(NSString *)apiVersion session:(SMUserSession *)session;


#pragma mark - CRUD operations
///-------------------------------
/// @name CRUD Operations
///-------------------------------


/** 
 Create a new object in your StackMob datastore.
 
 @param theObject A dictionary describing the object to create on StackMob. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param schema The StackMob schema in which to create this new object.
 @param successBlock A block to invoke after the object is successfully created. Passed the dictionary representation of the response from StackMob and the schema in which the new object was created.
 @param failureBlock A block to invoke if the data store fails to create the specified object. Passed the error returned by StackMob, the dictionary sent with this create request, and the schema in which the object was to be created.
 */
- (void)createObject:(NSDictionary *)theObject
            inSchema:(NSString *)schema
           onSuccess:(SMDataStoreSuccessBlock)successBlock
           onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Create a new object in your StackMob datastore.
 
 @param theObject A dictionary describing the object to create on StackMob. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param schema The StackMob schema in which to create this new object.
 @param options An options object contains headers and other configuration for this request
 @param successBlock A block to invoke after the object is successfully created. Passed the dictionary representation of the response from StackMob and the schema in which the new object was created.
 @param failureBlock A block to invoke if the data store fails to create the specified object. Passed the error returned by StackMob, the dictionary sent with this create request, and the schema in which the object was to be created.
 */
- (void)createObject:(NSDictionary *)theObject
            inSchema:(NSString *)schema
         withOptions:(SMRequestOptions *)options
           onSuccess:(SMDataStoreSuccessBlock)successBlock
           onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Read an existing object from your StackMob datastore.
 
 @param theObjectId The object id (the value of the primary key field) for the object to read.
 @param schema The StackMob schema containing this object.
 @param successBlock A block to invoke after the object is successfully read. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 */
- (void)readObjectWithId:(NSString *)theObjectId
                inSchema:(NSString *)schema
               onSuccess:(SMDataStoreSuccessBlock)successBlock
               onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/** 
 Read an existing object from your StackMob datastore (with request options).
 
 @param theObjectId The object id (the value of the primary key field) for the object to read.
 @param schema The StackMob schema containing this object.
 @param options An options object contains headers and other configuration for this request
 @param successBlock A block to invoke after the object is successfully read. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 */
- (void)readObjectWithId:(NSString *)theObjectId
                inSchema:(NSString *)schema
             withOptions:(SMRequestOptions *)options
               onSuccess:(SMDataStoreSuccessBlock)successBlock
               onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/** 
 Update an existing object in your StackMob datastore.
 
 @param theObjectId The object id (the value of the primary key field) for the object to update.
 @param schema The StackMob schema containing this object.
 @param updatedFields A dictionary describing the object. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param successBlock A block to invoke after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be found.
 */
- (void)updateObjectWithId:(NSString *)theObjectId
                  inSchema:(NSString *)schema
                    update:(NSDictionary *)updatedFields
                 onSuccess:(SMDataStoreSuccessBlock)successBlock
                 onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Update an existing object in your StackMob datastore (with request options).
 
 @param theObjectId The object id (the value of the primary key field) for the object to update.
 @param schema The StackMob schema containing this object.
 @param updatedFields A dictionary describing the object. Keys should map to valid StackMob fields. Values should be JSON serializable objects.
 @param options An options object contains headers and other configuration for this request
 @param successBlock A block to invoke after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be found.
 */
- (void)updateObjectWithId:(NSString *)theObjectId
                  inSchema:(NSString *)schema
                    update:(NSDictionary *)updatedFields
               withOptions:(SMRequestOptions *)options
                 onSuccess:(SMDataStoreSuccessBlock)successBlock
                 onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Do an atomic update on a particular value.
 
 @param theObjectId The object id (the value of the primary key field) for the object to update.
 @param field the field in the schema that represents the counter.
 @param schema The StackMob schema containing the counter.
 @param increment The value (positive or negative) to increment the counter by.
 @param successBlock A block to invoke after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be found.
 */
- (void)updateAtomicCounterWithId:(NSString *)theObjectId
                            field:(NSString *)field
                         inSchema:(NSString *)schema
                               by:(int)increment
                        onSuccess:(SMDataStoreSuccessBlock)successBlock
                        onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Do an atomic update on a particular value (with request options).
 
 @param theObjectId The object id (the value of the primary key field) for the object to update.
 @param field the field in the schema that represents the counter.
 @param schema The StackMob schema containing the counter.
 @param increment The value (positive or negative) to increment the counter by.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock A block to invoke after the object is successfully updated. Passed the dictionary representation of the response from StackMob and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the dictionary sent with this request, and the schema in which the object was to be found.
 */
- (void)updateAtomicCounterWithId:(NSString *)theObjectId
                            field:(NSString *)field
                         inSchema:(NSString *)schema
                               by:(int)increment
                      withOptions:(SMRequestOptions *)options
                        onSuccess:(SMDataStoreSuccessBlock)successBlock
                        onFailure:(SMDataStoreFailureBlock)failureBlock;

/** 
 Delete an existing object from your StackMob datastore.
 
 @param theObjectId The object id (the value of the primary key field) for the object to delete.
 @param schema The StackMob schema containing this object.
 @param successBlock A block to invoke after the object is successfully deleted. Passed the object id of the deleted object and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 */
- (void)deleteObjectId:(NSString *)theObjectId
              inSchema:(NSString *)schema
             onSuccess:(SMDataStoreObjectIdSuccessBlock)successBlock
             onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;

/** 
 Delete an existing object from your StackMob datastore (with request options).
 
 @param theObjectId The object id (the value of the primary key field) for the object to delete.
 @param schema The StackMob schema containing this object.
 @param options An options object contains headers and other configuration for this request
 @param successBlock A block to invoke after the object is successfully deleted. Passed the object id of the deleted object and the object's schema.
 @param failureBlock A block to invoke if the data store fails to read the specified object. Passed the error returned by StackMob, the object id sent with this request, and the schema in which the object was to be found.
 */
- (void)deleteObjectId:(NSString *)theObjectId
              inSchema:(NSString *)schema
           withOptions:(SMRequestOptions *)options
             onSuccess:(SMDataStoreObjectIdSuccessBlock)successBlock
             onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;


#pragma mark - Queries
///-------------------------------
/// @name Performing Queries
///-------------------------------


/** 
 Execute a query against your StackMob datastore.
  
 @param query A SMQuery object describing the query to perform.
 @param successBlock A block to invoke after the query succeeds. Passed an array of object dictionaries returned from StackMob (if any).
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performQuery:(SMQuery *)query onSuccess:(SMResultsSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Execute a query against your StackMob datastore (with request options).
  
 @param query A SMQuery object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock A block to invoke after the query succeeds. Passed an array of object dictionaries returned from StackMob (if any).
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performQuery:(SMQuery *)query withOptions:(SMRequestOptions *)options onSuccess:(SMResultsSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Count the results that would be returned by a query against your StackMob datastore.
  
 @param query A SMQuery object describing the query to perform.
 @param successBlock A block to invoke when the count is complete.  Passed the number of objects returned that would by the query.
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performCount:(SMQuery *)query onSuccess:(SMCountSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Count the results that would be returned by a query against your StackMob datastore (with request options).
  
 @param query A SMQuery object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock A block to invoke when the count is complete.  Passed the number of objects that would be returned by the query.
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performCount:(SMQuery *)query withOptions:(SMRequestOptions *)options onSuccess:(SMCountSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

@end
