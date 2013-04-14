//
//  TACAppDelegate.h
//  HouseDisplay
//
//  Created by lazy on 13-4-1.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIDownloadCache.h"

@class TACViewController;

@interface TACAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TACViewController *viewController;
@property (strong, nonatomic) ASIDownloadCache *downCache;

@end
