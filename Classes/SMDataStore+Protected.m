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

- (SMFullResponseSuccessBlock)SMFullResponseSuccessBlockForSchema:(NSString *)schema withSuccessBlock:(SMDataStoreSuccessBlock)successBlock
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(JSON, schema);
        }
    };
}

- (SMFullResponseSuccessBlock)SMFullResponseSuccessBlockForObjectId:(NSString *)theObjectId ofSchema:(NSString *)schema withSuccessBlock:(SMDataStoreObjectIdSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(theObjectId, schema);
        }
    };
}

- (SMFullResponseSuccessBlock)SMFullResponseSuccessBlockForSuccessBlock:(SMSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock();
        }
    };
}

- (SMFullResponseSuccessBlock)SMFullResponseSuccessBlockForResultSuccessBlock:(SMResultSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(JSON);
        }
    };
}

- (SMFullResponseSuccessBlock)SMFullResponseSuccessBlockForResultsSuccessBlock:(SMResultsSuccessBlock)successBlock 
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if (successBlock) {
            successBlock(JSON);
        }
    };
}


- (SMFullResponseFailureBlock)SMFullResponseFailureBlockForObject:(NSDictionary *)theObject ofSchema:(NSString *)schema withFailureBlock:(SMDataStoreFailureBlock)failureBlock
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if (failureBlock) {
            failureBlock([self errorFromResponse:response JSON:JSON], theObject, schema);
        }
    };
}

- (SMFullResponseFailureBlock)SMFullResponseFailureBlockForObjectId:(NSString *)theObjectId ofSchema:(NSString *)schema withFailureBlock:(SMDataStoreObjectIdFailureBlock)failureBlock
{
    return ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if (failureBlock) {
            failureBlock([self errorFromResponse:response JSON:JSON], theObjectId, schema);
        }
    };
}

- (SMFullResponseFailureBlock)SMFullResponseFailureBlockForFailureBlock:(SMFailureBlock)failureBlock
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

- (void)readObjectWithId:(NSString *)theObjectId inSchema:(NSString *)schema parameters:(NSDictionary *)parameters options:(SMRequestOptions *)options onSuccess:(SMDataStoreSuccessBlock)successBlock onFailure:(SMDataStoreObjectIdFailureBlock)failureBlock
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
        
        SMFullResponseSuccessBlock urlSuccessBlock = [self SMFullResponseSuccessBlockForSchema:schema withSuccessBlock:successBlock];
        SMFullResponseFailureBlock urlFailureBlock = [self SMFullResponseFailureBlockForObjectId:theObjectId ofSchema:schema withFailureBlock:failureBlock];
        [self queueRequest:request options:options onSuccess:urlSuccessBlock onFailure:urlFailureBlock];
    }
}

- (void)refreshAndRetry:(NSURLRequest *)request onSuccess:(SMFullResponseSuccessBlock)onSuccess onFailure:(SMFullResponseFailureBlock)onFailure
{
    if (self.session.refreshing) {
        if (onFailure) {
            NSError *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorRefreshTokenInProgress userInfo:nil];
            onFailure(request, nil, error, nil);
        }
    } else {
        __block SMRequestOptions *options = [SMRequestOptions options];
        [options setTryRefreshToken:NO];
        [self.session refreshTokenOnSuccess:^(NSDictionary *userObject) {
            [self queueRequest:[self.session signRequest:request] options:options onSuccess:onSuccess onFailure:onFailure];
        } onFailure:^(NSError *theError) {
            [self queueRequest:[self.session signRequest:request] options:options onSuccess:onSuccess onFailure:onFailure];
        }];
    }
}

- (void)queueRequest:(NSURLRequest *)request options:(SMRequestOptions *)options onSuccess:(SMFullResponseSuccessBlock)onSuccess onFailure:(SMFullResponseFailureBlock)onFailure
{
    if (![self.session accessTokenHasExpired] && self.session.refreshToken != nil && options.tryRefreshToken) {
        [self refreshAndRetry:request onSuccess:onSuccess onFailure:onFailure];
    } 
    else {
        SMFullResponseFailureBlock retryBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if ([response statusCode] == SMErrorUnauthorized && options.tryRefreshToken) {
                [self refreshAndRetry:request onSuccess:onSuccess onFailure:onFailure];
            } else if ([response statusCode] == SMErrorServiceUnavailable && options.numberOfRetries > 0) {
                NSString *retryAfter = [[response allHeaderFields] valueForKey:@"Retry-After"];
                if (retryAfter) {
                    [options setNumberOfRetries:(options.numberOfRetries - 1)];
                    double delayInSeconds = [retryAfter intValue] / 1000.00;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        if (options.retryBlock) {
                            options.retryBlock(request, response, error, JSON, options, onSuccess, onFailure);
                        } else {
                            [self queueRequest:[self.session signRequest:request] options:options onSuccess:onSuccess onFailure:onFailure];
                        }
                    });
                } else {
                    onFailure(request, response, error, JSON);
                }
            } else {
                onFailure(request, response, error, JSON);
            }
            
        };
        
        AFJSONRequestOperation *op = [SMJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:retryBlock];
        [[self.session oauthClientWithHTTPS:FALSE] enqueueHTTPRequestOperation:op];
    }
    
}



@end
