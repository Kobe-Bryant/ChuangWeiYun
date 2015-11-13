//
//  cwAppDelegate.m
//  cw
//
//  Created by siphp on 13-8-7.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "cwAppDelegate.h"
#import "Global.h"
#import "CustomTabBar.h"
#import "DBOperate.h"
#import "FileManager.h"
#import "alertView.h"
#import "CustomNavigationController.h"
#import "homeViewController.h"
#import "Common.h"
#import "system_config_model.h"
#import "apns_model.h"
#import "autopromotion_model.h"
#import "PfShare.h"
#import "CityChooseViewController.h"
#import "PfDetailViewController.h"
#import "ShopDetailsViewController.h"
#import "InformationDetailViewController.h"
#import "push_hit_log_model.h"
#import "preactivity_log_model.h"
#import "ad_log_model.h"
#import "shop_log_model.h"
#import "PreferentialObject.h"
#import "NSString+DES.h"
#import "browserViewController.h"
#import "Login_FeedbackViewController.h"
#import "autopromotion_model.h"
#import "product_log_model.h"
#import "news_log_model.h"
#import "shop_near_list_model.h"

@implementation cwAppDelegate

@synthesize window;
@synthesize navController;
@synthesize pageControll;
@synthesize guideUIScrollView;
@synthesize myDeviceToken;
@synthesize province;
@synthesize city;
@synthesize area;
@synthesize delegate;
@synthesize headerImage=_headerImage;
@synthesize Guideflag;
@synthesize mapflag;
@synthesize type;
@synthesize closetype;
@synthesize infoId;
@synthesize pushCount;
@synthesize pushClick;
@synthesize appUrl;
@synthesize shopIdStr;
@synthesize shopName;
@synthesize progressHUD;

#pragma mark - application init
// 数据库操作
- (void)operateDB
{
    int soft_ver = [[NSUserDefaults standardUserDefaults] integerForKey:APP_SOFTWARE_VER_KEY];
	if(soft_ver != CURRENT_APP_VERSION)
	{
		[FileManager removeFileDB:dataBaseFile];
        
		NSString *filepath = [FileManager getFileDBPath:@""];
		//获取所有下个目录下的文件名列表
		NSArray *fileList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath: filepath error:nil];
        
		for(int i=0;i < [fileList count]; i++) {
			[FileManager removeFileDB:[fileList objectAtIndex:i]];
		}
        
        filepath = [FileManager getFilePath:@""];
        
        NSArray *fileListPic = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath: filepath error:nil];
        
		for(int i=0;i < [fileListPic count]; i++) {
			[FileManager removeFile:[fileListPic objectAtIndex:i]];
		}
        
        [[NSUserDefaults standardUserDefaults] setInteger:CURRENT_APP_VERSION forKey:APP_SOFTWARE_VER_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
    
    //创建表结构
    [DBOperate createTable];
}

// 初始化框架 nav 及 bar 及 状态设置
- (void)initShellFrame
{
    window.backgroundColor = [UIColor blackColor];

    //显示状态栏
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if (IOS_7) {
       [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    }
    
    //下bar初始化
    CustomTabBar *tabViewController = [[CustomTabBar alloc]init];
    
    //默认选中第一个
    [tabViewController selectedTab:[tabViewController.buttons objectAtIndex:0]];
    CustomNavigationController *tabNavigation = [[CustomNavigationController alloc] initWithRootViewController:tabViewController];
    
    [tabViewController release];
    
    //上bar 自定义
    UINavigationBar *navBar = [tabNavigation navigationBar];
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        // set globablly for all UINavBars
        UIImage *img;
        if (IOS_7) { //chenfeng 14.2.9 add
            img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:IOS7BG_NAV_PIC ofType:nil]];
        }else{
            img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:BG_NAV_PIC ofType:nil]];
        }
    
        [navBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        [img release];
        navBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,
                                     [UIFont boldSystemFontOfSize:19],UITextAttributeFont,nil];
        
    }

    //上bar 背景

    self.navController = tabNavigation;
    self.window.rootViewController = self.navController;
    tabViewController.view.frame = CGRectMake( 0.0f , 0.0f , self.navController.view.frame.size.width , self.navController.view.frame.size.height);
    
    if (IOS_7) {
        [Common iosCompatibility:tabViewController];
    }
    
    [tabNavigation release];
}

//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

// 初始化程序启动第三方注册
- (void)initRegisterAppThirdparty
{
    // 百度地图
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
//    BOOL ret = [_mapManager start:@"700BFB35E4382872A2EA1E1BDC0F3CA496242B8D" generalDelegate:nil];
     //EtQ3IvDgGBq9q6XYbDlEMtcH
    BOOL ret = [_mapManager start:@"aD99cXbvKRLUfBoeKUAILHCG" generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }

    // weixin注册
    [[Global sharedGlobal] registerWXApi];
    
    // QQ注册
    TencentOAuth *tencentOauth = [[TencentOAuth alloc] initWithAppId:QQTencent andDelegate:self];
    [tencentOauth release];
}

