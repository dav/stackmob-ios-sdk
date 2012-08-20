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

#import "SMClient.h"
#import "SMDataStore.h"
#import "SMCoreDataStore.h"
#import "SMUserSession.h"
#import "SMDataStore+Protected.h"
#import "SMRequestOptions.h"
#import "SMError.h"

#define FB_TOKEN_KEY @"fb_at"
#define TW_TOKEN_KEY @"tw_tk"
#define TW_SECRET_KEY @"tw_ts"

static SMClient *defaultClient = nil;

@interface SMClient ()

@property(nonatomic, readwrite, copy) NSString *publicKey;
@property(nonatomic, readwrite, strong) SMUserSession * session;
@property(nonatomic, readwrite, strong) SMCoreDataStore *coreDataStore;
@end

@implementation SMClient

@synthesize appAPIVersion = _SM_appAPIVersion;
@synthesize publicKey = _SM_publicKey;
@synthesize apiHost = _SM_APIHost;
@synthesize userSchema = _SM_userSchema;
@synthesize userIdName = _SM_userIdName;
@synthesize passwordFieldName = _SM_passwordFieldName;

@synthesize session = _SM_session;
@synthesize coreDataStore = _SM_coreDataStore;

+ (void)setDefaultClient:(SMClient *)client
{
    defaultClient = client;
}

+ (SMClient *)defaultClient
{
    return defaultClient;
}

- (id)initWithAPIVersion:(NSString *)appAPIVersion 
                 apiHost:(NSString *)apiHost 
               publicKey:(NSString *)publicKey 
              userSchema:(NSString *)userSchema
              userIdName:(NSString *)userIdName
       passwordFieldName:(NSString *)passwordFieldName;
{
    self = [self init];
    if (self)
    {
        self.appAPIVersion = appAPIVersion;
        self.apiHost = apiHost;
        self.publicKey = publicKey;
        self.userSchema = userSchema;
        self.userIdName = userIdName;
        self.passwordFieldName = passwordFieldName;
        
        self.session = [[SMUserSession alloc] initWithAPIVersion:appAPIVersion apiHost:apiHost publicKey:publicKey userSchema:userSchema];
        self.coreDataStore = nil;

        if ([SMClient defaultClient] == nil)
        {
            [SMClient setDefaultClient:self];
        }
    }
    return self;  
}

- (id)initWithAPIVersion:(NSString *)appAPIVersion publicKey:(NSString *)publicKey
{
    return [self initWithAPIVersion:appAPIVersion
                            apiHost:DEFAULT_API_HOST 
                          publicKey:publicKey 
                         userSchema:DEFAULT_USER_SCHEMA
                         userIdName:DEFAULT_USER_ID_NAME 
                  passwordFieldName:DEFAULT_PASSWORD_FIELD_NAME];
}

- (SMDataStore *)dataStore
{
    return [[SMDataStore alloc] initWithAPIVersion:self.appAPIVersion session:self.session];
}

- (SMCoreDataStore *)coreDataStoreWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    if (self.coreDataStore == nil) {
        self.coreDataStore = [[SMCoreDataStore alloc] initWithAPIVersion:self.appAPIVersion session:self.session managedObjectModel:managedObjectModel];
    }
    
    return self.coreDataStore;
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock
{
    [self loginWithUsername:username password:password options:[SMRequestOptions options] onSuccess:successBlock onFailure:failureBlock];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
              options:(SMRequestOptions *)options
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock
{
    if (username == nil || password == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:username, self.userIdName, password, self.passwordFieldName, nil];
        [self.session doTokenRequestWithEndpoint:@"accessToken" credentials:args options:options onSuccess:successBlock onFailure:failureBlock]; 
    }
}

- (void)loginWithUsername:(NSString *)username
        temporaryPassword:(NSString *)tempPassword
       settingNewPassword:(NSString *)newPassword
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock
{
    [self loginWithUsername:username temporaryPassword:tempPassword settingNewPassword:newPassword options:[SMRequestOptions options] onSuccess:successBlock onFailure:failureBlock];
}

