//
//  TACDIYViewController.m
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYViewController.h"


#define kItemWidth 110
#define kDoor @"door"
#define kGlass @"glass"
#define kDisplay @"display"
#define kSelect @"select"
#define kHostAddress @"10.0.1.22"
#define currentState @"door"


@interface TACDIYViewController ()

@end

@implementation TACDIYViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark-
#pragma mark View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initParameter];
    [self showBackgroundImage];
    [self loadViewInfo];
    [self receiveData];
    
    self.coverFlow.type = iCarouselTypeLinear;
    [self.coverFlow reloadData];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mainImageView = nil;
    self.imageData = nil;
    self.jsonTempDataArray = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnButtonPressed:(id)sender {
    [self returnSuperView];
}


- (IBAction)menuButtonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"用户选项"]) {
        if (self.dropDown == nil) {
            lastDropIndex = -1;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dropDown" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropDownCellSelected:) name:@"dropDown" object:nil];
            self.dropDown = [[NIDropDown alloc] init];
            CGFloat height = 240;
            [self.dropDown showDropDown:sender withHeight:height usingArray:self.dropDownMenu];
            self.dropDown.delegate = self;
        } else {
            [self.dropDown hideDropDown:sender];
            self.dropDown = nil;
        }
    } else {
        [self reDrawDidFinish];
        [button setTitle:@"用户选项" forState:UIControlStateNormal];                                      
    }
}

#pragma mark-
#pragma mark Custom Methods

- (void)initParameter{
    self.isInCell = NO;
    self.firstLogin = YES;
    self.isEditing = NO;
    self.jsonTempDataArray = [[NSMutableArray alloc] init];
    self.dropDownMenu = @[@"设为封面",@"选择产品系列",@"重新框选区域",@"进入编辑模式",@"搜索产品",@"刷新数据"];
}


- (void)clearData{
    self.jsonTempDataArray = nil;
    self.jsonTempDataArray = [[NSMutableArray alloc] init];
}

- (void)loadViewInfo{
    NSInteger doorDisWidth,doorDisHeight;
    NSInteger doorPosX,doorPosY;
    doorDisWidth = [[self.viewInfomation objectForKey:@"displayDoorWidth"] integerValue];
    doorDisHeight = [[self.viewInfomation objectForKey:@"displayDoorHeight"] integerValue];
    doorPosX = [[self.viewInfomation objectForKey:@"doorPosX"] integerValue];
    doorPosY = [[self.viewInfomation objectForKey:@"doorPosY"] integerValue];
    doorPicRect = CGRectMake(doorPosX, doorPosY, doorDisWidth, doorDisHeight);
}

- (void)showBackgroundImage{
    
    self.mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1000, 600)];
    self.frontImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1000, 600)];
    
    NSMutableArray *array = [[TACDataCenter sharedInstance] backgrounds];
    UIImage *image = [array objectAtIndex:(self.viewTag - 1)];
    self.mainImageView.image = image;
    
    [self.view insertSubview:self.mainImageView atIndex:1];
    
}

- (void)receiveData{

    NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/fetch_images.php?background=%d&category=%@",kHostAddress,self.viewTag,currentState];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    NSString *text = @"正在请求数据";
    [self setHudStatus:text];
    
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

- (void)initScene{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [self requestImageForType:currentState ForUse:kDisplay AtIndex:0];
        //show picture in mainImageView
        [self.displayDoorImageView removeFromSuperview];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:doorPicRect];
            imageView.image = image;
            self.displayDoorImageView = imageView;
            [self.view insertSubview:self.displayDoorImageView atIndex:2];
        });
    });
}

- (void)returnSuperView{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeBackwards;
    animation.removedOnCompletion = NO;
    animation.type = @"rippleEffect";
    [self.view.superview.layer addAnimation:animation forKey:@"animationBack"];
    //[self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [self.view removeFromSuperview];
}

- (void)prepareForRequestData:(NSInteger)index{
    if (self.isEditing) {
        return;
    } else {
        NSString *dataUrl = [[[self.imageData objectForKey:currentState] objectForKey:kDisplay] objectAtIndex:index];
        NSString *url = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,dataUrl];
        NSString *key = [url MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [[UIImage alloc] init];
            if (data) {
                image = [UIImage imageWithData:data];
            } else {
                [self setHudStatus:@"正在加载"];
                image = [self requestImageForType:currentState ForUse:kDisplay AtIndex:index];
            }
            [self.displayDoorImageView removeFromSuperview];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:doorPicRect];
                imageView.image = image;
                [self setHudFinishStatus:@"加载完毕" withTime:0.2];
                
                self.displayDoorImageView = imageView;
                [self.view insertSubview:self.displayDoorImageView atIndex:2];
            });
        });
    }
}

