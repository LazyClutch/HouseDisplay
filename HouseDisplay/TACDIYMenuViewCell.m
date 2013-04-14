//
//  TACDIYMenuViewCell.m
//  HouseDisplay
//
//  Created by lazy on 13-4-7.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYMenuViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TACDIYMenuViewCell

- (id)init{
    if (self = [super init]) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 313, 163);
        [[NSBundle mainBundle] loadNibNamed:@"TACDIYMenuViewCell" owner:self options:nil];
        
        [self addSubview:self.view];
		
//		self.imageView.layer.cornerRadius = 4.0;
//		self.imageView.layer.masksToBounds = YES;
//		self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//		self.imageView.layer.borderWidth = 1.0;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
