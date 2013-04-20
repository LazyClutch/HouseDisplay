//
//  TACDataCenter.m
//  HouseDisplay
//
//  Created by lazy on 13-4-20.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDataCenter.h"

@implementation TACDataCenter

static TACDataCenter *_sharedInstance = nil;

- (void) operation
{
    // do something
    NSLog(@"Singleton");
}

+ (TACDataCenter *) sharedInstance
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init]; // or some other init method
    });
    return _sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [super allocWithZone:zone]; // or some other init method
    });
    return _sharedInstance;

}

- (id) copyWithZone:(NSZone*)zone
{
    return self;
}

@end
