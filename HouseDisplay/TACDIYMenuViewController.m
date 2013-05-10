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
#define kHostAddress @"10.0.1.22"

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
    [self initParameter];
    [self setSaveNotification];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.backgroundImageView.image = [UIImage imageNamed:@"content_background.jpg"];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    self.isDeleting = NO;
    lastSelectedIndex = nil;
    
    [self loadInformation];
    
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
    self.thumbnails = nil;
}

- (void)initParameter{
    self.thumbnails = [[NSMutableDictionary alloc] init];
    self.backgrounds = [[NSMutableDictionary alloc] init];
    self.viewsInfomation = [[NSMutableDictionary alloc] init];
}

- (void)showLoginSuccess{
    NSString *title = @"提示";
    NSString *message = @"登陆成功";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
    [alert show];
}

- (void)setSaveNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saveData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData:) name:@"saveData" object:nil];
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
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [self.imagePaths count]; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[self.imagePaths objectAtIndex:i] ofType:@"png"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage imageWithData:data];
        NSString *index = [NSString stringWithFormat:@"%d",i];
        [dict setObject:image forKey:index];
    }
    self.thumbnails = dict;
    
    [[TACDataCenter sharedInstance] setMenuThumbnails:self.thumbnails];
    
}

#pragma mark Save and Load Methods
- (void)writeThumbnailToFile{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSData *data = nil;
    NSArray *keys = [self.thumbnails allKeys];
    for (NSString *key in keys) {
        UIImage *image = [self.thumbnails objectForKey:key];
        data = UIImagePNGRepresentation(image);
        [dict setObject:data forKey:key];
    }
    NSString *fileName = @"/thumbnail.data2";
    NSString *filePath = [self dataFilePath:fileName];
    [dict writeToFile:filePath atomically:YES];
}

- (void)writeInformationToFile{
    NSString *fileName = @"/roomInfo.data";
    NSString *filePath = [self dataFilePath:fileName];
    [self.viewsInfomation writeToFile:filePath atomically:YES];
}

- (void)writeShownProductToFile{
    NSString *fileName = @"/shownProduct.data";
    NSString *filePath = [self dataFilePath:fileName];
    NSMutableDictionary *dict = [[TACDataCenter sharedInstance] shownProduct];
    [dict writeToFile:filePath atomically:YES];
}

- (void)writeBackgroundsToFile{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSData *data = nil;
    NSArray *keys = [self.backgrounds allKeys];
    for (NSString *key in keys) {
        UIImage *image = [self.backgrounds objectForKey:key];
        data = UIImagePNGRepresentation(image);
        [dict setObject:data forKey:key];
    }
    NSString *fileName = @"/background.data";
    NSString *filePath = [self dataFilePath:fileName];
    [dict writeToFile:filePath atomically:YES];
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
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.viewsInfomation = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        [[TACDataCenter sharedInstance] setViewsInformation:self.viewsInfomation];
        [self loadThumbnail];
        [self loadBackgrounds];
        [self loadShownProduct];
        [self.collectionView reloadData];
    } else {
        [self receiveData];
    }
}

- (void)loadShownProduct{
    NSString *fileName = @"/shownProduct.data";
    NSString *filePath = [self dataFilePath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        [[TACDataCenter sharedInstance] setShownProduct:dict];
    }
}

