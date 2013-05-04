//
//  TACDIYViewController.h
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TACDataCenter.h"
#import "iCarousel.h"
#import "MBProgressHUD.h"
#import "FTWCache.h"
#import "NSString+MD5.h"
#import "NSMutableDictionary+data.h"
#import "NIDropDown.h"
#import "ReflectionView.h"
#import "JSON.h"
#import "SPUserResizableView.h"


@interface TACDIYViewController : UIViewController <MBProgressHUDDelegate,iCarouselDataSource,iCarouselDelegate,NIDropDownDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,SPUserResizableViewDelegate>{
    NSString *outString; 
    CGRect doorPicRect;
    NSInteger lastDropIndex;
}

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIButton *setCoverButton;

@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIImageView *displayDoorImageView;
@property (strong, nonatomic) UIImageView *frontImageView;

@property (strong, nonatomic) NIDropDown *dropDown;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet iCarousel *coverFlow;
@property (strong, nonatomic) SPUserResizableView *currentResizableView;
@property (strong, nonatomic) SPUserResizableView *lastResizableView;

@property (strong, nonatomic) NSMutableDictionary *viewInfomation;
@property (strong, nonatomic) NSMutableDictionary *imageData;
@property (strong, nonatomic) NSMutableArray *catalogs;
@property (copy, nonatomic) NSMutableArray *jsonTempDataArray;
@property (strong, nonatomic) NSArray *dropDownMenu;

@property (strong, nonatomic) NSURLConnection *catalogConnection;
@property (strong, nonatomic) NSURLConnection *productConnection;

@property NSInteger viewTag;
@property BOOL hasGlassMaterial;
@property BOOL firstLogin;
@property BOOL isEditing;
@property BOOL isInCell;

- (IBAction)returnButtonPressed:(id)sender;

-(void)imageDidReceive:(UIImageView *)imageView;
- (IBAction)menuButtonPressed:(id)sender;


@end
