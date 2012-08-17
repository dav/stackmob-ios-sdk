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

@interface SMCustomCodeRequest : NSObject

@property (nonatomic, strong) NSMutableArray *queryStringParameters;
@property (nonatomic, strong) NSMutableDictionary *requestHeaders;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *requestBody;
@property (nonatomic, strong) NSString *httpVerb;

- (id)initPostRequestWithMethod:(NSString *)method body:(NSString *)body;
- (id)initPutRequestWithMethod:(NSString *)method body:(NSString *)body;
- (id)initGetRequestWithMethod:(NSString *)method;
- (id)initDeleteRequestWithMethod:(NSString *)method;
- (void)addQueryStringParameterWhere:(NSString *)key equals:(NSString *)value;

@end
