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

#import "SMSpecHelpers.h"

static SMSpecHelpers *_singletonInstance;

@interface SMSpecHelpers()

+ (SMSpecHelpers *)singleton;

@end

@implementation SMSpecHelpers

@synthesize managedObjectModel = _managedObjectModel;
@synthesize inMemoryPSC = _inMemoryPSC;
@synthesize inMemoryMOC = _inMemoryMOC;

- (NSManagedObjectModel *)managedObjectModel {

    if (_managedObjectModel == nil) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    }
    return _managedObjectModel;

}

- (NSPersistentStoreCoordinator *)inMemoryPSC {
    if (_inMemoryPSC == nil) {
        _inMemoryPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error;
        [_inMemoryPSC addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
        if (error != nil) {
            NSLog(@"Error: %@", error);
            abort();
        }
    }
    return _inMemoryPSC;
}

- (NSManagedObjectContext *)inMemoryMOC {
    if (_inMemoryMOC == nil) {
        _inMemoryMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_inMemoryMOC setPersistentStoreCoordinator:self.inMemoryPSC];
    }
    return _inMemoryMOC;
}

+ (SMSpecHelpers *)singleton {
    if (_singletonInstance == nil) {
        _singletonInstance = [[SMSpecHelpers alloc] init];
    }
    return _singletonInstance;
}

+ (NSEntityDescription *)entityForName:(NSString *)entityName {
    SMSpecHelpers *sh = [SMSpecHelpers singleton];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:sh.inMemoryMOC];
    NSAssert(entity != nil, @"Entity names are case-sensitive, also, check the .xcdatamodeld");
    return entity;
}

@end
