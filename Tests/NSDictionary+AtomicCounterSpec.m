/**
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

#import <Kiwi/Kiwi.h>
#import "NSDictionary+AtomicCounter.h"

SPEC_BEGIN(NSDictionary_AtomicCounterSpec)
__block NSDictionary *emptyDict;
__block NSDictionary *fullDict;
__block NSDictionary *hasIncrement;
beforeEach(^{
    emptyDict = [NSDictionary dictionary];
    fullDict = [NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"];
    hasIncrement = [NSDictionary dictionaryWithObject:@"foo" forKey:@"bar[inc]"];
});

describe(@"dictionaryByAppendingCounterUpdateForField:by:", ^{
    it(@"appends to an empty dictionary", ^{
        NSDictionary *result = [emptyDict dictionaryByAppendingCounterUpdateForField:@"bar" by:3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:3]];
    });
    it(@"appends to an dictionary with keys", ^{
        NSDictionary *result = [fullDict dictionaryByAppendingCounterUpdateForField:@"bar" by:3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:3]];
    });
    it(@"replaces an existing key", ^{
        NSDictionary *result = [hasIncrement dictionaryByAppendingCounterUpdateForField:@"bar" by:3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:3]];
    });
    it(@"appends negative increments", ^{
        NSDictionary *result = [fullDict dictionaryByAppendingCounterUpdateForField:@"bar" by:-3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:-3]];
    });
    it(@"appends zero increments", ^{
        NSDictionary *result = [fullDict dictionaryByAppendingCounterUpdateForField:@"bar" by:0];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:0]];
    });
});

describe(@"updateCounterForField:by:", ^{
    it(@"appends to an empty dictionary", ^{
        NSMutableDictionary *result = [emptyDict mutableCopy];
        [result updateCounterForField:@"bar" by:3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:3]];
    });
    it(@"appends to an dictionary with keys", ^{
        NSMutableDictionary *result = [fullDict mutableCopy];
        [result updateCounterForField:@"bar" by:3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:3]];
    });
    it(@"replaces an existing key", ^{
        NSMutableDictionary *result = [hasIncrement mutableCopy];
        [result updateCounterForField:@"bar" by:3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:3]];
    });
    it(@"appends negative increments", ^{
        NSMutableDictionary *result = [fullDict mutableCopy];
        [result updateCounterForField:@"bar" by:-3];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:-3]];
    });
    it(@"appends zero increments", ^{
        NSMutableDictionary *result = [fullDict mutableCopy];
        [result updateCounterForField:@"bar" by:0];
        [[[result valueForKey:@"bar[inc]"] should] equal:[NSNumber numberWithInt:0]];
    });
});

SPEC_END