// 初始化经纬度
- (void)initCLLocationCoord
{
    //经纬度初始化
    CLLocationCoordinate2D defaultLocation;
    defaultLocation.latitude = 22.548604;
    defaultLocation.longitude = 114.064515;
    [Global sharedGlobal].myLocation = defaultLocation;
}

// 推送通知注册 及 开启定位
- (void)applicationRegisterAndLocation
{
    //推送通知注册
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
    if (token != nil) {
		self.myDeviceToken = token;
        
        //获取位置
        [self getLocation];
	} else {
        //注册消息通知 获取token号
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                                 settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                                 categories:nil]];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            //这里还是原来的代码
            [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];

        }
    }
    
    //监听消息推送
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(launchNotification:)name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

// 初始化配置文件
- (void)initSystemConfig
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [Global sharedGlobal].netWorkQueueArray = arr;
    [arr release], arr = nil;
    
    // 自动登录
    BOOL autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoLogin"];
    if (autoLogin == YES) {
        [self isAutoLogin];
    }
    
    system_config_model *scMod = [[system_config_model alloc]init];
    scMod.where = [NSString stringWithFormat:@"tag ='%@'",SHOP_KEY];
    NSArray *arr1 = [scMod getList];
    if (arr1.count > 0) {
        [Global sharedGlobal].shop_id = [[arr1 lastObject] objectForKey:@"value"];
    }
    
    scMod.where = [NSString stringWithFormat:@"tag ='%@'",CITY_KEY];
    NSArray *arr2 = [scMod getList];
    if (arr2.count > 0) {
        [Global sharedGlobal].currCity = [[arr2 lastObject] objectForKey:@"value"];
    }

    [scMod release], scMod = nil;
}

// 初始化引导页
- (void)initGuideView
{
    system_config_model *scMod = [[system_config_model alloc]init];
    scMod.where = [NSString stringWithFormat:@"tag ='%@'",GUIDE_KEY];
    NSArray *arr3 = [scMod getList];
    if (arr3.count > 0) {
        //引导页
        BOOL isShowGuideView = [[[arr3 lastObject] objectForKey:@"value"] boolValue];
        if (!isShowGuideView) {
            [self addGuideView];
        }
    } else {
        [self addGuideView];
    }
    [scMod release], scMod = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 创建数据库
	[self operateDB];

    // 初始化配置文件
    [self initSystemConfig];

    // 初始化框架 nav 及 bar 及 状态设置
    [self initShellFrame];
    
    // 初始化经纬度
    [self initCLLocationCoord];
    
	// 推送通知注册 及 开启定位
	[self applicationRegisterAndLocation];
    
    // 第三方注册
	[self initRegisterAppThirdparty];
    
    // 初始化引导页
    [self initGuideView];
    
	//线程延迟 2 秒执行
	[NSThread sleepForTimeInterval:2];
	application.applicationIconBadgeNumber = 0;
    
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        
        [application endBackgroundTask:bgTask];
        
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    if (bgTask == UIBackgroundTaskInvalid) {
        NSLog(@"beginground error");
        return;
    } else {
        // 程序切换到后台写入配置表
        [self writeSystemConfig];
        // 统计
        [self accessCountService];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
    //home键激活 重新定位
    //推送通知注册
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
    if (token != nil) {
		self.myDeviceToken = token;
        
        //获取位置
        [self getLocation];
	} else {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                                 settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                                 categories:nil]];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            //这里还是原来的代码
            [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
            
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

// 程序切换到后台写入配置表
- (void)writeSystemConfig
{
    system_config_model *scMod = [[system_config_model alloc] init];
    scMod.where = [NSString stringWithFormat:@"tag ='%@'",CITY_KEY];
    NSArray *arr1 = [scMod getList];
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:
                           CITY_KEY,@"tag",
                           [Global sharedGlobal].currCity,@"value", nil]; 
    if (arr1.count > 0) {
        [scMod updateDB:dict1];
    } else {
        [scMod insertDB:dict1];
    }
    
    scMod.where = [NSString stringWithFormat:@"tag ='%@'",SHOP_KEY];
    NSArray *arr2 = [scMod getList];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
                           SHOP_KEY,@"tag",
                           [Global sharedGlobal].shop_id,@"value", nil];
    if (arr2.count > 0) {
        [scMod updateDB:dict2];
    } else {
        [scMod insertDB:dict2];
    }
    [scMod release], scMod = nil;
}

- (void)setGuideFrame
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
        self.guideUIScrollView.frame = CGRectMake(-KUIScreenWidth, 0.f, KUIScreenWidth, KUIScreenHeight+20.f);
    }completion:^(BOOL finished){
        [self.guideUIScrollView removeFromSuperview];
    }];
    
    Guideflag = 1;
}

