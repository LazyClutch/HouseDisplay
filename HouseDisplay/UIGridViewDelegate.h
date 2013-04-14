//
//  UIGridViewDelegate.h
//  HouseDisplay
//
//  Created by lazy on 13-4-1.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol UIGridViewDelegate


@optional
- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex;


@required
- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex;
- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex;

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid;
- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid;

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex;

@end

