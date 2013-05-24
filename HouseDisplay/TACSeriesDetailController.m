//
//  TACSeriesDetailController.m
//  HouseDisplay
//
//  Created by lazy on 13-5-6.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACSeriesDetailController.h"
#import "TACSeriesDetailCell.h"

#define kHostAddress @"115.28.39.103"
#define kMenuCellWidth  313
#define kMenuCellHeight 163


@interface TACSeriesDetailController ()

@end

@implementation TACSeriesDetailController

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
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[TACSeriesDetailCell class] forCellWithReuseIdentifier:@"SeriesDetailViewCellIdentifier"];
    [self.collectionView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestImage:(TACSeriesDetailCell *)cell atIndex:(NSInteger)index{
    NSMutableArray *products = self.seriesImages;
    NSMutableDictionary *dict = [self.seriesImages objectAtIndex:index];
    NSString *photo_id = [dict objectForKey:@"photo_id"];
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
        NSString *thumbUrl = [NSString stringWithFormat:@"http://%@/db_image/%@",kHostAddress,thumb];
        NSLog(@"%@",thumbUrl);
        NSString *key = [thumbUrl MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        if (data) {
            cell.detailImage.image = [UIImage imageWithData:data];
        } else {
            NSURL *url = [NSURL URLWithString:thumbUrl];
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:imgData];
            [FTWCache setObject:imgData forKey:key];
            cell.detailImage.image = img;
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,id JSON){
        NSLog(@"%@",error);
    }];
    [operation start];
    
}

- (IBAction)returnButtonPressed:(id)sender {
    [self.view removeFromSuperview];
}

#pragma mark-
#pragma mark UICollectionView Delegate Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.seriesImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TACSeriesDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SeriesDetailViewCellIdentifier" forIndexPath:indexPath];
    [self requestImage:cell atIndex:[indexPath row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(kMenuCellWidth, kMenuCellHeight);
    return size;
}

@end
