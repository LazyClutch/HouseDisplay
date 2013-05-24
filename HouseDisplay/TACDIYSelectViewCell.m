//
//  TACDIYSelectViewCell.m
//  HouseDisplay
//
//  Created by lazy on 13-5-24.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYSelectViewCell.h"

@implementation TACDIYSelectViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, 0, 80, 130)];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 130)];
        self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 80, 20)];
        self.labelView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.imageView];
        [self addSubview:self.labelView];
        
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
