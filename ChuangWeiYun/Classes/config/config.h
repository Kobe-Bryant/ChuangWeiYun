//
//  config.h
//  cw
//
//  Created by siphp on 13-8-7.
//  Copyright 2012 yunlai. All rights reserved.
//

/* ========================================系统 参数=============================================== */

//app名称
//#define appName @"创维云GO"
#define APPName @"创维云GO"

//系统版本号
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//版本ID KEY
#define APP_SOFTWARE_VER_KEY @"app_ver"

//版本ID 当前版本号
#define CURRENT_APP_VERSION 4

//引导页面个数 GuideView
#define GUIDE_VIEW_NUM 4

//城市 KEY
#define CITY_KEY @"city_key"
//分店 KEY
#define SHOP_KEY @"shop_key"

//是否显示引导 KEY
#define GUIDE_KEY @"guide_key"

//token号 key
#define TOKEN_KEY @"token_key"

/* ========================================UI 配置=============================================== */
//bar 配置
#define SHOW_NAV_TAB_BG 2
#define BG_NAV_PIC @"top_bar.png"
#define IOS7BG_NAV_PIC @"top_bar2.png"
#define BG_TAB_PIC @"bg_bottom_bar.png"

//上bar按钮颜色
#define COLOR_BAR_BUTTON [UIColor colorWithRed:15.f/255.f green:81.f/255.f blue:173.f/255.f alpha:1.f];

//底部bar 配置
#define ARRAYS_TAB_BAR [NSArray arrayWithObjects:@"首页",@"实体店",@"资讯",@"会员",@"百宝箱",nil];
#define ARRAYS_TAB_PIC_NAME [NSArray arrayWithObjects:@"home",@"shop",@"preferential",@"member",@"box",nil];

//下bar 文字未选中颜色
#define COLOR_UNSELECTED_TAB_BAR [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];

//下bar 文字选中颜色
#define COLOR_SELECTED_TAB_BAR [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];

//售后服务电话号码
#define SALE_SERVICE_PHONE_NUM @"95105555"

/* ========================================应用 配置=============================================== */

//网络请求接口地址

//#define ACCESS_SERVER_LINK @"http://192.168.1.28:8080/CW_APPInterfaceServer/"
#define ACCESS_SERVER_LINK @"http://app.skyallhere.net:9001/CW_APPInterfaceServer/"
//#define ACCESS_SERVER_LINK @"http://202.104.149.214:8080/CW_APPInterfaceServer/"


//网络请求加密key
#define SignSecureKey       @"CWAPP9I0I6IyunlaiINTERFACE"

//数据库名称
#define dataBaseFile        @"cw.db"

//图片下载最大数
#define DOWNLOAD_IMAGE_MAX_COUNT 3

//loading提示
#define LOADING_TIPS        @"云端同步中..."

//更新版本标题
#define VERSIONTITLE        @"发现新版本 v1.0.3"

//分享
#define CLIENT_SHARE_LINK   @"http://yungo.skyallhere.net:9001/download/index"

//微信授权
#define WEICHATID           @"wx26dc8e121a2fa5d1"
// QQ授权
#define QQTencent           @"100520264"    // (注：需要将其转为16进制)
//微博接口
#define SINA                @"sina"
#define TENCENT             @"tencent"
#define SinaAppKey          @"3494009615"
#define SinaAppSecret       @"e94cd60e99c18bbf0df7aaf3811f6c85"
#define QQAppKey            @"801460729"
#define QQAppSecret         @"dd4f243aa71ef1589d90c2bfcde18585"
#define SINAredirectUrl     @"http://our.3g.yunlai.cn"
#define TENCENTredirectUrl  @"http://yungo.skyallhere.net:9001/download/index"

#define HOME_STR_COLOR [UIColor colorWithRed:102.f/255.f green:102.f/255.f blue:102.f/255.f alpha:1.f]

/* ========================================网络请求标识=============================================== */

#define NEED_UPDATE     1
#define NO_UPDATE       0

//设备令牌
#define APNS_COMMAND_ID                     1

//广告
#define OPERAT_AD_REFRESH                   2

