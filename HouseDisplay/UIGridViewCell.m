//
//  UIGridViewCell.m
//  HouseDisplay
//
//  Created by lazy on 13-4-1.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "UIGridViewCell.h"


@implementation UIGridViewCell

@synthesize rowIndex;
@synthesize colIndex;
@synthesize view;

- (void) addSubview:(UIView *)v
{
	[super addSubview:v];
	v.exclusiveTouch = NO;
	v.userInteractionEnabled = NO;
}


@end
