//
//  CustomTabBar.h
//  LeqiClient
//
//  Created by ui on 11-5-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitySubbranchViewController.h"
#import "PopLoctionSkipView.h"

@class homeViewController;
@class shopViewController;
//@class preferentialViewController;
@class memberViewController;
@class boxViewController;
@class LoginViewController;
@class InformationsViewController;

@interface CustomTabBar : UITabBarController<UITabBarControllerDelegate, CitySubbranchViewControllerDelegate, PopLoctionSkipViewDelegate, UIAlertViewDelegate>
{
    UIImageView *logoView;
	homeViewController *homeView;
    shopViewController *shopView;
//    preferentialViewController *preferentialView;
    InformationsViewController *inforView;
    LoginViewController *LoginView;
    boxViewController *boxView;
	NSMutableArray *buttons;
	int currentSelectedIndex;
	UIImageView *slideBg;
    UIView *customTab;
    BOOL isHideToolbar;
    
    // dufu add 2013.10.25
    UIButton *tmpBtn;
    CitySubbranchEnum subbranchEnum;
    PopLoctionSkipView *plsView;
}

@property (nonatomic, retain) UIImageView *logoView;
@property (nonatomic, retain) homeViewController *homeView;
@property (nonatomic, retain) shopViewController *shopView;
//@property (nonatomic, retain) preferentialViewController *preferentialView;
@property (nonatomic, retain) InformationsViewController *inforView;
@property (nonatomic, retain) LoginViewController *LoginView;
@property (nonatomic, retain) boxViewController *boxView;
@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, assign) BOOL isHideToolbar;
@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, retain) UIView *customTab;
@property (nonatomic, retain) UIButton *tmpBtn;

- (void)hideRealTabBar;
- (void)customTabBar;
- (void)selectedTab:(UIButton *)button;

@end

