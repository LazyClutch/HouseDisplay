//
//  TACSeriesDetailController.h
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

@interface TACSeriesDetailController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UILabel *seriesLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *seriesImages;

- (IBAction)returnButtonPressed:(id)sender;

@end