- (void)loginWithUsername:(NSString *)username
        temporaryPassword:(NSString *)tempPassword
       settingNewPassword:(NSString *)newPassword
              options:(SMRequestOptions *)options
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock
{
    if (username == nil || tempPassword == nil || newPassword == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:username, self.userIdName, 
                              tempPassword, self.passwordFieldName, 
                              newPassword, @"new_password", nil];
        [self.session doTokenRequestWithEndpoint:@"accessToken" credentials:args options:options onSuccess:successBlock onFailure:failureBlock]; 
    }
}

- (void)getLoggedInUserOnSuccess:(SMResultSuccessBlock)successBlock
                       onFailure:(SMFailureBlock)failureBlock
{
    [self getLoggedInUserWithOptions:[SMRequestOptions options] onSuccess:successBlock onFailure:failureBlock];
}

- (void)getLoggedInUserWithOptions:(SMRequestOptions *)options
                         onSuccess:(SMResultSuccessBlock)successBlock
                         onFailure:(SMFailureBlock)failureBlock
{
    [self.dataStore readObjectWithId:@"loggedInUser" inSchema:self.userSchema options:options onSuccess:^(NSDictionary *theObject, NSString *schema) {
        successBlock(theObject);
    } onFailure:^(NSError *theError, NSString *theObject, NSString *schema) {
        failureBlock(theError);
    }];   
}

- (void)refreshLoginWithOnSuccess:(SMResultSuccessBlock)successBlock
                        onFailure:(SMFailureBlock)failureBlock
{
    [[self session] refreshTokenOnSuccess:successBlock onFailure:failureBlock];
}

- (void)sendForgotPaswordEmailForUser:(NSString *)username
                            onSuccess:(SMResultSuccessBlock)successBlock
                            onFailure:(SMFailureBlock)failureBlock
{
    if (username == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *args = [NSDictionary dictionaryWithObject:username forKey:self.userIdName];
        [self.dataStore createObject:args inSchema:[self.userSchema stringByAppendingPathComponent:@"forgotPassword"] onSuccess:^(NSDictionary *theObject, NSString *schema) {
            successBlock(theObject);
        } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
            failureBlock(theError);
        }];
    }
}

- (void)changeLoggedInUserPasswordFrom:(NSString *)oldPassword
                                     to:(NSString *)newPassword
                              onSuccess:(SMResultSuccessBlock)successBlock
                              onFailure:(SMFailureBlock)failureBlock
{
    if (oldPassword == nil || newPassword == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *old = [NSDictionary dictionaryWithObject:oldPassword forKey:@"password"];
        NSDictionary *new = [NSDictionary dictionaryWithObject:newPassword forKey:@"password"];
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:old, @"old", new, @"new", nil];
        SMRequestOptions *options = [SMRequestOptions options];
        options.isSecure = YES;
        [self.dataStore createObject:args inSchema:[self.userSchema stringByAppendingPathComponent:@"resetPassword"] options:options onSuccess:^(NSDictionary *theObject, NSString *schema) {
            successBlock(theObject);
        } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
            failureBlock(theError);
        }];
    }
}

- (void)logoutOnSuccess:(SMResultSuccessBlock)successBlock
                  onFailure:(SMFailureBlock)failureBlock
{
    [self.dataStore readObjectWithId:@"logout" inSchema:self.userSchema  onSuccess:^(NSDictionary *theObject, NSString *schema) {
        [[self session] clearSessionInfo];
        successBlock(theObject);
    } onFailure:^(NSError *theError, NSString *theObject, NSString *schema) {
        failureBlock(theError);
    }];  
}

- (BOOL)isLoggedIn
{
    return [self.session refreshToken] != nil || [self.session accessTokenHasExpired];
}

