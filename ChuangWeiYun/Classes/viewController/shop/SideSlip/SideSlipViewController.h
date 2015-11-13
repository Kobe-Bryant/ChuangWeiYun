//
//  SideSlipViewController.h
//  SideSlip
//
//  Created by yunlai on 13-8-5.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	FrontViewPositionLeft,
	FrontViewPositionRight
} FrontViewPosition;

@protocol SideSlipViewControllerDelegate;

@interface SideSlipViewController : UIViewController

@property (retain, nonatomic) UIViewController *frontViewController;
@property (retain, nonatomic) UIViewController *rearViewController;
@property (assign, nonatomic) FrontViewPosition currentFrontViewPosition;
@property (assign, nonatomic) id<SideSlipViewControllerDelegate> delegate;

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController;
- (void)revealGesture:(UIPanGestureRecognizer *)recognizer;
- (void)tapGesture:(UITapGestureRecognizer *)recognizer;
- (void)revealToggle:(id)sender;

@end

@protocol SideSlipViewControllerDelegate<NSObject>

@optional

- (BOOL)revealController:(SideSlipViewController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController;
- (BOOL)revealController:(SideSlipViewController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(SideSlipViewController *)revealController willRevealRearViewController:(UIViewController *)rearViewController;
- (void)revealController:(SideSlipViewController *)revealController didRevealRearViewController:(UIViewController *)rearViewController;

- (void)revealController:(SideSlipViewController *)revealController willHideRearViewController:(UIViewController *)rearViewController;
- (void)revealController:(SideSlipViewController *)revealController didHideRearViewController:(UIViewController *)rearViewController;

@end