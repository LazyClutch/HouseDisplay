//
//  TACDIYPhotoLibraryController.h
//  HouseDisplay
//
//  Created by lazy on 13-4-21.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SPUserResizableView.h"
#import "MBProgressHUD.h"

@interface TACDIYPhotoLibraryController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,SPUserResizableViewDelegate,UIGestureRecognizerDelegate,MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSMutableDictionary *imageInfo;

@property (strong, nonatomic) SPUserResizableView *currentResizableView;
@property (strong, nonatomic) SPUserResizableView *lastResizableView;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (nonatomic) UIImagePickerControllerSourceType sourceType;

- (void)setPhoto:(UIImage *)image;
- (IBAction)finishButtonPressed:(id)sender;
- (IBAction)returnButtonPressed:(id)sender;
@end
