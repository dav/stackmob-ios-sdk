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

#import "SMData.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Base64EncodedStringFromData.h"

@implementation SMData

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
@end