- (UIImage *)requestImageForType:(NSString *)type ForUse:(NSString *)usage AtIndex:(NSInteger)index{
    //request image
    NSMutableDictionary *dict = [self.imageData objectForKey:type];
    NSArray *array = [dict objectForKey:usage];
    NSString *dataUrl = [array objectAtIndex:index];
    NSString *url = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,dataUrl];
    NSString *key = [url MD5Hash];
    NSURL *imaUrl = [NSURL URLWithString:url];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.tag = index;
    NSData *data = [FTWCache objectForKey:key];
    UIImage *image = [[UIImage alloc] init];
    if (data != nil) {
        image = [UIImage imageWithData:data];
    } else {
        data = [NSData dataWithContentsOfURL:imaUrl];
        image = [UIImage imageWithData:data];
        [FTWCache setObject:data forKey:key];
    }
    return image;
}

- (void)setCover{

    self.returnButton.hidden = YES;
    self.setCoverButton.hidden = YES;
    
    UIGraphicsBeginImageContext(self.view.bounds.size);     
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();

    CGRect rect = CGRectMake(0, 0, 1000, 600);
    CGRect newRect = CGRectMake(0, 0, 313, 163);
    UIImageView *imgPrint = [[UIImageView alloc] initWithFrame:rect];
    UIImageView *newimg = [[UIImageView alloc] initWithFrame:newRect];
    imgPrint.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([viewImage CGImage], rect)];
    newimg.image = imgPrint.image;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:newimg.image forKey:@"thumbnail"];
    [dict setObject:[NSString stringWithFormat:@"%d",self.viewTag] forKey:@"tag"];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeThumb" object:dict];
    
    self.returnButton.hidden = NO;
    self.setCoverButton.hidden = NO;
      
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = @"成功设为封面";
	[self.hud hide:YES afterDelay:1];
}

- (void)toggleEdit{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.dropDownMenu];
    if (!self.isEditing) {
        [array replaceObjectAtIndex:3 withObject:@"完成编辑"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:@"已进入编辑模式，将图片拖出屏幕下方可删除图片" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alert show];
    } else {
        [array replaceObjectAtIndex:3 withObject:@"进入编辑模式"];
        
    }
    [self setIsEditing:!self.isEditing];
    self.dropDownMenu = array;
}

- (void)deleteProduct:(NSInteger)index{
    NSMutableDictionary *dict = self.imageData;
    NSMutableDictionary *imgDict = [dict objectForKey:currentState];
    
    NSMutableArray *array = [imgDict objectForKey:kSelect];
    [array removeObjectAtIndex:index];
    [imgDict setObject:array forKey:kSelect];

    array = [imgDict objectForKey:kDisplay];
    [array removeObjectAtIndex:index];
    [imgDict setObject:array forKey:kDisplay];
    
    [dict setObject:imgDict forKey:currentState];
    
    self.imageData = dict;
    
    [self.coverFlow removeItemAtIndex:index animated:YES];
    //[self.coverFlow remo]
}

- (BOOL)analyzeData:(NSMutableDictionary *)dict{
    NSArray *array = [dict allKeys];
    for (NSString *key in array) {
        NSArray *data = [dict objectForKey:key];
        if ([data count] != 0) {
            return NO;
        }
    }
    return YES;
}

- (void)reDraw{
    [self.setCoverButton setTitle:@"完成" forState:UIControlStateNormal];
    
    self.mainImageView.userInteractionEnabled = YES;
    CGRect gripFrame = doorPicRect;
    SPUserResizableView *resizableView = [[SPUserResizableView alloc] initWithFrame:gripFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:gripFrame];
    [contentView setBackgroundColor:[UIColor clearColor]];
    resizableView.contentView = contentView;
    resizableView.delegate = self;
    [resizableView showEditingHandles];
    self.currentResizableView = resizableView;
    self.lastResizableView = resizableView;
    [self.mainImageView addSubview:resizableView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles)];
    [gestureRecognizer setDelegate:self];
    [self.mainImageView addGestureRecognizer:gestureRecognizer];
}

