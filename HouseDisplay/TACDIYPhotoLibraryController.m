//
//  TACDIYPhotoLibraryController.m
//  HouseDisplay
//
//  Created by lazy on 13-4-21.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYPhotoLibraryController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define kImageWidth 1000
#define kImageHeight 600
#define kScreenWidth 1024
#define kScreenHeight 768
#define kMenuCellWidth  313
#define kMenuCellHeight 163

@interface TACDIYPhotoLibraryController ()

static UIImage *shrinkImage(UIImage *original, CGSize size);
@property (strong, nonatomic) UIPopoverController *imgPopoverController;


@end

@implementation TACDIYPhotoLibraryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self shootPicture];
    } else {
        [self choosePicture];
    }
    //[self showChoices];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.indexPath = nil;
    self.imageInfo = nil;
    self.imageView = nil;
}

- (void)showChoices{
    NSString *message = @"请选择导入背景的方式";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机拍摄",@"从图片库选取", nil];
    
    [sheet showInView:self.view];
}

- (void)shootPicture{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (void)choosePicture{
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType{
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        [picker.view sizeToFit];
        if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            UIPopoverController *popoverController=[[UIPopoverController alloc] initWithContentViewController:picker];
            self.imgPopoverController = popoverController;
            self.imgPopoverController.popoverContentSize = CGSizeMake(kImageWidth, kImageHeight);
            self.imgPopoverController.delegate = self;
            [self.imgPopoverController presentPopoverFromRect:CGRectMake(kScreenWidth, 0, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            self.view.multipleTouchEnabled = NO;
        } else {
            [self presentViewController:picker animated:YES completion:nil];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"设备不支持此种照片源" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
        [self.view removeFromSuperview];
    }
}

static UIImage *shrinkImage(UIImage *original, CGSize size){
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale, size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width * scale, size.height * scale), original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    CGContextRelease(context);
    CGImageRelease(shrunken);
    return final;
}

#pragma mark-
#pragma mark UIActionSheet Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self shootPicture];
            break;
        case 1:
            [self choosePicture];
            break;
        default:
            break;
    }
}


#pragma mark UIImagePickerController Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.view.multipleTouchEnabled = YES;
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    CGSize size = CGSizeMake(kImageWidth, kImageHeight);
    CGSize coverSize = CGSizeMake(kMenuCellWidth, kMenuCellHeight);
    UIImage *shrunkenImage = [[UIImage alloc] init];
    UIImage *shrunkenCoverImage = [[UIImage alloc] init];
    UIImage *image = [[UIImage alloc] init];
    if ([type isEqual:(NSString *)kUTTypeImage]) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        shrunkenImage = shrinkImage(image,size);
        shrunkenCoverImage = shrinkImage(image, coverSize);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:shrunkenImage forKey:@"image"];
        [dict setObject:self.indexPath forKey:@"indexpath"];
        [dict setObject:shrunkenCoverImage forKey:@"coverImage"];
        self.imageInfo = dict;
        self.imageView.image = shrunkenImage;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [picker dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.imgPopoverController dismissPopoverAnimated:YES];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"不是图片" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
        [self.view removeFromSuperview];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.imgPopoverController dismissPopoverAnimated:YES];
    }

}

- (IBAction)finishButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"insertItem" object:self.imageInfo];
    [self.view removeFromSuperview];
}

- (IBAction)returnButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}
@end