//添加引导页面
-(void)addGuideView
{
    CGFloat fixHeight = 0.0f;
    
    UIScrollView *guideView = [[UIScrollView alloc] initWithFrame:self.navController.view.frame];
    guideView.contentSize = CGSizeMake(guideView.frame.size.width, guideView.frame.size.height);
    guideView.pagingEnabled = YES;
    guideView.showsHorizontalScrollIndicator = NO;
    guideView.showsVerticalScrollIndicator = NO;
    guideView.delegate = self;
    guideView.backgroundColor = [UIColor whiteColor];
    
    for(int i = 0;i < GUIDE_VIEW_NUM;i++) {
        UIImage *guideImage = nil;
        if (KUIScreenHeight < 500) {
            guideImage = [UIImage imageCwNamed:[NSString stringWithFormat:@"guide_%d.png",i+1]];
        }else {
            guideImage = [UIImage imageCwNamed:[NSString stringWithFormat:@"guide%d.jpg",i+1]];
        }
        
        UIImageView *guideImageView = [[myImageView alloc]initWithFrame:CGRectMake(guideView.frame.size.width*i , fixHeight , KUIScreenWidth , guideImage.size.height/2)];
        guideImageView.image = guideImage;
        
        [guideView addSubview:guideImageView];
        [guideImageView release];
    }
    
    guideView.contentSize = CGSizeMake(GUIDE_VIEW_NUM * guideView.frame.size.width, guideView.frame.size.height);
    self.guideUIScrollView = guideView;
    [self.navController.view addSubview:guideView];
    [guideView release];
    
    //11.19 chenfeng
    CGFloat pageHeight = 0.f;
    
    if (KUIScreenHeight < 500) {
        pageHeight = KUIScreenHeight - 10.f;
    }else {
        pageHeight = KUIScreenHeight - 15.f;
    }
    
    UIPageControl *pc = [[UIPageControl alloc] initWithFrame:CGRectMake(0.f, pageHeight, KUIScreenWidth, 30.f)];
    pc.numberOfPages = 4;
    pc.currentPage = 0;
    pc.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    self.pageControll = pc;
   
    [self.window addSubview:pageControll];
    [pc release];
    
    [self updateDots];
}

- (void)updateDots
{
    for (int i = 0; i < [self.pageControll.subviews count]; i++) {
        UIView *subView = [self.pageControll.subviews objectAtIndex:i];
        if ([NSStringFromClass([subView class]) isEqualToString:NSStringFromClass([UIImageView class])]) {
            ((UIImageView*)subView).image = (self.pageControll.currentPage == i ? [UIImage imageNamed:@"blue_point.png"] : [UIImage imageNamed:@"white_point.png"]);
        }
    }
}

// 设置当前页 的page
- (void)setCurrentPage:(int)page
{
    self.pageControll.currentPage = page;
    [self updateDots];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    CGFloat pageWidth = self.guideUIScrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    pageControll.currentPage = page;
    [self setCurrentPage:page];
    
    if (offset.x > (GUIDE_VIEW_NUM - 1) * KUIScreenWidth) {
        if (Guideflag == 1) {
            return;
        }
        
        system_config_model *scMod = [[system_config_model alloc] init];
        scMod.where = [NSString stringWithFormat:@"tag ='%@'",GUIDE_KEY];
        NSArray *arr2 = [scMod getList];
        NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
                               GUIDE_KEY,@"tag",
                               [NSNumber numberWithBool:YES],@"value", nil];
        if (arr2.count > 0) {
            [scMod updateDB:dict2];
        } else {
            [scMod insertDB:dict2];
        }
        [scMod release], scMod = nil;
        
        [self.pageControll removeFromSuperview];
        self.navController.view.hidden = NO;
        
        [self performSelector:@selector(setGuideFrame)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {}

#pragma mark -
// 分享回调
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
}

// 分享回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"sourceApplication:%@",sourceApplication);
    
    NSDictionary *param = nil;
    BOOL state = NO;
    
    if (url != nil) {
        param = [NSDictionary dictionaryWithObjectsAndKeys:url,@"url", nil];
    }

    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        if (delegate != nil && [delegate respondsToSelector:@selector(sinaHandleCallBack:)]) {
            state = [delegate sinaHandleCallBack:param];
        }
        delegate = nil;
    } else if ([sourceApplication isEqualToString:@"com.tencent.WeiBo"]){
        if (delegate != nil && [delegate respondsToSelector:@selector(tencentHandleCallBack:)]) {
            state = [delegate tencentHandleCallBack:param];
        }
        delegate = nil;
    } else if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        state = [[Global sharedGlobal] handleOpenURL:url delegate:self];
    } else if ([sourceApplication isEqualToString:@"com.tencent.mqq"]) {
        state = [QQApiInterface handleOpenURL:url delegate:self];
    }
    
    [Common countObject:[Global sharedGlobal].countObj_id withType:[Global sharedGlobal]._countType];

    return state;
}

- (void)onReq:(QQBaseReq *)req {}
// QQ分享回调
- (void)onResp:(QQBaseResp *)resp
{
    switch (resp.type) {
        case ESENDMESSAGETOQQRESPTYPE:
            [[PfShare defaultSingle] pfShareRequest];
            break;
        default:
            break;
    }
}
// QQ分享回调
- (void)tencentDidLogin {}
- (void)tencentDidNotLogin:(BOOL)cancelled {}
- (void)tencentDidNotNetWork {}

