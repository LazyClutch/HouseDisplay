//
//  TACDIYMenuViewCell.m
//  HouseDisplay
//
//  Created by lazy on 13-4-21.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import "TACDIYMenuViewCell.h"

@implementation TACDIYMenuViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //      self.contentView.layer.cornerRadius = 10.0;
        [self.contentView setFrame:CGRectMake(0, 0, 313, 163)];
        self.thumbnails = [[UIImageView alloc] initWithFrame:[self.contentView bounds]];
    
        [self.contentView addSubview:self.thumbnails];
        
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
