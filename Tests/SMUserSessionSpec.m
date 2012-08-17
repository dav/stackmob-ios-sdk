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

SPEC_BEGIN(SMUserSessionSpec)

#pragma mark Authentication with StackMob

describe(@"Creating a SMUserSession instance", ^{
    __block SMUserSession *userSession  = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *publicKey = @"foo";
    __block NSString *userSchema = @"user";
    beforeEach(^{
        userSession = [[SMUserSession alloc] initWithAPIVersion:appAPIVersion 
                                                        apiHost:apiHost 
                                                      publicKey:publicKey
                                                     userSchema:userSchema];
    });
    describe(@"regularOAuthClient", ^{
        it(@"should not be nil", ^{
            [[userSession regularOAuthClient] shouldNotBeNil];
        });
        it(@"should get the right public key", ^{
            [[[[userSession regularOAuthClient] publicKey] should] equal:publicKey];
        });
        it(@"should get the right api version", ^{
            [[[userSession.regularOAuthClient defaultValueForHeader:@"Accept"] should] equal:@"application/vnd.stackmob+json; version=1"];
        });
        it(@"should set an http host", ^{
            [[userSession.regularOAuthClient.baseURL should] equal:[NSURL URLWithString:@"http://host"]];
        });
        
    });
    
    describe(@"secureOAuthClient", ^{
        it(@"should not be nil", ^{
            [[userSession secureOAuthClient] shouldNotBeNil];
        });
        it(@"should get the right public key", ^{
            [[[[userSession secureOAuthClient] publicKey] should] equal:publicKey];
        });
        it(@"should get the right api version", ^{
            [[[userSession.secureOAuthClient defaultValueForHeader:@"Accept"] should] equal:@"application/vnd.stackmob+json; version=1"];
        });
        it(@"should set an https host", ^{
            [[userSession.secureOAuthClient.baseURL should] equal:[NSURL URLWithString:@"https://host"]];
        });
        
    });
    describe(@"user schema", ^{
        it(@"should bet set to userSchema", ^{
            [[[userSession userSchema] should] equal:userSchema];
        });
    });
});

describe(@"getting an oauth2 client", ^{
    __block SMUserSession *userSession  = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *publicKey = @"foo";
    __block NSString *userSchema = @"user";
    beforeEach(^{
        userSession = [[SMUserSession alloc] initWithAPIVersion:appAPIVersion 
                                                        apiHost:apiHost 
                                                      publicKey:publicKey
                                                     userSchema:userSchema];
    });
    describe(@"http", ^{
        it(@"should return regularOAuthCleint", ^{
            [[[userSession oauthClientWithHTTPS:FALSE] should] equal:[userSession regularOAuthClient]];
        });
        
    });
    
    describe(@"https", ^{
        it(@"should return secureOAuthCleint", ^{
            [[[userSession oauthClientWithHTTPS:TRUE] should] equal:[userSession secureOAuthClient]];
        });
    });
});

describe(@"perform an access token request", ^{
    __block SMUserSession *userSession  = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *publicKey = @"foo";
    __block NSString *userSchema = @"user";
    beforeEach(^{
        userSession = [[SMUserSession alloc] initWithAPIVersion:appAPIVersion 
                                                        apiHost:apiHost 
                                                      publicKey:publicKey
                                                     userSchema:userSchema];
        userSession.tokenClient = [AFHTTPClient nullMock];
    });

    it(@"should create a request", ^{
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"foo", @"bar", @"mac", @"token_type", @"hmac-sha-1", @"mac_algorithm", nil];
        [[[userSession.tokenClient should] receive] requestWithMethod:@"POST" path:@"user/endpoint" parameters:dict];
        [userSession doTokenRequestWithEndpoint:@"endpoint" credentials:[NSDictionary dictionaryWithObjectsAndKeys:@"foo", @"bar", nil] options:[SMRequestOptions options] onSuccess:^(NSDictionary *data) {} onFailure:^(NSError * error) {}];
    });
    
    
    it(@"should enqueue the request", ^{
        AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] init];
        [[[SMJSONRequestOperation should] receiveAndReturn:operation] JSONRequestOperationWithRequest:[KWAny any] success:[KWAny any] failure:[KWAny any]];
        [[[userSession.tokenClient should] receive] enqueueHTTPRequestOperation:operation];
        [userSession doTokenRequestWithEndpoint:@"endpoint" credentials:[NSDictionary dictionaryWithObjectsAndKeys:@"foo", @"bar", nil] options:[SMRequestOptions options] onSuccess:^(NSDictionary *data) {} onFailure:^(NSError * error) {}];
    });
    
});

describe(@"parseTokenResults", ^{
    __block SMUserSession *userSession  = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *publicKey = @"foo";
    __block NSString *userSchema = @"user";
    beforeEach(^{
        userSession = [[SMUserSession alloc] initWithAPIVersion:appAPIVersion 
                                                        apiHost:apiHost 
                                                      publicKey:publicKey
                                                     userSchema:userSchema];
        userSession.tokenClient = [AFHTTPClient nullMock];
    });
    
    pending(@"should fail gracefully given bad input", ^{
        
    });
    
    pending(@"should convert the date in a dictionary", ^{

    });
    pending(@"should leave other values intact", ^{
        
    });
});

describe(@"saveAccessTokenInfo", ^{
    __block SMUserSession *userSession  = nil;
    __block NSString *appAPIVersion = @"1";
    __block NSString *apiHost = @"host";
    __block NSString *publicKey = @"foo";
    __block NSString *userSchema = @"user";
    beforeEach(^{
        userSession = [[SMUserSession alloc] initWithAPIVersion:appAPIVersion 
                                                        apiHost:apiHost 
                                                      publicKey:publicKey
                                                     userSchema:userSchema];
        userSession.tokenClient = [AFHTTPClient nullMock];
    });
    
    pending(@"should fail gracefully given bad input", ^{
        
    });
    
    pending(@"should set everything to nil given nil input", ^{
        
    });
    
    pending(@"should set everything given good input", ^{
        
    });
    
});








SPEC_END