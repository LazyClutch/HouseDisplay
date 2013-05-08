//
//  TACDIYViewController.m
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYViewController.h"
#import "TACSeriesSelectController.h"


#define kItemWidth 110
#define kDoor @"door"
#define kGlass @"glass"
#define kDisplay @"display"
#define kSelect @"select"
#define kHostAddress @"10.0.1.22"
#define currentState @"door"
#define DEFAULT_RECT CGRectMake(100,100,250,250)


@interface TACDIYViewController ()

@property (strong, nonatomic) TACSeriesSelectController *seriesController;

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
    [self loadCatalog];
    
    self.coverFlow.type = iCarouselTypeLinear;
    [self.coverFlow reloadData];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mainImageView = nil;
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
    self.shownProduct = [[NSMutableArray alloc] init];
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
    if (doorDisHeight == 0 && doorDisWidth == 0 && doorPosX == 0 && doorPosY == 0) {
        doorPicRect = DEFAULT_RECT;
    } else {
        doorPicRect = CGRectMake(doorPosX, doorPosY, doorDisWidth, doorDisHeight);
    }
}

- (void)showBackgroundImage{
    
    self.mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1000, 600)];
    self.frontImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1000, 600)];
    
    NSMutableDictionary *dict = [[TACDataCenter sharedInstance] backgrounds];
    NSString *key = [NSString stringWithFormat:@"%d",self.viewTag - 1];
    UIImage *image = [dict objectForKey:key];
    self.mainImageView.image = image;
    
    [self.view insertSubview:self.mainImageView atIndex:1];
    
}

- (void)loadCatalog{
    NSMutableDictionary *dict = [[TACDataCenter sharedInstance] shownProduct];
    NSString *key = [NSString stringWithFormat:@"%d",self.viewTag - 1];
    self.shownProduct = [dict objectForKey:key];
    NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/catalog.php?room_id=%d",kHostAddress,self.viewTag];
    NSLog(@"%@",requestURL);
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.catalogConnection = connection;
    NSString *text = @"正在请求数据";
    [self setHudStatus:text];

}

