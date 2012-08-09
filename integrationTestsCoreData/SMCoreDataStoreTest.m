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
#import "SMCoreDataIntegrationTestHelpers.h"
#import "SMIntegrationTestHelpers.h"

SPEC_BEGIN(SMCoreDataStoreTest)

describe(@"create an instance of SMCoreDataStore from SMClient", ^{
    __block SMClient *client = nil;
    __block SMCoreDataStore *coreDataStore = nil;
    __block NSManagedObjectModel *mom = nil;
    __block NSManagedObjectContext *moc = nil;
    beforeEach(^{
        mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
        client = [SMIntegrationTestHelpers defaultClient];
        coreDataStore = [client coreDataStoreWithManagedObjectModel:mom];
        
    });
    describe(@"obtaining a managedObjectContext hooked to SM", ^{
        beforeEach(^{
            moc = [coreDataStore managedObjectContext];
        });
        it(@"is not nil", ^{
            [moc shouldNotBeNil];
        });
    });
    describe(@"with a managedObjectContext from SMCoreDataStore", ^{
        beforeEach(^{
            moc = [coreDataStore managedObjectContext]; 
        });
        describe(@"inserting an object", ^{
            __block NSManagedObject *aPerson = nil;
            beforeEach(^{
                aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
                [aPerson setValue:@"the" forKey:@"first_name"];
                [aPerson setValue:@"dude" forKey:@"last_name"];
                [aPerson setValue:[aPerson sm_assignObjectId] forKey:[aPerson sm_primaryKeyField]];
            });
            afterEach(^{
                [moc deleteObject:aPerson];
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    [error shouldBeNil]; 
                }];
            });
            it(@"the context should have inserted objects", ^{
                [[theValue([[moc insertedObjects] count]) should] beGreaterThan:theValue(0)];
            });
            it(@"a call to save should not fail", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    [error shouldBeNil];
                    [[theValue([[moc insertedObjects] count]) should] equal:theValue(0)];
                }];
            });
        });
        describe(@"read, update", ^{
            __block NSManagedObject *aPerson = nil;
            beforeEach(^{
                aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
                [aPerson setValue:@"the" forKey:@"first_name"];
                [aPerson setValue:@"dude" forKey:@"last_name"];
                [aPerson setValue:[aPerson sm_assignObjectId] forKey:[aPerson sm_primaryKeyField]];
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    [error shouldBeNil];
                }];
            });
            afterEach(^{
                [moc deleteObject:aPerson];
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    [error shouldBeNil]; 
                }];
            });
            describe(@"reads the object", ^{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"last_name = 'dude'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    [[theValue([results count]) should] equal:theValue(1)];
                    NSManagedObject *theDude = [results objectAtIndex:0];
                    [[theValue([theDude valueForKey:@"first_name"]) should] equal:theValue(@"the")];
                }];
            });
            describe(@"updates the object", ^{
                [aPerson setValue:@"matt" forKey:@"first_name"];
                [aPerson setValue:@"StackMob" forKey:@"company"];
                [[theValue([[moc updatedObjects] count]) should] beGreaterThan:theValue(0)];
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    [error shouldBeNil]; 
                }];
            });
        });
    });
});


SPEC_END