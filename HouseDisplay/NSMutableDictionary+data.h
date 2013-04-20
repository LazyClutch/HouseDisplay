//
//  NSMutableDictionary+data.h
//  HouseDisplay
//
//  Created by lazy on 13-4-20.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (data)

+ (NSMutableDictionary *)dictionaryWithContentsOfData:(NSData *)data;
+ (NSMutableDictionary *)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
- (NSData*)toJSON;


@end
