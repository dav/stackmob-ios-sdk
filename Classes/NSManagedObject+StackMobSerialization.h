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

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

/**
 The methods in this category serve as the bread and butter for translating instances of `NSManagedObject` into StackMob equivalent objects.
 */
@interface NSManagedObject (StackMobSerialization)

/**
 Returns the StackMob equivalent schema for the entity name.
 */
- (NSString *)sm_schema;

/**
 Returns the unique StackMob ID for this object using the designated primary key attribute for the `NSManagedObject` instance entity.
 */
- (NSString *)sm_objectId;

/**
 Assigns a unique ID to the `NSManagedObject` instance.
 
 The id is placed in the object's primary key attribute, retrieved from <sm_primaryKeyField>. It is used as the reference when assigning a permanent ID to the Core Data `NSManagedObject` so that Core Data and StackMob are referencing the same key.
 
 @note When creating an `NSManagedObject`, you must call this method and set it's return string as the value for the primary key field.  A call to `save:` on the managed object context will fail if any newly inserted object has a nil value for its primary key field.  To avoid this, when you are done setting other values simply add the line (assuming your new object is called newManagedObject):
 
    [newManagedObject setValue:[newManagedObject sm_assignObjectId] forKey:[newManagedObject sm_primaryKeyField]];
 
 */
- (NSString *)sm_assignObjectId;

/**
 Returns the primary key field for the entity used to uniquely define the object on StackMob.
 
 If the `NSManagedObject` subclass for this entity conforms to the <SMModel> protocol, the return string from the overridden `primaryKeyFieldName` method is returned. Otherwise lowercaseEntityName_id (i.e. person_id for entity Person) is used.
 
 @note If the `NSManagedObject` subclass for this entity does not conforms to the `SMModel` protocol, and lowercaseEntityName_id is not one of the entity's attributes, a `SMExceptionIncompatibleObject` exception is thrown.
 */
- (NSString *)sm_primaryKeyField;

/**
 Converts an `NSManagedObject` into an equivalent dictionary form for StackMob to process.
 */
- (NSDictionary *)sm_dictionarySerialization;

/**
 Triggers the `sm_relationshipHeaderValuesByTraversingRelationshipsExcludingEntities:withKeyPath:` method in <NSEntityDescription(StackMobSerialization)>.
 
 @return A string of all relationship header components joined by &.
 */
- (NSString *)sm_relationshipHeader;

@end
