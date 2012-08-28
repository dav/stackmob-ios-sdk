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

#import <Foundation/Foundation.h>

/**
 `NSManagedObject` subclasses that have an attribute to be used by StackMob as it's primary key field that does not conform to lowercaseEntityName_id (i.e. person_id for entity Person) should adopt this protocol.  The will override the <primaryKeyFieldName> method to specify the name of the attribute to be used by StackMob as the primary key field.
 */
@protocol SMModel <NSObject>

/**
 Method to override in `NSManagedObject` subclass.
 
 @return the name of the attribute corresponding to the StackMob primary key field for this entity/schema. 
 */
+ (NSString *)primaryKeyFieldName;

@end