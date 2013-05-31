//
//  UICollectionView+ReloadWithFinish.h
//  HouseDisplay
//
//  Created by lazy on 13-5-31.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (ReloadWithFinish)

- (void) reloadDataWithCompletion:( void (^) (void) )completionBlock;

@end
