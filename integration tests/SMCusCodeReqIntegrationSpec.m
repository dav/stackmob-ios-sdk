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
#define CC_503_METHOD_NAME @"hello_world_503"

SPEC_BEGIN(SMCusCodeReqIntegrationSpec)

#if TEST_CUSTOM_CODE

describe(@"SMCusCodeReqIntegration", ^{
    __block SMClient *client = nil;
    context(@"given a custom code request", ^{
        beforeEach(^{
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
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"msg"] should] equal:@"Hello, world!"];
                [[[theResults objectForKey:@"body"] should] equal:@""];
            });
            it(@"should pass for DELETE", ^{
                aRequest = [[SMCustomCodeRequest alloc] initDeleteRequestWithMethod:CC_NO_PARAM_METHOD_NAME];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"msg"] should] equal:@"Hello, world!"];
                [[[theResults objectForKey:@"body"] should] equal:@""];
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
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
                    [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        callSuccess = YES;
                        theResults = (NSDictionary *)JSON;
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(callSuccess) should] beYes];
                [[[theResults objectForKey:@"param1"] should] equal:@"yo"];
                [[[theResults objectForKey:@"param2"] should]  equal:@"3"];
                [[[theResults objectForKey:@"body"] should]  equal:@"this is my body"];
            });
        });
        // NOT TESTABLE YET
        /*
        context(@"with a 503 response code", ^{
            __block SMCustomCodeRequest *aRequest = nil;
            __block BOOL failSuccess = NO;
            __block id theResults = nil;
            __block BOOL retryBlockCalled = NO;
            __block SMRequestOptions *options = nil;
            beforeEach(^{
                aRequest = nil;
                options = nil;
                failSuccess = NO; 
                retryBlockCalled = NO;
                theResults = nil;
            });
            it(@"should retry when returned a 503", ^{
                aRequest = [[SMCustomCodeRequest alloc] initGetRequestWithMethod:CC_503_METHOD_NAME];
                options = [SMRequestOptions options];
                [[options should] receive:@selector(setNumberOfRetries:)];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest options:options onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        failSuccess = YES;
                        [[[[error userInfo] valueForKey:NSLocalizedDescriptionKey] should] equal:@"Expected status code in (200-299), got 503"];
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(failSuccess) should] beYes];
                [[theValue(retryBlockCalled) should] beNo];
            });
            it(@"should call a retry block if provided when returned a 503", ^{
                aRequest = [[SMCustomCodeRequest alloc] initGetRequestWithMethod:CC_503_METHOD_NAME];
                options = [SMRequestOptions options];
                [options addSMErrorServiceUnavailableRetryBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON, SMRequestOptions *options, SMFullResponseSuccessBlock successBlock, SMFullResponseFailureBlock failureBlock) {
                    retryBlockCalled = YES;
                    [[client dataStore] retryCustomCodeRequest:request options:options onSuccess:successBlock onFailure:failureBlock];
                }];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [[client dataStore] performCustomCodeRequest:aRequest options:options onSuccess:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        syncReturn(semaphore);
                    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        failSuccess = YES;
                        [[[[error userInfo] valueForKey:NSLocalizedDescriptionKey] should] equal:@"Expected status code in (200-299), got 503"];
                        syncReturn(semaphore);
                    }];
                });
                [[theValue(failSuccess) should] beYes];
                [[theValue(retryBlockCalled) should] beYes];
            });
        });
         */
    });
});

#endif

SPEC_END