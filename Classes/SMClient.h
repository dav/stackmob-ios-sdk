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
#import "SMResponseBlocks.h"

@class SMRequestOptions;
@class SMDataStore;
@class SMUserSession;
@class SMCoreDataStore;

#define DEFAULT_API_HOST @"api.stackmob.com"
#define DEFAULT_USER_SCHEMA @"user"
#define DEFAULT_USER_ID_NAME @"username"
#define DEFAULT_PASSWORD_FIELD_NAME @"password"

/**
 An `SMClient` provides a high level interface to interacting with StackMob. A new client must be given at the very least an API version and public key in order to communicate with your StackMob application.
 
 `SMClient` sets default values for other configuration settings which may be set as necessary by your application.
 
 `SMClient` exposes a <defaultClient> for applications which use a globally available client to share configuration settings.
 
 ## Core Data Integration ##
 
 In order to use the Core Data integration, you must initialize an `SMClient` as well as a `NSManagedObjectModel`, then pass the `NSManagedObjectModel` instance to the `SMClient` instance method <coreDataStoreWithManagedObjectModel:> which returns an instance of <SMCoreDataStore>.  You can then retrieve an instance of `NSManagedObjectContext`:
 
    SMClient *client = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"12345"];
    SMCoreDataStore *coreDataStore = [client coreDataStoreWithManagedObjectModel:self.managedObjectModel];
    self.managedObjectContext = [coreDataStore managedObjectContext];
 
 It is important only to instantiate one `SMCoreDataStore` instance and use the same `NSManagedObjectInstance` instance throughout the duration of your application.  This ensures that you use the same copy of the context and persistent store.
 
 Last but not least, make sure to adhere to the [StackMob <--> Core Data Coding Practices](http://stackmob.github.com/stackmob-ios-sdk/index.html\#coding\_practices)!
 
 ## User Sessions ##
 
 When a client is instantiated, an instance of <SMUserSession> is initialized and configured with the provided settings.  This is where the user's OAuth2 credentials and token information is located, and is used by the internal <SMDataStore> instance to authenticate requests.
 
 ## Facebook Authentication ##
 
 The Facebook token used in the methods to create, link or login users comes from the Facebook SDK.  You must register your application with the Facebook developer website, import the SDK, and follow the tutorial to get the SDK set up in your application.  When you successfully login via Facebook, a method in your application is called and provided with the token you'll need to pass to the Facebook methods listed below.  This token does not changed once assigned but is used to verify that you have a currently authenticated session by the Facebook SDK.
 
 */
@interface SMClient : NSObject

@property(nonatomic, copy) NSString *appAPIVersion;
@property(nonatomic, copy) NSString *apiHost;
@property(nonatomic, readonly, copy) NSString *publicKey;
@property(nonatomic, copy) NSString *userSchema;
@property(nonatomic, copy) NSString *userIdName;
@property(nonatomic, copy) NSString *passwordFieldName;
@property(nonatomic, readonly, strong) SMUserSession * session;

#pragma mark init
///-------------------------------
/// @name Initialize
///-------------------------------

/**
 Override the default client.
 
 @param client The client to set.
 */
+ (void)setDefaultClient:(SMClient *)client;

/**
 A shared `SMClient` instance, for convenience. This will be the first `SMClient` object created, unless overridden
 via <setDefaultClient:>.
 */
+ (SMClient *)defaultClient;

/**
 Initialize specifying all parameters.
 
 @param appAPIVersion The API version of your StackMob application which this client instance should use.
 @param apiHost The host to connect to for API requests.
 @param publicKey Your StackMob application's OAuth2 public key.
 @param userSchema The StackMob schema that has been flagged as a user object.
 @param userIdName The StackMob primary key field name for the user object schema.
 @param passwordFieldName The StackMob field name for the password. 
 
 @return An instance of `SMClient`.
 */
- (id)initWithAPIVersion:(NSString *)appAPIVersion
                 apiHost:(NSString *)apiHost 
               publicKey:(NSString *)publicKey 
              userSchema:(NSString *)userSchema
              userIdName:(NSString *)userIdName
       passwordFieldName:(NSString *)passwordFieldName;

/**
 Initialize with only the most basic parameters and defaults for the rest.
 
 @param appAPIVersion The API version of your StackMob application which this client instance should use.
 @param publicKey Your StackMob application's OAuth2 public key.
 
 @return An instance of `SMClient`.
 */
- (id)initWithAPIVersion:(NSString *)appAPIVersion publicKey:(NSString *)publicKey;