//分店列表接口
#define SUBBRANCH_COMMAND_ID                6

//热销商品接口
#define HOT_PRODUCTS_COMMAND_ID              3
//资讯列表接口
#define INFORMATIONS_COMMAND_ID              4
//资讯列表接口 more
#define INFORMATIONS_MORE_COMMAND_ID         5
//资讯详情 请求数据
#define INFOR_DETAIL_COMMAND_ID              8
//售后服务 在线预约
#define SALE_SERVICE_COMMAND_ID              9
//应用库分类
#define SERVICE_CATS_COMMAND_ID              10
//应用库分类 more
#define SERVICE_CATS_MORE_COMMAND_ID         11
//应用库分类列表
#define SERVICE_CAT_LIST_COMMAND_ID          12
//应用库分类列表 more
#define SERVICE_CAT_LIST_MORE_COMMAND_ID     13
//取消喜欢 
#define CANCEL_LIKE_COMMAND_ID               14

//首页 产品中心
#define PRODUCTS_CENTER_COMMAND_ID           15
//首页 产品中心 商品列表
#define PRODUCTS_CENTER_LIST_COMMAND_ID      16
//首页 产品中心 商品列表更多
#define PRODUCTS_CENTER_LIST_MORE_COMMAND_ID 17

// 添加或者修改地址时提供地址选择器
#define ADDRESSCHOICELIST_COMMAND_ID        20

//分享获取优惠券
#define SHARE_GET_COMMAND_ID                29

// 分店 区间 30 -- 50
// 商品列表
#define SHOP_LIST_COMMAND_ID                30
// 商品列表 更多
#define SHOP_LIST_MORE_COMMAND_ID           31
// 商品分类
#define PRODUCT_CAT_COMMAND_ID              32
// 搜索商品
#define SEARCH_SHOP_COMMAND_ID              33
// 搜索商品 更多
#define SEARCH_SHOP_MORE_COMMAND_ID         34
// 商品详情接口
#define SHOP_DETAIL_COMMAND_ID              35
// 猜你喜欢列表接口
#define GUESSLIKE_COMMAND_ID                36
// 评论列表
#define COMMENT_LIST_COMMAND_ID             37
// 评论列表 更多
#define COMMENT_LIST_MORE_COMMAND_ID        38
// 喜欢
#define LIKE_COMMAND_ID                     39
// 评论
#define COMMENT_COMMAND_ID                  40
// 地址列表
#define ADDRESS_LIST_COMMAND_ID             41
// 地址列表 更多
#define ADDRESS_LIST_MORE_COMMAND_ID        42
// 添加或者修改会员地址
#define ADD_UPDATE_ADDRESS_COMMAND_ID       43
// 删除会员地址
#define DEL_MEMBER_ADDRESS_COMMAND_ID       44
// 提交预订
#define ORDER_COMMAND_ID                    45
// 我的优惠券列表
#define FAVORABLE_LIST_COMMAND_ID           46
// 我的优惠券列表 更多
#define FAVORABLE_LIST_MORE_COMMAND_ID      47
// 立即抢购可用优惠券
#define BOOK_COUPONS_COMMAND_ID             48
// 立即抢购可用优惠券 更多
#define BOOK_COUPONS_MORE_COMMAND_ID        49

// 优惠 区间 50 -- 60
// 优惠活动列表
#define PREACTIVITY_LIST_COMMAND_ID         50
// 优惠活动列表 更多
#define PREACTIVITY_LIST_MORE_COMMAND_ID    51
// 优惠活动详情
#define PREACTIVITY_DETAIL_COMMAND_ID       52
// 参加优惠活动
#define PREACTIVITY_JOIN_COMMAND_ID         53
// 优惠活动猜你喜欢列表接口
#define PREACTIVITY_GUESSLIKE_COMMAND_ID    54

// 统计
#define COUNT_COMMAND_ID                    55
// 可用的优惠券地图
#define PREACTIVITY_MAP_COMMAND_ID          56
// 排序地区地址
#define SORT_ADDRESS_COMMAND_ID             57

// 会员 区间 60 -- 90
// 会员登录
#define MEMBER_LOGIN_COMMAND_ID         61

