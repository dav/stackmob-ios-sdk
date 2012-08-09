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

#import "SMIncrementalStore+Query.h"
#import "SMError.h"

@implementation SMIncrementalStore (Query)

void setErrorWithReason(NSString *reason, NSError * __autoreleasing *error) {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason forKey:@"reason"];
    *error = [[NSError alloc] initWithDomain:SMErrorDomain code:SMErrorInvalidArguments userInfo:userInfo];
    *error = (__bridge id)(__bridge_retained CFTypeRef)*error;
}

void buildBetweenQuery(SMQuery *__autoreleasing *query, id lhs, id rhs, NSError *__autoreleasing *error) {
    if (![rhs isKindOfClass:[NSArray class]]) {
        setErrorWithReason(@"RHS must be an NSArray", error);
        return;
    }
    NSString *field = (NSString *)lhs;
    NSArray *range = (NSArray *)rhs;
    NSNumber *low = (NSNumber *)[range objectAtIndex:0];
    NSNumber *high = (NSNumber *)[range objectAtIndex:1];
    
    [*query where:field isGreaterThanOrEqualTo:low];
    [*query where:field isLessThanOrEqualTo:high];
    
    return;
}

void buildInQuery(SMQuery *__autoreleasing *query, id lhs, id rhs, NSError *__autoreleasing *error) {
    if (![rhs isKindOfClass:[NSArray class]]) {
        setErrorWithReason(@"RHS must be an NSArray", error);
        return;
    }
    NSString *field = (NSString *)lhs;
    NSArray *arrayToSearch = (NSArray *)rhs;
    
    [*query where:field isIn:arrayToSearch];
    
    return;
}

void buildQueryForPredicate(SMQuery *__autoreleasing *query, NSPredicate *predicate, NSError *__autoreleasing *error);

void buildQueryForCompoundPredicate(SMQuery *__autoreleasing *query, NSCompoundPredicate *compoundPredicate, NSError *__autoreleasing *error)
{
    if ([compoundPredicate compoundPredicateType] != NSAndPredicateType) {
        setErrorWithReason(@"Predicate type not supported.", error);
        return;
    }
    
    for (int i = 0; i < [[compoundPredicate subpredicates] count]; i++) {
        NSPredicate *subpredicate = [[compoundPredicate subpredicates] objectAtIndex:i];
        buildQueryForPredicate(query, subpredicate, error);
    } 
}

void buildQueryForComparisonPredicate(SMQuery *__autoreleasing *query, NSComparisonPredicate *comparisonPredicate, NSError *__autoreleasing *error) 
{        
    if (comparisonPredicate.leftExpression.expressionType != NSKeyPathExpressionType) {
        setErrorWithReason(@"LHS must be usable as a remote keypath", error);
        return;
    } else if (comparisonPredicate.rightExpression.expressionType != NSConstantValueExpressionType) {
        setErrorWithReason(@"RHS must be a constant-valued expression", error);
        return;
    }
    
    NSString *lhs = comparisonPredicate.leftExpression.keyPath;
    id rhs = comparisonPredicate.rightExpression.constantValue;
    
    switch (comparisonPredicate.predicateOperatorType) {
        case NSEqualToPredicateOperatorType:
            [*query where:lhs isEqualTo:rhs];
            return;
        case NSNotEqualToPredicateOperatorType:
            [*query where:lhs isNotEqualTo:rhs];
            return;
        case NSLessThanPredicateOperatorType:
            [*query where:lhs isLessThan:rhs];
            return;
        case NSLessThanOrEqualToPredicateOperatorType:
            [*query where:lhs isLessThanOrEqualTo:rhs];
            return;
        case NSGreaterThanPredicateOperatorType:
            [*query where:lhs isGreaterThan:rhs];
            return;
        case NSGreaterThanOrEqualToPredicateOperatorType:
            [*query where:lhs isGreaterThanOrEqualTo:rhs];
            return;
        case NSBetweenPredicateOperatorType:
            buildBetweenQuery(query, lhs, rhs, error);
            return;
        case NSInPredicateOperatorType:
            buildInQuery(query, lhs, rhs, error);
            return;
        default:
            setErrorWithReason(@"Predicate type not supported.", error);
            return;
    }
}

void buildQueryForPredicate(SMQuery *__autoreleasing *query, NSPredicate *predicate, NSError *__autoreleasing *error)
{    
    if ([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        buildQueryForCompoundPredicate(query, (NSCompoundPredicate *)predicate, error);
    }
    else if ([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        buildQueryForComparisonPredicate(query, (NSComparisonPredicate *)predicate, error);
    }
}

+ (SMQuery *)queryForFetchRequest:(NSFetchRequest *)fetchRequest 
                            error:(NSError *__autoreleasing *)error {
    
    SMQuery *query = [SMIncrementalStore queryForEntity:fetchRequest.entity 
                                              predicate:fetchRequest.predicate
                                                  error:error];
    
    if (*error != nil) {
        return nil;
    }
    
    // Limit / pagination
    
    if (fetchRequest.fetchBatchSize) { // The default is 0, which means "everything"
        setErrorWithReason(@"NSFetchRequest fetchBatchSize not supported", error);
        return nil;
    }
    
    NSUInteger fetchOffset = fetchRequest.fetchOffset;
    NSUInteger fetchLimit = fetchRequest.fetchLimit;
    NSString *rangeHeader;
    
    if (fetchOffset) {
        if (fetchLimit) {
            rangeHeader = [NSString stringWithFormat:@"objects=%i-%i", fetchOffset, fetchOffset+fetchLimit];
        } else {
            rangeHeader = [NSString stringWithFormat:@"objects=%i-", fetchOffset];
        }
        [[query requestHeaders] setValue:rangeHeader forKey:@"Range"];
    }
    
    // Ordering
    
    [fetchRequest.sortDescriptors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [query orderByField:[obj key] ascending:[obj ascending]];
    }];
    
    return query;
}


+ (SMQuery *)queryForEntity:(NSEntityDescription *)entityDescription 
                  predicate:(NSPredicate *)predicate 
                      error:(NSError *__autoreleasing *)error {
    
    SMQuery *query = [[SMQuery alloc] initWithEntity:entityDescription];
    buildQueryForPredicate(&query, predicate, error);
    
    return query;
}

@end