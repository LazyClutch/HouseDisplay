//
//  NSMutableDictionary+data.m
//  HouseDisplay
//
//  Created by lazy on 13-4-20.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "NSMutableDictionary+data.h"

@implementation NSMutableDictionary (data)

+ (NSMutableDictionary *)dictionaryWithContentsOfData:(NSData *)data {
    CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)CFBridgingRetain(data),
                                                               kCFPropertyListImmutable,
                                                               NULL);
    if(plist == nil) return nil;
    if ([(id)CFBridgingRelease(plist) isKindOfClass:[NSMutableDictionary class]]) {
        return (NSMutableDictionary *)CFBridgingRelease(plist);
    }
    else {
        CFRelease(plist);
        return nil;
    }
}

+ (NSMutableDictionary *)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress{
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

- (NSData *)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

@end
