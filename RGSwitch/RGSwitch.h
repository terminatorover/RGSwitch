//
//  RGDrawerView.h
//  Drawing
//
//  Created by ROBERA GELETA on 2/19/16.
//  Copyright (c) 2016 ROBERA GELETA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGSwitch : UIView
@property BOOL isOn;
- (void)animateToOn;- (void)animateToOff;
@property (nonatomic) UIColor *buttonColor;//button
@property (nonatomic) UIColor *stripColor;
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;//note the width will not be considered as the height of the switch drives the width. 
@end
