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
 `SMRequestOptions` is a class designed to supply various choices to requests, including:
 
 * Whether or not it is secure (https).
 * Extra headers to add to the request
 * Select and expand choices to control the data being returned to you
 * The ability to disable automatic login refresh
 
 */
@interface SMRequestOptions : NSObject

@property(nonatomic, retain) NSDictionary *headers;
@property(nonatomic, readwrite) BOOL isSecure;
@property(nonatomic, readwrite) BOOL tryRefreshToken;

/**
 Empty options with no special settings
 
 @return An `SMRequestOptions` object with the default options
 */
+ (SMRequestOptions *)options;

/**
 Options that will add additional headers to a request.
 
 @param headers A dictionary of headers to be attached to a request.
 
 @return An `SMRequestOptions` object with headers set to the supplied dictionary.
 */
+ (SMRequestOptions *)optionsWithHeaders:(NSDictionary *)headers;

/**
 Options that will enable https for a request
 
 @return An `SMRequestOptions` object with isSecure set to `YES`.
 */
+ (SMRequestOptions *)optionsWithHTTPS;

#pragma mark - Expanding relationships

/**
 Expand relationships by `depth` levels.
 
 For example, if `depth` is 1, include any direct child objects nested inside the query results. The option is currently only honored for login calls, datastore reads, and queries.
 
 @param depth The depth to expand to, maximum 3.
 */
- (void)setExpandDepth:(NSUInteger)depth;


#pragma mark - Limiting returned properties

/**
 Return a subset of the schema's fields.
 
 See [the docs](https://stackmob.com/devcenter/docs/Datastore-API#a-selecting_fields_to_return) for details on the format. The option is currently only honored for login calls, datastore reads, and queries
 
 @param fields An array containing the names of the fields to return.
 */
- (void)restrictReturnedFieldsTo:(NSArray *)fields;

@end
