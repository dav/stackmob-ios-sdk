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

#ifdef SMDEBUG
#   define DLog(fmt, ...) NSLog((@"Performing %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the SMDEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#import "SMClient.h"

#import "SMDataStore.h"
#import "SMQuery.h"
#import "SMCustomCodeRequest.h"
#import "SMCoreDataStore.h"
#import "SMIncrementalStore.h"

#import "SMUserSession.h"
#import "SMOAuth2Client.h"
#import "SMJSONRequestOperation.h"

#import "SMError.h"
#import "SMRequestOptions.h"
#import "Synchronization.h"

#import "NSArray+Enumerable.h"
#import "NSManagedObject+StackMobSerialization.h"
#import "NSEntityDescription+StackMobSerialization.h"
#import "SMIncrementalStore+Query.h"
#import "SMResponseBlocks.h"

#import "SMBinaryDataConversion.h"

