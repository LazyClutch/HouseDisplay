//
//  TACDIYMenuViewController.h
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "NSString+MD5.h"
#import "TACDataCenter.h"

@interface TACDIYMenuViewController : UIViewController <UIGridViewDelegate>{
    NSString *outstring;
}

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIGridView *gridView;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray *imagePaths;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) NSArray *viewsInfomation;

- (IBAction)returnButtonPressed:(id)sender;

@end
