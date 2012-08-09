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
#import "SMCoreDataStore.h"
#import "SMIncrementalStore.h"

SPEC_BEGIN(SMCoreDataStoreSpec)

describe(@"SMCoreDataStore", ^{
    describe(@"initialize from sm client", ^{
        __block NSManagedObjectModel *mom = nil;
        __block SMClient *client = nil;
        __block SMCoreDataStore *coreDataStore = nil;
        beforeEach(^{
            mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
            client = [[SMClient alloc] initWithAPIVersion:@"1" publicKey:@"publicKey"];
        });
        it(@"the client should return an initialized SMCoreDataStore instance", ^{
            [coreDataStore shouldBeNil];
            coreDataStore = [client coreDataStoreWithManagedObjectModel:mom];
            [coreDataStore shouldNotBeNil];
            [[theValue([coreDataStore apiVersion]) should] equal:theValue([client appAPIVersion])];
            [[theValue([coreDataStore session]) should] equal:theValue([client session])];
        });
    });
    describe(@"SMCoreDataStore pieces", ^{
        __block NSManagedObjectModel *mom = nil;
        __block SMClient *client = nil;
        __block SMCoreDataStore *coreDataStore = nil;
        beforeEach(^{
            mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
            client = [[SMClient alloc] initWithAPIVersion:@"1" publicKey:@"publicKey"];
            coreDataStore = [client coreDataStoreWithManagedObjectModel:mom];
        });
        describe(@"SMCoreDataStore init", ^{
            it(@"should take a managedObjectModel as an argument and set it", ^{
                NSArray *momEntities = [mom entities];
                NSArray *cdsEntities = [[[coreDataStore persistentStoreCoordinator] managedObjectModel] entities];
                for (NSEntityDescription *entityDescription in momEntities) {
                    int anIndex = [cdsEntities indexOfObject:entityDescription];
                    [[theValue(anIndex) shouldNot] equal:theValue(NSNotFound)];
                }
            });
            context(@"-managedObjectContext", ^{
                it(@"returns a MOC hooked up to SM", ^{
                    NSManagedObjectContext *aContext = [coreDataStore managedObjectContext];
                    [aContext shouldNotBeNil];
                    [[theValue([aContext concurrencyType]) should] equal:theValue(NSPrivateQueueConcurrencyType)];
                });
            });
            context(@"-persistentStoreCoordinator", ^{
                it(@"adds the SMIncrementalStore to the PSC", ^{
                    NSPersistentStoreCoordinator *psc = [coreDataStore persistentStoreCoordinator];
                    [[theValue([[[psc persistentStores] objectAtIndex:0] class]) should] equal:theValue([SMIncrementalStore class])];
                });
            });

        });
        describe(@"after initializing, can set merge policy", ^{
            NSManagedObjectContext *theContext = [coreDataStore managedObjectContext];
            [theContext shouldNotBeNil];
            [theContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
            [[theValue([theContext mergePolicy]) should] equal:theValue(NSMergeByPropertyStoreTrumpMergePolicy)];
        });
    });
});

SPEC_END