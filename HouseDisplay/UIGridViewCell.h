//
//  UIGridViewCell.h
//  HouseDisplay
//
//  Created by lazy on 13-4-1.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIGridViewCell : UIButton {

}

@property int rowIndex;
@property int colIndex;
@property (nonatomic, strong) IBOutlet UIView *view;

@end