// 预订中
- (void)progress
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.window.frame];
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = @"正在获取分店数据，请稍等...";
    [self.window addSubview:self.progressHUD];
    [self.window bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result type:(int)atype
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.window];
    progressHUDTmp.center = CGPointMake(self.window.center.x, self.window.center.y + 120);
    
    UIImage *img = nil;
    if (atype == 1) {
        img = [UIImage imageCwNamed:@"icon_ok_normal.png"];
    } else if (atype == 0) {
        img = [UIImage imageCwNamed:@"icon_tip_normal.png"];
    }
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [self.window addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (self.progressHUD) {
        [progressHUD removeFromSuperview];
        self.progressHUD = nil;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 20) {                  // 关店弹窗逻辑
        NSLog(@"[Global sharedGlobal].isRefShop = %d",[Global sharedGlobal].isRefShop);
        if ([Global sharedGlobal].isRefShop) {
            NSArray *arrayViewControllers = self.navController.viewControllers;
            if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]]) {
                CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
                
                UIButton *btn = (UIButton *)[tabViewController.view viewWithTag:90001];
                
                [tabViewController selectedTab:btn];
            }
            
            if ([Global sharedGlobal].isCloseCity) {
                [self progress];
                
                [self accessShopService];
            }
        }
    }else {
        if (buttonIndex == 0) {
            // push点击次数
            pushClick++;
            [self readAndWritePushLog];
            
            if (self.type == 1) {
                ShopDetailsViewController *view = [[ShopDetailsViewController alloc]init];
                view.productID = self.infoId;
                view.cwStatusType = StatusTypeProductPush;
                [self.navController pushViewController:view animated:YES];
                [view release];
            } else if (self.type == 3) {
                if (self.appUrl.length > 0) {
                    browserViewController *browser = [[browserViewController alloc] init];
                    browser.url = self.appUrl;
                    [self.navController pushViewController:browser animated:YES];
                    [browser release];
                }else {
                    PfDetailViewController *pfDetailView = [[PfDetailViewController alloc]init];
                    pfDetailView.promotionId = self.infoId;
                    pfDetailView.navigationItem.title = @"优惠券详情";
                    [self.navController pushViewController:pfDetailView animated:YES];
                    [pfDetailView release];
                }
            } else if (self.type == 2) {
                InformationDetailViewController *detail = [[InformationDetailViewController alloc] init];
                detail.inforId = self.infoId;
                [self.navController pushViewController:detail animated:YES];
                [detail release];
            } else if (self.type == 4) {
                if (self.shopIdStr != nil &&  [self.shopIdStr intValue] > 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:self.shopIdStr forKey:@"isFeedbackMsg"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:self.shopName forKey:@"isFeedbackShop"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                Login_FeedbackViewController *login_feedback = [[Login_FeedbackViewController alloc] init];
                [self.navController pushViewController:login_feedback animated:YES];
                [login_feedback release];
            } else if (self.type == 5) {
                NSLog(@"[Global sharedGlobal].isRefShop = %d",[Global sharedGlobal].isRefShop);
                if ([Global sharedGlobal].isRefShop) {
                    NSArray *arrayViewControllers = self.navController.viewControllers;
                    if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]]) {
                        CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
                        
                        UIButton *btn = (UIButton *)[tabViewController.view viewWithTag:90001];
                        
                        [tabViewController selectedTab:btn];
                    }
                    
                    if ([Global sharedGlobal].isCloseCity) {
                        [self progress];
                        
                        [self accessShopService];
                    }
                }
            } else {
                NSLog(@"self.infoId = %@",self.infoId);
            }
            
            self.infoId = nil;
        } else {
            if (self.type == 4) {
                if (self.shopIdStr != nil &&  [self.shopIdStr intValue] > 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:self.shopIdStr forKey:@"isFeedbackMsg"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.shopName forKey:@"isFeedbackShop"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    UIView *msgTipView = [[UIView alloc] initWithFrame:CGRectMake(302,1,17,17)];
                    msgTipView.tag = 22222;
                    
                    NSArray *arrayViewControllers = self.navController.viewControllers;
                    if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
                    {
                        CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
                        [tabViewController.customTab addSubview:msgTipView];
                    }
                    
                    UIImage *msgImg = [UIImage imageCwNamed:@"icon_num.png"];
                    UIImageView *msgImageView = [[UIImageView alloc] initWithImage:msgImg];
                    msgImageView.frame = CGRectMake(0, 0, 17, 17);
                    msgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                    [msgTipView addSubview:msgImageView];
                    [msgImageView release];
                    
                    [msgTipView release];
                }
            }
        }
    }
}
#pragma mark -
#pragma mark Application lifecycle
- (void)showString:(NSDictionary*)userInfo
{
    //接收到消息推送后处理函数 apns支持自定义字段
    NSLog(@"userInfo====%@",userInfo);
	NSDictionary *content = [userInfo objectForKey:@"aps"];
    self.type = [[userInfo objectForKey:@"catalog"] intValue];
    self.infoId = [userInfo objectForKey:@"contentId"];
    self.appUrl = [userInfo objectForKey:@"url"];
    
    self.shopIdStr = [userInfo objectForKey:@"shop_id"];
    self.shopName = [userInfo objectForKey:@"shop_name"];
    [Global sharedGlobal].push_id = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"push_id"]];
    
    if (self.type == 5) {
        if (self.closetype == 0) {
            if (content.count != 0) {
                
                NSString *oldShopId = [NSString stringWithFormat:@"%d",[[userInfo objectForKey:@"old_shop_id"] intValue]];
                
                shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
                snlMod.where = [NSString stringWithFormat:@"id = '%@'",oldShopId];
                [snlMod deleteDBdata];
                [snlMod release];
                
                if ([oldShopId isEqualToString:[Global sharedGlobal].shop_id]) {
                    [Global sharedGlobal].shop_id = [NSString stringWithFormat:@"%d",[[userInfo objectForKey:@"new_shop_id"] intValue]];
                    
                    NSString *oldCity = [userInfo objectForKey:@"city"];
                    
                    if (![oldCity isEqualToString:[Global sharedGlobal].currCity]) {
                        [Global sharedGlobal].currCity = oldCity;
                        [Global sharedGlobal].isCloseCity = YES;
                    }
                    [Global sharedGlobal].isRefShop = YES;
                    
                    NSString *alertstr = [NSString stringWithFormat:@"您当前选择的分店已经关闭，请切换到新的分店"];
                    //,[userInfo objectForKey:@"old_shop_name"],[userInfo objectForKey:@"new_shop_name"
                    
                    //弹窗提示
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertstr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            }
        }
    } else {
        if (content.count != 0) {
            //弹窗提示
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[content objectForKey:@"alert"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            [alert show];
            [alert release];
            
            pushCount++;
        }
    }
}

- (void)launchNotification:(NSNotification*)notification
{
	[self showString:[[notification userInfo]objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	[self showString:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error in registration. Error: %@", error);
    
    // 获取位置
    [self getLocation];
}

// 获取token号回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString *mydevicetoken = [[[NSMutableString stringWithFormat:@"%@",deviceToken]stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""];
	self.myDeviceToken = mydevicetoken;
    
    NSLog(@"self.myDeviceToken=======%@",self.myDeviceToken);
    
    // 保存token号
    [[NSUserDefaults standardUserDefaults] setObject:self.myDeviceToken forKey:TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 获取位置
    [self getLocation]; 
}

#pragma mark -
#pragma mark locationManager
//获取地理位置
- (void)getLocation
{
    if ([Common isLoctionOpen]) {
        CLLocationManager *manger = [[CLLocationManager alloc] init];
        [Global sharedGlobal].locManager = manger;
        [manger release], manger = nil;
        if (IOS_VERSION >= 8.0) {
            [[Global sharedGlobal].locManager requestAlwaysAuthorization];
        }
        [Global sharedGlobal].locManager.desiredAccuracy = kCLLocationAccuracyBest;
        [Global sharedGlobal].locManager.delegate = self;
        [[Global sharedGlobal].locManager startUpdatingLocation];
    } else {
        [self locationSelf];
    }
}

// 得到定位地址
- (NSString *)getAddress:(NSString *)address
{    
    NSRange rang = [address rangeOfString:@"省"];
    if (rang.length == 0) {
        rang = [address rangeOfString:@"区"];
        if (rang.length == 0) {
            return address;
        } else {
            return [address substringFromIndex:rang.length + rang.location];
        }
    } else {
        return [address substringFromIndex:rang.length + rang.location];
    }
}

// 定位城市赋值
- (void)locationSelf
{
#if TARGET_IPHONE_SIMULATOR
    self.city = @"深圳市";
    self.province = @"广东省";
    self.area = @"南山区";
#elif TARGET_OS_IPHONE
#endif
    
//    self.city = @"北京市";
    //上传token和统计信息给服务器
    self.myDeviceToken = self.myDeviceToken == nil ? @"" : self.myDeviceToken;

    [Global sharedGlobal].locationCity = self.city;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"CityAddressLocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CityLocation" object:nil];
    
    if ([Global sharedGlobal].currCity.length == 0) {
        [Global sharedGlobal].currCity = [Global sharedGlobal].locationCity;
    }

    // 地区选择器
    [self accessAddressListService];
    
    //请求设备令牌接口
    [self apnsAccess];
}

//定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"dufu didUpdateToLocation......");
    
    [Global sharedGlobal].isLoction = YES;
    
    mapflag = NO;
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude - 0.00311111 longitude:newLocation.coordinate.longitude + 0.00511111]; // 0.002899
    
    // 获取坐标点
    [Global sharedGlobal].myLocation = loc.coordinate;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (mapflag == NO) {
            for (CLPlacemark *placemark in placemarks) {

                self.province = [placemark.addressDictionary objectForKey:@"State"];
                
                self.city = [placemark.addressDictionary objectForKey:@"City"];
                
                self.area = [placemark.addressDictionary objectForKey:@"SubLocality"];
                
                NSLog(@"placemark.addressDictionary = %@",placemark.addressDictionary);
                NSLog(@"getAddress     address = %@",[placemark.addressDictionary objectForKey:@"Name"]);
                [Global sharedGlobal].locationAddress = [self getAddress:[placemark.addressDictionary objectForKey:@"Name"]];
            }
            
            // 定位城市赋值
            [self locationSelf];
            
            [[Global sharedGlobal].locManager stopUpdatingLocation];
            [Global sharedGlobal].locManager.delegate = nil;
            
            mapflag = YES;
        }
    }];
    [loc release];
    [geocoder release];
}

