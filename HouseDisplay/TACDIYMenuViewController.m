//
//  TACDIYMenuViewController.m
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYMenuViewController.h"
#import "TACDIYViewController.h"
#import "TACDIYMenuViewCell.h"
#import "TACDIYPhotoLibraryController.h"

#define kMenuCellWidth  313
#define kMenuCellHeight 163

@interface TACDIYMenuViewController ()

@property (nonatomic, strong) TACDIYViewController *DIYViewController;
@property (nonatomic, strong) TACDIYPhotoLibraryController *photoLibraryController;

@end

@implementation TACDIYMenuViewController

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
    [self showLoginSuccess];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.backgroundImageView.image = [UIImage imageNamed:@"content_background.jpg"];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    self.isDeleting = false;
    
    [self loadThumbnail];
    
    NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"DIYInformation" ofType:@"plist"];
    NSMutableArray *dict = [[NSMutableArray alloc] initWithContentsOfFile:infoPath];
    self.viewsInfomation = dict;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[TACDIYMenuViewCell class] forCellWithReuseIdentifier:@"MenuViewCellIdentifier"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeThumb:) name:@"changeThumb" object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.imageViews = nil;
}

- (void)setThumbNail{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.imagePaths count]; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[self.imagePaths objectAtIndex:i] ofType:@"png"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage imageWithData:data];
        [array addObject:image];
    }
    self.imageViews = array;
    
    [[TACDataCenter sharedInstance] setMenuThumbnails:self.imageViews];
    
}

- (void)changeThumb:(NSNotification*)notification{
    NSMutableArray *array = [[TACDataCenter sharedInstance] menuThumbnails];
    self.imageViews = array;
    [self.collectionView reloadData];
    
    [self writeThumbnailToFile];
}

- (void)showLoginSuccess{
    NSString *title = @"提示";
    NSString *message = @"登陆成功";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)returnButtonPressed:(id)sender {
    [UIView beginAnimations:@"animationBack" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.superview cache:YES];
    [UIView commitAnimations];
    [self.view removeFromSuperview];
}

- (IBAction)toggleButtonPressed:(id)sender {
    if (self.isDeleting) {
        self.isDeleting = NO;
        [self.toggleButton setTitle:@"编辑" forState:UIControlStateNormal];
    } else {
        self.isDeleting = YES;
        [self.toggleButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    NSLog(@"%@",self.toggleButton.titleLabel.text);
}

- (void)makeAnimation{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeBackwards;
    animation.removedOnCompletion = NO;
    animation.type = @"rippleEffect";
    [self.view.layer addAnimation:animation forKey:@"animation"];
    //[self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.view addSubview:self.DIYViewController.view];
}

#pragma makr Sava and Load Methods
- (void)writeThumbnailToFile{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSData *data = nil;
    for (UIImage *image in self.imageViews) {
        data = UIImagePNGRepresentation(image);
        [array addObject:data];
    }
    [array writeToFile:[self dataFilePath] atomically:YES];
}

- (NSString *)dataFilePath{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentDict = [path objectAtIndex:0];
    NSString *thumbFileName = @"/thumbnail.data2";
    return [documentDict stringByAppendingFormat:@"%@",thumbFileName];
}

- (void)loadThumbnail{
    NSString *filePath = [self dataFilePath];
    NSLog(@"%@",filePath);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        for (NSData *data in dataArray) {
            UIImage *image = [UIImage imageWithData:data];
            [array addObject:image];
        }
        self.imageViews = array;
        [self.collectionView reloadData];
    } else {
        self.imagePaths = @[@"diy1",@"diy2",@"diy3",@"diy4",@"diy5"];
        [self setThumbNail];
    }
    [[TACDataCenter sharedInstance] setMenuThumbnails:self.imageViews];

}

#pragma mark Grid View Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return ([self.imageViews count] + 1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(313, 163);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TACDIYMenuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuViewCellIdentifier" forIndexPath:indexPath];
    if ([indexPath row] < [self.imageViews count]) {
        cell.thumbnails.image = [self.imageViews objectAtIndex:[indexPath row]];
    } else {
        cell.thumbnails.image = [UIImage imageNamed:@"addMark.png"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isDeleting) {
        if ([indexPath row] < [self.imageViews count]) {
            [self deleteItem:indexPath];
        }
    } else {
        [self performSelection:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    
}

- (void)performSelection:(NSIndexPath *)indexPath{
    if ([indexPath row] < [self.imageViews count]) {
        self.DIYViewController = [[TACDIYViewController alloc] initWithNibName:@"TACDIYViewController" bundle:nil];
        
        NSMutableDictionary *dict = [self.viewsInfomation objectAtIndex:[indexPath row]];
        [self.DIYViewController setViewInfomation:dict];
        
        BOOL hasGlass = ([indexPath row] < 3) ? YES : NO;
        [self.DIYViewController setViewTag:[indexPath row] + 1];
        [self.DIYViewController setHasGlassMaterial:hasGlass];
        [self makeAnimation];
    } else {
        NSString *message = @"请选择导入背景的方式";
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机拍摄",@"从图片库选取", nil];
        
        [sheet showInView:(UIView *)[self.collectionView cellForItemAtIndexPath:indexPath]];
        self.photoLibraryController = [[TACDIYPhotoLibraryController alloc] init];
        [self.photoLibraryController setIndexPath:indexPath];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertItem:) name:@"insertItem" object:nil];
    }
}

- (void)deleteItem:(NSIndexPath *)indexPath{
    NSString *title = @"警告";
    NSString *message = @"确实要删除该场景吗？";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
    [alert show];
}


- (void)insertItem:(NSNotification *)notification{
    
    NSMutableDictionary *dict = (NSMutableDictionary *)[notification object];
    
    NSIndexPath *indexPath = [dict objectForKey:@"indexpath"];
    UIImage *image = [dict objectForKey:@"image"];
    
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    imgArray = self.imageViews;
    [imgArray addObject:image];
    self.imageViews = imgArray;
    
    NSArray *array = [NSArray arrayWithObjects:indexPath,nil];
    [self.collectionView insertItemsAtIndexPaths:array];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self.photoLibraryController setSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            [self.photoLibraryController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default:
            break;
    }
    [self.view addSubview:self.photoLibraryController.view];
}


@end