#pragma mark datastore
///-------------------------------
/// @name Retrieving a Data Store
///-------------------------------

/**
 With the instance of <SMCoreDataStore> returned by this method you can call the <code>- (NSManagedObjectContext)managedObjectContext</code> method to retrieve an instance of `NSManagedObjectContext` that has been configured to StackMob.  It includes an `NSPersistentStoreCoordinator` of type <SMIncrementalStore> which has been initialized with the `NSManagedObjectModel` provided to this method.
 
 @param managedObjectModel An instance of `NSManagedObjectModel` set to the data model to be replicated on StackMob.
 
 @return An instance of `SMCoreDataStore`.
 */
- (SMCoreDataStore *)coreDataStoreWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

/**
 A `dataStore` instance should be used to make direct REST calls to StackMob.  See <SMDataStore> for basic CRUD methods.
 
 @return An `SMDataStore` instance using this client's configurations.
 */
- (SMDataStore *)dataStore;

#pragma mark auth
///-------------------------------
/// @name Basic Authentication
///-------------------------------

/**
 Login a user to your app with a username/password. 
 
 The credentials should match an existing user object.
 
 @param username The username to log in with.
 @param password The password to log in with.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure. If the error code is `SMErrorTemporaryPasswordResetRequired`, you should prompt the user supply a new password and call <loginWithUsername:temporaryPassword:settingNewPassword:onSuccess:onFailure:>.
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock;

/**
 Login a user to your app with a username/password. 
 
 The credentials should match an existing user object.
 
 @param username The username to log in with.
 @param password The password to log in with.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure. If the error code is `SMErrorTemporaryPasswordResetRequired`, you should prompt the user supply a new password and call <loginWithUsername:temporaryPassword:settingNewPassword:onSuccess:onFailure:>.
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
              options:(SMRequestOptions *)options
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock;

/**
 Login a user to your app with a username and temporary password, changing the users's password to the supplied new password.
 
 This call is meant to be used as part of the forgot password flow. After the user receives an email with their temporary password, they should be taken to a login screen with an extra field for a new password, and that should hook up to this API. Your app can detect this situation via <loginWithUsername:password:onSuccess:onFailure:> returning the error `SMErrorTemporaryPasswordResetRequired` to the failure block.
 
 @param username The username to log in with.
 @param tempPassword The temporary password received via email.
 @param newPassword The new password to be set, invalidating the old and temporary passwords.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)loginWithUsername:(NSString *)username
        temporaryPassword:(NSString *)tempPassword
       settingNewPassword:(NSString *)newPassword      
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock;

/**
 Login a user to your app with a username and temporary password, changing the users's password to the supplied new password. 
 
 This call is meant to be used as part of the forgot password flow. After the user receives an email with their temporary password, they should be taken to a login screen with an extra field for a new password, and that should hook up to this API. Your app can detect this situation via <loginWithUsername:password:onSuccess:onFailure:> returning the error `SMErrorTemporaryPasswordResetRequired`.
 
 @param username The username to log in with.
 @param tempPassword The temporary password received via email.
 @param newPassword The new password to be set, invalidating the old and temporary passwords.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)loginWithUsername:(NSString *)username
        temporaryPassword:(NSString *)tempPassword
       settingNewPassword:(NSString *)newPassword
              options:(SMRequestOptions *)options
                onSuccess:(SMResultSuccessBlock)successBlock
                onFailure:(SMFailureBlock)failureBlock;

/**
 Refresh the current login. 
 
 Only use this method if you plan to manually manage your session. Logins expire after an hour and needs to be refreshed. This is handled automatically when you make a request, but for highly concurrent systems you may want to call this manually.
 
 @param successBlock Completion block called on success with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)refreshLoginWithOnSuccess:(SMResultSuccessBlock)successBlock
                        onFailure:(SMFailureBlock)failureBlock;

/** @name Retrieve the Logged In User */

