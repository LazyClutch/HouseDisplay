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
#import "TACPhotoSelecter.h"
#import <ImageIO/ImageIO.h>

#define kMenuCellWidth  313
#define kMenuCellHeight 163
#define kActionSheetDelete 10
#define kActionSheetSelect 6

@interface TACDIYMenuViewController ()

@property (nonatomic, strong) TACDIYViewController *DIYViewController;
@property (nonatomic, strong) TACDIYPhotoLibraryController *photoLibraryController;
@property (nonatomic, strong) TACPhotoSelecter *photoSelector;

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
    self.isDeleting = NO;
    lastSelectedIndex = nil;
    
    [self loadInformation];
    [self loadThumbnail];
    [self loadBackgrounds];
    
    [self setDataCenter];
    
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

#pragma mark Thumbnail Methods

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

- (void)setDataCenter{
    [[TACDataCenter sharedInstance] setViewsInformation:self.viewsInfomation];
}


- (void)setBackground{
    NSArray *array = [[NSArray alloc] initWithObjects:@"1_back",@"2_back",@"3_back",@"4_back",@"5_back", nil];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSString *name in array) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage imageWithData:data];
        [images addObject:image];
    }
    self.backgrounds = images;
    
    [[TACDataCenter sharedInstance] setBackgrounds:images];
}

#pragma mark Save and Load Methods
- (void)writeThumbnailToFile{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSData *data = nil;
    for (UIImage *image in self.imageViews) {
        data = UIImagePNGRepresentation(image);
        [array addObject:data];
    }
    NSString *fileName = @"/thumbnail.data2";
    NSString *filePath = [self dataFilePath:fileName];
    [array writeToFile:filePath atomically:YES];
}

- (void)writeInformationToFile{
    NSString *fileName = @"/roomInfo.data";
    NSString *filePath = [self dataFilePath:fileName];
    [self.viewsInfomation writeToFile:filePath atomically:YES];
}

- (void)writeBackgroundsToFile{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSData *data = nil;
    for (UIImage *image in self.backgrounds) {
        data = UIImageJPEGRepresentation(image, 1.0);
        [array addObject:data];
    }
    NSString *fileName = @"/background.data";
    NSString *filePath = [self dataFilePath:fileName];
    [array writeToFile:filePath atomically:YES];
}

- (NSString *)dataFilePath:(NSString *)fileName{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDict = [path objectAtIndex:0];
    NSString *thumbFileName = fileName;
    return [documentDict stringByAppendingFormat:@"%@",thumbFileName];
}

- (void)loadInformation{
    NSString *fileName = @"/roomInfo.data";
    NSString *filePath = [self dataFilePath:fileName];
    NSLog(@"%@",filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.viewsInfomation = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    } else {
        NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"houseInfomation" ofType:@"plist"];
        NSMutableArray *dict = [[NSMutableArray alloc] initWithContentsOfFile:infoPath];
        self.viewsInfomation = dict;
    }
}

- (void)loadBackgrounds{
    NSString *fileName = @"/background.data";
    NSString *filePath = [self dataFilePath:fileName];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        dataArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        for (NSData *data in dataArray) {
            UIImage *image = [UIImage imageWithData:data];
            [array addObject:image];
        }
        self.backgrounds = array;
    } else {
        [self setBackground];
    }
    [[TACDataCenter sharedInstance] setBackgrounds:self.backgrounds];
}

