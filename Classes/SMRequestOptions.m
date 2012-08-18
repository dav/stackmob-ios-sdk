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

#import "SMRequestOptions.h"

@implementation SMRequestOptions

@synthesize headers = _SM_headers;
@synthesize isSecure = _SM_isSecure;
@synthesize tryRefreshToken = _SM_tryRefreshToken;
@synthesize numberOfRetries = _SM_numberOfRetries;
@synthesize retryBlock = _SM_retryBlock;


+ (SMRequestOptions *)options
{
    SMRequestOptions *opts = [[SMRequestOptions alloc] init];
    opts.tryRefreshToken = YES;
    opts.numberOfRetries = 3;
    opts.retryBlock = nil;
    return opts;
}

+ (SMRequestOptions *)optionsWithHeaders:(NSDictionary *)headers
{
    SMRequestOptions *opt = [SMRequestOptions options];
    opt.headers = headers;
    return opt;
}


+ (SMRequestOptions *)optionsWithHTTPS
{
    SMRequestOptions *opt = [SMRequestOptions options];
    opt.isSecure = YES;
    return opt;
}

+ optionsWithExpandDepth:(NSUInteger)depth
{
    SMRequestOptions *opt = [SMRequestOptions options];
    [opt setExpandDepth:depth];
    return opt;
}

+ optionsWithReturnedFieldsRestrictedTo:(NSArray *)fields
{
    SMRequestOptions *opt = [SMRequestOptions options];
    [opt restrictReturnedFieldsTo:fields];
    return opt;
}

- (void)setExpandDepth:(NSUInteger)depth
{
    [self.headers setValue:[NSString stringWithFormat:@"%d", depth] forKey:@"X-StackMob-Expand"];
}

- (void)restrictReturnedFieldsTo:(NSArray *)fields
{
    [self.headers setValue:[fields componentsJoinedByString:@","] forKey:@"X-StackMob-Select"];
}

- (void)addSMErrorServiceUnavailableRetryBlock:(SMFailureRetryBlock)retryBlock
{
    self.retryBlock = retryBlock;
}

@end