- (void)loadBackgrounds{
    NSString *fileName = @"/background.data";
    NSString *filePath = [self dataFilePath:fileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dataArray = [[NSMutableDictionary alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        dataArray = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        NSArray *array = [dataArray allKeys];
        for (NSString *key in array) {
            NSData *data = [dataArray objectForKey:key];
            UIImage *image = [UIImage imageWithData:data];
            [dict setObject:image forKey:key];
        }
        self.backgrounds = dict;
        [[TACDataCenter sharedInstance] setBackgrounds:self.backgrounds];
    }
}

- (void)loadThumbnail{
    NSString *fileName = @"/thumbnail.data2";
    NSString *filePath = [self dataFilePath:fileName];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dataArray = [[NSMutableDictionary alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        dataArray = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        NSArray *array = [dataArray allKeys];
        for (NSString *key in array) {
            NSData *data = [dataArray objectForKey:key];
            UIImage *image = [UIImage imageWithData:data];
            [dict setObject:image forKey:key];
        }
        self.thumbnails = dict;
        [[TACDataCenter sharedInstance] setBackgrounds:self.thumbnails];
    }
}

- (void)saveData:(NSNotification *)notification{
    [self writeThumbnailToFile];
    [self writeInformationToFile];
    [self writeBackgroundsToFile];
    [self writeShownProductToFile];
}

#pragma mark Network Methods
- (void)receiveData{
    [self setHudStatus:@"正在请求数据"];
    NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/room.php",kHostAddress];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.thumbConnection = connection;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.hud.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSString *message = @"连接超时，请检查网络";
    NSString *title = @"超时";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    self.hud.hidden = YES;
    [self.collectionView reloadData];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    outString = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *str in self.jsonTempDataArray) {
        [array addObject:str];
    }
    [array addObject:outString];
    self.jsonTempDataArray = array;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *jsonStr = [[NSString alloc] init];
    for (NSString *str in self.jsonTempDataArray) {
        jsonStr = [jsonStr stringByAppendingString:str];
    }
    NSMutableArray *json = [jsonStr JSONValue];
    [self setHudFinishStatus:@"数据接受完毕" withTime:1.0];
    NSMutableDictionary *views = self.viewsInfomation;
    for (NSMutableDictionary *dict in json) {
        NSString *key = [NSString stringWithFormat:@"%d",[views count]];
        [views setObject:dict forKey:key];
    }
    self.viewsInfomation = views;
    [self.collectionView reloadData];
    [[TACDataCenter sharedInstance] setViewsInformation:self.viewsInfomation];
}

- (BOOL)analyzeData:(NSMutableArray *)data{
    NSMutableDictionary *dict = [data objectAtIndex:0];
    NSArray *array = [dict allKeys];
    for (NSString *key in array) {
        NSArray *arr = [dict objectForKey:key];
        if ([arr count] != 0) {
            return NO;
        }
    }
    return YES;
}

- (void)updateData:(NSMutableDictionary *)dict atIndex:(NSInteger)index{
    NSMutableDictionary *views = self.viewsInfomation;
    NSMutableDictionary *newDict = dict;
    NSString *system = [NSString stringWithFormat:@"%d",1];
    [newDict setObject:system forKey:@"system"];
    
    NSString *back = [dict objectForKey:@"background"];
    NSString *backStr = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,back];
    NSURL *backURL = [NSURL URLWithString:backStr];
    NSString *key = [backStr MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    UIImage *image = [[UIImage alloc] init];
    if (data) {
        image = [UIImage imageWithData:data];
    } else {
        NSData *backData = [NSData dataWithContentsOfURL:backURL];
        image = [UIImage imageWithData:backData];
        [FTWCache setObject:backData forKey:key];
    }
    NSMutableDictionary *backs = self.backgrounds;
    NSString *indexStr = [NSString stringWithFormat:@"%d",index];
    [backs setObject:image forKey:indexStr];
    
    self.backgrounds = backs;
    NSString *dictKey = [NSString stringWithFormat:@"%d",index];
    [views setObject:newDict forKey:dictKey];
    
    [[TACDataCenter sharedInstance] setBackgrounds:backs];
}

#pragma mark -
#pragma mark Hud Delegate Methods

- (void)setHudStatus:(NSString *)text{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = text;
    self.hud.dimBackground = YES;
}

- (void)setHudFinishStatus:(NSString *)text withTime:(CGFloat)time{
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = text;
	[self.hud hide:YES afterDelay:time];
}

#pragma mark Grid View Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return ([self.viewsInfomation count] + 1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(kMenuCellWidth, kMenuCellHeight);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TACDIYMenuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuViewCellIdentifier" forIndexPath:indexPath];
    if ([indexPath row] < [self.viewsInfomation count]) {
        if ([indexPath row] < [self.thumbnails count]) {
            NSString *imgkey = [NSString stringWithFormat:@"%d",[indexPath row]];
            UIImage *image = [self.thumbnails objectForKey:imgkey];
            cell.thumbnails.image = image;
        } else {
            cell.thumbnails.image = nil;
            NSString *imgkey = [NSString stringWithFormat:@"%d",[indexPath row]];
            NSMutableDictionary *dict = [self.viewsInfomation objectForKey:imgkey];
            NSString *thumb = [dict objectForKey:@"thumb"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *thumbStr = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,thumb];
                NSURL *thumbURL = [NSURL URLWithString:thumbStr];
                NSString *key = [thumbStr MD5Hash];
                NSData *data = [FTWCache objectForKey:key];
                NSString *imgkey = [NSString stringWithFormat:@"%d",[indexPath row]];
                if (data) {
                    cell.thumbnails.image = [UIImage imageWithData:data];
                    NSMutableDictionary *thumbs = self.thumbnails;
                    [thumbs setObject:cell.thumbnails.image forKey:imgkey];
                    self.thumbnails = thumbs;
                    [[TACDataCenter sharedInstance] setMenuThumbnails:thumbs];
                } else {
                    NSData *thumbData = [NSData dataWithContentsOfURL:thumbURL];
                    [FTWCache setObject:thumbData forKey:key];
                    UIImage *thumbImage = [UIImage imageWithData:thumbData];
                    if (thumbImage != nil) {
                        NSMutableDictionary *thumbs = self.thumbnails;
                        [thumbs setObject:thumbImage forKey:imgkey];
                        self.thumbnails = thumbs;
                        [[TACDataCenter sharedInstance] setMenuThumbnails:thumbs];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.thumbnails.image = thumbImage;
                        });
                    }
                }
                [self updateData:dict atIndex:[indexPath row]];
            });
        }
    } else {
        cell.thumbnails.image = [UIImage imageNamed:@"addMark.png"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isDeleting) {
        NSLog(@"%d%d",[indexPath row],[self.thumbnails count]);
        if ([indexPath row] < [self.thumbnails count]) {
            [self deleteItem:indexPath];
        }
    } else {
        [self performSelection:indexPath];
    }
}

