//
//  CustomTabBar.m
//  LeqiClient
//
//  Created by ui on 11-5-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomTabBar.h"
#import "Common.h"
#import "MButton.h"
#import "homeViewController.h"
#import "shopViewController.h"
#import "preferentialViewController.h"
#import "InformationsViewController.h"
#import "memberViewController.h"
#import "boxViewController.h"
#import "LoginViewController.h"
#import "FrontViewController.h"
#import "BackViewController.h"
#import "Global.h"
#import "system_config_model.h"
#import "ShopObject.h"
#import "PopLoctionHelpView.h"
#import "Global.h"
#import "CityLoction.h"

@implementation CustomTabBar

@synthesize logoView;
@synthesize homeView;
@synthesize shopView;
//@synthesize preferentialView;
@synthesize inforView;
@synthesize LoginView;
@synthesize boxView;
@synthesize currentSelectedIndex;
@synthesize buttons;
@synthesize customTab;
@synthesize isHideToolbar;
@synthesize tmpBtn;

//初始化
- (id)init
{
	self = [super init];//调用父类初始化函数
	if (self != nil)
    {
		NSArray *tabArray = ARRAYS_TAB_BAR;
		NSMutableArray *controllers = [NSMutableArray array];
		for(int i = 0; i < [tabArray count]; i++)
        {
			if (i == 0){
				homeViewController *tempHomeView = [[homeViewController alloc] init];
                self.homeView = tempHomeView;
                [tempHomeView release];
				[controllers addObject:self.homeView];
			}
            else if(i == 1)
            {
                FrontViewController *front = [[FrontViewController alloc]init];
                BackViewController *back = [[BackViewController alloc]init];
                shopViewController *tempShopView = [[shopViewController alloc] initWithFrontViewController:front rearViewController:back];
                
                [front release];
                [back release];
//				shopViewController *tempShopView = [[shopViewController alloc] init];
                self.shopView = tempShopView;
                [tempShopView release];
				[controllers addObject:self.shopView];
			}
            else if (i == 2)
            {
                InformationsViewController *infors = [[InformationsViewController alloc] init];
                self.inforView = infors;
                [infors release];
                [controllers addObject:self.inforView];
//				preferentialViewController *tempPreferentialView = [[preferentialViewController alloc] init];
//                self.preferentialView = tempPreferentialView;
//                [tempPreferentialView release];
//				[controllers addObject:self.preferentialView];
			}
            else if (i == 3)
            {
				LoginViewController *tempMemberView = [[LoginViewController alloc] init];
                self.LoginView = tempMemberView;
                [tempMemberView release];
				[controllers addObject:self.LoginView];
			}
            else if (i == 4)
            {
				boxViewController *tempBoxView = [[boxViewController alloc] init];
                self.boxView = tempBoxView;
                [tempBoxView release];
				[controllers addObject:self.boxView];
			}
		}
		
		self.viewControllers = controllers;
		self.customizableViewControllers = controllers;
		//self.delegate = self;
		
		
		//添加首页图片title
		UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0,0 ,0 ,0)];
		UIImage *logoImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"logo_home" ofType:@"png"]];
		int imgWidth = logoImage.size.width;
		int imgHeight = logoImage.size.height;
		int x = (self.view.frame.size.width - imgWidth) / 2;
		int y = (44 - logoImage.size.height)/2;
		[logo setFrame:CGRectMake(x,y ,imgWidth ,imgHeight)];
		logo.image = logoImage;
        self.logoView = logo;
        [logoImage release];
        [logo release];
		self.navigationItem.titleView = self.logoView;
		
		self.view.backgroundColor = [UIColor clearColor];
		
	}
#ifdef SHOW_NAV_TAB_BG
	UIView *v = [[UIView alloc] initWithFrame:self.view.frame];
	UIImage *img = [UIImage imageNamed:BG_TAB_PIC];
	UIColor *bcolor = [[UIColor alloc] initWithPatternImage:img];
	v.backgroundColor = bcolor;
	[self.tabBar insertSubview:v atIndex:0];
	self.tabBar.opaque = YES;
	[bcolor release];
	[v release];
#else
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 49);
	UIView *view = [[UIView alloc] initWithFrame:frame];
	UIColor *color = COLOR_UNSELECTED_TAB_BAR;
	[view setBackgroundColor:color];
	[[self tabBar] insertSubview:view atIndex:0];
	[[self tabBar] setAlpha:1];
	[view release];
#endif
	
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    
    UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_bottom_bar_focus" ofType:@"png"]];
	slideBg = [[UIImageView alloc] initWithImage:img];
	[img release];
    
	[self hideRealTabBar];
	[self customTabBar];
    isHideToolbar = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if (subbranchEnum == CitySubbranchShop || subbranchEnum == CitySubbranchMember) {
        subbranchEnum = CitySubbranchNormal;
        [self chooseBtn:self.tmpBtn];
    }
}

