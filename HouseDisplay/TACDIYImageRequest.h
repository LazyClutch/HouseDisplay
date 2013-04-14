//
//  TACDIYImageRequest.h
//  HouseDisplay
//
//  Created by lazy on 13-4-11.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "TACDIYViewController.h"
#import "TACAppDelegate.h"

@interface TACDIYImageRequest : NSOperation

@property (strong, nonatomic) NSURL *resourceURL;
@property (strong, nonatomic) NSObject *hostObject;
@property (assign, nonatomic) SEL resourceDidReceive;
@property (assign, nonatomic) TACAppDelegate *appDelegate;
@property (strong, nonatomic) ASIHTTPRequest *httpRequest;
@property (strong, nonatomic) UIImageView *imageView;

- (void)didStartHttpRequest:(ASIHTTPRequest *)request;
- (void)didFinishHttpRequest:(ASIHTTPRequest *)request;
- (void)didFailedHttpRequest:(ASIHTTPRequest *)request;
- (void)cancelResource;
- (void)resourceDidReceive:(NSData *)data;

@end