#pragma mark Edit Methods

- (void)performSelection:(NSIndexPath *)indexPath{
    if ([indexPath row] < [self.viewsInfomation
                           count]) {
        self.DIYViewController = [[TACDIYViewController alloc] initWithNibName:@"TACDIYViewController" bundle:nil];
        NSString *imgkey = [NSString stringWithFormat:@"%d",[indexPath row]];
        NSMutableDictionary *dict = [self.viewsInfomation objectForKey:imgkey];
        [self.DIYViewController setViewInfomation:dict];
        
        NSInteger tag = [indexPath row];
        [self.DIYViewController setViewTag:tag + 1];
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
    
    NSMutableDictionary *backgrounds = self.backgrounds;
    NSString *backKey = [NSString stringWithFormat:@"%d",[self.backgrounds count]];
    [backgrounds setObject:background forKey:backKey];
    [[TACDataCenter sharedInstance] setBackgrounds:backgrounds];
        
    NSMutableDictionary *thumbArray = self.thumbnails;
    NSString *thumbKey = [NSString stringWithFormat:@"%d",[self.thumbnails count]];
    [thumbArray setObject:coverImage forKey:thumbKey];
    [[TACDataCenter sharedInstance] setMenuThumbnails:thumbArray];
    
    NSMutableDictionary *viewsInfo = self.viewsInfomation;
    [dict removeObjectForKey:@"image"];
    [dict removeObjectForKey:@"indexpath"];
    [dict removeObjectForKey:@"coverImage"];
    NSString *viewsKey = [NSString stringWithFormat:@"%d",[indexPath row]];
    [viewsInfo setObject:dict forKey:viewsKey];
    [[TACDataCenter sharedInstance] setViewsInformation:viewsInfo];
    
    self.viewsInfomation = viewsInfo;
    self.thumbnails = thumbArray;
    self.backgrounds = backgrounds;
    
    NSArray *array = [NSArray arrayWithObjects:indexPath,nil];
    [self.collectionView insertItemsAtIndexPaths:array];
    [self.collectionView reloadData];
    
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
    
    NSMutableDictionary *thumbs = [[TACDataCenter sharedInstance] menuThumbnails];
    NSString *key = [NSString stringWithFormat:@"%d",tag-1];
    [thumbs setObject:thumbnail forKey:key];
    [[TACDataCenter sharedInstance] setMenuThumbnails:thumbs];
    
    self.thumbnails = thumbs;
    [self.collectionView reloadData];
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
    if (self.isDeleting && buttonIndex == 0) {
        NSInteger row = [lastSelectedIndex row];
        NSString *key = [NSString stringWithFormat:@"%d",row];
        NSMutableDictionary *dict = [self.viewsInfomation objectForKey:key];
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
    NSString *key = [NSString stringWithFormat:@"%d",index];
    NSMutableDictionary *view = [[TACDataCenter sharedInstance] viewsInformation];
    NSMutableDictionary *thumbnails = [[TACDataCenter sharedInstance] menuThumbnails];
    NSMutableDictionary *backgrounds = [[TACDataCenter sharedInstance] backgrounds];
    [view removeObjectForKey:key];
    [thumbnails removeObjectForKey:key];
    [backgrounds removeObjectForKey:key];
    [[TACDataCenter sharedInstance] setViewsInformation:view];
    [[TACDataCenter sharedInstance] setMenuThumbnails:thumbnails];
    [[TACDataCenter sharedInstance] setBackgrounds:backgrounds];
}

@end
