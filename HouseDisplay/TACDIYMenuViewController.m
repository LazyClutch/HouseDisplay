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

#define kMenuCellWidth  313
#define kMenuCellHeight 163

@interface TACDIYMenuViewController ()

@property (nonatomic, strong) TACDIYViewController *DIYViewController;

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
    
    self.imagePaths = @[@"diy1",@"diy2",@"diy3",@"diy4",@"diy5"];
    [self setThumbNail];
    
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

#pragma mark Grid View Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.imagePaths count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(313, 163);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TACDIYMenuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuViewCellIdentifier" forIndexPath:indexPath];
    cell.thumbnails.image = [self.imageViews objectAtIndex:[indexPath row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.DIYViewController = [[TACDIYViewController alloc] initWithNibName:@"TACDIYViewController" bundle:nil];
    
    NSMutableDictionary *dict = [self.viewsInfomation objectAtIndex:[indexPath row]];
    [self.DIYViewController setViewInfomation:dict];
    
    BOOL hasGlass = ([indexPath row] < 3) ? YES : NO;
    [self.DIYViewController setViewTag:[indexPath row] + 1];
    [self.DIYViewController setHasGlassMaterial:hasGlass];
    [self makeAnimation];
}


@end
