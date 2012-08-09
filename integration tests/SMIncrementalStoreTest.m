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
#import "Person.h"
#import "Superpower.h"

SPEC_BEGIN(SMIncrementalStoreTest)

describe(@"with fixtures", ^{
    __block NSArray *fixturesToLoad;
    __block NSDictionary *fixtures;
    
    __block NSManagedObjectContext *moc;
    __block NSPredicate *predicate;
    [SMCoreDataIntegrationTestHelpers registerForMOCNotificationsWithContext:moc];
    
    beforeEach(^{
        fixturesToLoad = [NSArray arrayWithObjects:@"person", nil];
        fixtures = [SMIntegrationTestHelpers loadFixturesNamed:fixturesToLoad];
        moc = [SMCoreDataIntegrationTestHelpers moc];
    });
    
    afterEach(^{
        [SMIntegrationTestHelpers destroyAllForFixturesNamed:fixturesToLoad];
    });
    
    
    describe(@"save requests", ^{
        __block NSArray *people;
        __block int beforeInsert;
        __block int afterInsert;
        
        describe(@"insert", ^{
            it(@"inserts an object", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    [error shouldBeNil];
                    people = results;
                    beforeInsert = [people count];
                    DLog(@"beforeInsert is %d", beforeInsert);
                }];
                NSManagedObject *sean = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
                [sean setValue:@"Sean" forKey:@"first_name"];
                [sean setValue:@"Smith" forKey:@"last_name"];
                [sean setValue:@"StackMob" forKey:@"company"];
                [sean setValue:[NSNumber numberWithInt:15] forKey:@"armor_class"];
                [sean setValue:[sean sm_assignObjectId] forKey:@"person_id"];
                DLog(@"inserted objects before save %@", [moc insertedObjects]);
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                DLog(@"inserted objects after save are %@", [moc insertedObjects]);
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    people = results;
                    afterInsert = [people count];
                    DLog(@"afterInsert is %d", afterInsert);
                    [[theValue(afterInsert) should] equal:theValue(beforeInsert + 1)];
                }];
            });
            
            it(@"inserts an object with a one-to-one relationship", ^{
                // create person
                NSManagedObject *sean = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
                [sean setValue:@"Bob" forKey:@"first_name"];
                [sean setValue:@"Bobberson" forKey:@"last_name"];
                [sean setValue:@"StackMob" forKey:@"company"];
                [sean setValue:[NSNumber numberWithInt:15] forKey:@"armor_class"];
                [sean setValue:[sean sm_assignObjectId] forKey:@"person_id"];
                
                
                // create superpower
                NSManagedObject *invisibility = [NSEntityDescription insertNewObjectForEntityForName:@"Superpower" inManagedObjectContext:moc];
                [invisibility setValue:@"invisibility" forKey:@"name"];
                [invisibility setValue:[NSNumber numberWithInt:7] forKey:@"level"];
                [invisibility setValue:[invisibility sm_assignObjectId] forKey:@"superpower_id"];
                
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                //link superpower to person
                [sean setValue:invisibility forKey:@"superpower"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                __block NSManagedObject *person;
                __block NSManagedObject *superpower;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"last_name = 'Bobberson'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    person = [results objectAtIndex:0];
                    NSString *personId = [person valueForKey:@"person_id"];
                    NSString *personSuperpowerPersonId = [[[person valueForKey:@"superpower"] valueForKey:@"person"] valueForKey:@"person_id"];
                    [[theValue(personId) should] equal:theValue(personSuperpowerPersonId)];
                    
                }];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makeSuperpowerFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    superpower = [results objectAtIndex:0];
                    NSString *superpowerId = [superpower valueForKey:@"superpower_id"];
                    NSString *superpowerPersonSuperpowerId = [[[superpower valueForKey:@"person"] valueForKey:@"superpower"] valueForKey:@"superpower_id"];
                    [[theValue(superpowerId) should] equal:theValue(superpowerPersonSuperpowerId)];
                    
                }];
                
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[superpower sm_objectId] inSchema:[superpower sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted superpower");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"Did not delete superpower with error userInfo %@", [theError userInfo]);
                }];
            });


            it(@"inserts/updates an object with a one-to-many relationship", ^{
                // create person
                NSManagedObject *sean = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
                [sean setValue:@"Bob" forKey:@"first_name"];
                [sean setValue:@"Bobberson" forKey:@"last_name"];
                [sean setValue:@"StackMob" forKey:@"company"];
                [sean setValue:[NSNumber numberWithInt:15] forKey:@"armor_class"];
                [sean setValue:[sean sm_assignObjectId] forKey:[sean sm_primaryKeyField]];
                // create 2 interests
                NSManagedObject *basketball = [NSEntityDescription insertNewObjectForEntityForName:@"Interest" inManagedObjectContext:moc];
                [basketball setValue:@"basketball" forKey:@"name"];
                [basketball setValue:[NSNumber numberWithInt:10] forKey:@"years_involved"];
                [basketball setValue:[basketball sm_assignObjectId] forKey:[basketball sm_primaryKeyField]];
                
                NSManagedObject *tennis = [NSEntityDescription insertNewObjectForEntityForName:@"Interest" inManagedObjectContext:moc];
                [tennis setValue:@"tennis" forKey:@"name"];
                [tennis setValue:[NSNumber numberWithInt:3] forKey:@"years_involved"];
                [tennis setValue:[tennis sm_assignObjectId] forKey:[tennis sm_primaryKeyField]];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                // link the two
                [basketball setValue:sean forKey:@"person"];
                [tennis setValue:sean forKey:@"person"];
                
                //[sean addBasketballObject:basketball];
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                [sean setValue:@"Sean" forKey:@"first_name"];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // fetch and check
                __block NSString *seanId = [sean valueForKey:[sean sm_primaryKeyField]];
                __block NSString *bbId = [basketball valueForKey:[basketball sm_primaryKeyField]];
                __block NSString *tennisId = [tennis valueForKey:[tennis sm_primaryKeyField]];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"last_name = 'Bobberson'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    Person *result = [results objectAtIndex:0];
                    [[theValue([result valueForKey:@"person_id"]) should] equal:theValue(seanId)];
                    [[[result objectID] should] equal:[sean objectID]]; 
                    NSSet *interests = [result valueForKey:@"interests"];
                    [[theValue([interests count]) should] equal:[NSNumber numberWithInt:2]];
                    [interests enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSString *objName = [obj valueForKey:@"name"];
                        if ([objName isEqualToString:@"basketball"]) {
                            [[theValue([obj valueForKey:@"interest_id"]) should] equal:theValue(bbId)];
                        } else if ([objName isEqualToString:@"tennis"]) {
                            [[theValue([obj valueForKey:@"interest_id"]) should] equal:theValue(tennisId)];
                        }
                    }];
                    
                }];
                
                predicate = [NSPredicate predicateWithFormat:@"name = 'basketball'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makeInterestFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    NSManagedObject *result = [results objectAtIndex:0];
                    [[theValue([result valueForKey:@"interest_id"]) should] equal:theValue(bbId)];
                    [[[result objectID] should] equal:[basketball objectID]];
                    [[theValue([[result valueForKey:@"person"] valueForKey:@"person_id"]) should] equal:theValue(seanId)];
                }];

                
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[basketball sm_objectId] inSchema:[basketball sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted basketball");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"Did not delete basketball with error userInfo %@",[theError userInfo]);
                }];
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[tennis sm_objectId] inSchema:[tennis sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted tennis");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"Did not delete tennis with error userInfo %@",[theError userInfo]);
                }];
                
            });
            
            it(@"inserts/updates an object with a many-to-many relationship", ^{
                // make 2 person objects
                NSManagedObject *bob = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
                [bob setValue:@"Bob" forKey:@"first_name"];
                [bob setValue:@"Bobberson" forKey:@"last_name"];
                [bob setValue:@"StackMob" forKey:@"company"];
                [bob setValue:[NSNumber numberWithInt:15] forKey:@"armor_class"];
                [bob setValue:[bob sm_assignObjectId] forKey:[bob sm_primaryKeyField]];
                
                NSManagedObject *jack = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
                [jack setValue:@"Jack" forKey:@"first_name"];
                [jack setValue:@"Jackerson" forKey:@"last_name"];
                [jack setValue:@"StackMob" forKey:@"company"];
                [jack setValue:[NSNumber numberWithInt:20] forKey:@"armor_class"];
                [jack setValue:[jack sm_assignObjectId] forKey:[jack sm_primaryKeyField]];
                
                // make 2 favorite objects
                NSManagedObject *blueBottle = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:moc];
                [blueBottle setValue:@"coffee" forKey:@"genre"];
                [blueBottle setValue:[blueBottle sm_assignObjectId] forKey:[blueBottle sm_primaryKeyField]];
                
                NSManagedObject *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:moc];
                [batman setValue:@"movies" forKey:@"genre"];
                [batman setValue:[batman sm_assignObjectId] forKey:[batman sm_primaryKeyField]];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // link bob to each of the favorites
                NSMutableSet *set = [NSMutableSet set];
                [set addObject:blueBottle];
                [set addObject:batman];
                [bob setValue:set forKey:@"favorites"];
                [jack setValue:set forKey:@"favorites"];
                
                // link each favorite to jack (for vareity)
                
                //[[batman valueForKey:@"persons"] unionSet:[NSSet setWithObject:jack]];
                //[[blueBottle valueForKey:@"persons"] unionSet:[NSSet setWithObject:jack]];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // fetch and check
                __block NSString *batmanId = [batman valueForKey:[batman sm_primaryKeyField]];
                __block NSString *blueBottleId = [blueBottle valueForKey:[blueBottle sm_primaryKeyField]];
                __block NSString *bobId = [bob valueForKey:[bob sm_primaryKeyField]];
                __block NSString *jackId = [jack valueForKey:[jack sm_primaryKeyField]];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"last_name = 'Bobberson'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    Person *result = [results objectAtIndex:0];
                    [[theValue([result valueForKey:@"person_id"]) should] equal:theValue(bobId)];
                    [[[result objectID] should] equal:[bob objectID]]; 
                    NSSet *favorites = [result valueForKey:@"favorites"];
                    [[theValue([favorites count]) should] equal:[NSNumber numberWithInt:2]];
                    [favorites enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSString *objGenre = [obj valueForKey:@"genre"];
                        if ([objGenre isEqualToString:@"movies"]) {
                            [[theValue([obj valueForKey:@"favorite_id"]) should] equal:theValue(batmanId)];
                        } else if ([objGenre isEqualToString:@"coffee"]) {
                            [[theValue([obj valueForKey:@"favorite_id"]) should] equal:theValue(blueBottleId)];
                        }
                    }];
                    
                }];
                
                predicate = [NSPredicate predicateWithFormat:@"last_name = 'Jackerson'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    Person *result = [results objectAtIndex:0];
                    [[theValue([result valueForKey:@"person_id"]) should] equal:theValue(jackId)];
                    [[[result objectID] should] equal:[jack objectID]]; 
                    NSSet *favorites = [result valueForKey:@"favorites"];
                    [[theValue([favorites count]) should] equal:[NSNumber numberWithInt:2]];
                    [favorites enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSString *objGenre = [obj valueForKey:@"genre"];
                        if ([objGenre isEqualToString:@"movies"]) {
                            [[theValue([obj valueForKey:@"favorite_id"]) should] equal:theValue(batmanId)];
                        } else if ([objGenre isEqualToString:@"coffee"]) {
                            [[theValue([obj valueForKey:@"favorite_id"]) should] equal:theValue(blueBottleId)];
                        }
                    }];
                    
                }];
                
                predicate = [NSPredicate predicateWithFormat:@"genre = 'movies'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makeFavoriteFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    NSManagedObject *result = [results objectAtIndex:0];
                    [[theValue([result valueForKey:@"favorite_id"]) should] equal:theValue(batmanId)];
                    [[[result objectID] should] equal:[batman objectID]]; 
                    NSSet *persons = [result valueForKey:@"persons"];
                    [[theValue([persons count]) should] equal:[NSNumber numberWithInt:2]];
                    [persons enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSString *objLastName = [obj valueForKey:@"last_name"];
                        if ([objLastName isEqualToString:@"Bobberson"]) {
                            [[theValue([obj valueForKey:@"person_id"]) should] equal:theValue(bobId)];
                        } else if ([objLastName isEqualToString:@"Jackerson"]) {
                            [[theValue([obj valueForKey:@"person_id"]) should] equal:theValue(jackId)];
                        }
                    }];
                    
                }];
                
                predicate = [NSPredicate predicateWithFormat:@"genre = 'coffee'"];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makeFavoriteFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                    NSManagedObject *result = [results objectAtIndex:0];
                    [[theValue([result valueForKey:@"favorite_id"]) should] equal:theValue(blueBottleId)];
                    [[[result objectID] should] equal:[blueBottle objectID]]; 
                    NSSet *persons = [result valueForKey:@"persons"];
                    [[theValue([persons count]) should] equal:[NSNumber numberWithInt:2]];
                    [persons enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSString *objLastName = [obj valueForKey:@"last_name"];
                        if ([objLastName isEqualToString:@"Bobberson"]) {
                            [[theValue([obj valueForKey:@"person_id"]) should] equal:theValue(bobId)];
                        } else if ([objLastName isEqualToString:@"Jackerson"]) {
                            [[theValue([obj valueForKey:@"person_id"]) should] equal:theValue(jackId)];
                        }
                    }];
                    
                }];
                
                
                
                // delete objects
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[blueBottle sm_objectId] inSchema:[blueBottle sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted blueBottle");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"Did not delete blueBottle with error userInfo %@",[theError userInfo]);
                }];
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[batman sm_objectId] inSchema:[batman sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted batman");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"Did not delete batman with error userInfo %@",[theError userInfo]);
                }];
                
            });

        });
        
        describe(@"update", ^{
            it(@"updates an object", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    people = results;
                }];
                
                
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousUpdate:moc withObject:[[people objectAtIndex:0] objectID] andBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    DLog(@"Executed syncronous update");
                }];
                NSLog(@"updated objects after update %@", [moc updatedObjects]);
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[[results objectAtIndex:0] should] haveValue:[NSNumber numberWithInt:20] forKey:@"armor_class"];
                }];
            });
        });
        
        describe(@"delete", ^{
            it(@"deletes objects from StackMob", ^{
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    people = results;
                    DLog(@"people after first fetch is %@", people);
                }];
                [SMCoreDataIntegrationTestHelpers executeSynchronousDelete:moc withObject:[[people objectAtIndex:0] objectID] andBlock:^(NSError *error) {
                    DLog(@"Executed syncronous delete");
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    DLog(@"people after second fetch is %@", results);
                    [[results should] haveCountOf:2];
                    [[[results objectAtIndex:0] should] haveValue:@"Vaznaian" forKey:@"last_name"];
                    [[[results objectAtIndex:1] should] haveValue:@"Williams" forKey:@"last_name"];
                }];
            });
            
            it(@"deletes objects with relationships", ^{
                __block Person *firstPerson;
                __block NSString *firstPersonName;
                __block int countOfPeopleBeforeDelete;
                __block int countOfPeopleAfterDelete;
                // grab a person
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    countOfPeopleBeforeDelete = [results count];
                    firstPerson = [results objectAtIndex:0];
                    firstPersonName = [firstPerson valueForKey:@"first_name"];
                    DLog(@"people after first fetch is %@", people);
                }];
                
                // add an interest
                NSManagedObject *batman = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:moc];
                [batman setValue:@"movies" forKey:@"genre"];
                [batman setValue:[batman sm_assignObjectId] forKey:[batman sm_primaryKeyField]];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // link the interest to the person
                NSSet *aSet = [NSSet setWithObject:firstPerson];
                [batman setValue:aSet forKey:@"persons"];
                
                // save
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // delete the person
                [SMCoreDataIntegrationTestHelpers executeSynchronousDelete:moc withObject:[firstPerson objectID] andBlock:^(NSError *error) {
                    DLog(@"Executed syncronous delete");
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // make sure everything is cool
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    DLog(@"people after second fetch is %@", results);
                    countOfPeopleAfterDelete = [results count];
                    [[theValue(countOfPeopleAfterDelete) should] equal:theValue(countOfPeopleBeforeDelete - 1)];
                }];
                
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[batman sm_objectId] inSchema:[batman sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted batman");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"Did not delete batman with error userInfo %@",[theError userInfo]);
                }];
                
            });
        });
        
        describe(@"retreiving an object with to-many relationships as faults", ^{
            it(@"cache insert and new relationship for objectID return the correct things", ^{
                __block Person *firstPerson;
                __block NSString *firstPersonName;
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    firstPerson = [results objectAtIndex:0];
                    firstPersonName = [firstPerson valueForKey:@"first_name"];
                }];
                
                
                NSManagedObject *basketball = [NSEntityDescription insertNewObjectForEntityForName:@"Interest" inManagedObjectContext:moc];
                [basketball setValue:@"basketball" forKey:@"name"];
                [basketball setValue:[NSNumber numberWithInt:10] forKey:@"years_involved"];
                [basketball setValue:[basketball sm_assignObjectId] forKey:[basketball sm_primaryKeyField]];
                
                NSManagedObject *tennis = [NSEntityDescription insertNewObjectForEntityForName:@"Interest" inManagedObjectContext:moc];
                [tennis setValue:@"tennis" forKey:@"name"];
                [tennis setValue:[NSNumber numberWithInt:3] forKey:@"years_involved"];
                [tennis setValue:[tennis sm_assignObjectId] forKey:[tennis sm_primaryKeyField]];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // link the two
                [basketball setValue:firstPerson forKey:@"person"];
                [tennis setValue:firstPerson forKey:@"person"];

                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"first_name = %@", firstPersonName];
                [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makePersonFetchRequest:predicate] andBlock:^(NSArray *results, NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                    [[theValue([results count]) should] equal:[NSNumber numberWithInt:1]];
                }];
                
                // update and save
                [firstPerson setValue:@"Cool" forKey:@"last_name"];
                
                [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
                    if (error != nil) {
                        DLog(@"Error userInfo is %@", [error userInfo]);
                        [error shouldBeNil];
                    }
                }];
                
                // delete objects
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[basketball sm_objectId] inSchema:[basketball sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted basketball");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"Did not delete basketball with error userInfo %@", [theError userInfo]);
                }];
                [[[SMIntegrationTestHelpers defaultClient] dataStore] deleteObjectId:[tennis sm_objectId] inSchema:[tennis sm_schema] onSuccess:^(NSString *theObjectId, NSString *schema) {
                    DLog(@"Deleted tennis");
                } onFailure:^(NSError *theError, NSString *theObjectId, NSString *schema) {
                    [theError shouldBeNil];
                    DLog(@"did not delete tennis with error userInfo %@", [theError userInfo]);
                }];

            });
                        
        });
        
    });
    
});

SPEC_END
