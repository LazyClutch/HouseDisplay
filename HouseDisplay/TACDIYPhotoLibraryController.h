//
//  TACDIYPhotoLibraryController.h
//  HouseDisplay
//
//  Created by lazy on 13-4-21.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TACDIYPhotoLibraryController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) UIImagePickerControllerSourceType sourceType;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)returnButtonPressed:(id)sender;
@end
