//
//  CommandOperationParser.h
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CmdOperationParser : NSObject

+ (NSMutableArray*)parser:(int)commandId withJsonResult:(NSString*)jsonResult withVersion:(int*)ver withParam:(NSMutableDictionary*)param;

// 设备令牌接口
+ (NSMutableArray*)parseApns:(NSDictionary *)resultDic getVersion:(int*)ver;

// 广告接口
+ (NSMutableArray*)parseAd:(NSDictionary *)resultDic getVersion:(int*)ver;

// 分店列表接口
+ (NSMutableArray*)parseNearShop:(NSDictionary *)resultDic getVersion:(int*)ver;

// 热销商品接口
+ (NSMutableArray*)parseHotProducts:(NSDictionary *)resultDic getVersion:(int*)ver;

// 资讯列表接口
+ (NSMutableArray*)parseInformations:(NSDictionary *)resultDic getVersion:(int*)ver;

//资讯列表 more
+ (NSMutableArray*)parseInformationsMore:(NSDictionary *)resultDic getVersion:(int*)ver;

//资讯列表详情页面 数据
+ (NSMutableArray*)parseInformationDetail:(NSDictionary *)resultDic getVersion:(int*)ver;

//资讯详情 评论
+ (NSMutableArray*)parseInformationComments:(NSDictionary *)resultDic getVersion:(int*)ver;

//售后服务 在线预约接口
+ (NSMutableArray*)parseResult:(NSDictionary *)resultDic getVersion:(int*)ver;

//应用库分类
+ (NSMutableArray*)parseAppCats:(NSDictionary *)resultDic getVersion:(int*)ver withShopId:(int)shop_id;

//应用库分类 more
+ (NSMutableArray*)parseAppCatsMore:(NSDictionary *)resultDic getVersion:(int*)ver withShopId:(int)shop_id;

//应用库分类列表
+ (NSMutableArray*)parseAppCatList:(NSDictionary *)resultDic withId:(int)cat_Id getVersion:(int*)ver withShopId:(int)shop_id;

//应用库分类列表 more
+ (NSMutableArray*)parseAppCatListMore:(NSDictionary *)resultDic getVersion:(int*)ver withShopId:(int)shop_id;

// 添加或者修改地址时提供地址选择器
+ (NSMutableArray *)parseAddressChoice_list:(NSDictionary *)resultDic getVersion:(int*)ver;

// 分享获得优惠券
+ (NSMutableArray *)parseShare_pf:(NSDictionary *)resultDic getVersion:(int*)ver;

// 商品列表接口
+ (NSMutableArray *)parseShop_list:(NSDictionary *)resultDic getVersion:(int*)ver;

// 商品列表接口  更多
+ (NSMutableArray *)parseShop_list_more:(NSDictionary *)resultDic getVersion:(int*)ver;

// 商品分类接口
+ (NSMutableArray *)parseproduct_cat:(NSDictionary *)resultDic getVersion:(int*)ver withCommandId:(int)_commandId;

// 首页产品中心 商品列表接口
+ (NSMutableArray *)parseProductsCenter_list:(NSDictionary *)resultDic getVersion:(int*)ver;

// 搜索商品接口
+ (NSMutableArray *)parseSearch_shop:(NSDictionary *)resultDic getVersion:(int*)ver;

// 商品详情接口
+ (NSMutableArray *)parseShop_detail:(NSDictionary *)resultDic getVersion:(int*)ver;

// 猜你喜欢接口
+ (NSMutableArray *)parseGuess_like:(NSDictionary *)resultDic getVersion:(int*)ver;

// 评论列表接口
+ (NSMutableArray *)parseComment_list:(NSDictionary *)resultDic getVersion:(int*)ver;

// 喜欢接口
+ (NSMutableArray *)parseLike:(NSDictionary *)resultDic getVersion:(int*)ver;

// 评论接口
+ (NSMutableArray *)parseComment:(NSDictionary *)resultDic getVersion:(int*)ver;

// 地址列表接口
+ (NSMutableArray *)parseAddress_list:(NSDictionary *)resultDic getVersion:(int*)ver;

// 地址列表接口 更多
+ (NSMutableArray *)parseAddress_list_more:(NSDictionary *)resultDic getVersion:(int*)ver;

// 排序地址
+ (NSMutableArray *)parseAddress_sort:(NSDictionary *)resultDic getVersion:(int*)ver;

// 添加或者修改地址
+ (NSMutableArray *)parseAdd_update_address:(NSDictionary *)resultDic getVersion:(int*)ver;

// 提交预订
+ (NSMutableArray *)parseOrder:(NSDictionary *)resultDic getVersion:(int*)ver;

// 我的优惠券列表  
+ (NSMutableArray *)parseFavorable_list:(NSDictionary *)resultDic getVersion:(int*)ver;

// 我的优惠券列表  更多
+ (NSMutableArray *)parseFavorable_list_more:(NSDictionary *)resultDic getVersion:(int*)ver;

// 立即抢购可用优惠券
+ (NSMutableArray *)parseBook_coupons:(NSDictionary *)resultDic getVersion:(int*)ver;

