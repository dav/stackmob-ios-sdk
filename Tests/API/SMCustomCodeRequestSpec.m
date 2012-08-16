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
#import "SMCustomCodeRequest.h"

SPEC_BEGIN(SMCustomCodeRequestSpec)

describe(@"SMCustomCodeRequest", ^{
  describe(@"initialize", ^{
      __block SMCustomCodeRequest *request = nil;
      context(@"method and verb", ^{
          beforeEach(^{
              request = nil;
              request = [[SMCustomCodeRequest alloc] initWithMethod:@"my-cool-method" andHTTPVerb:@"PUT"]; 
          });
          it(@"should properly initialize with a method and verb", ^{
              [request shouldNotBeNil];
              [[request.method should] equal:@"my-cool-method"];
              [[request.httpVerb should] equal:@"PUT"];
              [request.requestBody shouldBeNil];
          });
      });
      context(@"method, verb and body", ^{
          beforeEach(^{
              request = nil;
              request = [[SMCustomCodeRequest alloc] initWithMethod:@"my-cool-method" andHTTPVerb:@"PUT" andRequestBody:@"this is my body"]; 
          });
          it(@"should properly initialize with a method and verb", ^{
              [request shouldNotBeNil];
              [[request.method should] equal:@"my-cool-method"];
              [[request.httpVerb should] equal:@"PUT"];
              [[request.requestBody should] equal:@"this is my body"];
          });
      });
  });
    describe(@"add query parameters", ^{
        __block SMCustomCodeRequest *request = nil;
        beforeEach(^{
            request = nil;
            request = [[SMCustomCodeRequest alloc] initWithMethod:@"my-cool-method" andHTTPVerb:@"PUT"]; 
        });
        it(@"should set query parameters", ^{
            [request addQueryStringParameterWhere:@"a" equals:@"3"];
            [request addQueryStringParameterWhere:@"a" equals:@"1"];
            [request addQueryStringParameterWhere:@"b" equals:@"3"];
            [[theValue([request.queryStringParameters count]) should] equal:theValue(3)];
        });
    });
});

SPEC_END