/**
 Return the full object associated with the logged in user.
 
 Useful on app startup to replace login when the user is already logged in.
 
 @param options An options object contains headers and other configuration for this request.
 @param successBlock Completion block called on success with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)getLoggedInUserWithOptions:(SMRequestOptions *)options
                         onSuccess:(SMResultSuccessBlock)successBlock
                         onFailure:(SMFailureBlock)failureBlock;

/**
 Return the full object associated with the logged in user.
 
 Useful on app startup to replace login when the user is already logged in.
 
 @param successBlock Completion block called on success with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)getLoggedInUserOnSuccess:(SMResultSuccessBlock)successBlock
                       onFailure:(SMFailureBlock)failureBlock;

/**
 Check whether the current user is logged in.
 
 This method first checks if a refresh token exists, and if that fails checks to see if the expiration date on the access token is later than the current time.  The reason we return `YES` to this method if a refresh token exists is because automatic refresh of a session using the refresh token is initiated if a request comes back unauthorized or the current access token has expired.  The developer does not have to worry about refreshing their own user sessions. 
 
 @return `YES` if the current user is logged in, otherwise `NO`.
 */
- (BOOL)isLoggedIn;

/**
 Check whether the user is logged out by returning the negation of <isLoggedIn>.
 
 @return `YES` if the current user is logged out, otherwise `NO`.
 */
- (BOOL)isLoggedOut;


/** @name Logout */

/**
 Logout, clearing token validity locally and on the server.
 
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)logoutOnSuccess:(SMResultSuccessBlock)successBlock
              onFailure:(SMFailureBlock)failureBlock;

/** @name Reseting Password */

/**
 Kick off the "Forgot Password" process.
 
 This should be hooked up to a button on the login screen. An email will be sent to the user with a temporary 
 password. They can then use that temporary password to login with <loginWithUsername:temporaryPassword:settingNewPassword:onSuccess:onFailure:>.
 
 @param username The user to send the email to.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)sendForgotPaswordEmailForUser:(NSString *)username
                            onSuccess:(SMResultSuccessBlock)successBlock
                            onFailure:(SMFailureBlock)failureBlock;

/**
 Reset a user's password securely.
 
 This would be hooked up to a password reset form. Changing a password via the regular datastore APIs 
 will result in an error. This API requires the user to be logged in as well as to supply their old password.
 
 @param oldPassword The user's current password.
 @param newPassword The new password for the user.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */

- (void)changeLoggedInUserPasswordFrom:(NSString *)oldPassword
                                    to:(NSString *)newPassword
                             onSuccess:(SMResultSuccessBlock)successBlock
                             onFailure:(SMFailureBlock)failureBlock;


#pragma mark Facebook
///-------------------------------
/// @name Facebook Authentication
///-------------------------------

