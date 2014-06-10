//
//  UIWheelSlider.h
//  UIWheelSlider
//
//  Created by yuanfeng on 14-6-10.
//  Copyright (c) 2014年 yuanfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWheelSlider : UIControl

@property(nonatomic) float value;                                   // default 0.0. this value will be pinned to min/max
@property(nonatomic) float minimumValue;                            // default 0.0. the current value may change if outside new min value
@property(nonatomic) float maximumValue;                            // default 1.0. the current value may change if outside new max value

@property(nonatomic) BOOL continuous;                               // if set, value change events are generated any time the value changes due to dragging. default = YES

@property(nonatomic) double deltaRadian;                            //default M_PI/30. The radian between two gears

@property(nonatomic,retain) UIColor *minimumTintColor;              //default [UIColor colorWithRed:72.0/255.0 green:211.0/255.0 blue:199.0/255.0 alpha:1.0];
@property(nonatomic,retain) UIColor *maximumTintColor;              //default [UIColor colorWithRed:1.0 green:67.0/255.0 blue:85.0/255.0 alpha:1.0];
@end