- (void)reDrawDidFinish{
    self.mainImageView.userInteractionEnabled = NO;
    doorPicRect = CGRectMake(self.lastResizableView.frame.origin.x, self.lastResizableView.frame.origin.y, self.lastResizableView.bounds.size.width, self.lastResizableView.bounds.size.height);
    NSString *x = [NSString stringWithFormat:@"%f",self.lastResizableView.frame.origin.x];
    NSString *y = [NSString stringWithFormat:@"%f",self.lastResizableView.frame.origin.y];
    NSString *w = [NSString stringWithFormat:@"%f",self.lastResizableView.bounds.size.width];
    NSString *h = [NSString stringWithFormat:@"%f",self.lastResizableView.bounds.size.height];
    NSMutableDictionary *dict = self.viewInfomation;
    [dict setObject:x forKey:@"doorPosX"];
    [dict setObject:y forKey:@"doorPosY"];
    [dict setObject:w forKey:@"displayDoorWidth"];
    [dict setObject:h forKey:@"displayDoorHeight"];
    [self.currentResizableView removeFromSuperview];
    [self.lastResizableView removeFromSuperview];
    self.lastResizableView = nil;
    self.currentResizableView = nil;
}

#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.hud.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
	outString = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *str in self.jsonTempDataArray) {
        [array addObject:str];
    }
    [array addObject:outString];
    self.jsonTempDataArray = array;
}

-(void) connection:(NSURLConnection *)connection
  didFailWithError: (NSError *)error {
    NSString *message = @"连接超时，请检查网络";
    NSString *title = @"超时";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    self.hud.hidden = YES;
    [self.coverFlow reloadData];
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *jsonStr = [[NSString alloc] init];
    for (NSString *str in self.jsonTempDataArray) {
        jsonStr = [jsonStr stringByAppendingString:str];
    }
    NSMutableDictionary *json = [jsonStr JSONValue];
    BOOL isDataEmpty = [self analyzeData:json];
    if (isDataEmpty) {
        return;
    }
    NSArray *keys = [json allKeys];
    for (NSString *key in keys) {
        NSArray *images = [json objectForKey:key];
        [dict setObject:images forKey:key];
    }
    [data setObject:dict forKey:currentState];
    self.imageData = data;
    NSData *cacheData = [self.imageData toJSON];
    
    NSString *cacheName = currentState;
    cacheName = [cacheName stringByAppendingFormat:@"%d",self.viewTag];
    NSString *cacheKey = [cacheName MD5Hash];
    [FTWCache setObject:cacheData forKey:cacheKey];
    
    [self.coverFlow reloadData];
    if (self.firstLogin) {
        [self initScene];
        self.firstLogin = NO;
    }
    [self setHudFinishStatus:@"数据读取完毕" withTime:2.0];
}

#pragma mark Cover View Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    NSMutableDictionary *dict = [self.imageData objectForKey:currentState];
    NSArray *data = [dict objectForKey:kSelect];
    return [data count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel{
    NSMutableDictionary *dict = [self.imageData objectForKey:currentState];
    NSArray *data = [dict objectForKey:kSelect];
    return [data count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    //init view
    UIImageView *imageView = nil;
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 130)];
        imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.hidden = NO;
        [view addSubview:imageView];
    } else {
        imageView = [[view subviews] lastObject];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [[UIImage alloc] init];
        image = [self requestImageForType:currentState ForUse:kSelect AtIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
    
    //save cache
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    [self prepareForRequestData:index];
}

- (void)carousel:(iCarousel *)carousel didSwipeItemAtIndex:(NSInteger)index{
    if (self.isEditing) {
        [self deleteProduct:index];
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel{
    return kItemWidth;
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

#pragma mark Dropdown Methods
- (void)niDropDownDelegateMethod:(NIDropDown *)sender{
    self.dropDown = nil;
}

- (void)dropDownCellSelected:(NSNotification *)notification{
    NSInteger index = [[notification object] integerValue];
    if (index == lastDropIndex) {
        return;
    } else {
        lastDropIndex = index;
    }
    NSString *cell = [self.dropDownMenu objectAtIndex:index];
    for (int i = 0;i < [self.dropDownMenu count];i++){
        NSString *opt = [self.dropDownMenu objectAtIndex:i];
        if ([cell isEqualToString:opt]) {
            index = i;
            break;
        }
    }
    switch (index) {
        case 0:
            [self setCover];
            break;
        case 1:
            //[self chooseSeries];
            break;
        case 2:
            [self reDraw];
            break;
        case 3:
            [self toggleEdit];
            break;
        case 4:
            //[self searchProduct];
            break;
        case 5:
            self.jsonTempDataArray = nil;
            self.imageData = nil;
            [self receiveData];
            break;
        default:
            break;
    }
}

@end