/**
 Create a user linked with a Facebook account.
 
 The username for this method is extracted from the Facebook account.
 @param fbToken A Facebook access token obtained from Facebook.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)createUserWithFacebookToken:(NSString *)fbToken
                          onSuccess:(SMResultSuccessBlock)successBlock
                          onFailure:(SMFailureBlock)failureBlock;

/**
 Create a user linked with a Facebook account
 
 @param fbToken A Facebook access token obtained from Facebook
 @param username The username to user, rather than getting one from Facebook.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)createUserWithFacebookToken:(NSString *)fbToken
                           username:(NSString *)username
                          onSuccess:(SMResultSuccessBlock)successBlock
                          onFailure:(SMFailureBlock)failureBlock;

/**
 Link the logged in user with a Facebook account.
 
 @param fbToken A Facebook access token obtained from Facebook.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)linkLoggedInUserWithFacebookToken:(NSString *)fbToken
                                onSuccess:(SMResultSuccessBlock)successBlock
                                onFailure:(SMFailureBlock)failureBlock;

/**
 Login a user to your app with a Facebook token.
 
 The credentials should match a existing user object that has a linked Facebook account, via either <createUserWithFacebookToken:onSuccess:onFailure:>, or <linkLoggedInUserWithFacebookToken:onSuccess:onFailure:>.
 
 @param fbToken A Facebook access token obtained from Facebook.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)loginWithFacebookToken:(NSString *)fbToken
                     onSuccess:(SMResultSuccessBlock)successBlock
                     onFailure:(SMFailureBlock)failureBlock;

/**
 Login a user to your app with a Facebook token.
 
 The credentials should match a existing user object that has a linked Facebook account, via either <createUserWithFacebookToken:onSuccess:onFailure:>, or <linkLoggedInUserWithFacebookToken:onSuccess:onFailure:>.
 
 @param fbToken A Facebook access token obtained from Facebook.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)loginWithFacebookToken:(NSString *)fbToken
                   options:(SMRequestOptions *)options
                     onSuccess:(SMResultSuccessBlock)successBlock
                     onFailure:(SMFailureBlock)failureBlock;

/**
 Update the logged in users's Facebook status.
 
 The logged in user must have a linked Facebook account, via either 
 <createUserWithFacebookToken:onSuccess:onFailure:>, or <linkLoggedInUserWithFacebookToken:onSuccess:onFailure:>.
 
 @param message The message to post.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)updateFacebookStatusWithMessage:(NSString *)message
                          onSuccess:(SMResultSuccessBlock)successBlock
                          onFailure:(SMFailureBlock)failureBlock;

/**
 Get Facebook info for the logged in users.
 
 The logged in user must have a linked Facebook account, via either 
 <createUserWithFacebookToken:onSuccess:onFailure:>, or <linkLoggedInUserWithFacebookToken:onSuccess:onFailure:>.
 
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)getLoggedInUserFacebookInfoWithOnSuccess:(SMResultSuccessBlock)successBlock
                                       onFailure:(SMFailureBlock)failureBlock;


#pragma mark twitter
///-------------------------------
/// @name Twitter Authentication
///-------------------------------

/**
 Create a user linked with a Twitter account
 
 The username is extracted from the Twitter account.
 
 @param twitterToken A Twitter token obtained from Twitter.
 @param twitterSecret A Twitter secret obtained from Twitter.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)createUserWithTwitterToken:(NSString *)twitterToken
                     twitterSecret:(NSString *)twitterSecret
                         onSuccess:(SMResultSuccessBlock)successBlock
                         onFailure:(SMFailureBlock)failureBlock;

/**
 Create a user linked with a Twitter account.
 
 @param twitterToken A Twitter token obtained from Twitter.
 @param twitterSecret A Twitter secret obtained from Twitter.
 @param username The username to user, rather than getting one from Twitter.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)createUserWithTwitterToken:(NSString *)twitterToken
                     twitterSecret:(NSString *)twitterSecret
                          username:(NSString *)username
                         onSuccess:(SMResultSuccessBlock)successBlock
                         onFailure:(SMFailureBlock)failureBlock;

/**
 Link the logged in user with a Twitter account.
 
 @param twitterToken A Twitter token obtained from Twitter.
 @param twitterSecret A Twitter secret obtained from Twitter.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)linkLoggedInUserWithTwitterToken:(NSString *)twitterToken
                           twitterSecret:(NSString *)twitterSecret
                               onSuccess:(SMResultSuccessBlock)successBlock
                               onFailure:(SMFailureBlock)failureBlock;

/**
 Login a user to your app with twitter credentials.
 
 The credentials should match a existing user object that has a linked Twitter account, via either <createUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>, or <linkLoggedInUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>.
 
 @param twitterToken A Twitter token obtained from Twitter.
 @param twitterSecret A Twitter secret obtained from Twitter.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)loginWithTwitterToken:(NSString *)twitterToken
                twitterSecret:(NSString *)twitterSecret
                    onSuccess:(SMResultSuccessBlock)successBlock
                    onFailure:(SMFailureBlock)failureBlock;

/**
 Login a user to your app with twitter credentials.
 
 The credentials should match a existing user object that has a linked Twitter account, via either 
 <createUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>, or <linkLoggedInUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>.
 
 @param twitterToken A Twitter token obtained from Twitter.
 @param twitterSecret A Twitter secret obtained from Twitter.
 @param options An options object contains headers and other configuration for this request.
 @param successBlock Completion block called on successful login with the user object for the logged in user.
 @param failureBlock Completion block called on failure.
 */
- (void)loginWithTwitterToken:(NSString *)twitterToken
                twitterSecret:(NSString *)twitterSecret
                  options:(SMRequestOptions *)options
                    onSuccess:(SMResultSuccessBlock)successBlock
                    onFailure:(SMFailureBlock)failureBlock;

/**
 Update the logged in users's Twitter status.
 
 The logged in user must have a linked Twitter account, via either 
 <createUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>, or <linkLoggedInUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>.
 
 @param message The message to post.
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)updateTwitterStatusWithMessage:(NSString *)message
                             onSuccess:(SMResultSuccessBlock)successBlock
                             onFailure:(SMFailureBlock)failureBlock;

/**
 Get Twitter info for the logged in users.
 
 The logged in user must have a linked Twitter account, via either
 <createUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>, or <linkLoggedInUserWithTwitterToken:twitterSecret:onSuccess:onFailure:>.
 
 @param successBlock Completion block called on success.
 @param failureBlock Completion block called on failure.
 */
- (void)getLoggedInUserTwitterInfoOnSuccess:(SMResultSuccessBlock)successBlock
                                      onFailure:(SMFailureBlock)failureBlock;


@end
