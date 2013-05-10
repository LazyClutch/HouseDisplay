//
//  NSMutableArray+MutableDeepCopy.m
//  HouseDisplay
//
//  Created by lazy on 13-5-10.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "NSMutableArray+MutableDeepCopy.h"

@implementation NSMutableArray (MutableDeepCopy)

- (NSMutableArray *)mutableDeepCopy{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (id value in self) {
        id oneCopy = nil;
        if ([value respondsToSelector:@selector(mutableDeepCopy)]) {
            oneCopy = [value mutableDeepCopy];
        } else if([value respondsToSelector:@selector(mutableCopy)]){
            oneCopy = [value mutableCopy];
        }
        if (oneCopy == nil) {
            oneCopy = [value copy];
        }
        [returnArray addObject:oneCopy];
    }
    return returnArray;
}

@end
