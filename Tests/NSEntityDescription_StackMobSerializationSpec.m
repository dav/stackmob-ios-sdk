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
#import "SMError.h"
#import "NSEntityDescription+StackMobSerialization.h"

SPEC_BEGIN(NSEntityDescription_StackMobSerializationSpec)

describe(@"NSEntityDescription_StackMobSerializationSpec", ^{
    __block NSEntityDescription *mapEntity = nil;
    beforeEach(^{
        mapEntity = [[NSEntityDescription alloc] init];
        [mapEntity setName:@"Map"];
        [mapEntity setManagedObjectClassName:@"Map"];
        
        NSAttributeDescription *mapId = [[NSAttributeDescription alloc] init];
        [mapId setName:@"map_id"];
        [mapId setAttributeType:NSStringAttributeType];
        
        NSAttributeDescription *name = [[NSAttributeDescription alloc] init];
        [name setName:@"name"];
        [name setAttributeType:NSStringAttributeType];
        
        NSAttributeDescription *url = [[NSAttributeDescription alloc] init];
        [url setName:@"URL"];
        [url setAttributeType:NSStringAttributeType];
        
        NSAttributeDescription *poorlyNamed = [[NSAttributeDescription alloc] init];
        [poorlyNamed setName:@"poorlyNamed"];
        [poorlyNamed setAttributeType:NSStringAttributeType];
        
        NSAttributeDescription *alsoPoorlyNamed = [[NSAttributeDescription alloc] init];
        [alsoPoorlyNamed setName:@"PoorlyNamed"];
        [alsoPoorlyNamed setAttributeType:NSStringAttributeType];
        
        [mapEntity setProperties:[NSArray arrayWithObjects:mapId, name, url, poorlyNamed, alsoPoorlyNamed, nil]];
    });
    
    describe(@"-sm_schema", ^{
        it(@"returns the lower case version of the entity name", ^{
            [[[mapEntity sm_schema] should] equal:@"map"];
        });
    });
    
    describe(@"-sm_fieldNameForProperty:", ^{
        it(@"retuns the lower case version of the property name", ^{
            NSPropertyDescription *urlProperty = [[mapEntity propertiesByName] objectForKey:@"URL"];
            [[[mapEntity sm_fieldNameForProperty:urlProperty] should] equal:@"url"];
        });
    });
    
    describe(@"-sm_propertyForField:", ^{
        context(@"when only single property matches", ^{
            it(@"returns the property", ^{
                NSPropertyDescription *urlProperty = [[mapEntity propertiesByName] objectForKey:@"URL"];
                [[[mapEntity sm_propertyForField:@"url"] should] equal:urlProperty];
            });
        });
        context(@"when multiple properties might match", ^{
            it(@"should raise", ^{
                [[theBlock(^{
                    [mapEntity sm_propertyForField:@"poorlynamed"];
                }) should] raiseWithName:SMExceptionIncompatibleObject];
            });
        });
        context(@"when no properties match", ^{
            it(@"should return nil", ^{
                [[mapEntity sm_propertyForField:@"unknown"] shouldBeNil];
            });
        });
    });
});

SPEC_END