// 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"dufu didFailWithError......");
    
    [[Global sharedGlobal].locManager stopUpdatingLocation];
	[Global sharedGlobal].locManager.delegate = nil;
    
    if (error.code == kCLErrorDenied){
        [Global sharedGlobal].isLoction = NO;
    } else {
        [Global sharedGlobal].isLoction = YES;
    }
    
    // 定位城市赋值
    [self locationSelf];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {}

- (void)dealloc {
    [navController release];
    [window release];
    [pageControll release];
    [guideUIScrollView release];
    [myDeviceToken release];
    [province release];
    [city release];
    [infoId release];
    RELEASE_SAFE(_popUpdateView);
    [super dealloc];
}

#pragma mark - network
//设备令牌接口
- (void)apnsAccess
{
    // 优惠券版本号
    int promoteVer = 0;
    
    // 评分版本号
    int gradeVer = 0;
    
    // 升级版本号
    int updateVer = 0;
    
    // 获取优惠券和评分版本号
    apns_model *apnsMod = [[apns_model alloc]init];
    NSArray *arr = [apnsMod getList];
    [apnsMod release], apnsMod = nil;
    
    // 升级版本号
    autopromotion_model *autoMod = [[autopromotion_model alloc]init];
    NSArray *autoArr = [autoMod getList];
    [autoMod release], autoMod = nil;
    
    if (arr.count > 0) {
        NSDictionary *dict = [arr lastObject];
        promoteVer = [[dict objectForKey:@"pro_ver"] intValue];
        gradeVer = [[dict objectForKey:@"grade_ver"] intValue];
    }
    if (autoArr.count > 0) {
        promoteVer = [[[autoArr lastObject] objectForKey:@"promote_ver"] intValue];
    }
    
    NSString *shopID = @"0";
    if ([Global sharedGlobal].shop_id.length > 0) {
        shopID = [Global sharedGlobal].shop_id;
    }
    
    NSString *userID = @"0";
    if ([Global sharedGlobal].user_id.length > 0) {
        userID = [Global sharedGlobal].user_id;
    }
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Common getMacAddress],@"mac_addr",
                                       [NSNumber numberWithDouble:[Global sharedGlobal].myLocation.latitude],@"latitude",
                                       [NSNumber numberWithDouble:[Global sharedGlobal].myLocation.longitude],@"longitude",
                                       [NSNumber numberWithInt:0],@"platform",
                                       self.myDeviceToken,@"token",
                                       self.province,@"pro",
                                       self.city,@"city",
                                       [NSNumber numberWithInt:promoteVer],@"pro_ver",
                                       [NSNumber numberWithInt:gradeVer],@"grade_ver",
                                       [NSNumber numberWithInt:updateVer],@"auto_ver",
                                       shopID,@"shop_id",
                                       userID,@"user_id",
                                       nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:APNS_COMMAND_ID accessAdress:@"apns.do?param=" delegate:self withParam:nil];
    
}

