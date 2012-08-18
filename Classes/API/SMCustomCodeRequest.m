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

#import "SMCustomCodeRequest.h"

@interface SMCustomCodeRequest (hidden)

- (id)initWithMethod:(NSString *)method body:(NSString *)body httpVerb:(NSString *)verb;

@end

@implementation SMCustomCodeRequest (hidden)

- (id)initWithMethod:(NSString *)method body:(NSString *)body httpVerb:(NSString *)verb;
{
    self = [super init];
    if (self) {
        self.method = method; 
        self.httpVerb = verb;
        self.requestBody = body ? body : nil;
        self.queryStringParameters = [NSMutableArray arrayWithCapacity:1];
    }
    
    return self;
}

@end

@implementation SMCustomCodeRequest

@synthesize queryStringParameters = _queryStringParameters;
@synthesize method = _method;
@synthesize requestBody = _requestBody;
@synthesize httpVerb = _httpVerb;

- (id)initPostRequestWithMethod:(NSString *)method body:(NSString *)body
{
    return [self initWithMethod:method body:body httpVerb:@"POST"];
}

- (id)initPutRequestWithMethod:(NSString *)method body:(NSString *)body
{
    return [self initWithMethod:method body:body httpVerb:@"PUT"];
}

- (id)initGetRequestWithMethod:(NSString *)method
{
    return [self initWithMethod:method body:nil httpVerb:@"GET"];
}

- (id)initDeleteRequestWithMethod:(NSString *)method
{
    return [self initWithMethod:method body:nil httpVerb:@"DELETE"];
}

- (void)addQueryStringParameterWhere:(NSString *)key equals:(NSString *)value
{
    [self.queryStringParameters addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
}

@end
