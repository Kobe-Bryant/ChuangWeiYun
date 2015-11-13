//
//  Global.h
//  cw
//
//  Created by siphp on 12-8-13.
//  Copyright 2012 yunlai. All rights reserved.
//

#include <netdb.h>
#import <CoreLocation/CoreLocation.h>
#import "WXApi.h"
#import "Common.h"

typedef enum _statusType {
    StatusTypeNormal                = 0,
	StatusTypeMemberShop            = 1,        // 会员中心商品详情页面
    StatusTypeMemberShopOrder       = 23,       // 会员中心预定页面商品详情页面
    StatusTypeMemberInformation     = 2,        // 会员中心资讯详情页面
    StatusTypeMemberChooseCity      = 3,        // 会员中心选择城市页面
    StatusTypeMemberChoosePf        = 4,        // 会员中心选择优惠券页面
    StatusTypeMemberChooseAddress   = 5,        // 会员中心选择地址列表页面
    StatusTypeMemberLogin           = 6,        // 会员中心是否登陆
    StatusTypeMap                   = 7,        // 分店列表和百宝箱关于我们定位页面进入地图
    StatusTypeHotShop               = 8,        // 热销商品挑跳详情
    StatusTypeHotAD                 = 9,        // 首页广告挑跳详情
    StatusTypePfDetail              = 10,       // 优惠活动详情跳转商品详情
    StatusTypeShopDetail            = 11,       // 商品详情跳转优惠活动详情
    StatusTypeAPP                   = 12,       // 启动后进入城市选择页
    StatusTypeDetailMap             = 13,       // 商品详情页进入地图
    StatusTypeFromCenter            = 14,       // 首页进入商品分类  hui add 2013.10.21
    StatusTypeFirstToMap            = 15,       // 首页附近的店进入地图
    StatusTypeServiceToMap          = 18,       // 便民服务进地图导航
    StatusTypeSelectSame            = 19,       // 实体店，选择相同城市的分店  hui add 11.11
    StatusTypeNearShop              = 20,       // 附近的店列表分店页面
    StatusTypeOrderToMember         = 21,       // 预订成功后今入会员预订列表，再点返回进入会员中心
    StatusTypeProductPush            = 22,
} CwStatusType;

/* ========================================全局变量=============================================== */

@interface Global : NSObject <WXApiDelegate>
{
    //定位
    CLLocationManager *locManager;
    CLLocationCoordinate2D myLocation;
    NSString *locationAddress;
    NSString *locationCity;
    // 当前城市
    NSString *currCity;
    //网络线程
    NSOperationQueue *netWorkQueue;
    NSMutableArray *netWorkQueueArray;
    
    // 用户ID
    NSString *user_id;
    // 分店ID
    NSString *shop_id;
    // 分享时的info_id(商品或者其他)
    NSString *info_id;

    //是否登陆
    BOOL _isLogin;
    BOOL _isChangedImage;
    
    // 定位是否开启失败
    BOOL _isLoction;
    // 是否为关店功能
    BOOL _isRefShop;
    BOOL _isCloseCity;
    
    NSString *shop_state;   //当前手机定位到的城市 有无分店       0 无 1有

    // TabBar判断定位
    BOOL loctionFlag;
    
    NSString *countObj_id;
    CountType _countType;
    NSString *shopCount;
    
    NSString *push_id; //推送id
}

@property (nonatomic, retain) CLLocationManager *locManager;
@property (nonatomic, assign) CLLocationCoordinate2D myLocation;
@property (nonatomic, retain) NSString *locationAddress;
@property (nonatomic, retain) NSString *locationCity;
@property (nonatomic, retain) NSString *currCity;
@property (nonatomic, retain) NSOperationQueue *netWorkQueue;
@property (nonatomic, retain) NSMutableArray *netWorkQueueArray;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *shop_id;
@property (nonatomic, retain) NSString *info_id;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) BOOL isChangedImage;
@property (nonatomic, assign) BOOL isLoction;
@property (nonatomic, assign) BOOL loctionFlag;
@property (nonatomic, assign) BOOL isRefShop;
@property (nonatomic, assign) BOOL isCloseCity;

@property (nonatomic, retain) NSString *shop_state;
//hui add
@property (nonatomic, retain) NSString *countObj_id;
@property (nonatomic, assign) CountType _countType;

@property (nonatomic, retain) NSString *push_id;

+ (Global *)sharedGlobal;

- (void)registerWXApi;

- (BOOL)handleOpenURL:(NSURL *)url delegate:(id)delegate;

@end