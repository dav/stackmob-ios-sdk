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

#import "SMOAuth2Client.h"
#import <CommonCrypto/CommonHMAC.h>
#import "SMVersion.h"

static NSString* Base64EncodedStringFromData(NSData *data);

@implementation SMOAuth2Client

@synthesize version = _SM_version;
@synthesize publicKey = _SM_publicKey;
@synthesize apiHost = _SM_apiHost;
@synthesize accessToken = _SM_accessToken;
@synthesize macKey = _SM_macKey;

- (id)initWithAPIVersion:(NSString *)version
                   scheme:(NSString *)scheme
                  apiHost:(NSString *)apiHost 
                publicKey:(NSString *)publicKey 
{
    self = [super initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", scheme, apiHost]]];
    
    if (self) {
        self.version = version;
        self.publicKey = publicKey;
        NSString *acceptHeader = [NSString stringWithFormat:@"application/vnd.stackmob+json; version=%@", version];
        [self setDefaultHeader:@"Accept" value:acceptHeader]; 
        [self setDefaultHeader:@"X-StackMob-API-Key" value:self.publicKey];
        [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"StackMob/%@ (%@/%@; %@;)", SDK_VERSION, [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[NSLocale currentLocale] localeIdentifier]]];
        self.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method 
                                       path:(NSString *)path 
                                 parameters:(NSDictionary *)parameters
{
    
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [self signRequest:request];
    return request;
}

- (void)signRequest:(NSMutableURLRequest *)request
{
    if ([self hasValidCredentials]) {
        NSString *queryString = [[request URL] query] == nil ? @"" : [NSString stringWithFormat:@"&%@", [[request URL] query]];
        NSString *pathAndQuery = [NSString stringWithFormat:@"%@%@", [[request URL] path], queryString];
        NSString *macHeader = [self createMACHeaderForHttpMethod:[request HTTPMethod] path:pathAndQuery];
        [request setValue:macHeader forHTTPHeaderField:@"Authorization"];
    }
}

- (BOOL)hasValidCredentials
{
    return self.accessToken != nil && self.macKey != nil;
}

- (NSString *) getPort
{
    if ([[self baseURL] port] != nil) {
        return [[[self baseURL] port] stringValue];
    } else if ([[[self baseURL] scheme] hasPrefix:@"https"]) {
        return @"443";
    } else {
        return @"80";
    }
}

- (NSString *)createMACHeaderForHttpMethod:(NSString *)method path:(NSString *)path timestamp:(double)timestamp nonce:(NSString *)nonce
{

    NSString *host = [[self baseURL] host];
    NSString *port = [self getPort];
    
    // create base
    NSArray *baseArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%.f", timestamp], nonce, method, path, host, port, nil];
    unichar newline = 0x0A;
    NSString *baseString = [baseArray componentsJoinedByString:[NSString stringWithFormat:@"%C", newline]];
    baseString = [baseString stringByAppendingString:[NSString stringWithFormat:@"%C", newline]];
    baseString = [baseString stringByAppendingString:[NSString stringWithFormat:@"%C", newline]];
    
    const char *keyCString = [self.macKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *baseCString = [baseString cStringUsingEncoding:NSUTF8StringEncoding];
    
    
    char buffer[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, keyCString, strlen(keyCString), baseCString, strlen(baseCString), buffer); 
    NSData *digestData = [NSData dataWithBytes:buffer length:CC_SHA1_DIGEST_LENGTH];
    NSString *mac = Base64EncodedStringFromData(digestData); 
    //return 'MAC id="' + id + '",ts="' + ts + '",nonce="' + nonce + '",mac="' + mac + '"'
    unichar quotes = 0x22;
    NSString *returnString = [NSString stringWithFormat:@"MAC id=%C%@%C,ts=%C%.f%C,nonce=%C%@%C,mac=%C%@%C", quotes, self.accessToken, quotes, quotes, timestamp, quotes, quotes, nonce, quotes, quotes, mac, quotes];
    return returnString; 
}


- (NSString *)createMACHeaderForHttpMethod:(NSString *)method path:(NSString *)path
{
    return [self createMACHeaderForHttpMethod:method path:path timestamp:[[NSDate date] timeIntervalSince1970] nonce:[NSString stringWithFormat:@"n%d", arc4random() % 10000]];
}


// The function below was inspired on
//
// AFOAuth2Client.m
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
static NSString * Base64EncodedStringFromData(NSData *data) 
{
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) value |= (0xFF & input[j]); 
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

@end
