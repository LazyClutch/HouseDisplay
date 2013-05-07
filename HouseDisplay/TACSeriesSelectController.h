//
//  TACSeriesSelectController.h
//  HouseDisplay
//
//  Created by lazy on 13-5-6.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "JSON.h"
#import "NSString+Encode.h"
#import "AFNetworking.h"
#import "FTWCache.h"
#import "NSString+MD5.h"

@interface TACSeriesSelectController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,MBProgressHUDDelegate>{
    NSString *outString;
}

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *seriesInfo;
@property (strong, nonatomic) NSMutableArray *seriesDetails;
@property (strong, nonatomic) NSMutableArray *jsonTempDataArray;

@property (strong, nonatomic) NSURLConnection *seriesConnection;
@property (strong, nonatomic) NSURLConnection *productConnection;

@property (strong, nonatomic) MBProgressHUD *hud;

@property BOOL isSelecting;

- (IBAction)returnButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;

@end
