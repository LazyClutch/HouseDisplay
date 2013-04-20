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

@property (nonatomic, strong)TACDIYMenuViewController *diyMenuViewController;

@end

@implementation TACViewController

#pragma mark-
#pragma mark Lifecycle Methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    //Init ViewControllers
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.userTextField becomeFirstResponder];
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

- (IBAction)loginButtonPressed:(id)sender {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
    [self processLogin];
}

- (void)processLogin{
    if ([[self.userTextField text] isEqual:kUsername] && [[self.passwordTextField text] isEqual:kPassword]) {
        self.diyMenuViewController = [[TACDIYMenuViewController alloc] init];
        [self makeAnimation:self.diyMenuViewController];
    } else {
        NSString *message = @"登陆失败";
        NSString *title = @"抱歉";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
    }
    
}
@end
