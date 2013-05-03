//
//  TACPhotoSelecter.h
//  HouseDisplay
//
//  Created by lazy on 13-4-25.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage-Extensions.h"

@interface TACPhotoSelecter : UIView<UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSMutableDictionary *imageInfo;
@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, strong) UIPopoverController *imgPopoverController;


- (void)pickerPicture;

@end
