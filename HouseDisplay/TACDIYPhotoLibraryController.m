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
    self.imageView.image = self.image;
    [self addResizableView];
    //[self showChoices];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.indexPath = nil;
    self.imageInfo = nil;
    self.imageView = nil;
}

- (void)setPhoto:(UIImage *)image{
    self.image = [[UIImage alloc] init];
    self.image = image;
}

- (void)addResizableView{
    
    CGRect gripFrame = CGRectMake(50, 50, 200, 150);
    SPUserResizableView *resizableView = [[SPUserResizableView alloc] initWithFrame:gripFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:gripFrame];
    [contentView setBackgroundColor:[UIColor clearColor]];
    resizableView.contentView = contentView;
    resizableView.delegate = self;
    [resizableView showEditingHandles];
    self.currentResizableView = resizableView;
    self.lastResizableView = resizableView;
    [self.imageView addSubview:resizableView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles)];
    [gestureRecognizer setDelegate:self];
    [self.imageView addGestureRecognizer:gestureRecognizer];

}



- (IBAction)finishButtonPressed:(id)sender {
    NSString *x = [NSString stringWithFormat:@"%f",self.lastResizableView.frame.origin.x];
    NSString *y = [NSString stringWithFormat:@"%f",self.lastResizableView.frame.origin.y];
    NSString *w = [NSString stringWithFormat:@"%f",self.lastResizableView.bounds.size.width];
    NSString *h = [NSString stringWithFormat:@"%f",self.lastResizableView.bounds.size.height];
    NSMutableDictionary *dict = self.imageInfo;
    [dict setObject:x forKey:@"doorPosX"];
    [dict setObject:y forKey:@"doorPosY"];
    [dict setObject:w forKey:@"displayDoorWidth"];
    [dict setObject:h forKey:@"displayDoorHeight"];
    self.imageInfo = dict;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"insertItem" object:self.imageInfo];
    [self.view removeFromSuperview];
}

- (IBAction)returnButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}

#pragma mark ResizableView Methods
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView {
    [self.currentResizableView hideEditingHandles];
    self.currentResizableView = userResizableView;
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView {
    self.lastResizableView = userResizableView;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return NO;
}

- (void)hideEditingHandles {
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    [self.lastResizableView hideEditingHandles];
}
@end
