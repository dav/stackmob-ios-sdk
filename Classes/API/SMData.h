//
//  SMData.h
//  stackmob-ios-sdk
//
//  Created by Matt Vaznaian on 8/13/12.
//  Copyright (c) 2012 StackMob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMData : NSObject

+ (NSString *)stringForBinaryData:(NSData *)data withName:(NSString *)name andContentType:(NSString *)contentType;

@end
