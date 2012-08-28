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
 The primary purpose for this category is use the information and methods provided by an `NSEntityDescription` to return StackMob equivalent descriptions of schemas and fields.  This is useful when we have an entity description for entity Person and we want to translate that into the schema for StackMob, or for creating relationship headers needed when posting objects with nested relationship objects.
 */
@interface NSEntityDescription (StackMobSerialization)

/**
 Returns the StackMob equivalent schema for the entity name.
 */
- (NSString *)sm_schema;

/**
 Returns the primary key field for the entity used to uniquely define the object on StackMob.
 
 If the `NSManagedObject` subclass for this entity conforms to the <SMModel> protocol, the return string from the overridden <primaryKeyFieldName> method is returned. Otherwise lowercaseEntityName_id is used.
 
 @note If the `NSManagedObject` subclass for this entity does not conforms to the 'SMModel' protocol, and lowercaseEntityName_id (i.e. person_id for entity Person) is not one of the entity's attributes, a `SMExceptionIncompatibleObject` exception is thrown.
 */
- (NSString *)sm_primaryKeyField;

/**
 Given a property description, returns the equivalent field name on StackMob.
 
 @param property The description of an entity's property.
 
 @note An `SMExceptionIncompatibleObject` exception is thrown if the field name matches multiple properties.
 
 @return The StackMob field name for that property. 
 */
- (NSString *)sm_fieldNameForProperty:(NSPropertyDescription *)property;

/**
 Given a StackMob field name, returns the equivalent `NSPropertyDescription` for the Core Data attribute or relationship.
 
 @param fieldName The field name from StackMob.
 
 @return An `NSPropertyDescription` for the equivalent Core Data attribute or relationship, if one exists. 
 */
- (NSPropertyDescription *)sm_propertyForField:(NSString *)fieldName;

/**
 A recursive method to traverse an `NSEntityDescription`'s properties and create a relationship header needed by StackMob when POSTing objects which contain nested relationship objects.
 
 @param processedEntities A set of the entities that have already been processed.
 @param path The current path in the traversal tree, which allows us to add headers like person.superpower.interest=interest.
 
 @return An `NSArray` containing each piece of the relationship header, which is then joined by & to form an `NSString` and added to the request headers.
 */
- (NSArray *)sm_relationshipHeaderValuesByTraversingRelationshipsExcludingEntities:(NSMutableSet *)processedEntities keyPath:(NSString *)path;

@end
