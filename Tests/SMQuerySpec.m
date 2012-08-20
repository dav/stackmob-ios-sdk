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
#import "SMQuery.h"

#define TEST_SCHEMA @"test"
#define CONCAT(prefix, suffix) ([NSString stringWithFormat:@"%@%@", prefix, suffix])

SPEC_BEGIN(SMQuerySpec)

__block SMQuery *query;

beforeEach(^{
    query = [[SMQuery alloc] initWithSchema:TEST_SCHEMA];
});

describe(@"-initWithEntity", ^{
    it(@"builds a query with the given entity name as its schema", ^{
        [[[query schemaName] should] equal:TEST_SCHEMA];
    });
});

describe(@"where clauses", ^{
    NSString *field1 = @"field1";
    NSString *value1 = @"value1";
    NSArray *valueArray1 = [NSArray arrayWithObjects:@"value1", @"value2", @"value3", nil];
    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(37.7750, 122.4183); // SF
    CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(52.134068, -106.647635); // Saskatoon
    
    it(@"-where:isEqualTo", ^{
        [query where:field1 isEqualTo:value1];
        [[[[query requestParameters] objectForKey:field1] should] equal:@"value1"];
    });
    it(@"-where:isNotEqualTo", ^{
        [query where:field1 isNotEqualTo:@"value1"];
        [[[[query requestParameters] objectForKey:CONCAT(field1, @"[ne]")] should] equal:@"value1"];
    });
    it(@"-where:isLessThan", ^{
        [query where:field1 isLessThan:@"value1"];
        [[[[query requestParameters] objectForKey:CONCAT(field1, @"[lt]")] should] equal:value1];
    });
    it(@"-where:isLessThanOrEqualTo", ^{
        [query where:@"field1" isLessThanOrEqualTo:@"value1"];
        [[[[query requestParameters] objectForKey:CONCAT(field1, @"[lte]")] should] equal:value1];
    });
    it(@"-where:isGreaterThan", ^{
        [query where:field1 isGreaterThan:@"value1"];
        [[[[query requestParameters] objectForKey:CONCAT(field1, @"[gt]")] should] equal:value1];
    });
    it(@"-where:isGreaterThanOrEqualTo", ^{
        [query where:field1 isGreaterThanOrEqualTo:value1];
        [[[[query requestParameters] objectForKey:CONCAT(field1, @"[gte]")] should] equal:value1];
    });
    it(@"-where:isIn", ^{
        [query where:field1 isIn:[NSArray arrayWithObjects:@"value1", @"value2", @"value3", nil]];
        NSString *expectation = [valueArray1 componentsJoinedByString:@","];
        [[[[query requestParameters] objectForKey:CONCAT(field1, @"[in]")] should] equal:expectation];
    });
    it(@"-where:isWithin:milesOf", ^{
        [query where:field1 isWithin:0.25 milesOf:location1];
        NSString *expectation = [NSString stringWithFormat:@"%.6f,%.6f,%.6f", 
                                 location1.latitude,
                                 location1.longitude,
                                 0.000063185];
        NSString *results = [[query requestParameters] objectForKey:CONCAT(field1, @"[within]")];
        [[results should] equal:expectation];
    });
    it(@"-where:isWithin:metersOf", ^{
        [query where:field1 isWithin:1000.0 metersOf:location1];
        NSString *expectation = [NSString stringWithFormat:@"%.6f,%.6f,%.6f", 
                                 location1.latitude,
                                 location1.longitude,
                                 0.000157];
        NSArray *results = [[query requestParameters] objectForKey:CONCAT(field1, @"[within]")];
        [[results should] equal:expectation];
    });
    it(@"-where:isWithinBoundsWithSWCorner:andNECorner:", ^{
        [query where:field1 isWithinBoundsWithSWCorner:location1 andNECorner:location2];
        NSString *expectation = [NSString stringWithFormat:@"%.6f,%.6f,%.6f,%.6f",
                                 location1.latitude,
                                 location1.longitude,
                                 location2.latitude,
                                 location2.longitude];
        NSString *results = [[query requestParameters] objectForKey:CONCAT(field1, @"[within]")];
        [[results should] equal:expectation];
    });
});

describe(@"multiple where clauses", ^{
    it(@"concatenates the queries", ^{
        [query where:@"field1" isEqualTo:@"value1"];
        [query where:@"field2" isGreaterThan:[NSNumber numberWithInt:2]];
        NSDictionary *requestParameters = [query requestParameters];
        [[requestParameters should] haveCountOf:2];
        [[requestParameters should] haveValue:@"value1" forKey:@"field1"];
        [[requestParameters should] haveValue:[NSNumber numberWithInt:2] forKey:CONCAT(@"field2", @"[gt]")];
    });
});

describe(@"field selection", ^{
    __block NSArray *selectFields;
    beforeEach(^{
        selectFields = [NSArray arrayWithObjects:@"field1", @"field2", nil];
    });
});

describe(@"pagination and limit", ^{
    it(@"-fromIndex:toIndex", ^{
        NSString *expectedRangeHeader = @"objects=11-22";
        [query fromIndex:11 toIndex:22];
        [[[[query requestHeaders] objectForKey:@"Range"] should] equal:expectedRangeHeader];
    });
    it(@"-limit", ^{
        NSString *expectedRangeHeader = @"objects=0-9";
        [query limit:10];
        [[[[query requestHeaders] objectForKey:@"Range"] should] equal:expectedRangeHeader];
    });
});

describe(@"ordering", ^{
    NSString *field1 = @"field1";
    NSString *field2 = @"field2";
    NSString *orderByHeader = @"X-StackMob-OrderBy";
    
    describe(@"when the intent is to sort by one field", ^{
        it(@"-orderByField", ^{
            NSString *expectedOrderByHeader = [NSString stringWithFormat:@"field1:asc", field1];
            [query orderByField:field1 ascending:YES];
            [[[[query requestHeaders] objectForKey:orderByHeader] should] equal:expectedOrderByHeader];
        });    
    });
    describe(@"when the intent is to sort by multiple fields", ^{
        it(@"-orderByField", ^{
            NSString *expectedOrderByHeader = [NSString stringWithFormat:@"%@:asc,%@:desc", field1, field2];
            [query orderByField:field1 ascending:YES];
            [query orderByField:field2 ascending:NO];
            [[[[query requestHeaders] objectForKey:orderByHeader] should] equal:expectedOrderByHeader];    
        });
    });
});

describe(@"near", ^{
    NSString *field1 = @"field1";
    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(37.7750, 122.4183); // SF

    it(@"-where:near:", ^{
        [query where:field1 near:location1];
        NSString *expectation = [NSString stringWithFormat:@"%.6f,%.6f",
                                 location1.latitude,
                                 location1.longitude];
        NSArray *results = [[query requestParameters] objectForKey:CONCAT(field1, @"[near]")];
        [[results should] equal:expectation];
    });
});

SPEC_END