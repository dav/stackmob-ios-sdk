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

SPEC_BEGIN(SMCusCodeReqIntegrationSpec)

describe(@"SMCusCodeReqIntegration", ^{
    __block SMClient *client = nil;
    __block NSArray *queryStringParameters = nil;
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
            beforeEach(^{
                aRequest = nil;
                callSuccess = NO; 
            });
            // for each verb, test the method with the given parameters
            it(@"should pass for each verb", ^{
                [verbsToTest enumerateObjectsUsingBlock:^(id verb, NSUInteger idx, BOOL *stop){
                    aRequest = nil;
                    callSuccess = NO;
                    aRequest = [[SMCustomCodeRequest alloc] initWithMethod:CC_NO_PARAM_METHOD_NAME andHTTPVerb:verb andRequestBody:nil];
                    syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                        [[client dataStore] performCustomCodeRequest:aRequest onSuccess:^(id results) {
                            callSuccess = YES;
                            syncReturn(semaphore);
                        } onFailure:^(NSError *error) {
                            syncReturn(semaphore);
                        }];
                    });
                    [[theValue(callSuccess) should] beYes];
                }];
            });
        });
        /*
        context(@"with parameters", ^{
            [client shouldNotBeNil];
            __block SMCustomCodeRequest *aRequest = nil;
            // for each verb, test the method with the given parameters
            [verbsToTest enumerateObjectsUsingBlock:^(id verb, NSUInteger idx, BOOL *stop){
                aRequest = [[SMCustomCodeRequest alloc] initWithMethod:CC_METHOD_NAME andHTTPVerb:verb andRequestBody:nil];
            }];
        });
         */
    });
});

SPEC_END