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

@interface TACDIYMenuViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate>{
    NSString *outstring;
}

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray *imagePaths;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) NSArray *viewsInfomation;

@property BOOL isDeleting;

- (IBAction)returnButtonPressed:(id)sender;
- (IBAction)toggleButtonPressed:(id)sender;

@end
