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
#import "SMClient.h"
#import "SMCoreDataStore.h"
#import "SMIntegrationTestHelpers.h"
#import "SMCoreDataIntegrationTestHelpers.h"
#import "Superpower.h"
#import "SMData.h"

SPEC_BEGIN(SMDataCDIntegrationSpec)

describe(@"SMDataCDIntegration", ^{
    __block SMClient *client = nil;
    __block SMCoreDataStore *coreDataStore = nil;
    __block NSManagedObjectModel *mom = nil;
    __block NSManagedObjectContext *moc = nil;
    __block Superpower *superpower = nil;
    beforeEach(^{
        mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
        client = [SMIntegrationTestHelpers defaultClient];
        coreDataStore = [client coreDataStoreWithManagedObjectModel:mom];
        moc = [coreDataStore managedObjectContext];
        
    });
    describe(@"should successfully set binary data when translated to string", ^{
        __block NSString *dataString = nil;
        beforeEach(^{
            superpower = [NSEntityDescription insertNewObjectForEntityForName:@"Superpower" inManagedObjectContext:moc];
            NSError *error = nil;
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString* pathToImageFile = [bundle pathForResource:@"rogue" ofType:@"jpg"];
            NSData *theData = [NSData dataWithContentsOfFile:pathToImageFile options:NSDataReadingMappedIfSafe error:&error];
            [error shouldBeNil];
            dataString = [SMData stringForBinaryData:theData withName:@"whatever" andContentType:@"image/jpg"];
            [dataString shouldNotBeNil];
            [superpower setName:@"cool"];
            [superpower setPic:dataString];
            [superpower setSuperpower_id:[superpower sm_assignObjectId]];
        });
        it(@"should persist to StackMob", ^{
            [SMCoreDataIntegrationTestHelpers executeSynchronousSave:moc withBlock:^(NSError *error) {
               [error shouldBeNil]; 
            }];
            
            [SMCoreDataIntegrationTestHelpers executeSynchronousFetch:moc withRequest:[SMCoreDataIntegrationTestHelpers makeSuperpowerFetchRequest:nil] andBlock:^(NSArray *results, NSError *error) {
                [error shouldBeNil];
                [[theValue([results count]) should] equal:theValue(1)];
                NSString *picString = [[results objectAtIndex:0] valueForKey:@"pic"];
                NSLog(@"picstring is %@", [picString substringWithRange:NSMakeRange(0, 200)]);
            }];
            
            NSLog(@"picstring is now %@", [[superpower valueForKey:@"pic"] substringToIndex:20]);
            
            [SMCoreDataIntegrationTestHelpers executeSynchronousDelete:moc withObject:[superpower objectID] andBlock:^(NSError *error) {
                [error shouldBeNil];
            }];
        });
    });
    
});

SPEC_END