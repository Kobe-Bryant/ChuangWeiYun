//
//  PopShareView.h
//  ShareDemo
//
//  Created by yunlai on 13-7-11.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareAPIAction;

@interface PopShareView : UIView
{
    UIView *bgView;
    NSArray *butArrayText;
    NSArray *butArrayImage;
    
    CGFloat bgViewHeight;
    
    ShareAPIAction *share;
    
    id delegatePop;
    UINavigationController *navController;
}

@property (retain, nonatomic) UIView *bgView;
@property (retain, nonatomic) NSArray *butArrayText;
@property (retain, nonatomic) NSArray *butArrayImage;
@property (retain, nonatomic) ShareAPIAction *share;
@property (retain, nonatomic) id delegatePop;
@property (retain, nonatomic) UINavigationController *navController;

+ (PopShareView *)defaultExample;

- (void)showPopupView:(UIViewController *)viewController delegate:(id)adelegate;

@end
