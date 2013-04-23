//
//  NIDropDown.h
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NIDropDown;
@protocol NIDropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender;
@end 

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) id <NIDropDownDelegate> delegate;

-(void)hideDropDown:(UIButton *)b;
- (void)showDropDown:(UIButton *)b withHeight:(CGFloat)height usingArray:(NSArray *)arr;
@end
