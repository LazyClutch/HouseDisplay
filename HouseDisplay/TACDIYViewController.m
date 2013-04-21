//
//  TACDIYViewController.m
//  HouseDisplay
//
//  Created by lazy on 13-4-2.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYViewController.h"
#import "ReflectionView.h"
#import "JSON.h"

#define kItemWidth 110
#define kDoor @"door"
#define kGlass @"glass"
#define kDisplay @"display"
#define kSelect @"select"
#define kHostAddress @"10.0.1.10"


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
    
    self.firstLogin = YES;
    self.jsonTempDataArray = [[NSMutableArray alloc] init];
    //[self setImageRequestQueue];
    [self showBackgroundImage];
    [self loadViewInfo];
    [self loadCacheData];
    
    self.coverFlow.type = iCarouselTypeLinear;
    [self.coverFlow reloadData];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mainImageView = nil;
    self.imageData = nil;
    self.originalIndexArray = nil;
    self.jsonTempDataArray = nil;
    self.originalOperationDic = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnButtonPressed:(id)sender {
    [self returnSuperView];
}

- (IBAction)doorButtonPressed:(id)sender {
    if ([currentState isEqual:kDoor]) {
        return;
    }
    currentState = kDoor;
    [self clearData];
    [self loadCacheData];
}

- (IBAction)glassButtonPressed:(id)sender {
    if ([currentState isEqual:kGlass]) {
        return;
    }
    currentState = kGlass;
    [self clearData];
    [self loadCacheData];
}

#pragma mark-
#pragma mark Custom Methods

- (void)loadCacheData{
    NSString *cacheName = [NSString stringWithString:currentState];
    cacheName = [cacheName stringByAppendingFormat:@"%d",self.viewTag];
    NSString *cacheKey = [cacheName MD5Hash];
    NSData *data = [FTWCache objectForKey:cacheKey];
    NSString *dataStr = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    NSMutableDictionary *dict = [dataStr JSONValue];
    if (dict) {
        self.imageData = dict;
        [self.coverFlow reloadData];
        if (self.firstLogin) {
            [self initScene];
            self.firstLogin = NO;
        }
    } else {
        [self receiveData];
    }
}

- (void)clearData{
    self.jsonTempDataArray = nil;
    self.jsonTempDataArray = [[NSMutableArray alloc] init];
    self.originalOperationDic = nil;
    self.originalIndexArray = nil;
}

- (void)loadViewInfo{
    NSInteger doorDisWidth,doorDisHeight,glassDicWidth,glassDicHeight;
    NSInteger doorPosX,doorPosY,glassPosX,glassPosY;
    doorDisWidth = [[self.viewInfomation objectForKey:@"displayDoorWidth"] integerValue];
    doorDisHeight = [[self.viewInfomation objectForKey:@"displayDoorHeight"] integerValue];
    doorPosX = [[self.viewInfomation objectForKey:@"doorPosX"] integerValue];
    doorPosY = [[self.viewInfomation objectForKey:@"doorPosY"] integerValue];
    if ([[self.viewInfomation allKeys] count] >= 7) {     //glass & door
        glassDicHeight = [[self.viewInfomation objectForKey:@"displayGlassHeight"] integerValue];
        glassDicWidth = [[self.viewInfomation objectForKey:@"displayGlassWidth"] integerValue];
        glassPosX = [[self.viewInfomation objectForKey:@"glassPosX"] integerValue];
        glassPosY = [[self.viewInfomation objectForKey:@"glassPosY"] integerValue];
        glasspicRect = CGRectMake(glassPosX, glassPosY, glassDicWidth, glassDicHeight);

    }
    doorPicRect = CGRectMake(doorPosX, doorPosY, doorDisWidth, doorDisHeight);
}

- (void)receiveData{
    
    self.doorButton.enabled = NO;
    self.glassButton.enabled = NO;
    NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/fetch_images.php?background=%d&category=%@",kHostAddress,self.viewTag,currentState];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    [self setHudStatus];
    
}

- (void)setHudStatus{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"正在请求数据";
    self.hud.dimBackground = YES;
    //[self.hud showWhileExecuting:@selector(receiveData) onTarget:self withObject:nil animated:YES];
    //[self.hud showWhileExecuting:@selector(requestImageForType:ForUse:AtIndex:) onTarget:self withObject:nil animated:YES];
}

