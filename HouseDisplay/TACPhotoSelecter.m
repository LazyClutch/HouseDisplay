//
//  TACPhotoSelecter.m
//  HouseDisplay
//
//  Created by lazy on 13-4-25.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACPhotoSelecter.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define kImageWidth 1000
#define kImageHeight 600
#define kScreenWidth 1024
#define kScreenHeight 768
#define kMenuCellWidth  313
#define kMenuCellHeight 163

@implementation TACPhotoSelecter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)pickerPicture{
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self shootPicture];
    } else {
        [self choosePicture];
    }
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
            self.imgPopoverController.popoverContentSize = CGSizeMake(kMenuCellWidth, kMenuCellHeight);
            self.imgPopoverController.delegate = self;
            [self.imgPopoverController presentPopoverFromRect:CGRectMake(413, -30, 1, 1) inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            self.multipleTouchEnabled = NO;
        } else {
            UIDevice *currentDevice = [UIDevice currentDevice];
            while ([currentDevice isGeneratingDeviceOrientationNotifications])
                [currentDevice endGeneratingDeviceOrientationNotifications];
            [self.parentViewController presentViewController:picker animated:YES completion:nil];
            while ([currentDevice isGeneratingDeviceOrientationNotifications])
                [currentDevice endGeneratingDeviceOrientationNotifications];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"设备不支持此种照片源" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
        [self removeFromSuperview];
    }
}


#pragma mark-
#pragma mark Shrink Image using C Methods

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

#pragma mark UIImagePickerController Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.multipleTouchEnabled = YES;
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    CGSize size = CGSizeMake(kImageWidth, kImageHeight);
    CGSize coverSize = CGSizeMake(kMenuCellWidth, kMenuCellHeight);
    UIImage *shrunkenImage = [[UIImage alloc] init];
    UIImage *shrunkenCoverImage = [[UIImage alloc] init];
    UIImage *image = [[UIImage alloc] init];
    UIImage *newImage = [[UIImage alloc] init];
    if ([type isEqual:(NSString *)kUTTypeImage]) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (image.imageOrientation != UIImageOrientationUp) {
            newImage = [image imageRotatedByDegrees:180];
        } else {
            newImage = image;
        }
        shrunkenImage = shrinkImage(newImage,size);
        shrunkenCoverImage = shrinkImage(newImage, coverSize);
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSString *system = [NSString stringWithFormat:@"%d",2];
        [dict setObject:system forKey:@"system"];
        [dict setObject:shrunkenImage forKey:@"image"];
        [dict setObject:self.indexPath forKey:@"indexpath"];
        [dict setObject:shrunkenCoverImage forKey:@"coverImage"];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [picker dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.imgPopoverController dismissPopoverAnimated:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pickerPicture" object:dict];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"不是图片" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
        [self removeFromSuperview];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.imgPopoverController dismissPopoverAnimated:YES];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
