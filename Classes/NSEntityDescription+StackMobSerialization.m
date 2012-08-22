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

#import "NSEntityDescription+StackMobSerialization.h"
#import "SMModel.h"
#import "SMError.h"

@implementation NSEntityDescription (StackMobSerialization)

- (NSString *)sm_schema
{
    return [[self name] lowercaseString];
}

- (NSString *)sm_primaryKeyField
{
    NSString *objectIdField = [[self sm_schema] stringByAppendingFormat:@"_id"];
    id aClass = NSClassFromString([self name]);
    if (aClass != nil) {
        if ([aClass conformsToProtocol:@protocol(SMModel)]) {
            objectIdField = [(id <SMModel>)aClass primaryKeyFieldName];
            if (NO == [objectIdField isEqualToString:[objectIdField lowercaseString]]) {
                [NSException raise:SMExceptionIncompatibleObject format:@"%@ returned an invalid primary key field name (%@). Field names must be lower case.", [self description], objectIdField];
            }
        }
    }
    return objectIdField;
}

- (NSString *)sm_fieldNameForProperty:(NSPropertyDescription *)property 
{
    return [[property name] lowercaseString];
}

- (NSPropertyDescription *)sm_propertyForField:(NSString *)fieldName
{
    NSMutableSet *matchingProperties = [NSMutableSet set];
    [[self propertiesByName] enumerateKeysAndObjectsUsingBlock:^(id propertyName, id property, BOOL *stop) {
        if ([fieldName isEqualToString:[self sm_fieldNameForProperty:property]]) {
            [matchingProperties addObject:property];
        }
    }];
    
    if ([matchingProperties count] > 1) {
        [NSException raise:SMExceptionIncompatibleObject format:@"Multiple matching properties found for field \"%@\":%@", fieldName, matchingProperties];
    }
    else if ([matchingProperties count] == 0) {
        return nil;
    }
    return [matchingProperties anyObject];
}

- (NSArray *)sm_relationshipHeaderValuesByTraversingRelationshipsExcludingEntities:(NSMutableSet *)processedEntities keyPath:(NSString *)path
{
    if (processedEntities == nil) {
        processedEntities = [NSMutableSet set];
    }
    [processedEntities addObject:self];
    
    NSMutableArray *headerValues = [NSMutableArray array];
    
    [[self relationshipsByName] enumerateKeysAndObjectsUsingBlock:^(id relationshipName, id relationship, BOOL *stop) {
        NSMutableString *relationshipKeyPath = [NSMutableString string];
        if (path && [path length] > 0) {
            [relationshipKeyPath appendFormat:@"%@.", path];
        }
        [relationshipKeyPath appendString:[self sm_fieldNameForProperty:relationship]];
        
        [headerValues addObject:[NSString stringWithFormat:@"%@=%@", relationshipKeyPath, [[relationship destinationEntity] sm_schema]]];
        
        NSEntityDescription *destination = [relationship destinationEntity];
        if (NO == [processedEntities containsObject:destination]) {
            [headerValues addObjectsFromArray:[destination sm_relationshipHeaderValuesByTraversingRelationshipsExcludingEntities:processedEntities keyPath:relationshipKeyPath]];
        }
    }];
    
    return headerValues;
}

@end
