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

#import "StackMob.h"
#import "SMIntegrationTestHelpers.h"
#import "SMCoreDataIntegrationTestHelpers.h"

SPEC_BEGIN(SMIncrementalStorePredicateTest)

describe(@"with fixtures", ^{
    __block NSArray *fixturesToLoad;
    __block NSDictionary *fixtures;
    
    __block NSManagedObjectContext *moc;
    __block NSPredicate *predicate;
    [SMCoreDataIntegrationTestHelpers registerForMOCNotificationsWithContext:[SMCoreDataIntegrationTestHelpers moc]];
    
    beforeEach(^{
        fixturesToLoad = [NSArray arrayWithObjects:@"person", nil];
        fixtures = [SMIntegrationTestHelpers loadFixturesNamed:fixturesToLoad];
        moc = [SMCoreDataIntegrationTestHelpers moc];
    });
    
    afterEach(^{
        [SMIntegrationTestHelpers destroyAllForFixturesNamed:fixturesToLoad];
    });
    
    describe(@"compound predicates", ^{
        describe(@"AND predicate", ^{
            beforeEach(^{
                predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                             [NSArray arrayWithObjects:
                              [NSPredicate predicateWithFormat:@"company = %@", @"Carbon Five"],
                              [NSPredicate predicateWithFormat:@"last_name = %@", @"Williams"], 
                              nil]];
            });
            it(@"works correctly", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:1];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jonah"];  
                }];
            });
        });
        describe(@"NOT predicate", ^{
            beforeEach(^{
                predicate = [NSCompoundPredicate notPredicateWithSubpredicate:
                             [NSPredicate predicateWithFormat:@"last_name = %@", @"Vaznaian"]];
            });
            it(@"returns an error", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [[error should] beNonNil];
                }];
            });    
        });
        describe(@"OR predicate", ^{
            beforeEach(^{
                predicate = [NSCompoundPredicate orPredicateWithSubpredicates:
                             [NSArray arrayWithObjects:
                              [NSPredicate predicateWithFormat:@"company = %@", @"Carbon Five"],
                              [NSPredicate predicateWithFormat:@"last_name = %@", @"Williams"], 
                              nil]];
            });
            it(@"returns an error", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [[error should] beNonNil];
                }];
            });
        });
    });
    
    describe(@"sorting", ^{
        __block NSFetchRequest *fetchRequest;
        __block NSArray *sortDescriptors;
        __block NSSortDescriptor *firstNameSD;
        __block NSSortDescriptor *companyNameSD;
        __block NSSortDescriptor *armorClassSD;
        beforeEach(^{
            firstNameSD = [NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:NO];
            companyNameSD = [NSSortDescriptor sortDescriptorWithKey:@"company" ascending:NO];
            armorClassSD = [NSSortDescriptor sortDescriptorWithKey:@"armor_class" ascending:YES];
        });
        it(@"applies one sort descriptor correctly", ^{
            sortDescriptors = [NSArray arrayWithObject:firstNameSD];
            fetchRequest = [SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil];
            [fetchRequest setSortDescriptors:sortDescriptors];
            [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:fetchRequest andBlock:^(NSArray *results, NSError *error) {
                [error shouldBeNil];
                [[[results objectAtIndex:0] should] haveValue:@"Matt" forKey:@"first_name"];
                [[[results objectAtIndex:1] should] haveValue:@"Jonah" forKey:@"first_name"];
                [[[results objectAtIndex:2] should] haveValue:@"Jon" forKey:@"first_name"];
            }];
        });
        it(@"applies multiple sort descriptors correctly", ^{
            sortDescriptors = [NSArray arrayWithObjects:companyNameSD, armorClassSD, nil];
            fetchRequest = [SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil];
            [fetchRequest setSortDescriptors:sortDescriptors];
            [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:fetchRequest andBlock:^(NSArray *results, NSError *error) {
                [error shouldBeNil];
                [[[results objectAtIndex:0] should] haveValue:@"Vaznaian" forKey:@"last_name"];
                [[[results objectAtIndex:1] should] haveValue:@"Cooper" forKey:@"last_name"];
                [[[results objectAtIndex:2] should] haveValue:@"Williams" forKey:@"last_name"]; 
            }];
        });
    });
    
    describe(@"pagination / limiting", ^{
        __block NSFetchRequest *fetchRequest;
        describe(@"fetchLimit", ^{
            beforeEach(^{
                fetchRequest = [SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil];
                [fetchRequest setFetchLimit:1];
            });
            it(@"returns the expected results", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:fetchRequest andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:1];
                    [[[results objectAtIndex:0] should] haveValue:@"Cooper" forKey:@"last_name"];
                }];
            });
        });
        
        describe(@"fetchOffset", ^{
            beforeEach(^{
                fetchRequest = [SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil];
                [fetchRequest setFetchOffset:1];
            });
            it(@"returns the expected results", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:fetchRequest andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[results objectAtIndex:0] should] haveValue:@"Vaznaian" forKey:@"last_name"];
                    [[[results objectAtIndex:1] should] haveValue:@"Williams" forKey:@"last_name"];
                }];
            });            
        });
        
        describe(@"fetchBatchSize", ^{
            beforeEach(^{
                fetchRequest = [SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil];
                [fetchRequest setFetchBatchSize:1];
            });
            it(@"returns an error", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:fetchRequest andBlock:^(NSArray *results, NSError *error) {
                    [[error should] beNonNil];
                }];
            });
        });
    });
    
    describe(@"NSIncrementalStore implementation guide says we must implement", ^{
        pending(@"shouldRefreshFetchedObjects", nil);
        pending(@"propertiesToGroupBy", nil);
        pending(@"havingPredicate", nil);
    });
    
    describe(@"queries", ^{
        describe(@"error handling", ^{
            describe(@"when the left-hand side is not a keypath", ^{
                beforeEach(^{
                    predicate = [NSPredicate predicateWithFormat:@"%@ == last_name", @"Vaznaian"];
                });
                it(@"returns an error", ^{
                    [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                        [[error should] beNonNil];
                        [results shouldBeNil];
                    }];
                });
            });
            describe(@"when the right-hand side is not a constant", ^{
                beforeEach(^{
                    predicate = [NSPredicate predicateWithFormat:@"%@ == %@", @"last_name", @"Vaznaian"];
                });
                it(@"returns an error", ^{
                    [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                        [[error should] beNonNil];
                        [results shouldBeNil];  
                    }];
                    
                });    
            });
        });
        describe(@"==", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"last_name == %@", @"Cooper"];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:1];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];   
                }];
            });
        });
        describe(@"=", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"last_name = %@", @"Cooper"];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:1];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];   
                }];
            });
        });
        describe(@"!=", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"last_name != %@", @"Williams"];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];   
                    [[[[results objectAtIndex:1] valueForKey:@"first_name"] should] equal:@"Matt"];                  
                }];
            });
        });
        describe(@"<>", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"last_name <> %@", @"Williams"];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];   
                    [[[[results objectAtIndex:1] valueForKey:@"first_name"] should] equal:@"Matt"];                  
                }];
            });   
        });
        describe(@"<", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"armor_class < %@", [NSNumber numberWithInt:15]];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:1];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];
                }];
            });        
        });
        describe(@">", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"armor_class > %@", [NSNumber numberWithInt:15]];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:1];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Matt"];                    
                }];
            });        
        });
        describe(@"<=", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"armor_class <= %@", [NSNumber numberWithInt:15]];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];   
                    [[[[results objectAtIndex:1] valueForKey:@"first_name"] should] equal:@"Jonah"];
                }];
            });
        });
        describe(@"=<", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"armor_class =< %@", [NSNumber numberWithInt:15]];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];   
                    [[[[results objectAtIndex:1] valueForKey:@"first_name"] should] equal:@"Jonah"];
                }];
            });
        });
        describe(@">=", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"armor_class >= %@", [NSNumber numberWithInt:15]];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Matt"];   
                    [[[[results objectAtIndex:1] valueForKey:@"first_name"] should] equal:@"Jonah"];
                }];
            });       
        });
        describe(@"=>", ^{
            beforeEach(^{
                predicate = [NSPredicate predicateWithFormat:@"armor_class => %@", [NSNumber numberWithInt:15]];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Matt"];   
                    [[[[results objectAtIndex:1] valueForKey:@"first_name"] should] equal:@"Jonah"];
                }];
            });        
        });
        describe(@"BETWEEN", ^{
            beforeEach(^{
                NSArray *range = [NSArray arrayWithObjects:
                                  [NSNumber numberWithInt:12],
                                  [NSNumber numberWithInt:15], 
                                  nil];
                predicate = [NSPredicate predicateWithFormat:@"armor_class BETWEEN %@", range];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[results should] haveCountOf:2];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Jon"];   
                    [[[[results objectAtIndex:1] valueForKey:@"first_name"] should] equal:@"Jonah"];
                }];
            });
        });
        describe(@"IN", ^{
            __block NSArray *first_names;
            beforeEach(^{
                first_names = [NSArray arrayWithObjects:@"Aaron", @"Bob", @"Clyde", @"Ducksworth", @"Elliott", @"Matt", nil];
                predicate = [NSPredicate predicateWithFormat:@"first_name IN %@", first_names];
            });
            it(@"works", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[[[results objectAtIndex:0] valueForKey:@"first_name"] should] equal:@"Matt"];   
                }];
            });
        });
    });
    
});

SPEC_END