- (void)loadProduct{
    for (NSMutableDictionary *dict in self.catalogs) {
        NSString *number = [[dict objectForKey:@"number"] URLEncodedString];
        NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/product.php?catalog_number=%@",kHostAddress,number];
        NSURL *url = [NSURL URLWithString:requestURL];
        NSLog(@"%@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
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
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIImage *image = [self requestImageForType:currentState ForUse:kDisplay AtIndex:0];
//        //show picture in mainImageView
//        [self.displayDoorImageView removeFromSuperview];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:doorPicRect];
//            imageView.image = image;
//            self.displayDoorImageView = imageView;
//            [self.view insertSubview:self.displayDoorImageView atIndex:2];
//        });
//    });
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

- (void)updateDataCenter:(NSMutableArray *)array{
    NSMutableDictionary *dict = [[TACDataCenter sharedInstance] shownProduct];
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    NSString *key = [NSString stringWithFormat:@"%d",self.viewTag - 1];
    [dict setObject:array forKey:key];
    [[TACDataCenter sharedInstance] setShownProduct:dict];
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

- (void)chooseSeries{
    self.seriesController = [[TACSeriesSelectController alloc] init];
    [self.seriesController setRoomCatalog:self.catalogs];
    [self.view addSubview:self.seriesController.view];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"chooseSeries" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seriesDisChosen:) name:@"chooseSeries" object:nil];
}

- (void)deleteProduct:(NSInteger)index{
    NSMutableArray *dict = self.shownProduct;
    [dict removeObjectAtIndex:index];
    
    self.shownProduct = dict;
    [self updateDataCenter:self.shownProduct];
    [self.coverFlow removeItemAtIndex:index animated:YES];
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
    resizableView.contentView = self.displayDoorImageView;
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
    UIImage *image = self.displayDoorImageView.image;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:doorPicRect];
    self.displayDoorImageView = imageView;
    self.displayDoorImageView.image = image;
    [self.view insertSubview:self.displayDoorImageView atIndex:2];
    [self.currentResizableView removeFromSuperview];
    [self.lastResizableView removeFromSuperview];
    self.lastResizableView = nil;
    self.currentResizableView = nil;
}

- (void)seriesDisChosen:(NSNotification *)notification{
    NSMutableArray *array = (NSMutableArray *)[notification object];
    NSMutableArray *combineArray = self.catalogs;
    for (NSMutableDictionary *dict in array) {
        [combineArray addObject:dict];
    }
    [self loadProduct];
}

#pragma mark Load Image Methods

- (void)loadImageAtIndex:(NSInteger)index{
    if (self.isEditing) {
        return;
    } else {
        NSString *dataUrl = [[self.shownProduct objectAtIndex:index] objectForKey:@"origion"];
        NSString *url = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,dataUrl];
        NSString *key = [url MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [[UIImage alloc] init];
            if (data) {
                image = [UIImage imageWithData:data];
            } else {
                [self setHudStatus:@"正在加载"];
                NSURL *imgUrl = [NSURL URLWithString:url];
                NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
                [FTWCache setObject:imgData forKey:key];
                image = [UIImage imageWithData:imgData];
                //image = [self requestImageForType:currentState ForUse:kDisplay AtIndex:index];
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

- (void)requestImageAtIndex:(NSInteger)index forView:(UIImageView *)imageView{
    NSMutableArray *products = self.shownProduct;
    NSMutableDictionary *dict = [self.shownProduct objectAtIndex:index];
    NSString *photo_id = [dict objectForKey:@"photo_id"];
    NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/photo.php?id=%@",kHostAddress,photo_id];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.productConnection = connection;
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *array = (NSArray *)JSON;
        if ([array count] >= 1) {
            NSMutableDictionary *arrayInfo = (NSMutableDictionary *)[array objectAtIndex:0];
            [dict addEntriesFromDictionary:arrayInfo];
            [products replaceObjectAtIndex:index withObject:dict];
            NSString *thumb = [arrayInfo objectForKey:@"thumb"];
            NSString *thumbUrl = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,thumb];
            NSString *key = [thumbUrl MD5Hash];
            NSURL *url = [NSURL URLWithString:thumbUrl];
            NSData *data = [FTWCache objectForKey:key];
            if (data) {
                imageView.image = [UIImage imageWithData:data];
            } else {
                NSData *imgData = [NSData dataWithContentsOfURL:url];
                UIImage *img = [UIImage imageWithData:imgData];
                [FTWCache setObject:imgData forKey:key];
                imageView.image = img;
            }
        }
    } failure:nil];
    [operation start];
}


#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.hud.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
        outString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
    if (connection == self.catalogConnection) {
        [self catalogDidLoad];
    } else if(connection == self.productConnection){
        NSString *jsonStr = [[NSString alloc] init];
        for (NSString *str in self.jsonTempDataArray) {
            jsonStr = [jsonStr stringByAppendingString:str];
        }
        self.jsonTempDataArray = nil;
        NSMutableArray *json = [jsonStr JSONValue];
    } else {
        NSString *jsonStr = [[NSString alloc] init];
        for (NSString *str in self.jsonTempDataArray) {
            jsonStr = [jsonStr stringByAppendingString:str];
        }
        self.jsonTempDataArray = nil;
        NSMutableArray *json = [jsonStr JSONValue];
        NSMutableArray *allPro = self.shownProduct;
        if (!allPro) {
            allPro = [[NSMutableArray alloc] init];
        }
        for (NSMutableDictionary *dict in json) {
            [allPro addObject:dict];
        }
        self.shownProduct = allPro;
        
        [self updateDataCenter:self.shownProduct];
        [self.coverFlow reloadData];
    }
    [self setHudFinishStatus:@"数据读取完毕" withTime:1.0];
}

- (void)catalogDidLoad{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *jsonStr = [[NSString alloc] init];
    for (NSString *str in self.jsonTempDataArray) {
        jsonStr = [jsonStr stringByAppendingString:str];
    }
    self.jsonTempDataArray = nil;
    NSMutableArray *json = [jsonStr JSONValue];
    for (NSMutableDictionary *dict in json) {
        NSString *name = [NSString stringWithUTF8String:[[dict objectForKey:@"name"] UTF8String]];
        NSString *number = [NSString stringWithUTF8String:[[dict objectForKey:@"number"] UTF8String]];
        [dict setObject:name forKey:@"name"];
        [dict setObject:number forKey:@"number"];
        [array addObject:dict];
    }
    self.catalogs = array;
    if (self.firstLogin) {
        [self initScene];
        self.firstLogin = NO;
    }
    [self loadProduct];
}

#pragma mark Cover View Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.shownProduct count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel{
    return 15;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    //init view
    UIImageView *imageView = nil;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 130)];
        imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.hidden = NO;
        [view addSubview:imageView];
        [view addSubview:indicator];
    } else {
        imageView = [[view subviews] lastObject];
    }
    
    [indicator setBounds:view.bounds];
    [indicator setHidesWhenStopped:YES];
    [indicator startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self requestImageAtIndex:index forView:imageView];
    });
    [indicator stopAnimating];
    //save cache
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    [self loadImageAtIndex:index];
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
            [self chooseSeries];
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
            [self loadCatalog];
            break;
        default:
            break;
    }
}

@end
