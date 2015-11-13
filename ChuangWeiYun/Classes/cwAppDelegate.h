//
//  cwAppDelegate.h
//  cw
//
//  Created by siphp on 13-8-7.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BMKMapManager.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h> 
#import "HttpRequest.h"
#import "MBProgressHUD.h"
#import "PopCheckUpdateView.h"

@protocol APPlicationDelegate <NSObject>
@optional
- (BOOL)tencentHandleCallBack:(NSDictionary*)param;
- (BOOL)sinaHandleCallBack:(NSDictionary*)param;
@end

@class CustomNavigationController;

@interface cwAppDelegate : NSObject <UIApplicationDelegate,UIScrollViewDelegate,CLLocationManagerDelegate,QQApiInterfaceDelegate,TencentSessionDelegate, UIGestureRecognizerDelegate,PopUpdateCheckDelegate,HttpRequestDelegate,MBProgressHUDDelegate> {
    UIWindow *window;
    CustomNavigationController *navController;
    UIPageControl *pageControll;
    UIScrollView *guideUIScrollView;
    BMKMapManager * _mapManager;
    
    NSString *myDeviceToken;
    NSString *province;
	NSString *city;
    NSString *area;
    
    UIImage *_headerImage;
    int Guideflag;                      // 判断
    int mapflag;                        // 判断
    int type;                           // push类型
    int closetype;                      // 设备令牌关店是否弹窗
    NSString *infoId;                   // 信息ID
    
    int pushCount;                      // push点击次数
    BOOL autoUpdate;                    // 自动更新标示符
    MBProgressHUD *progressHUD;         // 加载弹窗
    PopCheckUpdateView *_popUpdateView;
    id <APPlicationDelegate> delegate;
    
    UIBackgroundTaskIdentifier bgTask;
    long counter;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) CustomNavigationController *navController;
@property (nonatomic, retain) UIPageControl *pageControll;
@property (nonatomic, retain) UIScrollView *guideUIScrollView;
@property (nonatomic, retain) NSString *myDeviceToken;
@property (nonatomic, retain) NSString *province;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *area;
@property (nonatomic, assign) id <APPlicationDelegate> delegate;
@property (nonatomic, retain) UIImage *headerImage;
@property (nonatomic, assign) int Guideflag;
@property (nonatomic, assign) int mapflag;                          // 判断
@property (nonatomic, assign) int type;                             // push类型
@property (nonatomic, assign) int closetype;
@property (nonatomic, retain) NSString *infoId;
@property (nonatomic, assign) int pushClick;                      // push点击次数
@property (nonatomic, assign) int pushCount;                      // push接收次数
@property (nonatomic, assign) int cityFlag;                       // 城市定位flag
@property (nonatomic, retain) NSString *appUrl;
@property (nonatomic, retain) NSString *shopIdStr;
@property (nonatomic, retain) NSString *shopName;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
@end

