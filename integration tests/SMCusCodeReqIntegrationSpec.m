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

#import <Kiwi/Kiwi.h>
#import "SMIntegrationTestHelpers.h"
#import "StackMob.h"
#import "SMCustomCodeRequest.h"

#define CC_NO_PARAM_METHOD_NAME @"hello_world"
#define CC_PARAM_METHOD_NAME @"hello_world_params"

SPEC_BEGIN(SMCusCodeReqIntegrationSpec)

describe(@"SMCusCodeReqIntegration", ^{
    __block SMClient *client = nil;
    __block NSArray *verbsToTest = nil;
    context(@"given a custom code request", ^{
        beforeEach(^{
            verbsToTest = [NSArray arrayWithObjects:@"POST", @"GET", @"PUT", @"DELETE", nil];
            client =  [SMIntegrationTestHelpers defaultClient];
            [client shouldNotBeNil];
        });
        context(@"with no parameters or body", ^{
            __block SMCustomCodeRequest *aRequest = nil;
            __block BOOL callSuccess = NO;
            __block id theResults = nil;
            beforeEach(^{
                aRequest = nil;
                callSuccess = NO; 
                theResults = nil;
            });
            it(@"should pass for GET", ^{
                aRequest = [[SMCustomCodeRequest alloc] initGetRequestWithMethod:CC_NO_PARAM_METHOD_NAME];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"msg"] should] equal:@"Hello, world!"];
                [[theResults objectForKey:@"body"] shouldBeNil];
            });
            it(@"should pass for DELETE", ^{
                aRequest = [[SMCustomCodeRequest alloc] initDeleteRequestWithMethod:CC_NO_PARAM_METHOD_NAME];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"msg"] should] equal:@"Hello, world!"];
                [[theResults objectForKey:@"body"] shouldBeNil];
            });
                 
        });
        context(@"with a body and no parameters", ^{
            __block SMCustomCodeRequest *aRequest = nil;
            __block BOOL callSuccess = NO;
            __block id theResults = nil;
            beforeEach(^{
                aRequest = nil;
                callSuccess = NO; 
                theResults = nil;
            });
            it(@"should pass for POST", ^{
                aRequest = [[SMCustomCodeRequest alloc] initPostRequestWithMethod:CC_NO_PARAM_METHOD_NAME body:@"the body"];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"msg"] should] equal:@"Hello, world!"];
                [[[theResults objectForKey:@"body"] should]  equal:@"the body"];
            });
            it(@"should pass for PUT", ^{
                aRequest = [[SMCustomCodeRequest alloc] initPutRequestWithMethod:CC_NO_PARAM_METHOD_NAME body:@"the body"];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"msg"] should] equal:@"Hello, world!"];
                [[[theResults objectForKey:@"body"] should]  equal:@"the body"];
            });
        });
        context(@"with parameters and no body", ^{
            __block SMCustomCodeRequest *aRequest = nil;
            __block BOOL callSuccess = NO;
            __block id theResults = nil;
            beforeEach(^{
                aRequest = nil;
                callSuccess = NO; 
                theResults = nil;
            });
            it(@"should pass for GET", ^{
                aRequest = [[SMCustomCodeRequest alloc] initGetRequestWithMethod:CC_PARAM_METHOD_NAME];
                [aRequest addQueryStringParameterWhere:@"param1" equals:@"yo"];
                [aRequest addQueryStringParameterWhere:@"param2" equals:@"3"];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"param1"] should] equal:@"yo"];
                [[[theResults objectForKey:@"param2"] should]  equal:@"3"];
            });
            it(@"should pass for DELETE", ^{
                aRequest = [[SMCustomCodeRequest alloc] initDeleteRequestWithMethod:CC_PARAM_METHOD_NAME];
                [aRequest addQueryStringParameterWhere:@"param1" equals:@"yo"];
                [aRequest addQueryStringParameterWhere:@"param2" equals:@"3"];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"param1"] should] equal:@"yo"];
                [[[theResults objectForKey:@"param2"] should]  equal:@"3"];
            });
        });
        context(@"with parameters and a body", ^{
            __block SMCustomCodeRequest *aRequest = nil;
            __block BOOL callSuccess = NO;
            __block id theResults = nil;
            beforeEach(^{
                aRequest = nil;
                callSuccess = NO; 
                theResults = nil;
            });
            it(@"should pass for POST", ^{
                aRequest = [[SMCustomCodeRequest alloc] initPostRequestWithMethod:CC_PARAM_METHOD_NAME body:@"this is my body"];
                [aRequest addQueryStringParameterWhere:@"param1" equals:@"yo"];
                [aRequest addQueryStringParameterWhere:@"param2" equals:@"3"];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"param1"] should] equal:@"yo"];
                [[[theResults objectForKey:@"param2"] should]  equal:@"3"];
                [[[theResults objectForKey:@"body"] should]  equal:@"this is my body"];
            });
            it(@"should pass for PUT", ^{
                aRequest = [[SMCustomCodeRequest alloc] initPutRequestWithMethod:CC_PARAM_METHOD_NAME body:@"this is my body"];
                [aRequest addQueryStringParameterWhere:@"param1" equals:@"yo"];
                [aRequest addQueryStringParameterWhere:@"param2" equals:@"3"];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                        callSuccess = YES;
                        theResults = results;
                        syncReturn(semaphore);
                    } onFailure:^(NSError *error) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"param1"] should] equal:@"yo"];
                [[[theResults objectForKey:@"param2"] should]  equal:@"3"];
                [[[theResults objectForKey:@"body"] should]  equal:@"this is my body"];
            });
        });

    });
});

SPEC_END