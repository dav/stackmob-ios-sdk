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
#import "SMIntegrationTestHelpers.h"

SPEC_BEGIN(CRUDTests)

describe(@"CRUD", ^{
    __block SMDataStore *dataStore = nil;
    beforeEach(^{
        dataStore = [SMIntegrationTestHelpers dataStore];
    });
    it(@"should successfully create a data store", ^{
        [dataStore shouldNotBeNil];
    });
    
    context(@"creating a new book object", ^{
        __block NSDictionary *newBook = nil;
        __block NSString *newBookTitle = nil;
        beforeEach(^{
            newBookTitle = [NSString stringWithFormat:@"Twilight part %ld", random() % 10000];
            NSDictionary *book = [NSDictionary dictionaryWithObjectsAndKeys:
                                  newBookTitle, @"title",
                                  @"Rabid Fan", @"author",
                                  nil];
            
            [[dataStore.session.regularOAuthClient operationQueue] shouldNotBeNil];
            syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                [dataStore createObject:book inSchema:@"book" onSuccess:^(NSDictionary *theObject, NSString *schema) {
                    newBook = theObject;
                    syncReturn(semaphore);
                    NSLog(@"Created %@", theObject);
                } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                    NSLog(@"Failed to create a new %@: %@", schema, theError);
                    syncReturn(semaphore);
                }];
            });
            
            [newBook shouldNotBeNil];
        });
        afterEach(^{
            [dataStore deleteObjectId:[newBook objectForKey:@"book_id"] inSchema:@"book" onSuccess:^(NSString *theObjectId, NSString *schema) {
                NSLog(@"Deleted %@", theObjectId);
            } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                NSLog(@"Failed to delete %@", [newBook objectForKey:@"book_id"]);
            }];
            newBook = nil;
        });
        it(@"creates a new book object", ^{
            [newBook shouldNotBeNil];
            [[[newBook objectForKey:@"title"] should] equal:newBookTitle];
            [[newBook objectForKey:@"book_id"] shouldNotBeNil];
            [[newBook objectForKey:@"lastmoddate"] shouldNotBeNil];
            [[newBook objectForKey:@"createddate"] shouldNotBeNil];
        });
        context(@"when reading the new book object", ^{
            __block NSDictionary *readBook = nil;
            beforeEach(^{
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [dataStore readObjectWithId:[newBook objectForKey:@"book_id"] inSchema:@"book" onSuccess:^(NSDictionary *theObject, NSString *schema) {
                        readBook = theObject;
                        NSLog(@"Read %@", theObject);
                        syncReturn(semaphore);
                    } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                        NSLog(@"failed to read the object with error: %@", theError);
                        syncReturn(semaphore);
                    }]; 
                });
            });
            
            [readBook shouldNotBeNil];
            
            it(@"returns the object's attributes", ^{
                [[readBook should] equal:newBook]; 
            });
        });
        context(@"updating the new object", ^{
            __block NSDictionary *updatedBook = nil;
            __block NSDictionary *updatedFields = nil;
            beforeEach(^{
                updatedFields = [NSDictionary dictionaryWithObjectsAndKeys:@"Coolest Author Ever", @"author", nil];
                syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                    [dataStore updateObjectWithId:[newBook objectForKey:@"book_id"] inSchema:@"book" update:updatedFields onSuccess:^(NSDictionary *theObject, NSString *schema) {
                        updatedBook = theObject;
                        NSLog(@"updated %@", theObject);
                        syncReturn(semaphore);
                    } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                        NSLog(@"failed to update the object with error: %@", theError);
                        syncReturn(semaphore);
                    }]; 
                });
                
                [updatedBook shouldNotBeNil];
                
                 
            });
            it(@"updates the object's attributes", ^{
                [[[updatedBook objectForKey:@"book_id"] should] equal:[newBook objectForKey:@"book_id"]];
                [[[updatedBook objectForKey:@"author"] should] equal:@"Coolest Author Ever"];
            });
        });
    });
    context(@"deleting the new book", ^{
        __block NSDictionary *newBook = nil;
        __block NSString *newBookTitle = nil;
        beforeEach(^{
            newBookTitle = [NSString stringWithFormat:@"Twilight part %ld", random() % 10000];
            NSDictionary *book = [NSDictionary dictionaryWithObjectsAndKeys:
                                  newBookTitle, @"title",
                                  @"Rabid Fan", @"author",
                                  nil];
            
            [[dataStore.session.regularOAuthClient operationQueue] shouldNotBeNil];
            syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                [dataStore createObject:book inSchema:@"book" onSuccess:^(NSDictionary *theObject, NSString *schema) {
                    newBook = theObject;
                    syncReturn(semaphore);
                    NSLog(@"Created %@", theObject);
                } onFailure:^(NSError *theError, NSDictionary *theObject, NSString *schema) {
                    NSLog(@"Failed to create a new %@: %@", schema, theError);
                    syncReturn(semaphore);
                }];
            });
            
            [newBook shouldNotBeNil];
        });
        
        __block BOOL deleteSucceeded = NO;
        it(@"deletes the object", ^{
            deleteSucceeded = NO;
            syncWithSemaphore(^(dispatch_semaphore_t semaphore) {
                [dataStore deleteObjectId:[newBook objectForKey:@"book_id"] inSchema:@"book" onSuccess:^(NSString *theObjectId, NSString *schema) {
                    NSLog(@"deleted %@", theObjectId);
                    deleteSucceeded = YES;
                    syncReturn(semaphore);
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    NSLog(@"failed to delete the object with error: %@", theError);
                    syncReturn(semaphore);
                }];
            });
            
            [theValue(deleteSucceeded) shouldNotBeNil];
            [[theValue(deleteSucceeded) should] beYes];
        });
    });
});

SPEC_END