//自动登陆
- (void)isAutoLogin
{
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    NSArray *nameArray = [remember getList];
    NSLog(@"RememberName = %@",nameArray);

    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
    
    NSArray *passwordArray = [remember getList];
    NSLog(@"RememberPassword = %@",passwordArray);
    
    RELEASE_SAFE(remember);

    if ([nameArray count]>0 && [passwordArray count]>0) {
        
        NSString *reqUrl = @"member/login.do?param=";
        
        NSString *decryptUseDES=[NSString decryptUseDES:[[passwordArray objectAtIndex:0]objectForKey:@"value"] key:@"1234567812345678"];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
        
        NSString *shopID = @"0";
        if ([Global sharedGlobal].shop_id.length > 0) {
            shopID = [Global sharedGlobal].shop_id;
        }
        
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [[nameArray objectAtIndex:0]objectForKey:@"value"],@"username",
                                                    [Common sha1:decryptUseDES],@"password",
                                                                          token,@"token",
                                                                         shopID,@"shop_id",nil];
        
        [[NetManager sharedManager] accessService:requestDic data:nil command:MEMBER_LOGIN_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
    }else {
        [Global sharedGlobal].isLogin = NO;
        [Global sharedGlobal].user_id = nil;
    }
}

// 自动登陆
- (void)updateAction:(NSMutableArray *)array
{
    if (![[array lastObject] isEqual:CwRequestTimeout]) {
        int resultInt = [[[array objectAtIndex:0] objectForKey:@"ret"]intValue];
        if (resultInt == 1) {
            [Global sharedGlobal].isLogin = YES;
            [Global sharedGlobal].user_id = [NSString stringWithFormat:@"%d",[[[[array objectAtIndex:0] objectForKey:@"userInfo"] objectForKey:@"id"] intValue]];
        }else {
            [Global sharedGlobal].isLogin = NO;
            [Global sharedGlobal].user_id = nil;
        }

    }
    
}

