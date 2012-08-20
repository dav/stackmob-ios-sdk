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

SPEC_BEGIN(SMOAuth2ClientSpec)

describe(@"Creating a SMOAuth2ClientSpec instance", ^{
    __block SMOAuth2Client *client  = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *scheme = @"https";
    __block NSString *publicKey = @"foo";
    beforeEach(^{
        client = [[SMOAuth2Client alloc] initWithAPIVersion:appAPIVersion scheme:scheme apiHost:apiHost publicKey:publicKey];
    });
    
    it(@"should get the right public key", ^{
        [[[client publicKey] should] equal:publicKey];
    });
    it(@"should get the right api version", ^{
        [[[client defaultValueForHeader:@"Accept"] should] equal:@"application/vnd.stackmob+json; version=1"];
    });
    it(@"should set an http host", ^{
        [[client.baseURL should] equal:[NSURL URLWithString:@"https://host"]];
    });
});

describe(@"Generating a mac key", ^{
    __block SMOAuth2Client *client  = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *scheme = @"https";
    __block NSString *publicKey = @"foo";
    beforeEach(^{
        client = [[SMOAuth2Client alloc] initWithAPIVersion:appAPIVersion scheme:scheme apiHost:apiHost publicKey:publicKey];
        client.accessToken = @"accessToken";
        client.macKey = @"macKey";
    });
    it(@"should not be nil", ^{
        [[client createMACHeaderForHttpMethod:@"POST" path:@"hello" timestamp:1337 nonce:@"noncenonce"] shouldNotBeNil]; 
    });
    it(@"should match this particular precomputed value", ^{
        [[[client createMACHeaderForHttpMethod:@"POST" path:@"hello" timestamp:1337 nonce:@"noncenonce"] should] equal:@"MAC id=\"accessToken\",ts=\"1337\",nonce=\"noncenonce\",mac=\"ZpsJivPXcc4cTc6I50bC5XpQfEU=\""]; 
    });
});

describe(@"has valid credentials", ^{
    
});

describe(@"Generating a request", ^{
    __block SMOAuth2Client *client  = nil;
    __block NSMutableURLRequest *req = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *scheme = @"https";
    __block NSString *publicKey = @"foo";
    beforeEach(^{
        client = [[SMOAuth2Client alloc] initWithAPIVersion:appAPIVersion scheme:scheme apiHost:apiHost publicKey:publicKey];
        client.accessToken = @"accessToken";
        client.macKey = @"macKey";
        req = [client requestWithMethod:@"GET" path:@"hello" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"worl!@#(%#^+_)d", @"hello", nil]];
    });
    it(@"should not be nil", ^{
        [[req should] beNonNil]; 
    });
    it(@"should have an api key header", ^{
        [[[req valueForHTTPHeaderField:@"X-StackMob-API-Key"] should] beNonNil]; 
    });
    describe(@"content-type header", ^{
        context(@"on POST", ^{
            it(@"should set content-type", ^{
                NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"hello" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"worl!@#(%#^+_)d", @"hello", nil]];
                [[[request valueForHTTPHeaderField:@"Content-Type"] should] equal:@"application/json"]; 
            });
        });
        context(@"on PUT", ^{
            it(@"should set content-type", ^{
                NSMutableURLRequest *request = [client requestWithMethod:@"PUT" path:@"hello" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"worl!@#(%#^+_)d", @"hello", nil]];
                [[[request valueForHTTPHeaderField:@"Content-Type"] should] equal:@"application/json"]; 
            });
        });
        context(@"on GET", ^{
            it(@"should not set content-type", ^{
                NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:@"hello" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"worl!@#(%#^+_)d", @"hello", nil]];
                [[request valueForHTTPHeaderField:@"Content-Type"] shouldBeNil]; 
            });
        });
        context(@"on DELETE", ^{
            it(@"should not set content-type", ^{
                NSMutableURLRequest *request = [client requestWithMethod:@"DELETE" path:@"hello" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"worl!@#(%#^+_)d", @"hello", nil]];
                [[request valueForHTTPHeaderField:@"Content-Type"] shouldBeNil]; 
            });
        });

               
    });
    it(@"should have an accept header", ^{
        [[[req valueForHTTPHeaderField:@"Accept"] should] equal:@"application/vnd.stackmob+json; version=1"]; 
    });
    it(@"should have an X-StackMob-API-Key header", ^{
        [[[req valueForHTTPHeaderField:@"X-StackMob-API-Key"] should] equal:publicKey]; 
    });
});

describe(@"-customCodeRequest:options", ^{
    context(@"given a custom code request", ^{
        __block SMCustomCodeRequest *request = nil;
        __block SMClient *client = nil;
        __block SMDataStore *dataStore = nil;
        beforeEach(^{
            client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"public key"];
            dataStore = [[SMDataStore alloc] initWithAPIVersion:@"0" session:[client session]];
            request = [[SMCustomCodeRequest alloc] initPostRequestWithMethod:@"method" body:@"body"]; 
        });
        it(@"customCodeRequest should set all the right fields with no parameters", ^{
            NSURLRequest *aRequest = nil;
            aRequest = [dataStore.session.regularOAuthClient customCodeRequest:request options:[SMRequestOptions optionsWithHeaders:[NSDictionary dictionaryWithObject:@"blah" forKey:@"newHeader"]]];
            [aRequest shouldNotBeNil];
            
            [[theValue([[aRequest allHTTPHeaderFields] count]) should] equal:theValue(4)];
            
            NSData *theData = [aRequest HTTPBody];
            NSString *decodedString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
            [[decodedString should] equal:@"body"];
            
            [[[aRequest HTTPMethod] should] equal:@"POST"];
        
            [[[aRequest URL] should] equal:[NSURL URLWithString:@"http://api.stackmob.com/method"]];
        });
        it(@"customCodeRequest should set all the right fields with parameters", ^{
            
            [request addQueryStringParameterWhere:@"a" equals:@"3"];
            [request addQueryStringParameterWhere:@"a" equals:@"1"];
            [request addQueryStringParameterWhere:@"bob" equals:@"5"];
            
            NSURLRequest *aRequest = nil;
            aRequest = [dataStore.session.regularOAuthClient customCodeRequest:request options:[SMRequestOptions optionsWithHeaders:[NSDictionary dictionaryWithObject:@"blah" forKey:@"newHeader"]]];
            [aRequest shouldNotBeNil];
            
            [[theValue([[aRequest allHTTPHeaderFields] count]) should] equal:theValue(4)];
            
            NSData *theData = [aRequest HTTPBody];
            NSString *decodedString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
            [[decodedString should] equal:@"body"];
            
            [[[aRequest HTTPMethod] should] equal:@"POST"];
            
            [[[aRequest URL] should] equal:[NSURL URLWithString:@"http://api.stackmob.com/method?a=3&a=1&bob=5"]];
        });

    });
});

SPEC_END