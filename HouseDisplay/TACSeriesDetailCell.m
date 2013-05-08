//
//  TACSeriesDetailCell.m
//  HouseDisplay
//
//  Created by lazy on 13-5-6.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACSeriesDetailCell.h"

@implementation TACSeriesDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setFrame:CGRectMake(0, 0, 320, 200)];
        CGRect thumbRect = CGRectMake(0, 0, 320, 200);
        
        self.detailImage = [[UIImageView alloc] initWithFrame:thumbRect];
        
        [self.contentView addSubview:self.detailImage];
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
