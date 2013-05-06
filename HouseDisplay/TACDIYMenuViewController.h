//
//  TACDIYMenuViewController.h
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TACDIYMenuViewCell.h"
#import "NSString+MD5.h"
#import "TACDataCenter.h"
#import "TACDIYPhotoLibraryController.h"
#import "MBProgressHUD.h"
#import "JSON.h"

@interface TACDIYMenuViewController : UIViewController<UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIActionSheetDelegate,NSURLConnectionDataDelegate,MBProgressHUDDelegate,UIApplicationDelegate>{
    NSString *outString;
    NSIndexPath *lastSelectedIndex;
}

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray *imagePaths;

@property (strong, nonatomic) NSMutableDictionary *thumbnails;

//viewsinformation contain the information of all rooms including ID, url for thumb, url for background
@property (strong, nonatomic) NSMutableDictionary *viewsInfomation;

@property (strong, nonatomic) NSMutableDictionary *backgrounds;
@property (strong, nonatomic) NSMutableArray *jsonTempDataArray;

@property (strong, nonatomic) NSURLConnection *thumbConnection;

@property BOOL isDeleting;

- (IBAction)returnButtonPressed:(id)sender;
- (IBAction)toggleButtonPressed:(id)sender;

@end