//自定义下bar
- (void)customTabBar
{
    UIView *tempCustomTab = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 367.0f , 320.0f , 49.0f)];
    tempCustomTab.backgroundColor = [UIColor colorWithRed:0.f green:106.f/255.f blue:193.f/255.f alpha:1.f];
    self.customTab = tempCustomTab;
    [tempCustomTab release];
    [self.view addSubview:self.customTab];
    
    slideBg.frame = CGRectMake(0.0f , 0.0f , 64.0f, 49.0f);
    [self.customTab addSubview:slideBg];
    
	//创建按钮
    NSArray *tabArray = ARRAYS_TAB_BAR;
    NSArray *tabPicNameArray = ARRAYS_TAB_PIC_NAME;
	int viewCount = [tabArray count];
	self.buttons = [NSMutableArray arrayWithCapacity:viewCount];
	double _width = self.view.frame.size.width / viewCount;
	
	for (int i = 0; i < viewCount; i++) {
		UIButton *btn = [MButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(i*_width, 0.0f , _width, 49.0f);
		[btn addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
		btn.tag = i+90000;
        
        //未选中图片
        NSString *normalImgString = [NSString stringWithFormat:@"icon_%@_normal",[tabPicNameArray objectAtIndex:i]];
        UIImage *normalImg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:normalImgString ofType:@"png"]];
		[btn setImage:normalImg forState:UIControlStateNormal];
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        [normalImg release];
        
        //选中后图片
        NSString *selectedImgString = [NSString stringWithFormat:@"icon_%@_selected",[tabPicNameArray objectAtIndex:i]];
        UIImage *selectedImg = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectedImgString ofType:@"png"]];
		[btn setImage:selectedImg forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageCwNamed:@"bottomfocus.png"] forState:UIControlStateSelected];
        [selectedImg release];
        
        //字体居中跟大小
        btn.titleLabel.textAlignment = UITextAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        //未选中文字
        [btn setTitle:[tabArray objectAtIndex:i] forState:UIControlStateNormal];
        
        //选中后文字
        [btn setTitle:[tabArray objectAtIndex:i] forState:UIControlStateSelected];
        
        //未选中文字颜色
        UIColor *colorUnselectedTabBar = COLOR_UNSELECTED_TAB_BAR;
        [btn setTitleColor:colorUnselectedTabBar forState:UIControlStateNormal];
        
        //选中后文字颜色
        UIColor *colorSelectedTabBar = COLOR_SELECTED_TAB_BAR;
        [btn setTitleColor:colorSelectedTabBar forState:UIControlStateSelected];
        
		[self.buttons addObject:btn];
		[self.customTab addSubview:btn];
		[btn release];
	}

	currentSelectedIndex = 90000;

}

//隐藏真实Tab
- (void)hideRealTabBar
{
	for(UIView *view in self.view.subviews){
		if([view isKindOfClass:[UITabBar class]]){
			view.hidden = YES;
			break;
		}
	}
}

//点击
- (void)selectedTab:(UIButton *)button
{
    if (!button.selected)
    {
        if (button.tag == 90001) {
            if (![Common isLoctionOpen] || ![Common isLoction]) {
                [Common MsgBox:@"定位未开启" messege:@"请在”设置->隐私->定位服务“中确认“定位”和“创维云GO”是否为开启状态" cancel:@"确定" other:@"帮助" delegate:self];
                return;
            }
            
            if (![[CityLoction defaultSingle] showLoctionView]) {
                return;
            }
            
            if (![self citySubbranchView:CitySubbranchShop]) {
                self.tmpBtn = button;
                return;
            }
        }

        [self chooseBtn:button];
    }
}

// dufu mod 2013.10.24
- (void)chooseBtn:(UIButton *)button
{
    //取消上一次选中
    UIButton *currentSelectedButton = (UIButton*)[self.view viewWithTag:self.currentSelectedIndex];
    if ([currentSelectedButton isKindOfClass:[UIButton class]])
    {
        [currentSelectedButton setSelected:NO];
    }
    
    //设置本次选中
    [button setSelected:YES];
    
    self.currentSelectedIndex = button.tag;
    self.selectedIndex = self.currentSelectedIndex-90000;
    
    CGFloat fixHeight;
    
    if (self.selectedIndex == 1) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        fixHeight = [UIScreen mainScreen].bounds.size.height - 49.0f;
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        fixHeight = [UIScreen mainScreen].bounds.size.height - 49.0f - 44.0f - 20.0f;
    }
    NSLog(@"%ffixHeight====%f",[UIScreen mainScreen].bounds.size.height,fixHeight);
    self.customTab.frame = CGRectMake(self.customTab.frame.origin.x,fixHeight,320.0f,49.0f);
    
    //执行选中事件
    [self tabBarController:self didSelectViewController:self.selectedViewController];
    
    //选中动画效果
    [self performSelector:@selector(slideTabBg:) withObject:button];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	
	@try {
        
        NSArray *tabArray = ARRAYS_TAB_BAR;
		int selectedIndextmp = [self selectedIndex];

		if(selectedIndextmp == 0) {
            
			self.title = nil;
			self.navigationItem.titleView = logoView;
            
		} else if(selectedIndextmp == 1) {
            
			self.navigationItem.titleView = nil;
			self.title = [tabArray objectAtIndex:selectedIndextmp];
            
		} else if(selectedIndextmp == 2) {
            
			self.navigationItem.titleView = nil;
            //self.title = @"优惠活动";
            self.title = @"行业资讯";
            
		} else if(selectedIndextmp == 3) {
            
			self.navigationItem.titleView = nil;
            if ([Global sharedGlobal].isLogin) {
                self.title = @"会员中心";
            } else {
                self.title = @"登录";
            }
		} else if(selectedIndextmp == 4) {
            
			self.navigationItem.titleView = nil;
			self.title = [tabArray objectAtIndex:selectedIndextmp];
            
		}
	} @catch (NSException *exception) {
        
		NSLog(@"tabchoose: Caught %@: %@", [exception name], [exception reason]);
		return;
	}
}

