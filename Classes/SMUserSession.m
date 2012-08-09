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

#import "StackMob.h"
#import "AFJSONRequestOperation.h"
#import "SMVersion.h"

#define ACCESS_TOKEN @"access_token"
#define EXPIRES_IN @"expires_in"
#define MAC_KEY @"mac_key"
#define REFRESH_TOKEN @"refresh_token"


@implementation SMUserSession


@synthesize regularOAuthClient = _SM_regularOAuthClient;
@synthesize secureOAuthClient = _SM_secureOAuthClient;
@synthesize tokenClient = _SM_tokenClient;  
@synthesize userSchema = _SM_userSchema;
@synthesize expiration = _SM_expiration;
@synthesize refreshToken = _SM_refreshToken;
@synthesize refreshing = _SM_refreshing;
@synthesize oauthStorageKey = _SM_oauthStorageKey;

- (id)initWithAPIVersion:(NSString *)version 
                 apiHost:(NSString *)apiHost 
               publicKey:(NSString *)publicKey 
              userSchema:(NSString *)userSchema
{
    self = [super init];
    if (self) {
        self.regularOAuthClient = [[SMOAuth2Client alloc] initWithAPIVersion:version scheme:@"http" apiHost:apiHost publicKey:publicKey];
        self.secureOAuthClient = [[SMOAuth2Client alloc] initWithAPIVersion:version scheme:@"https" apiHost:apiHost publicKey:publicKey];
        self.tokenClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", apiHost]]];    
        NSString *acceptHeader = [NSString stringWithFormat:@"application/vnd.stackmob+json; version=%@", version];
        [self.tokenClient setDefaultHeader:@"Accept" value:acceptHeader]; 
        [self.tokenClient setDefaultHeader:@"X-StackMob-API-Key" value:publicKey];
        [self.tokenClient setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        [self.tokenClient setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"StackMob/%@ (%@/%@; %@;)", SDK_VERSION, [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[NSLocale currentLocale] localeIdentifier]]];
        self.userSchema = userSchema;
        self.refreshing = NO;
        self.oauthStorageKey = [NSString stringWithFormat:@"%@.oauth", publicKey];
        [self saveAccessTokenInfo:[[NSUserDefaults standardUserDefaults] dictionaryForKey:self.oauthStorageKey]];
        
    }
    
    return self;
}


- (BOOL)accessTokenHasExpired
{
    return [[self.expiration laterDate:[NSDate date]] isEqualToDate:self.expiration];
}

- (void)clearSessionInfo
{
    [self saveAccessTokenInfo:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.oauthStorageKey];
}

- (id)oauthClientWithHTTPS:(BOOL)https
{
    return https ? self.secureOAuthClient : self.regularOAuthClient;
}

- (void)refreshTokenOnSuccess:(void (^)(NSDictionary *userObject))successBlock
                        onFailure:(void (^)(NSError *theError))failureBlock
{
    if (self.refreshToken == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else if (self.refreshing) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorRefreshTokenInProgress userInfo:nil];
            failureBlock(error);
        }
    } else {
        self.refreshing = YES;//Don't ever trigger two refreshToken calls
        [self doTokenRequestWithEndpoint:@"refreshToken" credentials:[NSDictionary dictionaryWithObjectsAndKeys:self.refreshToken, @"refresh_token", nil] withOptions:[SMRequestOptions options] onSuccess:successBlock onFailure:failureBlock]; 
    }
    
}

- (void)doTokenRequestWithEndpoint:(NSString *)endpoint
                       credentials:(NSDictionary *)credentials 
                       withOptions:(SMRequestOptions *)options
                         onSuccess:(void (^)(NSDictionary *userObject))successBlock
                         onFailure:(void (^)(NSError *theError))failureBlock
{
    NSMutableDictionary *args = [credentials mutableCopy];
    [args setValue:@"mac" forKey:@"token_type"];
    [args setValue:@"hmac-sha-1" forKey:@"mac_algorithm"];
    NSMutableURLRequest *request = [self.tokenClient requestWithMethod:@"POST" path:[self.userSchema stringByAppendingPathComponent:endpoint] parameters:args];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [options.headers enumerateKeysAndObjectsUsingBlock:^(id headerField, id headerValue, BOOL *stop) {
        [request setValue:headerValue forHTTPHeaderField:headerField]; 
    }];
    AFSuccessBlock successHandler = ^void(NSURLRequest *req, NSHTTPURLResponse *response, id JSON) {   
        successBlock([self parseTokenResults:JSON]);
    };
    AFFailureBlock failureHandler = ^void(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error, id JSON) {
        self.refreshing = NO;
        int statusCode = response.statusCode;
        NSString *domain = HTTPErrorDomain;
        if ([[JSON valueForKey:@"error_description"] isEqualToString:@"Temporary password reset required."]) {
            statusCode = SMErrorTemporaryPasswordResetRequired;
            domain = SMErrorDomain;
        }
        failureBlock([NSError errorWithDomain:domain code:response.statusCode userInfo:JSON]);
    };
    AFJSONRequestOperation * op = [SMJSONRequestOperation JSONRequestOperationWithRequest:request success:successHandler failure:failureHandler];
    [self.tokenClient enqueueHTTPRequestOperation:op];
}

- (NSDictionary *) parseTokenResults:(NSDictionary *)result
{
    NSMutableDictionary *resultsToSave = [result mutableCopy];
    NSNumber *expires = [result valueForKey:EXPIRES_IN];
    [resultsToSave setObject:[NSDate dateWithTimeIntervalSinceNow:expires.intValue] forKey:EXPIRES_IN];
    [self saveAccessTokenInfo:resultsToSave];
    [[NSUserDefaults standardUserDefaults] setObject:resultsToSave forKey:self.oauthStorageKey];
    return [[result valueForKey:@"stackmob"] valueForKey:@"user"];   
}

- (void)saveAccessTokenInfo:(NSDictionary *)result
{
    NSString *accessToken = [result valueForKey:ACCESS_TOKEN];
    NSString *refreshToken = [result valueForKey:REFRESH_TOKEN];
    NSDate *expiration = [result valueForKey:EXPIRES_IN];
    NSString *macKey = [result valueForKey:MAC_KEY];
    self.expiration = expiration;
    self.refreshToken = refreshToken;
    self.regularOAuthClient.accessToken = accessToken;
    self.regularOAuthClient.macKey = macKey;
    self.secureOAuthClient.accessToken = accessToken;
    self.secureOAuthClient.macKey = macKey;
    self.refreshing = NO;
}

- (NSURLRequest *) signRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *newRequest = [request mutableCopy];
    //Both have the same credentials so it doesn't matter which we use here
    [self.regularOAuthClient signRequest:newRequest];
    return newRequest;
}



@end
