//
//  UICollectionView+ReloadWithFinish.m
//  HouseDisplay
//
//  Created by lazy on 13-5-31.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "UICollectionView+ReloadWithFinish.h"

@implementation UICollectionView (ReloadWithFinish)

- (void) reloadDataWithCompletion:( void (^) (void) )completionBlock {
    [self reloadData];
    if(completionBlock) {
        completionBlock();
    }
}

@end
