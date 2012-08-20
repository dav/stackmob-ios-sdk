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

#import "NSManagedObject+StackMobSerialization.h"
#import "SMError.h"
#import "SMModel.h"
#import "SMError.h"
#import "NSEntityDescription+StackMobSerialization.h"

@implementation NSManagedObject (StackMobSerialization)

- (NSString *)sm_schema
{
    return [[self entity] sm_schema];
}

- (NSString *)sm_objectId
{
    NSString *objectIdField = [self sm_primaryKeyField];
    if ([[[self entity] attributesByName] objectForKey:objectIdField] == nil) {
        [NSException raise:SMExceptionIncompatibleObject format:@"Unable to locate a primary key field for %@, expected %@ or the return value from +(NSString *)primaryKeyFieldName if adopting the SMModel protocol.", [self description], objectIdField];
    }
    return [self valueForKey:objectIdField];
}

- (NSString *)sm_assignObjectId
{    
    id objectId = [self sm_objectId];
    if (objectId == nil || objectId == [NSNull null]) {
        CFUUIDRef uuid = CFUUIDCreate(CFAllocatorGetDefault());
        objectId = (__bridge_transfer NSString *)CFUUIDCreateString(CFAllocatorGetDefault(), uuid);
        [self setValue:objectId forKey:[self sm_primaryKeyField]];
        CFRelease(uuid);
    }
    return objectId;
}

- (NSString *)sm_primaryKeyField
{
    NSString *objectIdField = [[self sm_schema] stringByAppendingFormat:@"_id"];
    if ([self conformsToProtocol:@protocol(SMModel)]) {
        objectIdField = [(id <SMModel>)[self class] primaryKeyFieldName];
        if (NO == [objectIdField isEqualToString:[objectIdField lowercaseString]]) {
            [NSException raise:SMExceptionIncompatibleObject format:@"%@ returned an invalid primary key field name (%@). Field names must be lower case.", [self description], objectIdField];
        }
    }
    return objectIdField;
}

- (NSDictionary *)sm_dictionarySerializationByTraversingRelationshipsExcludingObjects:(NSMutableSet *)processedObjects entities:(NSMutableSet *)processedEntities
{
    if (processedObjects == nil) {
        processedObjects = [NSMutableSet set];
    }
    if (processedEntities == nil) {
        processedEntities = [NSMutableSet set];
    }
    // might not be needed
    [self sm_assignObjectId];
    
    [processedObjects addObject:self];
    
    NSEntityDescription *entity = [self entity];
    
    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
    [entity.propertiesByName enumerateKeysAndObjectsUsingBlock:^(id propertyName, id property, BOOL *stop) {
        if ([property isKindOfClass:[NSAttributeDescription class]]) {
            NSAttributeDescription *attributeDescription = (NSAttributeDescription *)property;
            if (attributeDescription.attributeType != NSUndefinedAttributeType) {
                id value = [self valueForKey:(NSString *)propertyName];
                // do not support [NSNull null] values yet
                /*
                 if (value == nil) {
                 value = [NSNull null];
                 }
                 */
                if (value != nil) {
                    [objectDictionary setObject:value forKey:[entity sm_fieldNameForProperty:property]];
                }
            }
        }
        else if ([property isKindOfClass:[NSRelationshipDescription class]]) {
            NSRelationshipDescription *relationship = (NSRelationshipDescription *)property;
            // get the relationship contents for the property
            id relationshipContents = [self valueForKey:propertyName];
            if (relationshipContents) {
                // to many relationship
                if ([relationship isToMany]) {
                    
                    NSMutableArray *relatedObjectDictionaries = [NSMutableArray array];
                    [(NSSet *)relationshipContents enumerateObjectsUsingBlock:^(id child, BOOL *stop) {
                        NSString *childObjectId = [child sm_objectId];
                        if (childObjectId == nil) {
                            [NSException raise:SMExceptionIncompatibleObject format:@"Trying to serialize an object with a to-many relationship whose value references an object with a nil value for it's primary key field.  Please make sure you assign object ids with sm_assignObjectId before attaching to relationships.  The object in question is %@", [child description]];
                        }
                        [relatedObjectDictionaries addObject:[child sm_objectId]];
                    }];
                    [objectDictionary setObject:relatedObjectDictionaries forKey:[entity sm_fieldNameForProperty:property]];
                }
                // one to one relationship
                else {
                    if ([processedObjects containsObject:relationshipContents]) {
                        [objectDictionary setObject:[NSDictionary dictionaryWithObject:[relationshipContents sm_objectId] forKey:[relationshipContents sm_primaryKeyField]] forKey:[entity sm_fieldNameForProperty:property]];
                    }
                    else {
                        [objectDictionary setObject:[relationshipContents sm_dictionarySerializationByTraversingRelationshipsExcludingObjects:processedObjects entities:processedEntities] forKey:[entity sm_fieldNameForProperty:property]];
                    }
                }
            }
        }
    }];
    
    return objectDictionary;
}

- (NSDictionary *)sm_dictionarySerialization
{
    return [self sm_dictionarySerializationByTraversingRelationshipsExcludingObjects:nil entities:nil];
}

- (NSString *)sm_relationshipHeader 
{
    NSArray *headerValues = [[self entity] sm_relationshipHeaderValuesByTraversingRelationshipsExcludingEntities:nil keyPath:nil];    
    
    return [headerValues componentsJoinedByString:@"&"];
}

@end
