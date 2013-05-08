//
//  TACSeriesSelectController.m
//  HouseDisplay
//
//  Created by lazy on 13-5-6.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACSeriesSelectController.h"
#import "TACSeriesSelectCell.h"

#define kHostAddress @"10.0.1.22"
#define kMenuCellWidth  313
#define kMenuCellHeight 163


@interface TACSeriesSelectController ()

@end

@implementation TACSeriesSelectController

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
    self.seriesInfo = [[NSMutableArray alloc] init];
    self.seriesDetails = [[NSMutableArray alloc] init];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[TACSeriesSelectCell class] forCellWithReuseIdentifier:@"SeriesViewCellIdentifier"];
    self.isSelecting = NO;
    [self loadSeries];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)editButtonPressed:(id)sender {
    if (self.isSelecting) {
        [self.editButton setTitle:@"选择系列" forState:UIControlStateNormal];
        self.collectionView.allowsMultipleSelection = NO;
        NSArray *array = self.collectionView.indexPathsForSelectedItems;
        NSMutableArray *chosenCata = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in array) {
            NSMutableDictionary *dict = [self.seriesInfo objectAtIndex:[indexPath row]];
            [chosenCata addObject:dict];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"chooseSeries" object:chosenCata];
        [self.view removeFromSuperview];
    } else {
        [self.editButton setTitle:@"完成选择" forState:UIControlStateNormal];
        self.collectionView.allowsMultipleSelection = YES;
    }
    [self setIsSelecting:!self.isSelecting];
}

- (void)loadSeries{
    [self setHudStatus:@"正在请求数据"];
    NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/catalog.php?room_id=0",kHostAddress];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.seriesConnection = connection;
}

- (void)loadProduct{
    for (NSMutableDictionary *dict in self.seriesInfo) {
        NSString *number = [dict objectForKey:@"number"];
        NSString *name = [number URLEncodedString];
        for (NSMutableDictionary *catalog in self.roomCatalog) {
            NSString *cataName = [catalog objectForKey:@"number"];
            if (![number isEqualToString:cataName]) {
                NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/product.php?catalog_number=%@",kHostAddress,name];
                NSLog(@"%@",requestURL);
                NSURL *url = [NSURL URLWithString:requestURL];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4];
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            }
        }
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

- (void)requestCover:(TACSeriesSelectCell *)cell atIndex:(NSInteger)index{
    NSMutableArray *products = self.seriesDetails;
    NSMutableArray *dict = [self.seriesDetails objectAtIndex:index];
    NSMutableDictionary *coverDict = [dict objectAtIndex:0];
    NSString *photo_id = [coverDict objectForKey:@"photo_id"];
    NSString *requestURL = [NSString stringWithFormat:@"http://%@/db_image/photo.php?id=%@",kHostAddress,photo_id];
    NSLog(@"%@",requestURL);
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *array = (NSArray *)JSON;
        NSMutableDictionary *arrayInfo = (NSMutableDictionary *)[array objectAtIndex:0];
        [products replaceObjectAtIndex:index withObject:dict];
        NSString *thumb = [arrayInfo objectForKey:@"origion"];
        NSString *labelTitle = [coverDict objectForKey:@"name"];
        NSString *thumbUrl = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,thumb];
        NSLog(@"%@",thumbUrl);
        NSString *key = [thumbUrl MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        if (data) {
            cell.thumbnail.image = [UIImage imageWithData:data];
        } else {
            NSURL *url = [NSURL URLWithString:thumbUrl];
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:imgData];
            [FTWCache setObject:imgData forKey:key];
            cell.thumbnail.image = img;
        }
        cell.description.textAlignment = NSTextAlignmentCenter;
        cell.description.text = labelTitle;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,id JSON){
        NSLog(@"%@",error);
    }];
    [operation start];

}

#pragma mark-
#pragma mark UICollectionView Delegate Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.seriesDetails count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TACSeriesSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SeriesViewCellIdentifier" forIndexPath:indexPath];
    [self requestCover:cell atIndex:[indexPath row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isSelecting) {
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(kMenuCellWidth, kMenuCellHeight);
    return size;
}


#pragma mark Network Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.hud.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSString *message = @"连接超时，请检查网络";
    NSString *title = @"超时";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    self.hud.hidden = YES;
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
    self.jsonTempDataArray = nil;
    if (connection == self.seriesConnection) {
        NSMutableArray *json = [jsonStr JSONValue];
        self.seriesInfo = json;
        [self loadProduct];
    } else {
        NSMutableDictionary *json = [jsonStr JSONValue];
        NSMutableArray *array = self.seriesDetails;
        [array addObject:json];
        [self.collectionView reloadData];
    }
    [self setHudFinishStatus:@"数据读取完毕" withTime:1.0];
}

@end
