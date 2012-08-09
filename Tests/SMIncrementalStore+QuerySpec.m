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
#import "SMSpecHelpers.h"
#import "SMIncrementalStore+Query.h"

SPEC_BEGIN(SMIncrementalStore_QuerySpec)

__block NSEntityDescription *entity;
__block NSPredicate *predicate;
__block SMQuery *query;
__block NSError *error;

describe(@"-queryForEntity:predicate:error", ^{
    beforeEach(^{
        entity = [SMSpecHelpers entityForName:@"Person"];
        query = nil;
        error = nil;
    });
    describe(@"when the left-hand side is not a keypath", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"%@ == last_name", @"Vaznaian"];
        });
        it(@"returns an error", ^{
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
            [[error should] beNonNil];
        });
    });
    describe(@"when the right-hand side is not a constant", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"%@ == %@", @"last_name", @"Vaznaian"];
        });
        it(@"returns an error", ^{
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
            [[error should] beNonNil];
        });
    });
    describe(@"==", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"last_name == %@", @"Cooper"];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:@"Cooper" forKey:@"last_name"];
        });
    });
    describe(@"=", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"last_name = %@", @"Cooper"];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:@"Cooper" forKey:@"last_name"];
        });
    });
    describe(@"!=", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"last_name != %@", @"Williams"];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:@"Williams" forKey:@"last_name[ne]"];
        });
    });
    describe(@"<>", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"last_name <> %@", @"Williams"];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:@"Williams" forKey:@"last_name[ne]"];
        });   
    });
    describe(@"<", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"armor_class < %@", [NSNumber numberWithInt:16]];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:16] forKey:@"armor_class[lt]"];
        });        
    });
    describe(@">", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"armor_class > %@", [NSNumber numberWithInt:16]];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:16] forKey:@"armor_class[gt]"];
        });        
    });
    describe(@"<=", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"armor_class <= %@", [NSNumber numberWithInt:16]];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:16] forKey:@"armor_class[lte]"];
        });
    });
    describe(@"=<", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"armor_class <= %@", [NSNumber numberWithInt:16]];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:16] forKey:@"armor_class[lte]"];
        });
    });
    describe(@">=", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"armor_class >= %@", [NSNumber numberWithInt:16]];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:16] forKey:@"armor_class[gte]"];
        });       
    });
    describe(@"=>", ^{
        beforeEach(^{
            predicate = [NSPredicate predicateWithFormat:@"armor_class => %@", [NSNumber numberWithInt:16]];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:16] forKey:@"armor_class[gte]"];
        });        
    });
    describe(@"BETWEEN", ^{
        beforeEach(^{
            NSArray *range = [NSArray arrayWithObjects:
                              [NSNumber numberWithInt:12],
                              [NSNumber numberWithInt:16], 
                              nil];
            predicate = [NSPredicate predicateWithFormat:@"armor_class BETWEEN %@", range];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:2];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:12] forKey:@"armor_class[gte]"];
            [[[query requestParameters] should] haveValue:[NSNumber numberWithInt:16] forKey:@"armor_class[lte]"];
        });
    });
    describe(@"IN", ^{
        __block NSArray *first_names;
        beforeEach(^{
            first_names = [NSArray arrayWithObjects:@"Aaron", @"Bob", @"Clyde", @"Ducksworth", @"Elliott", nil];
            predicate = [NSPredicate predicateWithFormat:@"first_name IN %@", first_names];
            query = [SMIncrementalStore queryForEntity:entity predicate:predicate error:&error];
        });
        it(@"returns the correct query", ^{
            NSString *expectation = [first_names componentsJoinedByString:@","];
            [error shouldBeNil];
            [[[query requestParameters] should] haveCountOf:1];
            [[[query requestParameters] should] haveValue:expectation forKey:@"first_name[in]"];
        });
    });
});

SPEC_END