- (BOOL)isLoggedOut
{
    return ![self isLoggedIn];
}

- (void)createUserWithFacebookToken:(NSString *)fbToken
                          onSuccess:(SMResultSuccessBlock)successBlock
                          onFailure:(SMFailureBlock)failureBlock
{
    [self createUserWithFacebookToken:fbToken username:nil onSuccess:successBlock onFailure:failureBlock];
}

- (void)createUserWithFacebookToken:(NSString *)fbToken
                           username:(NSString *)username
                          onSuccess:(SMResultSuccessBlock)successBlock
                          onFailure:(SMFailureBlock)failureBlock
{
    if (fbToken == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSMutableDictionary *args = [[NSDictionary dictionaryWithObject:fbToken forKey:FB_TOKEN_KEY] mutableCopy];
        if (username != nil) {
            [args setValue:username forKey:self.userIdName];
        }
        [self.dataStore readObjectWithId:@"createUserWithFacebook" inSchema:self.userSchema parameters:args options:[SMRequestOptions optionsWithHTTPS] onSuccess:^(NSDictionary *theObject, NSString *schema) {
            successBlock(theObject);
        } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
            failureBlock(theError);
        }];
    }
}

- (void)linkLoggedInUserWithFacebookToken:(NSString *)fbToken
                                onSuccess:(SMResultSuccessBlock)successBlock
                                onFailure:(SMFailureBlock)failureBlock
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:fbToken, FB_TOKEN_KEY, nil];
    [self.dataStore readObjectWithId:@"linkUserWithFacebook" inSchema:self.userSchema parameters:args options:[SMRequestOptions optionsWithHTTPS] onSuccess:^(NSDictionary *theObject, NSString *schema) {
        successBlock(theObject);
    } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
        failureBlock(theError);
    }]; 
}

- (void)loginWithFacebookToken:(NSString *)fbToken
                     onSuccess:(SMResultSuccessBlock)successBlock
                     onFailure:(SMFailureBlock)failureBlock
{
    [self loginWithFacebookToken:fbToken options:[SMRequestOptions options] onSuccess:successBlock onFailure:failureBlock];
}

- (void)loginWithFacebookToken:(NSString *)fbToken
                   options:(SMRequestOptions *)options
                     onSuccess:(SMResultSuccessBlock)successBlock
                     onFailure:(SMFailureBlock)failureBlock
{
    if (fbToken == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:fbToken, FB_TOKEN_KEY, nil];
        [self.session doTokenRequestWithEndpoint:@"facebookAccessToken" credentials:args options:options onSuccess:successBlock onFailure:failureBlock]; 
    }
}

- (void)updateFacebookStatusWithMessage:(NSString *)message
                              onSuccess:(SMResultSuccessBlock)successBlock
                              onFailure:(SMFailureBlock)failureBlock
{
    if (message == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *args = [NSDictionary dictionaryWithObject:message forKey:@"message"];

        [self.dataStore readObjectWithId:@"postFacebookMessage" inSchema:self.userSchema parameters:args options:[SMRequestOptions options] onSuccess:^(NSDictionary *theObject, NSString *schema) {
            successBlock(theObject);
        } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
            failureBlock(theError);
        }];
    }
}

- (void)getLoggedInUserFacebookInfoWithOnSuccess:(SMResultSuccessBlock)successBlock
                                       onFailure:(SMFailureBlock)failureBlock
{ 
    [self.dataStore readObjectWithId:@"getFacebookUserInfo" inSchema:self.userSchema onSuccess:^(NSDictionary *theObject, NSString *schema) {
        successBlock(theObject);
    } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
        failureBlock(theError);
    }];
}

- (void)createUserWithTwitterToken:(NSString *)twitterToken
                     twitterSecret:(NSString *)twitterSecret
                         onSuccess:(SMResultSuccessBlock)successBlock
                         onFailure:(SMFailureBlock)failureBlock
{
    [self createUserWithTwitterToken:twitterToken twitterSecret:twitterSecret username:nil onSuccess:successBlock onFailure:failureBlock];
}


