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

#import "SMDataStore+Protected.h"
#import "SMError.h"
#import "SMJSONRequestOperation.h"
#import "SMRequestOptions.h"

@implementation SMDataStore (SpecialCondition)

- (NSError *)errorFromResponse:(NSHTTPURLResponse *)response JSON:(id)JSON
{
    return [NSError errorWithDomain:HTTPErrorDomain code:response.statusCode userInfo:JSON];
}

- (AFSuccessBlock)AFSuccessBlockForSchema:(NSString *)schema withSuccessBlock:(SMDataStoreSuccessBlock)successBlock
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(JSON, schema);
        }
    };
}

- (AFSuccessBlock)AFSuccessBlockForObjectId:(NSString *)theObjectId ofSchema:(NSString *)schema withSuccessBlock:(SMDataStoreObjectIdSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(theObjectId, schema);
        }
    };
}

- (AFSuccessBlock)AFSuccessBlockForSuccessBlock:(SMSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock();
        }
    };
}

- (AFSuccessBlock)AFSuccessBlockForResultSuccessBlock:(SMResultSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(JSON);
        }
    };
}

- (AFSuccessBlock)AFSuccessBlockForResultsSuccessBlock:(SMResultsSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(JSON);
        }
    };
}


- (AFFailureBlock)AFFailureBlockForObject:(NSDictionary *)theObject ofSchema:(NSString *)schema withFailureBlock:(SMDataStoreFailureBlock)failureBlock
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if (failureBlock) {
            failureBlock([self errorFromResponse:response JSON:JSON], theObject, schema);
        }
    };
}

- (AFFailureBlock)AFFailureBlockForObjectId:(NSString *)theObjectId ofSchema:(NSString *)schema withFailureBlock:(SMDataStoreObjectIdFailureBlock)failureBlock
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if (failureBlock) {
            failureBlock([self errorFromResponse:response JSON:JSON], theObjectId, schema);
        }
    };
}

- (AFFailureBlock)AFFailureBlockForFailureBlock:(SMFailureBlock)failureBlock
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if (failureBlock) {
            failureBlock([self errorFromResponse:response JSON:JSON]);
        }
    };
}

- (int)countFromRangeHeader:(NSString *)rangeHeader results:(NSArray *)results
{
    if (rangeHeader == nil) {
        //No range header means we've got all the results right here (1 or 0)
        return [results count];
    } else {
        NSArray* parts = [rangeHeader componentsSeparatedByString: @"/"];
        if ([parts count] != 2) return -1;
        NSString *lastPart = [parts objectAtIndex: 1];
        if ([lastPart isEqualToString:@"*"]) return -2;
        if ([lastPart isEqualToString:@"0"]) return 0;
        int count = [lastPart intValue];
        if (count == 0) return -1; //real zero was filtered out above
        return count;
    } 
}

- (void)readObjectWithId:(NSString *)theObjectId inSchema:(NSString *)schema parameters:(NSDictionary *)parameters withOptions:(SMRequestOptions *)options onSuccess:(SMDataStoreSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock
{
    if (theObjectId == nil || schema == nil) {
        if (failureBlock) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:nil];
            failureBlock(error, theObjectId, schema);
        }
    } else {
        NSString *path = [schema stringByAppendingPathComponent:theObjectId];
        NSMutableURLRequest *request = [[self.session oauthClientWithHTTPS:options.isSecure] requestWithMethod:@"GET" path:path parameters:parameters];
        [options.headers enumerateKeysAndObjectsUsingBlock:^(id headerField, id headerValue, BOOL *stop) {
            [request setValue:headerValue forHTTPHeaderField:headerField]; 
        }];
        AFSuccessBlock urlSuccessBlock = [self AFSuccessBlockForSchema:schema withSuccessBlock:successBlock];
        AFFailureBlock urlFailureBlock = [self AFFailureBlockForObjectId:theObjectId ofSchema:schema withFailureBlock:failureBlock];
        [self queueRequest:request withRetry:options.tryRefreshToken onSuccess:urlSuccessBlock onFailure:urlFailureBlock];
    }
}

- (void)refreshAndRetry:(NSURLRequest *)request onSuccess:(AFSuccessBlock)onSuccess onFailure:(AFFailureBlock)onFailure
{
    if (self.session.refreshing) {
        if (onFailure) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorRefreshTokenInProgress userInfo:nil];
            onFailure(request, nil, error, nil);
        }
    } else {
        [self.session refreshTokenOnSuccess:^(NSDictionary *userObject) {
            [self queueRequest:[self.session signRequest:request] withRetry:NO onSuccess:onSuccess onFailure:onFailure];
        } onFailure:^(NSError *theError) {
            [self queueRequest:[self.session signRequest:request] withRetry:NO onSuccess:onSuccess onFailure:onFailure];
        }];
    }
}

- (void)queueRequest:(NSURLRequest *)request withRetry:(BOOL)retry onSuccess:(AFSuccessBlock)onSuccess onFailure:(AFFailureBlock)onFailure
{
    if (![self.session accessTokenHasExpired] && self.session.refreshToken != nil && retry) {
        [self refreshAndRetry:request onSuccess:onSuccess onFailure:onFailure];
    } else {
        AFFailureBlock retryBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if ([response statusCode] == SMErrorUnauthorized && retry) {
                [self refreshAndRetry:request onSuccess:onSuccess onFailure:onFailure];
            } else {
                onFailure(request, response, error, JSON);
            }
            
        };
        
        AFJSONRequestOperation *op = [SMJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:retryBlock];
        [[self.session oauthClientWithHTTPS:FALSE] enqueueHTTPRequestOperation:op];
    }
    
}



@end
