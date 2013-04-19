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
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.backgroundImageView.image = [UIImage imageNamed:@"content_background.jpg"];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    self.imageViews = @[@"diy1.png",@"diy2.png",@"diy3.png",@"diy4.png",@"diy5.png"];
    
    NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"DIYInformation" ofType:@"plist"];
    NSMutableArray *dict = [[NSMutableArray alloc] initWithContentsOfFile:infoPath];
    self.viewsInfomation = dict;
    
    // Do any additional setup after loading the view from its nib.
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
- (CGFloat)gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex{
    return kMenuCellHeight;
}

- (CGFloat)gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex{
    return kMenuCellWidth;
}

- (NSInteger)numberOfColumnsOfGridView:(UIGridView *)grid{
    return 3;
}

- (NSInteger)numberOfCellsOfGridView:(UIGridView *)grid{
    return 5;
}

- (UIGridViewCell *)gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex{
    TACDIYMenuViewCell *cell = (TACDIYMenuViewCell *)[grid dequeueReusableCell];
    if (cell == nil) {
        cell = [[TACDIYMenuViewCell alloc] init];
    }
    NSInteger number = 3 * rowIndex + columnIndex;
    NSString *imageName = [self.imageViews objectAtIndex:number];
    cell.thumbnails.image = [UIImage imageNamed:imageName];
    return cell;
}


- (void)gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex{
    self.DIYViewController = [[TACDIYViewController alloc] initWithNibName:@"TACDIYViewController" bundle:nil];
    
    NSInteger number = 3 * rowIndex + columnIndex;
    NSMutableDictionary *dict = [self.viewsInfomation objectAtIndex:number];
    [self.DIYViewController setViewInfomation:dict];
    
    BOOL hasGlass = (number < 3) ? YES : NO;
    [self.DIYViewController setViewTag:number + 1];
    [self.DIYViewController setHasGlassMaterial:hasGlass];
    [self makeAnimation];
}


@end
