//
//  TACDIYImageRequest.m
//  HouseDisplay
//
//  Created by lazy on 13-4-11.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYImageRequest.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation TACDIYImageRequest

-(id)init{
    
    if(self == [super init]){
        
        self.appDelegate = (TACAppDelegate *)[[UIApplication sharedApplication] delegate];
        
    }
    
    return self;
    
}


-(void)main{
    
    if(self.hostObject == nil)
        return;
    
    if(self.resourceURL == nil){
        [self resourceDidReceive:nil];
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.resourceURL];
    self.httpRequest = request;
    
    
    
    [self.httpRequest setDownloadCache:self.appDelegate.downCache];
    [self.httpRequest setDelegate:self];
    [self.httpRequest setDidStartSelector:@selector(didStartHttpRequest:)];
    [self.httpRequest setDidFinishSelector:@selector(didFinishHttpRequest:)];
    [self.httpRequest setDidFailSelector:@selector(didFailedHttpRequest:)];
    
    //发异步请求
    
    [self.httpRequest startAsynchronous];
    
}


//开始请求

-(void)didStartHttpRequest:(ASIHTTPRequest *)request{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

//请求成功返回处理结果

-(void)didFinishHttpRequest:(ASIHTTPRequest *)request{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    
    if([request responseStatusCode] == 200 || [request responseStatusCode] == 304){
        
        //判断是否来自缓存
        
        if([request didUseCachedResponse]){
            
            NSLog(@"=========资源请求：%@ 来自缓存============",[self.resourceURL absoluteURL]);
            
        }
        else{
            
            NSLog(@"=========资源请求：图片不来自缓存============");
        }
        
        
        [self resourceDidReceive:[request responseData]];
        
    }
    
    else {
        
        [self resourceDidReceive:nil];
        
    }
    
}

//失败请求返回处理结果

-(void)didFailedHttpRequest:(ASIHTTPRequest *)request{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self resourceDidReceive:nil];
    
}

//取消资源请求

-(void)cancelResource{
    
    [self.httpRequest cancel];
    
}

//资源接收处理方法

-(void)resourceDidReceive:(NSData *)resource{
    
    if([self.hostObject respondsToSelector:self.resourceDidReceive]){
        
        if(resource != nil && self.imageView != nil){
            
            self.imageView.image = [UIImage imageWithData:resource];
            
        }
        [self.hostObject performSelectorOnMainThread:self.resourceDidReceive withObject:self.imageView waitUntilDone:NO];
        
    }
    
}

@end