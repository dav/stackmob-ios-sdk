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

#import "SMCoreDataStore.h"
#import "SMIncrementalStore.h"
#import "SMError.h"

@interface SMCoreDataStore ()

@property(nonatomic, readwrite, strong)NSManagedObjectModel *managedObjectModel;
    

@end

@implementation SMCoreDataStore

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (id)initWithAPIVersion:(NSString *)apiVersion session:(SMUserSession *)session managedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    self = [super initWithAPIVersion:apiVersion session:session];
    if (self) {
        _managedObjectModel = managedObjectModel;
    }
    
    return self;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        [NSPersistentStoreCoordinator registerStoreClass:[SMIncrementalStore class] forStoreType:SMIncrementalStoreType];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error = nil;
        [_persistentStoreCoordinator addPersistentStoreWithType:SMIncrementalStoreType
                                   configuration:nil 
                                             URL:nil
                                            options:[NSDictionary dictionaryWithObject:self forKey:SM_DataStoreKey] 
                                           error:&error];
        if (error != nil) {
            [NSException raise:SMExceptionAddPersistentStore format:@"Error creating persistent store: %@", error];
        }
    }
    
    return _persistentStoreCoordinator;
    
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

@end
