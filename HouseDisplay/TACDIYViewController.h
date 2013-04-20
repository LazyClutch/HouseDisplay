//
//  TACDIYViewController.h
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "iCarousel.h"
#import "MBProgressHUD.h"

@interface TACDIYViewController : UIViewController <MBProgressHUDDelegate,iCarouselDataSource,iCarouselDelegate>{
    NSString *outString; 
    NSString *currentState;
    CGRect doorPicRect;
    CGRect glasspicRect;
}

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIButton *doorButton;
@property (strong, nonatomic) IBOutlet UIButton *glassButton;

@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIImageView *displayDoorImageView;
@property (strong, nonatomic) UIImageView *displayGlassImageView;
@property (strong, nonatomic) UIImageView *frontImageView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet iCarousel *coverFlow;

@property (strong, nonatomic) NSMutableDictionary *viewInfomation;
@property (strong, nonatomic) NSMutableDictionary *imageData;
@property (strong, nonatomic) NSMutableArray *originalIndexArray;
@property (copy, nonatomic) NSMutableArray *jsonTempDataArray;
@property (strong, nonatomic) NSMutableDictionary *originalOperationDic;
@property (strong, nonatomic) NSOperationQueue *requestImageQueue;

@property (strong, nonatomic) NSURLConnection *connection;

@property NSInteger viewTag;
@property BOOL hasGlassMaterial;
@property BOOL firstLogin;

- (IBAction)returnButtonPressed:(id)sender;
- (IBAction)doorButtonPressed:(id)sender;
- (IBAction)glassButtonPressed:(id)sender;
-(void)imageDidReceive:(UIImageView *)imageView;


@end
