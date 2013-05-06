//
//  TACSeriesSelectController.h
//  HouseDisplay
//
//  Created by lazy on 13-5-6.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TACSeriesSelectController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableDictionary *seriesInfo;
@property (strong, nonatomic) NSMutableArray *jsonTempDataArray;

@property BOOL isSelecting;

- (IBAction)returnButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;

@end
