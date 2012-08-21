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
#import "SMResponseBlocks.h"

#define POST @"POST"
#define GET @"GET"
#define PUT @"PUT"
#define DELETE @"DELETE"

@class SMUserSession;
@class SMRequestOptions;
@class SMCustomCodeRequest;

/**
 `SMDataStore` exposes an interface for performing CRUD operations on known StackMob objects and for executing a <SMQuery>.
 
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
 @param session An instance of <SMUserSession> configured with the proper credentials.  This is used to properly authenticate requests.
 
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
         options:(SMRequestOptions *)options
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
             options:(SMRequestOptions *)options
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
               options:(SMRequestOptions *)options
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
                      options:(SMRequestOptions *)options
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
           options:(SMRequestOptions *)options
             onSuccess:(SMDataStoreObjectIdSuccessBlock)successBlock
             onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock;


#pragma mark - Queries
///-------------------------------
/// @name Performing Queries
///-------------------------------


/** 
 Execute a query against your StackMob datastore.
  
 @param query An `SMQuery` object describing the query to perform.
 @param successBlock A block to invoke after the query succeeds. Passed an array of object dictionaries returned from StackMob (if any).
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performQuery:(SMQuery *)query onSuccess:(SMResultsSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Execute a query against your StackMob datastore (with request options).
  
 @param query An `SMQuery` object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock A block to invoke after the query succeeds. Passed an array of object dictionaries returned from StackMob (if any).
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performQuery:(SMQuery *)query options:(SMRequestOptions *)options onSuccess:(SMResultsSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Count the results that would be returned by a query against your StackMob datastore.
  
 @param query An `SMQuery` object describing the query to perform.
 @param successBlock A block to invoke when the count is complete.  Passed the number of objects returned that would by the query.
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performCount:(SMQuery *)query onSuccess:(SMCountSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

/** 
 Count the results that would be returned by a query against your StackMob datastore (with request options).
  
 @param query An `SMQuery` object describing the query to perform.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock A block to invoke when the count is complete.  Passed the number of objects that would be returned by the query.
 @param failureBlock A block to invoke if the data store fails to perform the query. Passed the error returned by StackMob.
 */
- (void)performCount:(SMQuery *)query options:(SMRequestOptions *)options onSuccess:(SMCountSuccessBlock)successBlock onFailure:(SMFailureBlock)failureBlock;

#pragma mark - Custom Code
///-------------------------------
/// @name Performing Custom Code Methods
///-------------------------------

/**
 Calls <performCustomCodeRequest:options:onSuccess:onFailure:> with `[SMRequestOptions options]` for the parameter `options`.
 
 @param customCodeRequest The request to execute.
 @param successBlock The block to call upon success.
 @param failureBlock The block to call upon failure.
 */
- (void)performCustomCodeRequest:(SMCustomCodeRequest *)customCodeRequest onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;
/**
 Execute a custom code method on StackMob.
 
 See [Getting Started With Custom Code](https://stackmob.com/devcenter/docs/Getting-Started:-Custom-Code-SDK) for more information.
 
 @param customCodeRequest The request to execute.
 @param options The options for this request.
 @param successBlock The block to call upon success.
 @param failureBlock The block to call upon failure.
 */
- (void)performCustomCodeRequest:(SMCustomCodeRequest *)customCodeRequest options:(SMRequestOptions *)options onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;

/**
 Retry executing a custom code method on StackMob.
 
 This method should only be called by developers defining their own custom code retry blocks.  See <SMRequestOptions> method `addSMErrorServiceUnavailableRetryBlock:`.
 
 @param request The request to execute.
 @param options The options for this request.
 @param successBlock The block to call upon success.
 @param failureBlock The block to call upon failure.
 */
- (void)retryCustomCodeRequest:(NSURLRequest *)request options:(SMRequestOptions *)options onSuccess:(SMFullResponseSuccessBlock)successBlock onFailure:(SMFullResponseFailureBlock)failureBlock;

@end
