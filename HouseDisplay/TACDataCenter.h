//
//  TACDataCenter.h
//  HouseDisplay
//
//  Created by lazy on 13-4-20.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TACDataCenter : NSObject

@property (strong, nonatomic) NSMutableDictionary *menuThumbnails;
@property (strong, nonatomic) NSMutableArray *viewsInformation;
@property (strong, nonatomic) NSMutableDictionary *backgrounds;

+ (TACDataCenter *) sharedInstance;
- (void) operation;

@end