- (void)initScene{
    UIImage *image = [self requestImageForType:currentState ForUse:kDisplay AtIndex:0];
    //show picture in mainImageView
    [self.displayDoorImageView removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:doorPicRect];
    imageView.image = image;
    self.displayDoorImageView = imageView;
    [self.view insertSubview:self.displayDoorImageView atIndex:2];
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

- (void)showBackgroundImage{
    
    currentState = kDoor;
    self.mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1000, 600)];
    self.frontImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1000, 600)];

    NSString *name = [self.viewInfomation objectForKey:@"background"];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    self.mainImageView.image = image;
    
    [self.view insertSubview:self.mainImageView atIndex:1];
    
    if (self.viewTag == 1) {
        name = [self.viewInfomation objectForKey:@"front"];
        imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        UIImage *imageFront = [UIImage imageWithContentsOfFile:imagePath];
        self.frontImageView.image = imageFront;
        [self.view insertSubview:self.frontImageView atIndex:4];
    } else if (self.viewTag >= 4){
        self.glassButton.hidden = YES;
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
    NSString *indexForString = [NSString stringWithFormat:@"%d",index];
    if ([self.originalIndexArray containsObject:indexForString]) {
        return nil;
    }
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

- (void)setImageRequestQueue{
    NSOperationQueue *tmpQueue = [[NSOperationQueue alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    self.requestImageQueue = tmpQueue;
    self.originalIndexArray = array;
    self.originalOperationDic = dict;
}

- (void)imageDidReceive:(UIImageView *)imageView{
    [self.originalIndexArray addObject:[NSString stringWithFormat:@"%d",imageView.tag]];
    [self.originalOperationDic removeObjectForKey:[NSString stringWithFormat:@"%d",imageView.tag]];
}

- (IBAction)setCoverButtonPressed:(id)sender {
    self.returnButton.hidden = YES;
    self.setCoverButton.hidden = YES;
    self.doorButton.hidden = YES;
    self.glassButton.hidden = YES;
    
    UIGraphicsBeginImageContext(self.view.bounds.size);     
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();

    CGRect rect = CGRectMake(0, 0, 1000, 600);
    CGRect newRect = CGRectMake(0, 0, 313, 163);
    UIImageView *imgPrint = [[UIImageView alloc] initWithFrame:rect];
    UIImageView *newimg = [[UIImageView alloc] initWithFrame:newRect];
    imgPrint.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([viewImage CGImage], rect)];
    newimg.image = imgPrint.image;
    NSMutableArray *array = [[TACDataCenter sharedInstance] menuThumbnails];
    [array replaceObjectAtIndex:(self.viewTag-1) withObject:newimg.image];
    [[TACDataCenter sharedInstance] setMenuThumbnails:array];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeThumb" object:nil];
    
    self.returnButton.hidden = NO;
    self.setCoverButton.hidden = NO;
    self.doorButton.hidden = NO;
    self.glassButton.hidden = NO;
}

#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.hud.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
	outString = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    //NSLog(@"%@",outString);
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
    self.doorButton.enabled = YES;
    self.glassButton.enabled = YES;
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    self.doorButton.enabled = YES;
    self.glassButton.enabled = YES;
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = @"数据读取完毕";
	[self.hud hide:YES afterDelay:2];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *jsonStr = [[NSString alloc] init];
    for (NSString *str in self.jsonTempDataArray) {
        jsonStr = [jsonStr stringByAppendingString:str];
    }
    //NSLog(@"%@",jsonStr);
    NSMutableDictionary *json = [jsonStr JSONValue];
    NSArray *keys = [json allKeys];
    for (NSString *key in keys) {
        NSArray *images = [json objectForKey:key];
        [dict setObject:images forKey:key];
    }
    [data setObject:dict forKey:currentState];
    self.imageData = data;
    NSData *cacheData = [self.imageData toJSON];
    
    NSString *cacheName = [NSString stringWithString:currentState];
    cacheName = [cacheName stringByAppendingFormat:@"%d",self.viewTag];
    NSString *cacheKey = [cacheName MD5Hash];
    [FTWCache setObject:cacheData forKey:cacheKey];
    
    [self.coverFlow reloadData];
    if (self.firstLogin) {
        [self initScene];
        self.firstLogin = NO;
    }
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
    
    imageView.image = [self requestImageForType:currentState ForUse:kSelect AtIndex:index];
    
    //save cache
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    
    NSString *dataUrl = [[[self.imageData objectForKey:currentState] objectForKey:kDisplay] objectAtIndex:index];
    NSString *url = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,dataUrl];
    NSString *key = [url MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    UIImage *image = [[UIImage alloc] init];
    
    if (data) {
        image = [UIImage imageWithData:data];
    } else {
        image = [self requestImageForType:currentState ForUse:kDisplay AtIndex:index];
    }
        
    if ([currentState isEqual: kDoor]) {
        [self.displayDoorImageView removeFromSuperview];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:doorPicRect];
        imageView.image = image;
        self.displayDoorImageView = imageView;
        [self.view insertSubview:self.displayDoorImageView atIndex:2];

    } else{
        [self.displayGlassImageView removeFromSuperview];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:glasspicRect];
        imageView.image = image;
        self.displayGlassImageView = imageView;
        [self.view insertSubview:self.displayGlassImageView atIndex:3];

    }    
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel{
    return kItemWidth;
}



@end
