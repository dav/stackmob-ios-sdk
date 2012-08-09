/**
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

#import <Kiwi/Kiwi.h>
#import "StackMob.h"

SPEC_BEGIN(SMDataStoreSpec)

describe(@"Creating a data store instance", ^{
    __block SMDataStore *dataStore = nil;
    __block SMClient *client = nil;
    beforeEach(^{
        client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"public key"];
        dataStore = [[SMDataStore alloc] initWithAPIVersion:@"0" session:[client session]];
    });
    it(@"should get its oauth credentials from the provided oauthClient variable", ^{
        [dataStore.session.regularOAuthClient shouldNotBeNil];
        [[dataStore.session.regularOAuthClient.publicKey should] equal:@"public key"];
        [[dataStore.session.regularOAuthClient.baseURL should] equal:[NSURL URLWithString:@"http://api.stackmob.com"]];
        [[[dataStore.session.regularOAuthClient defaultValueForHeader:@"Accept"] should] equal:@"application/vnd.stackmob+json; version=0"];
    });
    it(@"should have an application API version", ^{
        [[dataStore.apiVersion should] equal:@"0"];
    });
});

describe(@"CRUD", ^{
    __block SMDataStore *dataStore = nil;
    beforeEach(^{
        SMClient *client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"public"];
        dataStore = [[SMDataStore alloc] initWithAPIVersion:@"0" session:client.session];
        dataStore.session.regularOAuthClient = [SMOAuth2Client nullMock];
    });
    describe(@"-createObject:inSchema:onSuccess:onFailure:", ^{
        __block NSDictionary *objectToCreate = nil;
        beforeEach(^{
            objectToCreate = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"How to Write iOS Applications", @"title",
                              @"A. Developer", @"author",
                              nil];
        });
        context(@"given a valid schema and set of fields", ^{
            it(@"adds the request to the queue", ^{
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://stackmob.com"]];
                [[dataStore.session.regularOAuthClient should] receive:@selector(requestWithMethod:path:parameters:) andReturn:request];
                
                AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] init]; 
                [[[SMJSONRequestOperation should] receiveAndReturn:operation] JSONRequestOperationWithRequest:request success:[KWAny any] failure:[KWAny any]];
                
                [[[dataStore.session.regularOAuthClient should] receive] enqueueHTTPRequestOperation:operation];
                [dataStore createObject:objectToCreate inSchema:@"book" onSuccess:nil onFailure:nil];
            });
        });
        context(@"given a nil object", ^{
            it(@"should fail", ^{
                __block BOOL failureBlockCalled = NO;
                __block BOOL successBlockCalled = NO;
                [dataStore createObject:nil inSchema:@"book" onSuccess:^(NSDictionary *responseObject, NSString *schema){
                    successBlockCalled = YES;
                } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                    [theError shouldNotBeNil];
                    [[theError.domain should] equal:SMErrorDomain];
                    [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                    
                    [theObject shouldBeNil];
                    [[schema should] equal:@"book"];
                    failureBlockCalled = YES;
                }];
                [[theValue(successBlockCalled) should] beNo];
                [[theValue(failureBlockCalled) should] beYes];
            });
        });
        context(@"given a nil schema", ^{
            it(@"should fail", ^{
                __block BOOL failureBlockCalled = NO;
                __block BOOL successBlockCalled = NO;
                [dataStore createObject:objectToCreate inSchema:nil onSuccess:^(NSDictionary *responseObject, NSString *schema){
                    successBlockCalled = YES;
                } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                    [theError shouldNotBeNil];
                    [[theError.domain should] equal:SMErrorDomain];
                    [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                    
                    [[theObject should] equal:objectToCreate];
                    [schema shouldBeNil];
                    failureBlockCalled = YES;
                }];
                [[theValue(successBlockCalled) should] beNo];
                [[theValue(failureBlockCalled) should] beYes];
            });
        });
    });
    describe(@"-readObject:inSchema:withPrimaryKey:onCompletion:", ^{
        context(@"given a valid schema and object id", ^{
            it(@"creates an OAuth signed READ request", ^{
                [[[dataStore.session.regularOAuthClient should] receive] requestWithMethod:@"GET" path:@"book/1234" parameters:nil];
                [dataStore readObjectWithId:@"1234" inSchema:@"book" onSuccess:nil onFailure:nil];
            });
            it(@"adds the request to the queue", ^{
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://stackmob.com"]];
                [[dataStore.session.regularOAuthClient should] receive:@selector(requestWithMethod:path:parameters:) andReturn:request];
                
                AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] init]; 
                [[[SMJSONRequestOperation should] receiveAndReturn:operation] JSONRequestOperationWithRequest:request success:[KWAny any] failure:[KWAny any]];
                
                [[[dataStore.session.regularOAuthClient should] receive] enqueueHTTPRequestOperation:operation];
                [dataStore readObjectWithId:@"1234" inSchema:@"book" onSuccess:nil onFailure:nil];
            });
        });
        context(@"given a nil object id", ^{
            it(@"should fail", ^{
                __block BOOL failureBlockCalled = NO;
                __block BOOL successBlockCalled = NO;
                [dataStore readObjectWithId:nil inSchema:@"book" onSuccess:^(NSDictionary *responseObject, NSString *schema){
                    successBlockCalled = YES;
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldNotBeNil];
                    [[theError.domain should] equal:SMErrorDomain];
                    [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                    
                    [theObjectId shouldBeNil];
                    [[schema should] equal:@"book"];
                    failureBlockCalled = YES;
                }];
                [[theValue(successBlockCalled) should] beNo];
                [[theValue(failureBlockCalled) should] beYes];
            });
        });
        context(@"given a nil schema", ^{
            it(@"should fail", ^{
                __block BOOL failureBlockCalled = NO;
                __block BOOL successBlockCalled = NO;
                [dataStore readObjectWithId:@"1234" inSchema:nil onSuccess:^(NSDictionary *responseObject, NSString *schema){
                    successBlockCalled = YES;
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldNotBeNil];
                    [[theError.domain should] equal:SMErrorDomain];
                    [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                    
                    [[theObjectId should] equal:@"1234"];
                    [schema shouldBeNil];
                    failureBlockCalled = YES;
                }];
                [[theValue(successBlockCalled) should] beNo];
                [[theValue(failureBlockCalled) should] beYes];
            });
        });
    });
    describe(@"-updateSchema:withFields:result:", ^{
        context(@"given a valid object id and schema", ^{
            __block NSDictionary *updatedFields = nil;
            beforeEach(^(){
                updatedFields = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"New and Improved!", @"subtitle",
                                 nil];
            });
            it(@"adds the request to the queue", ^{
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://stackmob.com"]];
                [[dataStore.session.regularOAuthClient should] receive:@selector(requestWithMethod:path:parameters:) andReturn:request];
                
                AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] init]; 
                [[[SMJSONRequestOperation should] receiveAndReturn:operation] JSONRequestOperationWithRequest:request success:[KWAny any] failure:[KWAny any]];
                
                [[[dataStore.session.regularOAuthClient should] receive] enqueueHTTPRequestOperation:operation];
                [dataStore updateObjectWithId:@"1234" inSchema:@"book" update:updatedFields onSuccess:nil onFailure:nil];
            });
            context(@"given a nil object id", ^{
                it(@"should fail", ^{
                    __block BOOL failureBlockCalled = NO;
                    __block BOOL successBlockCalled = NO;
                    [dataStore updateObjectWithId:nil inSchema:@"book" update:updatedFields onSuccess:^(NSDictionary *responseObject, NSString *schema){
                        successBlockCalled = YES;
                    } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                        [theError shouldNotBeNil];
                        [[theError.domain should] equal:SMErrorDomain];
                        [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                        
                        [[theObject should] equal:updatedFields];
                        [[schema should] equal:@"book"];
                        failureBlockCalled = YES;
                    }];
                    [[theValue(successBlockCalled) should] beNo];
                    [[theValue(failureBlockCalled) should] beYes];
                });
            });
            context(@"given a nil schema", ^{
                it(@"should fail", ^{
                    __block BOOL failureBlockCalled = NO;
                    __block BOOL successBlockCalled = NO;
                    [dataStore updateObjectWithId:@"1234" inSchema:nil update:updatedFields onSuccess:^(NSDictionary *responseObject, NSString *schema){
                        successBlockCalled = YES;
                    } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                        [theError shouldNotBeNil];
                        [[theError.domain should] equal:SMErrorDomain];
                        [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                        
                        [[theObject should] equal:updatedFields];
                        [schema shouldBeNil];
                        failureBlockCalled = YES;
                    }];
                    [[theValue(successBlockCalled) should] beNo];
                    [[theValue(failureBlockCalled) should] beYes];
                });
            });
        });
    });
    
    describe(@"-deleteSchema:withFields:result:", ^{
        context(@"given a valid schema and object id", ^{
            it(@"creates an OAuth signed DELETE request", ^{
                [[[dataStore.session.regularOAuthClient should] receive] requestWithMethod:@"DELETE" path:@"book/1234" parameters:nil];
                [dataStore deleteObjectId:@"1234" inSchema:@"book" onSuccess:nil onFailure:nil];
            });
            it(@"adds the request to the queue", ^{
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://stackmob.com"]];
                [[dataStore.session.regularOAuthClient should] receive:@selector(requestWithMethod:path:parameters:) andReturn:request];
                
                AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] init]; 
                [[[SMJSONRequestOperation should] receiveAndReturn:operation] JSONRequestOperationWithRequest:request success:[KWAny any] failure:[KWAny any]];
                
                [[[dataStore.session.regularOAuthClient should] receive] enqueueHTTPRequestOperation:operation];
                [dataStore deleteObjectId:@"1234" inSchema:@"book" onSuccess:nil onFailure:nil];
            });
        });
        context(@"given a nil object id", ^{
            it(@"should fail", ^{
                __block BOOL failureBlockCalled = NO;
                __block BOOL successBlockCalled = NO;
                [dataStore deleteObjectId:nil inSchema:@"book" onSuccess:^(NSString *objectId, NSString *schema){
                    successBlockCalled = YES;
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldNotBeNil];
                    [[theError.domain should] equal:SMErrorDomain];
                    [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                    
                    [theObjectId shouldBeNil];
                    [[schema should] equal:@"book"];
                    failureBlockCalled = YES;
                }];
                [[theValue(successBlockCalled) should] beNo];
                [[theValue(failureBlockCalled) should] beYes];
            });
        });
        context(@"given a nil schema", ^{
            it(@"should fail", ^{
                __block BOOL failureBlockCalled = NO;
                __block BOOL successBlockCalled = NO;
                [dataStore deleteObjectId:@"1234" inSchema:nil onSuccess:^(NSString *objectId, NSString *schema){
                    successBlockCalled = YES;
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldNotBeNil];
                    [[theError.domain should] equal:SMErrorDomain];
                    [[theValue(theError.code) should] equal:theValue(SMErrorInvalidArguments)];
                    
                    [[theObjectId should] equal:@"1234"];
                    [schema shouldBeNil];
                    failureBlockCalled = YES;
                }];
                [[theValue(successBlockCalled) should] beNo];
                [[theValue(failureBlockCalled) should] beYes];
            });
        });
    });
}); 

pending(@"updateAtomicCounter", ^{

});

describe(@"performing queries", ^{
    it(@"should set the request headers", ^{
        
    });
    it(@"should set the request parameters", ^{
    });
    context(@"when successful", ^{
        context(@"when the query returns multiple objects", ^{
            pending(@"passes an array of the resulting objects to the result block", ^{});    
            pending(@"does not pass an error object to the result block", ^{});
        });
        context(@"when the query returns no results", ^{
            pending(@"passes an empty array to the result block", ^{});
            pending(@"does not pass an error object to the result block", ^{});
        });
    });
    context(@"when unsuccessful", ^{
        pending(@"passes a nil array to the result block", ^{});
        pending(@"passes an error object to the result block", ^{});
    });        
});

describe(@"performing counts", ^{
    it(@"should set the request headers", ^{
        
    });
    it(@"should set the request parameters", ^{
    });
    context(@"when successful", ^{
        context(@"when the query returns multiple objects", ^{
            pending(@"passes an array of the resulting objects to the result block", ^{});    
            pending(@"does not pass an error object to the result block", ^{});
        });
        context(@"when the query returns no results", ^{
            pending(@"passes an empty array to the result block", ^{});
            pending(@"does not pass an error object to the result block", ^{});
        });
    });
    context(@"when unsuccessful", ^{
        pending(@"passes a nil array to the result block", ^{});
        pending(@"passes an error object to the result block", ^{});
    });        
});

SPEC_END