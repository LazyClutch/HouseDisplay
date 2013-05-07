//
//  TACSeriesSelectCell.m
//  HouseDisplay
//
//  Created by lazy on 13-5-6.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACSeriesSelectCell.h"

@implementation TACSeriesSelectCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.contentView setFrame:CGRectMake(0, 0, 320, 200)];
        CGRect thumbRect = CGRectMake(0, 0, 320, 160);
        CGRect labelRect = CGRectMake(0, 160, 320, 40);
        self.thumbnail = [[UIImageView alloc] initWithFrame:thumbRect];
        self.description = [[UILabel alloc] initWithFrame:labelRect];
        self.description.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.thumbnail];
        [self.contentView addSubview:self.description];
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