// 优惠活动列表接口
+ (NSMutableArray *)parsePreactivity_list:(NSDictionary *)resultDic getVersion:(int*)ver;

// 优惠活动列表接口  更多
+ (NSMutableArray *)parsePreactivity_list_more:(NSDictionary *)resultDic getVersion:(int*)ver;

// 优惠活动详情
+ (NSMutableArray *)parsePreactivity_detail:(NSDictionary *)resultDic getVersion:(int*)ver;

// 参加优惠活动
+ (NSMutableArray *)parsePreactivity_join:(NSDictionary *)resultDic getVersion:(int*)ver;

// 优惠活动猜你喜欢
+ (NSMutableArray *)parsePreactivityGuess_like:(NSDictionary *)resultDic getVersion:(int*)ver;

// 统计
+ (NSMutableArray *)parseCount:(NSDictionary *)resultDic getVersion:(int*)ver;

// 优惠券可用商店地图
+ (NSMutableArray *)parsePreactivity_map:(NSDictionary *)resultDic getVersion:(int*)ver;

// 会员登录
+ (NSMutableArray *)parseLogin:(NSDictionary *)resultDic;

//会员注册
+ (NSMutableArray *)parseRegister:(NSDictionary *)resultDic;

//会员注销
+ (NSMutableArray *)parseLogout:(NSDictionary *)resultDic;

//会员获取验证码
+ (NSMutableArray *)parseGetauthcode:(NSDictionary *)resultDic;

//会员注册获取验证码
+ (NSMutableArray *)parseRegisterGetauthcode:(NSDictionary *)resultDic;

//会员修改密码
+ (NSMutableArray *)parseUpdatePwd:(NSDictionary *)resultDic;

//会员头像上传
+ (NSMutableArray *)parseUploaderImage:(NSDictionary *)resultDic;

//会员中心我赞过的商品接口
+ (NSMutableArray *)parseShopLikes:(NSDictionary *)resultDic;

//会员中心我赞过的商品接口 加载更多
+ (NSMutableArray *)parseShopMoreLikes:(NSDictionary *)resultDic;

//会员中心我赞过的资讯接口
+ (NSMutableArray *)parseMessageLikes:(NSDictionary *)resultDic;

//会员中心我赞过的资讯接口 加载更多
+ (NSMutableArray *)parseMessageMoreLikes:(NSDictionary *)resultDic;

//会员中心我的商品评论接口
+ (NSMutableArray *)parseShopComment:(NSDictionary *)resultDic;

//会员中心我的商品评论接口 加载更多
+ (NSMutableArray *)parseShopMoreComment:(NSDictionary *)resultDic;

//会员中心我的资讯评论接口
+ (NSMutableArray *)parseMsgComment:(NSDictionary *)resultDic;

//会员中心我的资讯评论接口 加载更多
+ (NSMutableArray *)parseMsgMoreComment:(NSDictionary *)resultDic;

//会员中心预订中全部预订接口
+ (NSMutableArray *)parseOrderlist:(NSDictionary *)resultDic;

//会员中心预订中全部预订接口 加载更多
+ (NSMutableArray *)parseOrderMorelist:(NSDictionary *)resultDic;

//会员中心预订中取消预订接口
+ (NSMutableArray *)parseCancelOrderlist:(NSDictionary *)resultDic;

//会员中心预订中取消预订接口 加载更多
+ (NSMutableArray *)parseCancelOrderMorelist:(NSDictionary *)resultDic;

//会员中心个人信息接口
+ (NSMutableArray *)parseUserinfo:(NSDictionary *)resultDic;

//会员中心预订中作废预订接口
+ (NSMutableArray *)parseOrderCancel:(NSDictionary *)resultDic;

//会员中心我的售后服务接口
+ (NSMutableArray *)parseMyAfterService:(NSDictionary *)resultDic;

//会员中心我的售后服务详情接口
+ (NSMutableArray *)parseMyServiceDetail:(NSDictionary *)resultDic;

//会员中心删除喜欢接口
+ (NSMutableArray *)parseDelLike:(NSDictionary *)resultDic;

//会员中心删除收货地址接口
+ (NSMutableArray *)parseDelAddress:(NSDictionary *)resultDic;


//百宝箱关于我们接口
+ (NSMutableArray *)parseAboutUs:(NSDictionary *)resultDic getVersion:(int*)ver;

//百宝箱应用推荐接口
+ (NSMutableArray *)parseRecommendApp:(NSDictionary *)resultDic getVersion:(int*)ver;

//百宝箱应用推荐接口 加载更多
+ (NSMutableArray *)parseMoreRecommendApp:(NSDictionary *)resultDic getVersion:(int*)ver;

//百宝箱发送留言反馈
+ (NSMutableArray*)parseSendFeedbackResult:(NSDictionary *)resultDic;

//百宝箱留言反馈列表
+ (NSMutableArray *)parseFeecbackList:(NSDictionary *)resultDic withId:(int)user_Id withShop:(int)shop_id;

//百宝箱留言反馈列表 more
+ (NSMutableArray *)parseFeecbackListMore:(NSDictionary *)resultDic withId:(int)user_Id withShop:(int)shop_id;
@end