//点击动画
- (void)slideTabBg:(UIButton *)btn
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.20];
	[UIView setAnimationDelegate:self];
	slideBg.frame = CGRectMake(btn.frame.origin.x , slideBg.frame.origin.y, slideBg.image.size.width, slideBg.image.size.height);
	[UIView commitAnimations];
}

- (void)dealloc
{
    [logoView release];
    [homeView release];
    [shopView release];
    //[preferentialView release];
    [inforView release];
    [LoginView release];
    self.boxView = nil;
	[slideBg release];
	[buttons release];
    [customTab release];
    if (plsView) {
        [plsView release];
    }
	[super dealloc];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        PopLoctionHelpView *helpView = [[PopLoctionHelpView alloc]init];
        [helpView addPopupSubview];
        [helpView release], helpView = nil;
    }
}

// dufu add 2013.10.25
- (void)createCityView:(CitySubbranchEnum)asubbranchEnum
{
    CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
    citySubbranch.delegate = self;
    citySubbranch.cityStr = [Global sharedGlobal].currCity;
    citySubbranch.cwStatusType = StatusTypeAPP;
    citySubbranch.subbranchEnum = asubbranchEnum;
    [self.navigationController pushViewController:citySubbranch animated:YES];
    [citySubbranch release], citySubbranch = nil;
}

// dufu add 2013.10.24
// 切换分店选择页
- (BOOL)citySubbranchView:(CitySubbranchEnum)asubbranchEnum
{
    if ([Global sharedGlobal].shop_id.length == 0) {
        [Global sharedGlobal].loctionFlag = YES;
        [self createCityView:asubbranchEnum];
        return NO;
    } else {
//       [Global sharedGlobal].shop_state = @"1";
//        NSLog(@"=== %d",[[Global sharedGlobal].shop_state intValue]);
        if ([[Global sharedGlobal].shop_state intValue] > 0) {
            
            if ([[Global sharedGlobal].locationCity rangeOfString:[Global sharedGlobal].currCity].location == NSNotFound
                && [Global sharedGlobal].loctionFlag == NO) {
                [Global sharedGlobal].loctionFlag = YES;
                if (plsView == nil) {
                    plsView = [[PopLoctionSkipView alloc]init];
                    plsView.delegate = self;
                }
                [plsView addPopupSubview:[Global sharedGlobal].locationCity city:[Global sharedGlobal].currCity];
                return NO;
            } else {
                [Global sharedGlobal].loctionFlag = YES;
            }
        }
    }

    return YES;
}

// dufu add 2013.10.24
// 切换分店选择页委托
#pragma mark - CitySubbranchViewControllerDelegate
- (void)chooseSubbranchInfo:(CitySubbranchEnum)asubbranchEnum
{
    subbranchEnum = asubbranchEnum;
}

// dufu add 2013.10.25
#pragma mark - PopLoctionSkipViewDelegate
- (void)popLoctionSkipViewClick:(PopLoctionSkipView *)skip 
{
    system_config_model *scMod = [[system_config_model alloc]init];
    scMod.where = [NSString stringWithFormat:@"tag ='%@'",CITY_KEY];
    NSArray *arr = [scMod getList];
    if (arr.count > 0) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              CITY_KEY,@"tag",
                              [Global sharedGlobal].locationCity,@"value", nil];
        [scMod updateDB:dict];
    }
    scMod.where = [NSString stringWithFormat:@"tag ='%@'",SHOP_KEY];
    NSArray *arr1 = [scMod getList];
    if (arr1.count > 0) {
        [scMod deleteDBdata];
    }
    [scMod release], scMod = nil;
    
    [Global sharedGlobal].currCity = [Global sharedGlobal].locationCity;
    [Global sharedGlobal].shop_id = nil;
    
    [ShopObject cleanShopListDB];
    
    [self createCityView:CitySubbranchShop];
}

- (void)popLoctionSkipViewClose:(PopLoctionSkipView *)skip
{
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return NO;
//}
//
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
@end
