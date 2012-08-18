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

#import "StackMob.h"
#import "Synchronization.h"

#define SM_TEST_API_VERSION @"0"
#define SM_TEST_API_BASEURL @"http://api.stackmob.com"
#define TEST_CUSTOM_CODE 0

@interface SMIntegrationTestHelpers : NSObject

+ (SMClient *)defaultClient;
+ (SMDataStore *)dataStore;

+ (NSDictionary *)loadFixturesNamed:(NSArray *)fixtureNames;
+ (void)destroyAllForFixturesNamed:(NSArray *)fixtureNames;

+ (NSArray *)loadFixture:(NSString *)fixtureName; 
+ (void)destroyFixture:(NSString *)fixtureName;

@end