- (void)loadThumbnail{
    NSString *fileName = @"/thumbnail.data2";
    NSString *filePath = [self dataFilePath:fileName];
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
    CGSize size = CGSizeMake(kMenuCellWidth, kMenuCellHeight);
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

#pragma mark Edit Methods

- (void)performSelection:(NSIndexPath *)indexPath{
    if ([indexPath row] < [self.imageViews count]) {
        self.DIYViewController = [[TACDIYViewController alloc] initWithNibName:@"TACDIYViewController" bundle:nil];
        
        NSMutableDictionary *dict = [self.viewsInfomation objectAtIndex:[indexPath row]];
        [self.DIYViewController setViewInfomation:dict];
        
        BOOL hasGlass = ([indexPath row] < 3) ? YES : NO;
        NSInteger tag = [indexPath row];
        [self.DIYViewController setViewTag:tag + 1];
        [self.DIYViewController setHasGlassMaterial:hasGlass];
        [self makeAnimation];
    } else {
        NSString *message = @"请选择导入背景的方式";
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机拍摄",@"从图片库选取", nil];
        sheet.tag = kActionSheetSelect;
        
        [sheet showInView:(UIView *)[self.collectionView cellForItemAtIndexPath:indexPath]];
        self.photoSelector = [[TACPhotoSelecter alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
        [self.photoSelector setIndexPath:indexPath];
        [self.photoSelector setParentViewController:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"insertItem" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertItem:) name:@"insertItem" object:nil];
    }
}

- (void)deleteItem:(NSIndexPath *)indexPath{
    if (lastSelectedIndex == nil) {
        lastSelectedIndex = indexPath;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确实要删除场景吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:@"取消", nil];
        actionSheet.tag = kActionSheetDelete;
        [actionSheet showInView:self.view];
    }
}


- (void)insertItem:(NSNotification *)notification{
    
    NSMutableDictionary *dict = (NSMutableDictionary *)[notification object];
    
    NSIndexPath *indexPath = [dict objectForKey:@"indexpath"];
    UIImage *coverImage = [dict objectForKey:@"coverImage"];
    UIImage *background = [dict objectForKey:@"image"];
    
    NSMutableArray *backgrounds = [NSMutableArray arrayWithArray:self.backgrounds];
    [backgrounds addObject:background];
    [[TACDataCenter sharedInstance] setBackgrounds:backgrounds];
        
    NSMutableArray *thumbArray = [NSMutableArray arrayWithArray:self.imageViews];
    [thumbArray addObject:coverImage];
    [[TACDataCenter sharedInstance] setMenuThumbnails:thumbArray];
    
    NSMutableArray *viewsInfo = [NSMutableArray arrayWithArray:self.viewsInfomation];
    [dict removeObjectForKey:@"image"];
    [dict removeObjectForKey:@"indexpath"];
    [dict removeObjectForKey:@"coverImage"];
    [viewsInfo addObject:dict];
    [[TACDataCenter sharedInstance] setViewsInformation:viewsInfo];
    
    self.viewsInfomation = viewsInfo;
    self.imageViews = thumbArray;
    self.backgrounds = backgrounds;
    
    [self writeThumbnailToFile];
    [self writeInformationToFile];
    [self writeBackgroundsToFile];
    
    NSArray *array = [NSArray arrayWithObjects:indexPath,nil];
    [self.collectionView insertItemsAtIndexPaths:array];
    
    [self insertItemForDetail:dict];
}

- (void)insertItemForDetail:(NSMutableDictionary *)dict{
    // set self.viewInformation defalut:0


}

#pragma mark NSNotificationCenter Methods

- (void)imageDidGotten:(NSNotification *)notification{
    NSMutableDictionary *dict = (NSMutableDictionary *)[notification object];
    UIImage *image = [dict objectForKey:@"image"];
    self.photoLibraryController = [[TACDIYPhotoLibraryController alloc] init];
    [self.view addSubview:self.photoLibraryController.view];
    [self.photoLibraryController setImageInfo:dict];
    [self.photoLibraryController setPhoto:image];
}

- (void)changeThumb:(NSNotification*)notification{
    NSMutableDictionary *dict = (NSMutableDictionary *)[notification object];
    
    UIImage *thumbnail = [dict objectForKey:@"thumbnail"];
    NSInteger tag = [[dict objectForKey:@"tag"] integerValue];
    
    NSMutableArray *array = [[TACDataCenter sharedInstance] menuThumbnails];
    [array replaceObjectAtIndex:(tag-1) withObject:thumbnail];
    [[TACDataCenter sharedInstance] setMenuThumbnails:array];
    
    self.imageViews = array;
    [self.collectionView reloadData];
    
    [self writeThumbnailToFile];
}

#pragma mark UIAlertView and UIActionSheet Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == kActionSheetDelete) {
        [self processDelete:buttonIndex];
    } else {
        [self processSelect:buttonIndex];
    }
}

- (void)processSelect:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    if (buttonIndex == 0 || buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pickerPicture" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidGotten:) name:@"pickerPicture" object:nil];
    }
    switch (buttonIndex) {
        case 0:
            [self.photoSelector setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self.view addSubview:self.photoSelector];
            [self.photoSelector pickerPicture];
            break;
        case 1:
            [self.photoSelector setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self.view addSubview:self.photoSelector];
            [self.photoSelector pickerPicture];
            break;
        default:
            break;
    }
}

- (void)processDelete:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    if (self.isDeleting && buttonIndex == 0) {
        NSInteger row = [lastSelectedIndex row];
        NSMutableDictionary *dict = [self.viewsInfomation objectAtIndex:row];
        NSString *system = [dict objectForKey:@"system"];
        NSInteger ix = [system integerValue];
        //BOOL isSystem = [[[self.viewsInfomation objectAtIndex:[lastSelectedIndex row]] objectForKey:@"system"] boolValue];
        if (ix == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"不能删除厂家自带的场景" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
            [alert show];
        } else {
            [self modifyDataByDelete];
            NSArray *array = [NSArray arrayWithObject:lastSelectedIndex];
            [self.collectionView deleteItemsAtIndexPaths:array];
            [self writeThumbnailToFile];
            [self writeInformationToFile];
            [self.toggleButton setTitle:@"编辑" forState:UIControlStateNormal];
            self.isDeleting = NO;
        }
        lastSelectedIndex = nil;
    }
}

- (void)modifyDataByDelete{
    NSInteger index = [lastSelectedIndex row];
    NSMutableArray *view = [[TACDataCenter sharedInstance] viewsInformation];
    NSMutableArray *thumbnails = [[TACDataCenter sharedInstance] menuThumbnails];
    NSMutableArray *backgrounds = [[TACDataCenter sharedInstance] backgrounds];
    [view removeObjectAtIndex:index];
    [thumbnails removeObjectAtIndex:index];
    [backgrounds removeObjectAtIndex:index];
    [[TACDataCenter sharedInstance] setViewsInformation:view];
    [[TACDataCenter sharedInstance] setMenuThumbnails:thumbnails];
    [[TACDataCenter sharedInstance] setBackgrounds:backgrounds];
}

@end