- (void)createUserWithTwitterToken:(NSString *)twitterToken
                     twitterSecret:(NSString *)twitterSecret
                          username:(NSString *)username
                         onSuccess:(SMResultSuccessBlock)successBlock
                         onFailure:(SMFailureBlock)failureBlock
{
    if (twitterToken == nil || twitterSecret == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSMutableDictionary *args = [[NSDictionary dictionaryWithObjectsAndKeys:twitterToken, TW_TOKEN_KEY, twitterSecret, TW_SECRET_KEY, nil] mutableCopy];
        if (username != nil) {
            [args setValue:username forKey:self.userIdName];
        }
        [self.dataStore readObjectWithId:@"createUserWithTwitter" inSchema:self.userSchema parameters:args options:[SMRequestOptions optionsWithHTTPS] onSuccess:^(NSDictionary *theObject, NSString *schema) {
            successBlock(theObject);
        } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
            failureBlock(theError);
        }];
    }   
}

- (void)linkLoggedInUserWithTwitterToken:(NSString *)twitterToken
                           twitterSecret:(NSString *)twitterSecret
                               onSuccess:(SMResultSuccessBlock)successBlock
                               onFailure:(SMFailureBlock)failureBlock
{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:twitterToken, TW_TOKEN_KEY, twitterSecret, TW_SECRET_KEY, nil];
    [self.dataStore readObjectWithId:@"linkUserWithTwitter" inSchema:self.userSchema parameters:args options:[SMRequestOptions optionsWithHTTPS] onSuccess:^(NSDictionary *theObject, NSString *schema) {
        successBlock(theObject);
    } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
        failureBlock(theError);
    }];  
}

- (void)loginWithTwitterToken:(NSString *)twitterToken
                twitterSecret:(NSString *)twitterSecret
                    onSuccess:(SMResultSuccessBlock)successBlock
                    onFailure:(SMFailureBlock)failureBlock
{
    [self loginWithTwitterToken:twitterToken twitterSecret:twitterSecret options:[SMRequestOptions options] onSuccess:successBlock onFailure:failureBlock];
}

- (void)loginWithTwitterToken:(NSString *)twitterToken
                twitterSecret:(NSString *)twitterSecret
                  options:(SMRequestOptions *)options
                    onSuccess:(SMResultSuccessBlock)successBlock
                    onFailure:(SMFailureBlock)failureBlock
{
    if (twitterToken == nil || twitterSecret == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:twitterToken, TW_TOKEN_KEY, twitterSecret, TW_SECRET_KEY, nil];
        [self.session doTokenRequestWithEndpoint:@"twitterAccessToken" credentials:args options:options onSuccess:successBlock onFailure:failureBlock]; 
    }
}

- (void)updateTwitterStatusWithMessage:(NSString *)message
                             onSuccess:(SMResultSuccessBlock)successBlock
                             onFailure:(SMFailureBlock)failureBlock
{
    if (message == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error);
        }
    } else {
        NSDictionary *args = [NSDictionary dictionaryWithObject:message forKey:@"message"];
        
        [self.dataStore readObjectWithId:@"twitterStatusUpdate" inSchema:self.userSchema parameters:args options:[SMRequestOptions options] onSuccess:^(NSDictionary *theObject, NSString *schema) {
            successBlock(theObject);
        } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
            failureBlock(theError);
        }];
    } 
}

- (void)getLoggedInUserTwitterInfoOnSuccess:(SMResultSuccessBlock)successBlock
                                      onFailure:(SMFailureBlock)failureBlock
{
    [self.dataStore readObjectWithId:@"getTwitterUserInfo" inSchema:self.userSchema onSuccess:^(NSDictionary *theObject, NSString *schema) {
        successBlock(theObject);
    } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
        failureBlock(theError);
    }];
}

@end
