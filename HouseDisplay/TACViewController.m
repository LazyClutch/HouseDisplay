//
//  TACViewController.m
//  HouseDisplay
//
//  Created by lazy on 13-4-1.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACViewController.h"
#import "TACDIYMenuViewController.h"

@interface TACViewController ()

@end

@implementation TACViewController

#pragma mark-
#pragma mark Lifecycle Methods

- (GNWheelView *)wheelView{
    return (GNWheelView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *mainMenu = [[NSBundle mainBundle] pathForResource:@"MainMenu" ofType:@"plist"];
    NSArray *mainMenuArray = [[NSArray alloc] initWithContentsOfFile:mainMenu];
    self.menuList = mainMenuArray;
        
    self.wheelView.delegate = self;
    self.wheelView.idleDuration = 0;
    
    //Init ViewControllers
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    TACDIYMenuViewController *diyMenuViewController = [[TACDIYMenuViewController alloc] init];
    [viewControllers addObject:diyMenuViewController];

    self.viewControllers = viewControllers;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.wheelView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeAnimation:(TACDIYMenuViewController *)menuViewController{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
    [self.view addSubview:menuViewController.view];
}

#pragma mark-
#pragma mark Wheel View Methods

- (NSUInteger)numberOfRowsOfWheelView:(GNWheelView *)wheelView{
    return [self.menuList count];
}

- (UIView *)wheelView:(GNWheelView *)wheelView viewForRowAtIndex:(unsigned int)index{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[self.menuList objectAtIndex:index] ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
    return imageView;
}

- (float)rowHeightInWheelView:(GNWheelView *)wheelView{
    return kMenuImageHeight;
}

- (float)rowWidthInWheelView:(GNWheelView *)wheelView{
    return kMenuImageWidth;
}

- (void)wheelView:(GNWheelView *)wheelView didSelectedRowAtIndex:(unsigned int)index{
    TACDIYMenuViewController *menuViewController;
    switch (index) {
        case 0:{
            menuViewController = [self.viewControllers objectAtIndex:0];
            break;
        }
        default:
            break;
    }
    [self makeAnimation:menuViewController];
}

@end
