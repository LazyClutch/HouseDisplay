//
//  TACViewController.h
//  HouseDisplay
//
//  Created by lazy on 13-4-1.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GNWheelView.h"

#define kMenuImageHeight 440;
#define kMenuImageWidth  540;

@interface TACViewController : UIViewController <GNWheelViewDelegate>

@property (strong, nonatomic) NSArray *menuList;
@property (strong, nonatomic) NSArray *viewControllers;


@end
