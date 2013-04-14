//
//  UIGridView.h
//  HouseDisplay
//
//  Created by lazy on 13-4-1.
//  Copyright (c) 2013年 Lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIGridViewDelegate;
@class UIGridViewCell;

@interface UIGridView : UITableView<UITableViewDelegate, UITableViewDataSource> {
	UIGridViewCell *tempCell;
}

@property (nonatomic, strong) IBOutlet id<UIGridViewDelegate> uiGridViewDelegate;

- (void) setUp;
- (UIGridViewCell *) dequeueReusableCell;

- (IBAction) cellPressed:(id) sender;

@end