// 发送统计
- (void)accessCountService
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *reqUrl = @"datastatistics.do?param=";
        
        push_hit_log_model *phlMod = [[push_hit_log_model alloc] init];
        NSMutableArray *arr1 = [phlMod getList];
        [phlMod release], phlMod = nil;
        
        shop_log_model *slMod = [[shop_log_model alloc] init];
        NSMutableArray *arr2 = [slMod getList];
        [slMod release], slMod = nil;
        
        preactivity_log_model *plMod = [[preactivity_log_model alloc] init];
        NSMutableArray *arr3 = [plMod getList];
        [plMod release], plMod = nil;
        
        ad_log_model *alMod = [[ad_log_model alloc] init];
        NSMutableArray *arr4 = [alMod getList];
        [alMod release], alMod = nil;
        
        product_log_model *prolMod = [[product_log_model alloc] init];
        NSMutableArray *arr5 = [prolMod getList];
        [prolMod release], prolMod = nil;
        
        news_log_model *newslMod = [[news_log_model alloc] init];
        NSMutableArray *arr6 = [newslMod getList];
        [newslMod release], newslMod = nil;
        
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"0",@"platform",
                                           [PreferentialObject getDateCount:[NSDate date]],@"created",
                                           arr3,@"preactivity_logs",
                                           arr4,@"ad_logs",
                                           arr1,@"push_hit_logs",
                                           arr2,@"shop_logs",
                                           arr5,@"product_logs",
                                           arr6,@"news_logs",
                                           nil];
        
        NSLog(@"hui === %@",requestDic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NetManager sharedManager] accessService:requestDic
                                                 data:nil
                                              command:COUNT_COMMAND_ID
                                         accessAdress:reqUrl
                                             delegate:self
                                            withParam:nil];
        });
    });
}

// 统计
- (void)updateMod:(NSMutableArray*)resultArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (resultArray.count > 0) {
            if ([[resultArray lastObject] intValue] == 1) {
                [self cleanLog];
            }
        }
        
        if (bgTask != UIBackgroundTaskInvalid) {
            NSLog(@"s;ldfkl;skfl;skfl;al;skdf");
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }
    });
}

// 地区选择器
- (void)accessAddressListService
{
    NSString *reqUrl = @"member/addresschoicelist.do?param=";

    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Common getVersion:ADDRESSCHOICELIST_COMMAND_ID],@"ver",
                                       nil];
    [[NetManager sharedManager] accessService:requestDic
                                         data:nil
                                      command:ADDRESSCHOICELIST_COMMAND_ID
                                 accessAdress:reqUrl
                                     delegate:self
                                    withParam:nil];
}

// 新版本升级
- (void)newUpdateVersion
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    if (autoUpdate == NO) {
        autopromotion_model *apMod = [[autopromotion_model alloc]init];
        NSArray *arr = [apMod getList];
        [apMod release];
        
        if (arr.count > 0) {
            NSDictionary *dict = [arr lastObject];
            int newVersion = [[dict objectForKey:@"promote_ver"] intValue];
            
            if (CURRENT_APP_VERSION < newVersion) {
                autoUpdate = YES;                
                // 12.12 chenfeng add
                NSString *tipTitle=@"";
                if ([arr count]!=0) {
                    tipTitle=[NSString stringWithFormat:@"%@",[dict objectForKey:@"remark"]];
                }
                
                _popUpdateView = [[PopCheckUpdateView alloc] initWithTitle:VERSIONTITLE andContent:tipTitle andBtnTitle:@"稍后提醒我" andTitle:@"立即更新"];
                _popUpdateView.delegate = self;
                [_popUpdateView addPopupSubview];
            }
        }
    }
    
    [pool release];
}

