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

#import <CoreData/CoreData.h>
#import "StackMob.h"
#import "NSManagedObject+StackMobSerialization.h"

typedef void (^SynchronousFetchBlock)(NSArray *results, NSError *error);
typedef void (^SynchronousErrorBlock)(NSError *error);


@interface SMCoreDataIntegrationTestHelpers : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel *stackMobMOM;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *stackMobPSC;
@property (readonly, strong, nonatomic) NSManagedObjectContext *stackMobMOC;

+ (NSManagedObjectContext *)moc;
+ (NSEntityDescription *)entityForName:(NSString *)entityName;
+ (NSFetchRequest *)makePersonFetchRequest:(NSPredicate *)predicate;
+ (NSFetchRequest *)makeSuperpowerFetchRequest:(NSPredicate *)predicate;
+ (NSFetchRequest *)makeFavoriteFetchRequest:(NSPredicate *)predicate;
+ (NSFetchRequest *)makeInterestFetchRequest:(NSPredicate *)predicate;
+ (void)executeSynchronousFetch:(NSManagedObjectContext *)moc withRequest:(NSFetchRequest *)fetchRequest andBlock:(SynchronousFetchBlock)block;
+ (void)executeSynchronousSave:(NSManagedObjectContext *)moc withBlock:(SynchronousErrorBlock)block;
+ (void)executeSynchronousUpdate:(NSManagedObjectContext *)moc withObject:(NSManagedObjectID *)objectID andBlock:(SynchronousErrorBlock)block;
+ (void)executeSynchronousDelete:(NSManagedObjectContext *)moc withObject:(NSManagedObjectID *)objectID andBlock:(SynchronousErrorBlock)block;
+ (void)registerForMOCNotificationsWithContext:(NSManagedObjectContext *)context;
+ (void)removeObserversrForMOCNotificationsWithContext:(NSManagedObjectContext *)context;
+ (void)MOCDidChange:(NSNotification *)notification;
+ (void)MOCDidSave:(NSNotification *)notification;
+ (void)MOCWillSave:(NSNotification *)notification;

@end