//
//  SMData.m
//  stackmob-ios-sdk
//
//  Created by Matt Vaznaian on 8/13/12.
//  Copyright (c) 2012 StackMob. All rights reserved.
//

#import "SMData.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation SMData

static NSString* Base64EncodedStringFromData(NSData *data);

+ (NSString *)stringForBinaryData:(NSData *)data withName:(NSString *)name andContentType:(NSString *)contentType
{
    
    return [NSString stringWithFormat:@"Content-Type: %@\n"
            "Content-Disposition: attachment; filename=%@\n"
            "Content-Transfer-Encoding: %@\n\n"
            "%@",
            contentType,
            name,
            @"base64",
            Base64EncodedStringFromData(data)];
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


/*
- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)mask error:(NSError **)errorPtr
{
    self = [super initWithContentsOfFile:path options:mask error:errorPtr];
    
    if (self) {
         
    }
    
    return self;
}
 */

@end
