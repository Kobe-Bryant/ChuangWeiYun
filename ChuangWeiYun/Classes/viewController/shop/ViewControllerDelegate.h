//
//  ViewControllerDelegate.h
//  SideSlip
//
//  Created by yunlai on 13-8-12.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ViewControllerDelegate <NSObject>

@optional
// 页面翻转函数
- (void)pageOverTurnView:(UIViewController *)viewController;
// 城市选择页
- (void)cityChoosePageTurn;

@end