//会员注册
#define MEMBER_REGIST_COMMAND_ID        62

//会员注册获取验证码
#define MEMBER_REGISTERAUTHCODE_COMMAND_ID 100

//会员获取验证码
#define MEMBER_AUTHCODE_COMMAND_ID      63

//会员重置密码
#define MEMBER_UPDATEPWD_COMMAND_ID     64

//会员上传头像
#define MEMBER_UPDATEPIMAGE_COMMAND_ID  65

//会员注销
#define MEMBER_LOGOUT_COMMAND_ID        66

//会员赞的商品列表
#define MEMBER_SHOPLIKE_COMMAND_ID      67

//会员赞的商品列表 加载更多
#define MEMBER_SHOPLIKE_MORE_COMMAND_ID 68

//会员赞的资讯列表
#define MEMBER_NEWSLIKE_COMMAND_ID      69

//会员赞的资讯列表 加载更多
#define MEMBER_NEWSLIKE_MORE_COMMAND_ID 70

//会员商品评论列表
#define MEMBER_SHOPCOMMEND_COMMAND_ID   71

//会员商品评论列表 加载更多
#define MEMBER_SHOPCOMMEND_MORE_COMMAND_ID 72

//会员资讯评论列表
#define MEMBER_MSGCOMMEND_COMMAND_ID       73

//会员资讯评论列表 加载更多
#define MEMBER_MSGCOMMEND_MORE_COMMAND_ID  74

//会员全部预订列表
#define MEMBER_ORDERLIST_COMMAND_ID        75

//会员全部预订列表 加载更多
#define MEMBER_ORDERLIST_MORE_COMMAND_ID   76

//会员取消预订列表
#define MEMBER_CANCELORDER_COMMAND_ID      77

//会员取消预订列表 加载更多
#define MEMBER_CANCELORDER_MORE_COMMAND_ID 78

//会员个人信息
#define MEMBER_USERINFO_COMMAND_ID         79

//会员预订中预订取消
#define MEMBER_ORDERCANCEL_COMMAND_ID      80

//会员中心我的售后服务
#define MEMBER_AFTERSERVICE_COMMAND_ID     81

//会员中心我的售后服务详情
#define MEMBER_AFTERSERVICE_DETAIL_COMMAND_ID  82

//会员删除商品喜欢
#define MEMBER_SHOPDELLIKE_COMMAND_ID      83

//会员删除资讯喜欢
#define MEMBER_MSGDELLIKE_COMMAND_ID       84


// 百宝箱 区间 90 -- 100

//关于我们
#define ABOUTUS_COMMAND_ID              90
#define SEND_FEEDBACK_COMMAND_ID        91
#define LOGIN_FEEDBACK_LIST_COMMAND_ID  92
#define FEEDBACK_LIST_MORE_COMMAND_ID   93

//应用推荐
#define RECOMMEND_APP_COMMAND_ID        94

//应用推荐加载更多
#define RECOMMEND_APP_MORE_COMMAND_ID   95

/* ========================================公用====================================================== */
// 尺寸
#define KUpBarHeight            44.f
#define KDownBarHeight          49.f
#define KUIScreenWidth          [UIScreen mainScreen].applicationFrame.size.width
#define KUIScreenHeight         [UIScreen mainScreen].applicationFrame.size.height

// IOS7适配
#define IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)

#define IOS6_7_DELTA(V,X,Y,W,H) if(IOS_7) {CGRect f = V.frame;f.origin.x += X;f.origin.y += Y;f.size.width +=W;f.size.height += H;V.frame=f;}

// 视图字体
#define KCWSystemFont(s)        [UIFont systemFontOfSize:s]
#define KCWboldSystemFont(s)    [UIFont boldSystemFontOfSize:s]

// view的背景色
#define KCWViewBgColor          [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]

#define KCWNetNOPrompt          @"网络不可用，请检查您的网络"
#define KCWServerBusyPrompt     @"服务器繁忙，请稍后再试"
#define KCWNetBusyPrompt        @"网络繁忙，加载失败，请稍后再试"

// 内存release置空
#define RELEASE_SAFE(x) do{[x release];x=nil;} while(0)