#pragma mark - PopUpdateCheckDelegate
//确定检查更新弹窗回调 12.12 chenfeng
- (void)OKCheckUpdates{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    [_popUpdateView closeView];
    autopromotion_model *apMod = [[autopromotion_model alloc]init];
    NSArray *arr = [apMod getList];
    [apMod release];
    
    if (arr.count > 0) {
        NSDictionary *dict = [arr lastObject];
        NSString *url = [dict objectForKey:@"url"];
        if (url.length > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
    
    [pool release];
}

// 分店请求
- (void)accessShopService
{
    NSString *reqUrl = @"shoplist.do?param=";

    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"0",@"ver",
                                       [Global sharedGlobal].currCity,@"city",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SUBBRANCH_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
     if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        
         switch(commandid) {
             case MEMBER_LOGIN_COMMAND_ID:          // 自动登陆
             {
                 [self updateAction:resultArray];
             }
                 break;
             case APNS_COMMAND_ID:                  // 设备令牌
             {
                 if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                     if (resultArray.count > 0) {
                         if ([[resultArray objectAtIndex:0] intValue] == -1) {
                             if (self.type != 5) {
                                 self.closetype = 1;
                                 
                                 NSString *oldShopId = [NSString stringWithFormat:@"%d",[[resultArray objectAtIndex:1] intValue]];
                                 
                                 shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
                                 snlMod.where = [NSString stringWithFormat:@"id = '%@'",oldShopId];
                                 [snlMod deleteDBdata];
                                 [snlMod release];
                                 
                                 if ([oldShopId isEqualToString:[Global sharedGlobal].shop_id]) {
                                     [Global sharedGlobal].shop_id = [NSString stringWithFormat:@"%d",[[resultArray objectAtIndex:3] intValue]];
                                     
                                     NSString *oldCity = [resultArray objectAtIndex:5];
                                     
                                     if (![oldCity isEqualToString:[Global sharedGlobal].currCity]) {
                                         [Global sharedGlobal].currCity = oldCity;
                                         [Global sharedGlobal].isCloseCity = YES;
                                     }
                                     [Global sharedGlobal].isRefShop = YES;
                                     
                                     NSString *alertstr = [NSString stringWithFormat:@"您当前选择的分店已经关闭，请切换到新的分店"];
                                     
                                     //弹窗提示
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertstr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                     alert.tag = 20;
                                     [alert show];
                                     [alert release];
                                 }
                             }
                         }
                     } else {
                         [self newUpdateVersion];
                     }
                 }
             }
                 break;
             case COUNT_COMMAND_ID:                 // 统计
             {
                 [self updateMod:resultArray];
             }
                 break;
             case ADDRESSCHOICELIST_COMMAND_ID:     // 地区选择器
             {
                 
             }
                 break;
             case SUBBRANCH_COMMAND_ID:             // 获取分店数据
             {
                 [self.progressHUD hide:YES afterDelay:0.f];
             }
                 break;
             default:
                 break;
         }
     }
    
}

#pragma mark -
// 读写push log数据
- (void)readAndWritePushLog
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"==%@",[Global sharedGlobal].push_id);
        NSString *pushId = nil;
        if ([Global sharedGlobal].push_id.length > 0) {
            pushId = [Global sharedGlobal].push_id;
        }else {
            pushId = @"0";
        }
        
        push_hit_log_model *phlMod = [[push_hit_log_model alloc]init];
        phlMod.where = [NSString stringWithFormat:@"push_id = '%@'",pushId];
        NSMutableArray *arr = [phlMod getList];
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:[pushId intValue]],@"push_id",
                                     [NSNumber numberWithInt:pushCount],@"ios_pushed",
                                     [NSNumber numberWithInt:pushClick],@"ios_click", nil];
        if (arr.count > 0) {
            NSDictionary *dict = [arr lastObject];
            
            int count = [[dict objectForKey:@"ios_pushed"] intValue];
            [data setObject:[NSNumber numberWithInt:pushCount+count] forKey:@"ios_pushed"];
            
            int click = [[dict objectForKey:@"ios_click"] intValue];
            [data setObject:[NSNumber numberWithInt:pushClick+click] forKey:@"ios_click"];
            
            [phlMod updateDB:data];
        } else {
            [phlMod insertDB:data];
        }
        
        [phlMod release], phlMod = nil;
        
        pushCount = 0;
        pushClick = 0;
    });
}

// 清除统计log
- (void)cleanLog
{
    push_hit_log_model *phlMod = [[push_hit_log_model alloc] init];
//    NSMutableArray *arr1 = [phlMod getList];
//    for (NSDictionary *dict in arr1) {
//        phlMod.where = [NSString stringWithFormat:@"shop_id = '%@'",[dict objectForKey:@"shop_id"]];
//        [phlMod deleteDBdata];
//    }
    [phlMod deleteDBdata];
    [phlMod release], phlMod = nil;
    
    shop_log_model *slMod = [[shop_log_model alloc] init];
    NSMutableArray *arr2 = [slMod getList];
    for (NSDictionary *dict in arr2) {
        slMod.where = [NSString stringWithFormat:@"id = '%@'",[dict objectForKey:@"id"]];
        [slMod deleteDBdata];
    }
    [slMod release], slMod = nil;
    
    preactivity_log_model *plMod = [[preactivity_log_model alloc] init];
    [plMod deleteDBdata];
    [plMod release], plMod = nil;
    
    ad_log_model *alMod = [[ad_log_model alloc] init];
    [alMod deleteDBdata];
    [alMod release], alMod = nil;
    
    product_log_model *prolMod = [[product_log_model alloc] init];
    [prolMod deleteDBdata];
    [prolMod release], prolMod = nil;
    
    news_log_model *newlMod = [[news_log_model alloc] init];
    [newlMod deleteDBdata];
    [newlMod release], newlMod = nil;
}
@end
