//
//  CommandOperationParser.m
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import "CmdOperationParser.h"
#import "SBJson.h"
#import "NSObject+SBJson.h"
#import "JSONKit.h"
#import "Common.h"
#import "ad_model.h"
#import "shop_near_list_model.h"
#import "hot_products_model.h"
#import "shop_list_model.h"
#import "shop_list_pics_model.h"
#import "product_cat_model.h"
#import "preactivity_list_model.h"
#import "preactivity_list_pics_model.h"
#import "preactivity_list_partner_pics_model.h"
#import "informations_model.h"
#import "information_images_model.h"
#import "member_info_model.h"
#import "member_shoplikes_model.h"
#import "member_msglikes_model.h"
#import "member_shopcomment_model.h"
#import "member_msgcomment_model.h"
#import "member_shopcommentPic_model.h"
#import "member_msgcommentPic_model.h"
#import "member_shoplikePic_model.h"
#import "member_msglikePic_model.h"
#import "member_allorder_list_model.h"
#import "member_allorder_listPic_model.h"
#import "member_orderdetail_list_model.h"
#import "member_after_service_model.h"
#import "service_cats_model.h"
#import "service_cat_list_model.h"
#import "address_list_model.h"
#import "favorable_list_pic_model.h"
#import "favorable_list_model.h"
#import "about_us_model.h"
#import "afterservice_detail_model.h"
#import "recommend_app_ads_model.h"
#import "recommend_app_model.h"
#import "apns_model.h"
#import "promotion_model.h"
#import "autopromotion_model.h"
#import "grade_model.h"
#import "member_likeshop_model.h"
#import "member_likeinformation_model.h"
#import "feedback_list_model.h"
#import "products_center_model.h"
#import "productsCenter_list_model.h"
#import "productsCenter_list_pics_model.h"
#import "addressChoice_list_model.h"
#import "Global.h"
#import "HttpRequest.h"
#import "promotions_id_model.h"
#import "informations_media_model.h"

@implementation CmdOperationParser

+(NSMutableArray*)parser:(int)commandId withJsonResult:(NSString*)jsonResult withVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
    NSMutableArray *resultArray = nil;

    NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    if (resultDic != nil && resultDic.count > 0) {
//        if ([[resultDic objectForKey:@"ret"] intValue] == -1) {
//            resultArray = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:-1]];
//        } else {
            // 根据 commandId 来确定解析数据的操作
            switch (commandId)
            {
                case APNS_COMMAND_ID:
                {
                    resultArray = [self parseApns:resultDic getVersion:ver];
                }
                    break;
                case OPERAT_AD_REFRESH:
                {
                    resultArray = [self parseAd:resultDic getVersion:ver];
                }
                    break;
                case SUBBRANCH_COMMAND_ID:
                {
                    resultArray = [self parseNearShop:resultDic getVersion:ver];
                }
                    break;
                case HOT_PRODUCTS_COMMAND_ID:
                {
                    resultArray = [self parseHotProducts:resultDic getVersion:ver];
                }
                    break;
                case INFORMATIONS_COMMAND_ID:
                {
                    resultArray = [self parseInformations:resultDic getVersion:ver];
                }
                    break;
                case INFORMATIONS_MORE_COMMAND_ID:
                {
                    resultArray = [self parseInformationsMore:resultDic getVersion:ver];
                }
                    break;
                case INFOR_DETAIL_COMMAND_ID:
                {
                    resultArray = [self parseInformationDetail:resultDic getVersion:ver];
                }
                    break;
                case SALE_SERVICE_COMMAND_ID:
                {
                    resultArray = [self parseResult:resultDic getVersion:ver];
                }
                    break;
                case SERVICE_CATS_COMMAND_ID:
                {
                    int shop_id = [[param objectForKey:@"shop"] intValue];
                    resultArray = [self parseAppCats:resultDic getVersion:ver withShopId:shop_id];
                }
                    break;
                case SERVICE_CATS_MORE_COMMAND_ID:
                {
                    int shop_id = [[param objectForKey:@"shop"] intValue];
                    resultArray = [self parseAppCatsMore:resultDic getVersion:ver withShopId:shop_id];
                }
                    break;
                case SERVICE_CAT_LIST_COMMAND_ID:
                {
                    int cat_id = [[param objectForKey:@"cat_id"] intValue];
                    int shop_id = [[param objectForKey:@"shop"] intValue];
                    resultArray = [self parseAppCatList:resultDic withId:cat_id getVersion:ver withShopId:shop_id];
                }
                    break;
                case SERVICE_CAT_LIST_MORE_COMMAND_ID:
                {
                    int shop_id = [[param objectForKey:@"shop"] intValue];
                    resultArray = [self parseAppCatListMore:resultDic getVersion:ver withShopId:shop_id];
                }
                    break;
                case ADDRESSCHOICELIST_COMMAND_ID:      // 添加或者修改地址时提供地址选择器
                {
                    resultArray = [self parseAddressChoice_list:resultDic getVersion:ver];
                }
                    break;
                case SHARE_GET_COMMAND_ID:              // 分享获得优惠券
                {
                    resultArray = [self parseShare_pf:resultDic getVersion:ver];
                }
                    break;
                case SHOP_LIST_COMMAND_ID:              // 商品列表
                {
                    resultArray = [self parseShop_list:resultDic getVersion:ver];
                }
                    break;
                case SHOP_LIST_MORE_COMMAND_ID:         // 商品列表  更多
                {
                    resultArray = [self parseShop_list_more:resultDic getVersion:ver];
                }
                    break;
                case PRODUCT_CAT_COMMAND_ID:            // 商品分类
                {
                    resultArray = [self parseproduct_cat:resultDic getVersion:ver withCommandId:PRODUCT_CAT_COMMAND_ID];
                }
                    break;
                case PRODUCTS_CENTER_COMMAND_ID:            // 首页 产品中心
                {
                    resultArray = [self parseproduct_cat:resultDic getVersion:ver withCommandId:PRODUCTS_CENTER_COMMAND_ID];
                }
                    break;
                case PRODUCTS_CENTER_LIST_COMMAND_ID:              // 首页产品中心 商品列表接口
                {
                    resultArray = [self parseProductsCenter_list:resultDic getVersion:ver];
                }
                    break;
                case PRODUCTS_CENTER_LIST_MORE_COMMAND_ID:         // 首页产品中心 商品列表接口  更多
                {
                    resultArray = [self parseShop_list_more:resultDic getVersion:ver];
                }
                    break;
                    
                case SEARCH_SHOP_COMMAND_ID:            // 搜索商品
                {
                    resultArray = [self parseSearch_shop:resultDic getVersion:ver];
                }
                    break;
                case SEARCH_SHOP_MORE_COMMAND_ID:       // 搜索商品 更多
                {
                    resultArray = [self parseSearch_shop:resultDic getVersion:ver];
                }
                    break;
                case SHOP_DETAIL_COMMAND_ID:            // 商品详情
                {
                    resultArray = [self parseShop_detail:resultDic getVersion:ver];
                }
                    break;
                case GUESSLIKE_COMMAND_ID:              // 猜你喜欢
                {
                    resultArray = [self parseGuess_like:resultDic getVersion:ver];
                }
                    break;
                case COMMENT_LIST_COMMAND_ID:           // 评论列表
                {
                    resultArray = [self parseComment_list:resultDic getVersion:ver];
                }
                    break;
                case COMMENT_LIST_MORE_COMMAND_ID:      // 评论列表 更多
                {
                    resultArray = [self parseComment_list:resultDic getVersion:ver];
                }
                    break;
                case LIKE_COMMAND_ID:                   // 喜欢
                {
                    resultArray = [self parseLike:resultDic getVersion:ver];
                }
                    break;
                case CANCEL_LIKE_COMMAND_ID:               ////////// 取消喜欢
                {
                    resultArray = [self parseLike:resultDic getVersion:ver];
                }
                    break;
                case COMMENT_COMMAND_ID:                // 评论
                {
                    resultArray = [self parseComment:resultDic getVersion:ver];
                }
                    break;
                case ADDRESS_LIST_COMMAND_ID:           // 地址列表
                {
                    resultArray = [self parseAddress_list:resultDic getVersion:ver];
                }
                    break;
                case ADDRESS_LIST_MORE_COMMAND_ID:      // 地址列表 更多
                {
                    resultArray = [self parseAddress_list:resultDic getVersion:ver];
                }
                    break;
                case SORT_ADDRESS_COMMAND_ID:           // 排序地址
                {
                    resultArray = [self parseAddress_sort:resultDic getVersion:ver];
                }
                    break;
                case ADD_UPDATE_ADDRESS_COMMAND_ID:     // 添加或者修改地址
                {
                    resultArray = [self parseAdd_update_address:resultDic getVersion:ver];
                }
                    break;
                case ORDER_COMMAND_ID:                  // 提交预订
                {
                    resultArray = [self parseOrder:resultDic getVersion:ver];
                }
                    break;
                case FAVORABLE_LIST_COMMAND_ID:         // 我的优惠券列表
                {
                    resultArray = [self parseFavorable_list:resultDic getVersion:ver];
                }
                    break;
                case FAVORABLE_LIST_MORE_COMMAND_ID:    // 我的优惠券列表  更多
                {
                    resultArray = [self parseFavorable_list_more:resultDic getVersion:ver];
                }
                    break;
                case BOOK_COUPONS_COMMAND_ID:           // 立即抢购可用优惠券
                {
                    resultArray = [self parseBook_coupons:resultDic getVersion:ver];
                }
                    break;
                case BOOK_COUPONS_MORE_COMMAND_ID:      // 立即抢购可用优惠券 更多
                {
                    resultArray = [self parseBook_coupons:resultDic getVersion:ver];
                }
                    break;
                case PREACTIVITY_LIST_COMMAND_ID:       // 优惠活动列表
                {
                    resultArray = [self parsePreactivity_list:resultDic getVersion:ver];
                }
                    break;
                case PREACTIVITY_LIST_MORE_COMMAND_ID:  // 优惠活动列表  更多
                {
                    resultArray = [self parsePreactivity_list_more:resultDic getVersion:ver];
                }
                    break;
                case PREACTIVITY_DETAIL_COMMAND_ID:     // 优惠活动详情
                {
                    resultArray = [self parsePreactivity_detail:resultDic getVersion:ver];
                }
                    break;
                case PREACTIVITY_JOIN_COMMAND_ID:       // 参加优惠活动
                {
                    resultArray = [self parsePreactivity_join:resultDic getVersion:ver];
                }
                    break;
                case PREACTIVITY_GUESSLIKE_COMMAND_ID:  // 优惠活动猜你喜欢
                {
                    resultArray = [self parsePreactivityGuess_like:resultDic getVersion:ver];
                }
                    break;
                case COUNT_COMMAND_ID:                  // 统计
                {
                    resultArray = [self parseCount:resultDic getVersion:ver];
                }
                    break;
                case PREACTIVITY_MAP_COMMAND_ID:        // 优惠券可用商店地图
                {
                    resultArray = [self parsePreactivity_map:resultDic getVersion:ver];
                }
                    break;
                case MEMBER_LOGIN_COMMAND_ID: // 会员登录
                {
                    resultArray = [self parseLogin:resultDic];
                }
                    break;
                case MEMBER_REGIST_COMMAND_ID: // 会员注册
                {
                    resultArray= [self parseRegister:resultDic];
                }
                    break;
                case MEMBER_LOGOUT_COMMAND_ID: // 会员注销
                {
                    resultArray= [self parseLogout:resultDic];
                }
                    break;
                    
                case MEMBER_AUTHCODE_COMMAND_ID: //会员获取验证码
                {
                    resultArray= [self parseGetauthcode:resultDic];
                }
                    break;
                    
                case MEMBER_REGISTERAUTHCODE_COMMAND_ID: //会员注册获取验证码
                {
                    resultArray= [self parseRegisterGetauthcode:resultDic];
                }
                    break;
                case MEMBER_UPDATEPWD_COMMAND_ID: // 会员密码修改
                {
                    resultArray= [self parseUpdatePwd:resultDic];
                }
                    break;
                case MEMBER_UPDATEPIMAGE_COMMAND_ID: // 会员头像上传
                {
                    resultArray= [self parseUploaderImage:resultDic];
                }
                    break;
                case MEMBER_SHOPLIKE_COMMAND_ID: // 会员我赞过的商品
                {
                    resultArray= [self parseShopLikes:resultDic];
                }
                    break;
                case MEMBER_SHOPLIKE_MORE_COMMAND_ID: // 会员我赞过的商品 加载更多
                {
                    resultArray= [self parseShopMoreLikes:resultDic];
                }
                    break;
                case MEMBER_NEWSLIKE_COMMAND_ID: // 会员我赞过的资讯
                {
                    resultArray= [self parseMessageLikes:resultDic];
                }
                    break;
                case MEMBER_NEWSLIKE_MORE_COMMAND_ID: // 会员我赞过的资讯 加载更多
                {
                    resultArray= [self parseMessageMoreLikes:resultDic];
                }
                    break;
                    
                case MEMBER_SHOPCOMMEND_COMMAND_ID: // 会员我的商品评论
                {
                    resultArray= [self parseShopComment:resultDic];
                }
                    break;
                case MEMBER_SHOPCOMMEND_MORE_COMMAND_ID: // 会员我的商品评论 更多
                {
                    resultArray= [self parseShopMoreComment:resultDic];
                }
                    break;
                    
                case MEMBER_MSGCOMMEND_COMMAND_ID: // 会员我的资讯评论
                {
                    resultArray= [self parseMsgComment:resultDic];
                }
                    break;
                    
                case MEMBER_MSGCOMMEND_MORE_COMMAND_ID: // 会员我的资讯评论 更多
                {
                    resultArray= [self parseMsgMoreComment:resultDic];
                }
                    break;
                    
                case MEMBER_ORDERLIST_COMMAND_ID: // 会员预订中全部预订
                {
                    resultArray= [self parseOrderlist:resultDic];
                }
                    break;
                    
                case MEMBER_ORDERLIST_MORE_COMMAND_ID: // 会员预订中全部预订 更多
                {
                    resultArray= [self parseOrderMorelist:resultDic];
                }
                    break;
                    
                case MEMBER_CANCELORDER_COMMAND_ID: // 会员预订中取消预订
                {
                    resultArray= [self parseCancelOrderlist:resultDic];
                }
                    break;
                    
                case MEMBER_USERINFO_COMMAND_ID: // 会员个人信息
                {
                    resultArray= [self parseUserinfo:resultDic];
                }
                    break;
                    
                case MEMBER_ORDERCANCEL_COMMAND_ID: // 会员取消预订
                {
                    resultArray= [self parseOrderCancel:resultDic];
                }
                    break;
                    
                case MEMBER_CANCELORDER_MORE_COMMAND_ID: // 会员取消预订 更多
                {
                    resultArray= [self parseCancelOrderMorelist:resultDic];
                }
                    break;
                    
                case MEMBER_AFTERSERVICE_COMMAND_ID: // 会员我的售后服务
                {
                    resultArray= [self parseMyAfterService:resultDic];
                }
                    break;
                    
                case MEMBER_AFTERSERVICE_DETAIL_COMMAND_ID: // 会员我的售后服务详情
                {
                    resultArray= [self parseMyServiceDetail:resultDic];
                }
                    break;
                    
                case MEMBER_SHOPDELLIKE_COMMAND_ID: // 会员删除商品喜欢
                {
                    resultArray= [self parseDelLike:resultDic];
                }
                    break;
                case MEMBER_MSGDELLIKE_COMMAND_ID: // 会员删除资讯喜欢
                {
                    resultArray= [self parseDelLike:resultDic];
                }
                    break;
                    
                case DEL_MEMBER_ADDRESS_COMMAND_ID: // 会员删除收货地址
                {
                    resultArray= [self parseDelAddress:resultDic];
                }
                    break;
                    
                case ABOUTUS_COMMAND_ID: // 百宝箱关于我们
                {
                    resultArray= [self parseAboutUs:resultDic getVersion:ver];
                }
                    break;
                case SEND_FEEDBACK_COMMAND_ID: // 百宝箱留言反馈
                {
                    resultArray= [self parseSendFeedbackResult:resultDic];
                }
                    break;
                case LOGIN_FEEDBACK_LIST_COMMAND_ID: // 百宝箱留言反馈list
                {
                    int user_id = [[param objectForKey:@"user_id"] intValue];
                    int shop_id = [[param objectForKey:@"shop_id"] intValue];
                    resultArray= [self parseFeecbackList:resultDic withId:user_id withShop:shop_id];
                }
                    break;
                case FEEDBACK_LIST_MORE_COMMAND_ID: // 百宝箱留言反馈list more
                {
                    int user_id = [[param objectForKey:@"user_id"] intValue];
                    int shop_id = [[param objectForKey:@"shop_id"] intValue];
                    resultArray= [self parseFeecbackListMore:resultDic withId:user_id withShop:shop_id];
                }
                    break;
                case RECOMMEND_APP_COMMAND_ID: // 百宝箱应用推荐
                {
                    resultArray= [self parseRecommendApp:resultDic getVersion:ver];
                }
                    break;
                case RECOMMEND_APP_MORE_COMMAND_ID: // 百宝箱应用推荐 加载更多
                {
                    resultArray= [self parseMoreRecommendApp:resultDic getVersion:ver];
                }
                    break;
                default:
                    break;
            }
//        }
    } else {
        resultArray = [NSMutableArray arrayWithObject:CwRequestTimeout];
    }

    return resultArray;
}

//设备令牌接口
+ (NSMutableArray*)parseApns:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    // 是否成功
    int ret = [[resultDic objectForKey:@"ret"] intValue];
	int is_Success = [[resultDic objectForKey:@"isSuccess"] intValue];
    NSLog(@"is_Success = %d",is_Success);
    // 成功
    if (is_Success == 1) {
        
        //创建模型
        apns_model *aMod = [[apns_model alloc] init];
        promotion_model *pMod = [[promotion_model alloc] init];
        autopromotion_model *atpMod = [[autopromotion_model alloc] init];
        grade_model *gMod = [[grade_model alloc] init];

        // apns信息
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [resultDic objectForKey:@"pro_ver"],@"pro_ver",
                              [resultDic objectForKey:@"grade_ver"],@"grade_ver",
                              [resultDic objectForKey:@"share_product_url"],@"share_product_url",
                              [resultDic objectForKey:@"share_news_url"],@"share_news_url",
                              [resultDic objectForKey:@"share_promotion_url"],@"share_promotion_url",
                              [resultDic objectForKey:@"client_downurl"],@"client_downurl",
                              nil];

        NSMutableArray *dbArray = [aMod getList];
        if ([dbArray count] > 0) {
            [aMod updateDB:dict];
        } else {
            [aMod insertDB:dict];
        }
        
        int pro_ver = [[resultDic objectForKey:@"pro_ver"] intValue];
        
        if ([[Common getVersion:APNS_COMMAND_ID] intValue] != pro_ver) {
            [pMod deleteDBdata];
        }
        
        // 优惠券信息
        NSDictionary *promotionDict = [resultDic objectForKey:@"promotion"];
        
        if (promotionDict != nil) {
            dbArray = [pMod getList];
            if ([dbArray count] > 0) {
                [pMod updateDB:promotionDict];
            } else {
                [pMod insertDB:promotionDict];
            }
        }
        
        // 评分地址
        NSDictionary *gradeDict = [resultDic objectForKey:@"grade"];
        
        if (gradeDict != nil) {
            dbArray = [gMod getList];
            if ([dbArray count] > 0) {
                [gMod updateDB:gradeDict];
            } else {
                [gMod insertDB:gradeDict];
            }
        }
        
        // 检查更新
        NSDictionary *autopromotionDict = [resultDic objectForKey:@"autopromotion"];
        
        if (autopromotionDict != nil) {
            dbArray = [atpMod getList];
            if ([dbArray count] > 0) {
                [atpMod updateDB:autopromotionDict];
            } else {
                [atpMod insertDB:autopromotionDict];
            }
        }

        [aMod release];
        [pMod release];
        [atpMod release];
        [gMod release];
        
        [Global sharedGlobal].shop_state = [resultDic objectForKey:@"shop_state"];
        
        [Common updateVersion:APNS_COMMAND_ID withVersion:pro_ver withDesc:@"设备令牌优惠券版本号"];
    }
    
    [pool release];
    
    if (ret == -1) {
        NSMutableArray *arr = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:-1]];
        [arr addObject:[resultDic objectForKey:@"old_shop_id"]];
        [arr addObject:[resultDic objectForKey:@"old_shop_name"]];
        [arr addObject:[resultDic objectForKey:@"new_shop_id"]];
        [arr addObject:[resultDic objectForKey:@"new_shop_name"]];
        [arr addObject:[resultDic objectForKey:@"city"]];
        return arr;
    }
    
	return nil;
}

//广告接口
+(NSMutableArray*)parseAd:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	////NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //创建模型
    ad_model *adMod = [[ad_model alloc] init];
    
    //广告版本号
	int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"ads"];
	
	//删除的应用数据
	NSString *delsString = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if (![delsString isEqualToString:@""] && delsString != nil)
	{
        *ver = NEED_UPDATE;
        
        adMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [adMod deleteDBdata];
	}
	
	//保存数据
	if ([listArray count] > 0)
	{
        [adMod deleteDBdata];
        
        *ver = NEED_UPDATE;
		for (int i = 0; i < [listArray count]; i++ )
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            
            //如果数据库字段跟接口字段一样,可以直接使用,如果不一样,则需要自己定义infoDic
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            adMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [adMod getList];
            if ([dbArray count] > 0) {
                [adMod updateDB:infoDic];
            } else {
                //插入数据库 注意前面删除中的 admod.where 如果是其他条件会起作用的操作 需要设置 adMod.where = nil;
             [adMod insertDB:infoDic];
            }
            adMod.where = nil;
		}
	}
    
	//更新版本号
    [Common updateVersion:OPERAT_AD_REFRESH withVersion:newVer withDesc:@"首页广告版本号"];
	
    [adMod release];
    
    [pool release];
	return nil;
}

//分店列表接口
+ (NSMutableArray*)parseNearShop:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;

	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *listArray = nil;

    //创建模型
    shop_near_list_model *nearShopMod = [[shop_near_list_model alloc] init];
    
    //版本号
    int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
    listArray = [resultDic objectForKey:@"shops"];
    
    //删除的应用数据
    NSString *delsString = [resultDic objectForKey:@"dels"];
    
    //删除数据
    if (![delsString isEqualToString:@""] && delsString != nil)
    {
        *ver = NEED_UPDATE;
        
        nearShopMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [nearShopMod deleteDBdata];
    }
    
    nearShopMod.where = nil;
    
    //保存数据
    if ([listArray count] > 0)
    {
        *ver = NEED_UPDATE;
        for (int i = 0; i < [listArray count]; i++ )
        {
            //非空判断 例子
            //[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            
            //如果数据库字段跟接口字段一样,可以直接使用,如果不一样,则需要自己定义infoDic
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            nearShopMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [nearShopMod getList];
            if ([dbArray count] > 0) {
                [nearShopMod updateDB:infoDic];
            } else {
                [nearShopMod insertDB:infoDic];
            }
        }
        
        NSString *city = [[listArray objectAtIndex:0] objectForKey:@"city"];
        
        //更新版本号
        [Common updateVersion:SUBBRANCH_COMMAND_ID withVersion:newVer withDesc:[NSString stringWithFormat:@"分店列表版本号%@",city]];
    }
    
    [nearShopMod release];

	return listArray;
}

//热销商品接口
+(NSMutableArray*)parseHotProducts:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;

	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    NSMutableArray *listArray = nil;
    //创建模型
    hot_products_model *hpMod = [[hot_products_model alloc] init];
    
    //广告版本号
    int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
    listArray = [resultDic objectForKey:@"products"];
    
    //删除的应用数据
    NSString *delsString = [resultDic objectForKey:@"dels"];
    
    //删除数据
    if (![delsString isEqualToString:@""] && delsString != nil)
    {
        *ver = NEED_UPDATE;
        
        hpMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [hpMod deleteDBdata];
    }
    
    hpMod.where = nil;
    
    //保存数据
    if ([listArray count] > 0)
    {
        [hpMod deleteDBdata];
        *ver = NEED_UPDATE;
        for (int i = 0; i < [listArray count]; i++ )
        {
            //非空判断 例子
            //[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            
            //如果数据库字段跟接口字段一样,可以直接使用,如果不一样,则需要自己定义infoDic
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            hpMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [hpMod getList];
            if ([dbArray count] > 0)
            {
                [hpMod updateDB:infoDic];
            }
            else
            {
                [hpMod insertDB:infoDic];
            }
            
        }
    }
    
    //广告其实不需要保证20条,给你们留个模版,方便复制使用
    /*
     //保证数据只有20条
     adMod.orderBy = @"position";
     adMod.orderType = @"desc";
     NSMutableArray *adItems = [adMod getList];
     for (int i = [adItems count] - 1; i > 19; i--)
     {
     NSDictionary *adDic = [adItems objectAtIndex:i];
     NSString *adId = [adDic objectForKey:@"id"];
     
     adMod.where = [NSString stringWithFormat:@"id = %@",adId];
     [adMod deleteDBdata];
     }
     */
    
    //更新版本号
    [Common updateVersion:HOT_PRODUCTS_COMMAND_ID withVersion:newVer withDesc:@"热销商品版本号"];
    
    [hpMod release];

	return listArray;
}

//资讯列表接口
+(NSMutableArray*)parseInformations:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *listArray = nil;

    //创建模型
    informations_model *infoMod = [[informations_model alloc] init];
    information_images_model *infoImgMod = [[information_images_model alloc] init];
    // dufu add 2013.12.06  用于视频保存
    informations_media_model *infomediaMod = [[informations_media_model alloc] init];
    
    int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
    listArray = [resultDic objectForKey:@"news"];
    
    //删除的应用数据
    NSString *delsString = [resultDic objectForKey:@"dels"];
    
    //删除数据
    if (![delsString isEqualToString:@""] && delsString != nil)
    {
        *ver = NEED_UPDATE;
        
        infoMod.where = [NSString stringWithFormat:@"new_id in (%@)",delsString];
        [infoMod deleteDBdata];
        
        infoImgMod.where = [NSString stringWithFormat:@"new_id in (%@)",delsString];
        [infoImgMod deleteDBdata];
        
        infomediaMod.where = [NSString stringWithFormat:@"new_id in (%@)",delsString];
        [infomediaMod deleteDBdata];
    }
    
    infoMod.where = nil;
    infoImgMod.where = nil;
    infomediaMod.where = nil;
    
    //保存数据
    if ([listArray count] > 0)
    {
        *ver = NEED_UPDATE;
        for (int i = 0; i < [listArray count]; i++ )
        {
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            //资讯列表数据
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [infoDic objectForKey:@"id"],@"new_id",
                                 [infoDic objectForKey:@"title"],@"title",
                                 [infoDic objectForKey:@"content"],@"content",
                                 [infoDic objectForKey:@"picture"],@"picture",
                                 [infoDic objectForKey:@"comment_sum"],@"comment_sum",
                                 [infoDic objectForKey:@"recommend"],@"recommend",
                                 [infoDic objectForKey:@"created"],@"created",
                                 [resultDic objectForKey:@"recommend_sate"],@"recommend_sate",
                                 [infoDic objectForKey:@"music"],@"music",nil];
            
            infoMod.where = [NSString stringWithFormat:@"new_id = %d",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [infoMod getList];
            if ([dbArray count] > 0)
            {
                [infoMod updateDB:dic];
            }
            else
            {
                [infoMod insertDB:dic];
            }
            
            // 资讯视频信息
            NSArray *mediaArr = [infoDic objectForKey:@"media"];
            infomediaMod.where = [NSString stringWithFormat:@"new_id = %d",[[infoDic objectForKey:@"id"] intValue]];
            [infomediaMod deleteDBdata];
            if (mediaArr.count > 0) {
                for (int i = 0; i < [mediaArr count]; i++ ) {
                    NSDictionary *dic2 = [mediaArr objectAtIndex:i];
                    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [infoDic objectForKey:@"id"],@"new_id",
                                           [dic2 objectForKey:@"image"],@"image",
                                           [dic2 objectForKey:@"video"],@"video",
                                           [dic2 objectForKey:@"url"],@"url",
                                           [dic2 objectForKey:@"is_web"],@"is_web",nil];
                    [infomediaMod insertDB:dict3];
                }
            }
            
            //详情页面图片
            NSArray *imageArr = [infoDic objectForKey:@"pics"];
            infoImgMod.where = [NSString stringWithFormat:@"new_id = %d",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *imgArray = [infoImgMod getList];
            if ([imgArray count] > 0) {
                [infoImgMod deleteDBdata];
            }
            for (int i = 0; i < [imageArr count]; i++ )
            {
                NSDictionary *dic2 = [imageArr objectAtIndex:i];
                [infoImgMod insertDB:dic2];
            }
        }
    }
    
    //保证数据只有20条
    NSString *sql = @"select * from t_informations order by recommend desc,created desc";
    NSMutableArray *adItems = [infoMod querSelectSql:sql];
    
    for (int i = [adItems count] - 1; i > 19; i--)
    {
        NSDictionary *adDic = [adItems objectAtIndex:i];
        NSString *adId = [adDic objectForKey:@"new_id"];
        
        infoMod.where = [NSString stringWithFormat:@"new_id = %@",adId];
        [infoMod deleteDBdata];
    }
    
    //更新版本号
    [Common updateVersion:INFORMATIONS_COMMAND_ID withVersion:newVer withDesc:@"资讯列表版本号"];
    
    [infoMod release];
    [infoImgMod release];
    [infomediaMod release];
    
	return listArray;
}

//资讯列表 more
+ (NSMutableArray*)parseInformationsMore:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    //更新数据
	NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    int newVer = [[resultDic objectForKey:@"ver"] intValue];
    NSMutableArray *listArray = [resultDic objectForKey:@"news"];
    //保存数据
    if ([listArray count] > 0)
    {
        *ver = NEED_UPDATE;
        for (int i = 0; i < [listArray count]; i++ )
        {
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] initWithDictionary:[listArray objectAtIndex:i]];
            
            [infoDic setObject:[NSNumber numberWithInt:[[resultDic objectForKey:@"recommend_sate"] intValue]] forKey:@"recommend_sate"];
            
            [resultArray addObject:infoDic];
            [infoDic release];
        }
    }
    
    //更新版本号
    [Common updateVersion:INFORMATIONS_COMMAND_ID withVersion:newVer withDesc:@"资讯列表版本号"];

	return resultArray;
}

//资讯列表详情页面 数据
+ (NSMutableArray*)parseInformationDetail:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithObject:resultDic];
    
    //更新数据
	//resultArray = [resultDic objectForKey:@"news"];

	return resultArray;
}

//资讯详情 评论
+ (NSMutableArray*)parseInformationComments:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
	NSMutableArray *resultArray = [resultDic objectForKey:@"comments"];
    
	return resultArray;
}

//售后服务 在线预约接口
+ (NSMutableArray*)parseResult:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    
    NSString *str = [resultDic objectForKey:@"ret"];
    if (str != nil) {
        [resultArray addObject:str];
    }
	return [resultArray autorelease];
}

//应用库分类
+ (NSMutableArray*)parseAppCats:(NSDictionary *)resultDic getVersion:(int*)ver withShopId:(int)shop_id
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    int newVer = [[resultDic objectForKey:@"ver"] intValue];
    //更新数据
    NSMutableArray *listArray = [resultDic objectForKey:@"servicecatalogs"];
    
    service_cats_model *infoMod = [[service_cats_model alloc] init];
    
    //删除的应用数据
    NSString *delsString = [resultDic objectForKey:@"dels"];
    
    //删除数据
    if (![delsString isEqualToString:@""] && delsString != nil)
    {
        *ver = NEED_UPDATE;
        
        infoMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [infoMod deleteDBdata];
    }
    
    infoMod.where = nil;
    
    //保存数据
    if ([listArray count] > 0)
    {
        *ver = NEED_UPDATE;
        //        infoMod.where = [NSString stringWithFormat:@"shop_id = %d",shop_id];
        //        NSMutableArray *dbArray = [infoMod getList];
        //        if ([dbArray count] == 0) {
        //            infoMod.where = nil;
        //            [infoMod deleteDBdata];
        //        }
        [infoMod deleteDBdata]; //去掉版本号
        
        for (int i = 0; i < [listArray count]; i++ )
        {
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] initWithDictionary:[listArray objectAtIndex:i]];
            
            [infoDic setObject:[NSNumber numberWithInt:shop_id] forKey:@"shop_id"];
            
            infoMod.where = [NSString stringWithFormat:@"id = %d and shop_id = %d",[[infoDic objectForKey:@"id"] intValue],shop_id];
            NSMutableArray *dbArray = [infoMod getList];
            if ([dbArray count] > 0)
            {
                [infoMod updateDB:infoDic];
            }
            else
            {
                [infoMod insertDB:infoDic];
            }
            
            [infoDic release];
        }
    }
    
    //保证数据只有20条
    infoMod.orderBy = @"position";
    infoMod.orderType = @"desc";
    NSMutableArray *infoItems = [infoMod getList];
    for (int i = [infoItems count] - 1; i > 19; i--)
    {
        NSDictionary *infoDic = [infoItems objectAtIndex:i];
        NSString *infoId = [infoDic objectForKey:@"id"];
        
        infoMod.where = [NSString stringWithFormat:@"id = %@ shop_id = '%d'",infoId,shop_id];
        [infoMod deleteDBdata];
    }
    
    //更新版本号
    //[Common updateVersion:SERVICE_CATS_COMMAND_ID withVersion:newVer withDesc:@"应用库分类版本号"];
    [Common updateCatVersion:SERVICE_CATS_COMMAND_ID withVersion:newVer withId:shop_id withDesc:@"应用库分类版本号"];
    
    [infoMod release];
    
    [pool release];
    
	return nil;
}

//应用库分类 more
+ (NSMutableArray*)parseAppCatsMore:(NSDictionary *)resultDic getVersion:(int*)ver withShopId:(int)shop_id
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];

    //更新数据
	NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];

    NSMutableArray *listArray = [resultDic objectForKey:@"servicecatalogs"];
    //保存数据
    if ([listArray count] > 0)
    {
        for (int i = 0; i < [listArray count]; i++ )
        {
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] initWithDictionary:[listArray objectAtIndex:i]];
            
            [infoDic setObject:[NSNumber numberWithInt:shop_id] forKey:@"shop_id"];
            
            [resultArray addObject:infoDic];
            [infoDic release];
        }
    }

	return resultArray;
}

//应用库分类列表
+ (NSMutableArray*)parseAppCatList:(NSDictionary *)resultDic withId:(int)cat_Id getVersion:(int*)ver withShopId:(int)shop_id
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *listArray = nil;

    int newVer = [[resultDic objectForKey:@"ver"] intValue];
    //更新数据
    listArray = [resultDic objectForKey:@"services"];
    
    service_cat_list_model *infoMod = [[service_cat_list_model alloc] init];
    
    //删除的应用数据
    NSString *delsString = [resultDic objectForKey:@"dels"];
    
    //删除数据
    if (![delsString isEqualToString:@""] && delsString != nil)
    {
        *ver = NEED_UPDATE;
        
        infoMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [infoMod deleteDBdata];
    }
    infoMod.where = nil;
    
    infoMod.where = [NSString stringWithFormat:@"service_catalog_id = %d and shop_id = %d",cat_Id,shop_id];
    NSMutableArray *dbArray = [infoMod getList];
    if ([dbArray count] == 0) {
        infoMod.where = nil;
        [infoMod deleteDBdata];
    }
    
    //保存数据
    if ([listArray count] > 0)
    {
        *ver = NEED_UPDATE;
        
        infoMod.where = [NSString stringWithFormat:@"service_catalog_id = %d and shop_id = %d",cat_Id,shop_id];
        [infoMod deleteDBdata];
        
        for (int i = 0; i < [listArray count]; i++ )
        {
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] initWithDictionary:[listArray objectAtIndex:i]];
            [infoDic setObject:[NSNumber numberWithInt:shop_id] forKey:@"shop_id"];
            
            infoMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [infoMod getList];
            if ([dbArray count] > 0)
            {
                [infoMod updateDB:infoDic];
            }
            else
            {
                [infoMod insertDB:infoDic];
            }
            [infoDic release],infoDic = nil;
        }
    }
    
    //    //保证数据只有20条
    //    infoMod.orderBy = @"position";
    //    infoMod.orderType = @"desc";
    //    NSMutableArray *infoItems = [infoMod getList];
    //    for (int i = [infoItems count] - 1; i > 19; i--)
    //    {
    //        NSDictionary *infoDic = [infoItems objectAtIndex:i];
    //        NSString *infoId = [infoDic objectForKey:@"id"];
    //        
    //        infoMod.where = [NSString stringWithFormat:@"id = %@",infoId];
    //        [infoMod deleteDBdata];
    //    }
    
    //更新版本号
    [Common updateCatVersion:SERVICE_CAT_LIST_COMMAND_ID withVersion:newVer withId:cat_Id withDesc:@"应用库分类列表版本号"];
    
    [infoMod release];
    
	return listArray;
}

//应用库分类列表 more
+ (NSMutableArray*)parseAppCatListMore:(NSDictionary *)resultDic getVersion:(int*)ver withShopId:(int)shop_id
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];

    NSMutableArray *listArray = [resultDic objectForKey:@"services"];
    //保存数据
    if ([listArray count] > 0)
    {
        for (int i = 0; i < [listArray count]; i++ )
        {
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] initWithDictionary:[listArray objectAtIndex:i]];
            
            [infoDic setObject:[NSNumber numberWithInt:shop_id] forKey:@"shop_id"];
            
            [resultArray addObject:infoDic];
            [infoDic release];
        }
    }
    
	return resultArray;
}

// // 添加或者修改地址时提供地址选择器
+ (NSMutableArray *)parseAddressChoice_list:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        if (resultDic != nil && resultDic.count > 0) {
            
            addressChoice_list_model *alMod = [[addressChoice_list_model alloc] init];
            
            int newVer = [[resultDic objectForKey:@"ver"] intValue];
            NSMutableArray *resultArray = [resultDic objectForKey:@"addresses"];
            if (resultArray.count > 0) {
                
                [alMod deleteDBdata];
                
                for (NSDictionary *dict in resultArray) {
                    int province_id = [[dict objectForKey:@"province_id"] intValue];
                    NSString *province = [dict objectForKey:@"province"];
                    
                    NSDictionary *adict = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt:1],@"level",
                                           [NSNumber numberWithInt:province_id],@"province_id",
                                           province,@"province",
                                           [NSNumber numberWithInt:province_id],@"city_id",
                                           @"",@"city",
                                           [NSNumber numberWithInt:province_id],@"area_id",
                                           @"",@"area",
                                           @"",@"address",
                                           nil];
                    alMod.where = [NSString stringWithFormat:@"province = '%@'",province];
                    NSMutableArray *dbArray = [alMod getList];
                    if ([dbArray count] > 0) {
                        [alMod updateDB:adict];
                    } else {
                        [alMod insertDB:adict];
                    }
                    
                    NSArray *citys = [dict objectForKey:@"citys"];
                    for (NSDictionary *dict in citys) {
                        int city_id = [[dict objectForKey:@"city_id"] intValue];
                        NSString *city = [dict objectForKey:@"city"];
                        
                        NSDictionary *bdict = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithInt:2],@"level",
                                               [NSNumber numberWithInt:province_id],@"province_id",
                                               province,@"province",
                                               [NSNumber numberWithInt:city_id],@"city_id",
                                               city,@"city",
                                               [NSNumber numberWithInt:city_id],@"area_id",
                                               @"",@"area",
                                               @"",@"address",
                                               nil];
                        alMod.where = [NSString stringWithFormat:@"city = '%@'",city];
                        NSMutableArray *dbArray = [alMod getList];
                        if ([dbArray count] > 0) {
                            [alMod updateDB:bdict];
                        } else {
                            [alMod insertDB:bdict];
                        }
                        
                        NSArray *areas = [dict objectForKey:@"areas"];
                        for (NSDictionary *dict in areas) {
                            int area_id = [[dict objectForKey:@"area_id"] intValue];
                            NSString *area = [dict objectForKey:@"area"];
                            NSString *address = [dict objectForKey:@"address"];
                            
                            NSDictionary *cdict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithInt:3],@"level",
                                                   [NSNumber numberWithInt:province_id],@"province_id",
                                                   province,@"province",
                                                   [NSNumber numberWithInt:city_id],@"city_id",
                                                   city,@"city",
                                                   [NSNumber numberWithInt:area_id],@"area_id",
                                                   area,@"area",
                                                   address,@"address",
                                                   nil];
                            alMod.where = [NSString stringWithFormat:@"area = '%@'",area];
                            NSMutableArray *dbArray = [alMod getList];
                            if ([dbArray count] > 0) {
                                [alMod updateDB:cdict];
                            } else {
                                [alMod insertDB:cdict];
                            }
                        }
                    }
                }
            }
            [alMod release], alMod = nil;
            
            // 更新版本号
            [Common updateVersion:ADDRESSCHOICELIST_COMMAND_ID withVersion:newVer withDesc:@"地区选择器版本号"];
        }
        
        [pool release];
    });

    return nil;
}

// 分享获得优惠券
+ (NSMutableArray *)parseShare_pf:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [NSMutableArray arrayWithCapacity:0];
    int ret = [[resultDic objectForKey:@"ret"] intValue];
    NSLog(@"ret = %d",ret);
    [listArray addObject:[NSString stringWithFormat:@"%d",ret]];
	
    return listArray;
}

// 商品列表接口
+ (NSMutableArray *)parseShop_list:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //广告版本号
	int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"products"];
	
	//删除的应用数据
	NSString *delsString = [resultDic objectForKey:@"dels"];
	
    //创建数据库模型
    shop_list_model *slMod = [[shop_list_model alloc] init];
    shop_list_pics_model *slpMod = [[shop_list_pics_model alloc] init];
    
	//删除数据
	if (![delsString isEqualToString:@""] && delsString != nil) {
        *ver = NEED_UPDATE;
        
        slMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [slMod deleteDBdata];
	}
    
    slMod.where = nil;
	
	//保存数据
	if ([listArray count] > 0) {
        *ver = NEED_UPDATE;
        
        NSDictionary *adict = [listArray objectAtIndex:0];
        
        if (adict.count > 0) {
            int catalog_id = [[adict objectForKey:@"catalog_id"] intValue];
            // 保证数据只有20条
            slMod.where = [NSString stringWithFormat:@"catalog_id = '%d'",catalog_id];
            NSMutableArray *slItems = [slMod getList];
            for (int i = 0; i < slItems.count; i++) {
                NSDictionary *slDic = [slItems objectAtIndex:i];
                NSString *slId = [slDic objectForKey:@"product_id"];
                slMod.where = [NSString stringWithFormat:@"product_id = '%@'",slId];
                [slMod deleteDBdata];
                
                slpMod.where = [NSString stringWithFormat:@"id = '%@'",slId];
                [slpMod deleteDBdata];
            }
        }
        
		for (int i = 0; i < [listArray count]; i++ ) {
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [infoDic objectForKey:@"id"],@"id",
                                  [infoDic objectForKey:@"product_id"],@"product_id",
                                  [infoDic objectForKey:@"catalog_id"],@"catalog_id",
                                  [infoDic objectForKey:@"name"],@"name",
                                  [infoDic objectForKey:@"image"],@"image",
                                  [infoDic objectForKey:@"stock"],@"stock",
                                  [infoDic objectForKey:@"price"],@"price",
                                  [infoDic objectForKey:@"market_price"],@"market_price",
                                  [infoDic objectForKey:@"content"],@"content",
                                  [infoDic objectForKey:@"product_model"],@"product_model",
                                  [infoDic objectForKey:@"parameter"],@"parameter",
                                  [infoDic objectForKey:@"detail_image"],@"detail_image",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"like_sum"] intValue]],@"like_sum",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"favorite_sum"] intValue]],@"favorite_sum",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"sale_sum"] intValue]],@"sale_sum",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"comment_sum"] intValue]],@"comment_sum",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"is_guess_like"] intValue]],@"is_guess_like",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"position"] intValue]],@"position",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"big_show"] intValue]],@"big_show",
                                  [NSNumber numberWithInt:[[infoDic objectForKey:@"share_gift"] intValue]],@"share_gift",
                                  nil];

            slMod.where = [NSString stringWithFormat:@"id = '%d'",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [slMod getList];
            if ([dbArray count] > 0) {
                [slMod updateDB:dict];
            } else {
                [slMod insertDB:dict];
            }
            
            // 产品图片
            NSArray *arrPic = [infoDic objectForKey:@"pics"];

            if (arrPic.count > 0) {
                slpMod.where = [NSString stringWithFormat:@"id = '%d'",[[[arrPic objectAtIndex:0] objectForKey:@"id"] intValue]];
                [slpMod deleteDBdata];
                slpMod.where = nil;
                for (NSDictionary *picDic in arrPic) {
                    [slpMod insertDB:picDic];
                }
            }
		}
        
        NSDictionary *dict = [listArray objectAtIndex:0];
        
        if (dict.count > 0) {
            int catalog_id = [[dict objectForKey:@"catalog_id"] intValue];
            // 保证数据只有20条
            slMod.where = [NSString stringWithFormat:@"catalog_id = '%d'",catalog_id];
            slMod.orderBy = @"id";
            slMod.orderType = @"desc";
            NSMutableArray *slItems = [slMod getList];
            for (int i = [slItems count] - 1; i > 19; i--) {
                NSDictionary *slDic = [slItems objectAtIndex:i];
                NSString *slId = [slDic objectForKey:@"product_id"];
                slMod.where = [NSString stringWithFormat:@"product_id = '%@'",slId];
                [slMod deleteDBdata];
                
                slpMod.where = [NSString stringWithFormat:@"id = '%@'",slId];
                [slpMod deleteDBdata];
            }
            
            // 更新版本号
            [Common updateCatVersion:SHOP_LIST_COMMAND_ID withVersion:newVer withId:catalog_id withDesc:@"商品列表版本号"];
        }
	}

    [slMod release];
    [slpMod release];
    
    [pool release];
    return nil;
}

// 商品列表接口  更多
+ (NSMutableArray *)parseShop_list_more:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"products"];
	
    return listArray;
}

// 商品分类接口
+ (NSMutableArray *)parseproduct_cat:(NSDictionary *)resultDic getVersion:(int*)ver withCommandId:(int)_commandId
{
    *ver = NO_UPDATE;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    //广告版本号
	int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"catalogs"];
	
	//删除的应用数据
	NSString *delsString = [resultDic objectForKey:@"dels"];
    
	if (_commandId == PRODUCT_CAT_COMMAND_ID) {
        //创建数据库模型
        product_cat_model *pcMod = [[product_cat_model alloc] init];
        //删除数据
        if (![delsString isEqualToString:@""] && delsString != nil) {
            *ver = NEED_UPDATE;
            
            pcMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
            [pcMod deleteDBdata];
        }
        
        pcMod.where = nil;

        //保存数据
        if ([listArray count] > 0 || listArray != nil) {
            
            *ver = NEED_UPDATE;
            
            [pcMod deleteDBdata];

            for (int i = 0; i < [listArray count]; i++ ) {
                
                NSDictionary *infoDic = [listArray objectAtIndex:i];
                
                pcMod.where = [NSString stringWithFormat:@"id = '%d'",[[infoDic objectForKey:@"id"] intValue]];
                NSMutableArray *dbArray = [pcMod getList];
                if ([dbArray count] > 0) {
                    [pcMod updateDB:infoDic];
                } else {
                    [pcMod insertDB:infoDic];
                }
            }
        }
        [pcMod release];
    }else {
        products_center_model *proCenMod = [[products_center_model alloc] init];
        
        //删除数据
        if (![delsString isEqualToString:@""] && delsString != nil) {
            *ver = NEED_UPDATE;
            
            proCenMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
            [proCenMod deleteDBdata];
        }
        
        proCenMod.where = nil;
        
        //保存数据
        if ([listArray count] > 0) {
            *ver = NEED_UPDATE;
            [proCenMod deleteDBdata];
            
            for (int i = 0; i < [listArray count]; i++ ) {
                
                NSDictionary *infoDic = [listArray objectAtIndex:i];
                
                proCenMod.where = [NSString stringWithFormat:@"id = '%d'",[[infoDic objectForKey:@"id"] intValue]];
                NSMutableArray *dbArray = [proCenMod getList];
                if ([dbArray count] > 0) {
                    [proCenMod updateDB:infoDic];
                } else {
                    [proCenMod insertDB:infoDic];
                }
            }
        }
        
        [proCenMod release];
    }

	//更新版本号
    [Common updateVersion:_commandId withVersion:newVer withDesc:@"商品分类版本号"];
    
    [pool release];
    return nil;
}

// 首页产品中心 商品列表接口
+ (NSMutableArray *)parseProductsCenter_list:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //广告版本号
	int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"products"];
	
	//删除的应用数据
	NSString *delsString = [resultDic objectForKey:@"dels"];
	
    //创建数据库模型
    productsCenter_list_model *slMod = [[productsCenter_list_model alloc] init];
    productsCenter_list_pics_model *slpMod = [[productsCenter_list_pics_model alloc] init];
    
	//删除数据
	if (![delsString isEqualToString:@""] && delsString != nil) {
        *ver = NEED_UPDATE;
        
        slMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [slMod deleteDBdata];
	}
    
    slMod.where = nil;
	
	//保存数据
	if ([listArray count] > 0) {
        [slMod deleteDBdata];
        [slpMod deleteDBdata];
        *ver = NEED_UPDATE;
		for (int i = 0; i < [listArray count]; i++ ) {
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [infoDic objectForKey:@"id"],@"id",
                                  [infoDic objectForKey:@"product_id"],@"product_id",
                                  [infoDic objectForKey:@"catalog_id"],@"catalog_id",
                                  [infoDic objectForKey:@"name"],@"name",
                                  [infoDic objectForKey:@"image"],@"image",
                                  [infoDic objectForKey:@"stock"],@"stock",
                                  [infoDic objectForKey:@"price"],@"price",
                                  [infoDic objectForKey:@"market_price"],@"market_price",
                                  [infoDic objectForKey:@"content"],@"content",
                                  [infoDic objectForKey:@"product_model"],@"product_model",
                                  [infoDic objectForKey:@"like_sum"],@"like_sum",
                                  [infoDic objectForKey:@"favorite_sum"],@"favorite_sum",
                                  [infoDic objectForKey:@"sale_sum"],@"sale_sum",
                                  [infoDic objectForKey:@"comment_sum"],@"comment_sum",
                                  [infoDic objectForKey:@"position"],@"position",
                                  [infoDic objectForKey:@"is_guess_like"],@"is_guess_like",
                                  [infoDic objectForKey:@"big_show"],@"big_show",
                                  nil];
            
            slMod.where = [NSString stringWithFormat:@"id = '%d'",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [slMod getList];
            if ([dbArray count] > 0) {
                [slMod updateDB:dict];
            } else {
                [slMod insertDB:dict];
            }
            
            // 产品图片
            NSArray *arrPic = [infoDic objectForKey:@"pics"];
            
            if (arrPic.count > 0) {
                slpMod.where = [NSString stringWithFormat:@"id = '%d'",[[[arrPic objectAtIndex:0] objectForKey:@"id"] intValue]];
                [slpMod deleteDBdata];
                slpMod.where = nil;
                for (NSDictionary *picDic in arrPic) {
                    [slpMod insertDB:picDic];
                }
            }
		}
        
        NSDictionary *dict = [listArray objectAtIndex:0];
        
        if (dict.count > 0) {
            int catalog_id = [[dict objectForKey:@"catalog_id"] intValue];
            // 保证数据只有20条
            slMod.where = [NSString stringWithFormat:@"catalog_id = '%d'",catalog_id];
            slMod.orderBy = @"id";
            slMod.orderType = @"desc";
            NSMutableArray *slItems = [slMod getList];
            for (int i = [slItems count] - 1; i > 19; i--) {
                NSDictionary *slDic = [slItems objectAtIndex:i];
                NSString *slId = [slDic objectForKey:@"product_id"];
                slMod.where = [NSString stringWithFormat:@"product_id = '%@'",slId];
                [slMod deleteDBdata];
                
                slpMod.where = [NSString stringWithFormat:@"id = '%@'",slId];
                [slpMod deleteDBdata];
            }
            
            // 更新版本号
            [Common updateCatVersion:PRODUCTS_CENTER_LIST_COMMAND_ID withVersion:newVer withId:catalog_id withDesc:@"产品中心商品列表版本号"];
        }
	}
    
    [slMod release];
    [slpMod release];
    
    [pool release];
    return nil;
}

// 搜索商品接口
+ (NSMutableArray *)parseSearch_shop:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"products"];
	
	return listArray;
}

// 商品详情接口
+ (NSMutableArray *)parseShop_detail:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
//    NSDictionary *dict = [resultDic objectForKey:@"product"];

    //更新数据
    NSMutableArray *listArray = [NSMutableArray arrayWithObject:resultDic];

	return listArray;
}

// 猜你喜欢接口
+ (NSMutableArray *)parseGuess_like:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"promotions"];
	
	return listArray;
}

// 评论列表接口
+ (NSMutableArray *)parseComment_list:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    //更新数据
    NSMutableArray *listArray = [NSMutableArray arrayWithObject:resultDic];

	return listArray;
}

// 喜欢接口
+ (NSMutableArray *)parseLike:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    int ret = [[resultDic objectForKey:@"ret"] intValue];
    //更新数据
	NSMutableArray *listArray = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d",ret]];
	
	return listArray;
}

// 评论接口
+ (NSMutableArray *)parseComment:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    int ret = [[resultDic objectForKey:@"ret"] intValue];
    //更新数据
	NSMutableArray *listArray = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%d",ret]];
	
	return listArray;
}

// 地址列表接口
+ (NSMutableArray *)parseAddress_list:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	 
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    //更新数据
    NSMutableArray *listArray = [resultDic objectForKey:@"addresses"];
    
    //创建数据库模型
    address_list_model *alMod = [[address_list_model alloc] init];
    
    //保存数据
    if ([listArray count] > 0) {
        *ver = NEED_UPDATE;
        for (int i = 0; i < [listArray count]; i++ ) {
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            alMod.where = [NSString stringWithFormat:@"id = '%d'",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [alMod getList];
            if ([dbArray count] > 0) {
                [alMod updateDB:infoDic];
            } else {
                [alMod insertDB:infoDic];
            }
        }
    }
    //
    //    //保证数据只有20条
    //    alMod.where = nil;
    //    alMod.orderBy = @"id";
    //    alMod.orderType = @"desc";
    //    NSMutableArray *plItems = [alMod getList];
    //    for (int i = [plItems count] - 1; i > 19; i--) {
    //        NSDictionary *plDic = [plItems objectAtIndex:i];
    //        NSString *plId = [plDic objectForKey:@"id"];
    //        
    //        alMod.where = [NSString stringWithFormat:@"id = '%@'",plId];
    //        [alMod deleteDBdata];
    //    }
    
    [alMod release];
    
    [pool release];

    return nil;
}

// 地址列表接口 更多
+ (NSMutableArray *)parseAddress_list_more:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"addresses"];
    
    return listArray;
}

// 排序地址
+ (NSMutableArray *)parseAddress_sort:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"addresses"];
    
    return listArray;
}

// 添加或者修改地址
+ (NSMutableArray *)parseAdd_update_address:(NSDictionary *)resultDic getVersion:(int*)ver
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

	NSString *ret = [resultDic objectForKey:@"ret"];
    NSString *sid = [resultDic objectForKey:@"id"];
    NSString *created = [resultDic objectForKey:@"created"];
    
    NSMutableArray *listArray = [NSMutableArray arrayWithObjects:ret,sid,created, nil];
    
    return listArray;
}

// 提交预订
+ (NSMutableArray *)parseOrder:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
    NSString *str = [NSString stringWithFormat:@"%d",[[resultDic objectForKey:@"ret"] intValue]];
    
    NSMutableArray *listArray = nil;
    if (str.length > 0) {
        listArray = [NSMutableArray arrayWithObject:str];
    }

    return listArray;
}

// 我的优惠券列表
+ (NSMutableArray *)parseFavorable_list:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"coupons"];
	
    //创建数据库模型
    favorable_list_model *flMod = [[favorable_list_model alloc] init];
    favorable_list_pic_model *flpMod = [[favorable_list_pic_model alloc] init];
    
	//保存数据
	if ([listArray count] > 0 || listArray != nil) {
        *ver = NEED_UPDATE;
        
        [flMod deleteDBdata];
        
		for (int i = 0; i < [listArray count]; i++ ) {
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [infoDic objectForKey:@"id"],@"id",
                                  [infoDic objectForKey:@"billno"],@"billno",
                                  [infoDic objectForKey:@"promotion_id"],@"promotion_id",
                                  [infoDic objectForKey:@"get_time"],@"get_time",
                                  [infoDic objectForKey:@"used"],@"used",
                                  [infoDic objectForKey:@"title"],@"title",
                                  [infoDic objectForKey:@"content"],@"content",
                                  [infoDic objectForKey:@"discount"],@"discount",
                                  [infoDic objectForKey:@"start_date"],@"start_date",
                                  [infoDic objectForKey:@"end_date"],@"end_date",
                                  [infoDic objectForKey:@"intro"],@"intro",
                                  [infoDic objectForKey:@"promotion_type"],@"promotion_type",
                                  [infoDic objectForKey:@"url"],@"url",
                                  [infoDic objectForKey:@"created"],@"created",
                                  [infoDic objectForKey:@"shop_id"],@"shop_id", nil];
            
            flMod.where = [NSString stringWithFormat:@"id = '%d'",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [flMod getList];
            if ([dbArray count] > 0) {
                [flMod updateDB:dict];
            } else {
                [flMod insertDB:dict];
            }
            
            // 关联商品
            NSArray *arrPic = [infoDic objectForKey:@"partner_pics"];
            
            for (NSDictionary *picDic in arrPic) {
                NSDictionary *adict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [picDic objectForKey:@"product_id"],@"product_id",
                                      [infoDic objectForKey:@"promotion_id"],@"promotion_id",
                                      [picDic objectForKey:@"img_path"],@"img_path",
                                      [picDic objectForKey:@"thumb_pic"],@"thumb_pic",
                                      [picDic objectForKey:@"product_name"],@"product_name", nil];
                
                flpMod.where = [NSString stringWithFormat:@"product_id = '%d' and promotion_id = '%d'",
                                [[picDic objectForKey:@"product_id"] intValue],[[infoDic objectForKey:@"promotion_id"] intValue]];
                NSMutableArray *dbArray = [flpMod getList];
                if ([dbArray count] > 0) {
                    [flpMod updateDB:adict];
                } else {
                    [flpMod insertDB:adict];
                }
			}
		}
	}
	
    //保证数据只有20条
    flMod.where = nil;
    flMod.orderBy = @"id";
    flMod.orderType = @"desc";
    NSMutableArray *plItems = [flMod getList];
    for (int i = [plItems count] - 1; i > 19; i--) {
        NSDictionary *plDic = [plItems objectAtIndex:i];
        NSString *plId = [plDic objectForKey:@"promotion_id"];
        
        flMod.where = [NSString stringWithFormat:@"promotion_id = '%@'",plId];
        [flMod deleteDBdata];
        
        flpMod.where = [NSString stringWithFormat:@"promotion_id = '%@'",plId];
        [flpMod deleteDBdata];
    }
	
    [flMod release];
    [flpMod release];
    
    [pool release];
    
    return nil;
}

// 我的优惠券列表  更多
+ (NSMutableArray *)parseFavorable_list_more:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"coupons"];
    
    return listArray;
}

// 立即抢购可用优惠券
+ (NSMutableArray *)parseBook_coupons:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"coupons"];
    
    return listArray;
}

// 优惠活动列表接口
+ (NSMutableArray *)parsePreactivity_list:(NSDictionary *)resultDic getVersion:(int*)ver
{
    *ver = NO_UPDATE;

	//NSDictionary *resultDic = [jsonResult objectFromJSONString];

    //广告版本号
	int newVer = [[resultDic objectForKey:@"ver"] intValue];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"preactivitys"];
	
	//删除的应用数据
	NSString *delsString = [resultDic objectForKey:@"dels"];
    
    // 得到更新时间
    NSMutableArray *timeArr = [NSMutableArray arrayWithObjects:[resultDic objectForKey:@"updatetime"], nil];
	
    //创建数据库模型
    preactivity_list_model *plMod = [[preactivity_list_model alloc] init];
    preactivity_list_pics_model *plpMod = [[preactivity_list_pics_model alloc] init];
    preactivity_list_partner_pics_model *plppMod = [[preactivity_list_partner_pics_model alloc] init];
    
	//删除数据
	if (![delsString isEqualToString:@""] && delsString != nil) {
        *ver = NEED_UPDATE;
        plMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
        [plMod deleteDBdata];
	}
    
    plMod.where = nil;
	
	//保存数据
	if ([listArray count] > 0 || listArray != nil) {
        
        [plMod deleteDBdata];
        [plpMod deleteDBdata];
        [plppMod deleteDBdata];
        
        *ver = NEED_UPDATE;
		for (int i = 0; i < [listArray count]; i++ ) {

            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [infoDic objectForKey:@"id"],@"id",
                                  [infoDic objectForKey:@"title"],@"title",
                                  [infoDic objectForKey:@"content"],@"content",
                                  [infoDic objectForKey:@"discount"],@"discount",
                                  [infoDic objectForKey:@"start_date"],@"start_date",
                                  [infoDic objectForKey:@"end_date"],@"end_date",
                                  [infoDic objectForKey:@"intro"],@"intro",
                                  [infoDic objectForKey:@"address"],@"address",
                                  [infoDic objectForKey:@"image"],@"image",
                                  [infoDic objectForKey:@"is_partner"],@"is_partner",
                                  [infoDic objectForKey:@"is_top"],@"is_top",
                                  [infoDic objectForKey:@"created"],@"created",
                                  [infoDic objectForKey:@"promotion_type"],@"promotion_type",
                                  [infoDic objectForKey:@"url"],@"url",
                                  [infoDic objectForKey:@"join_state"],@"join_state", nil];
            
            plMod.where = [NSString stringWithFormat:@"id = '%d'",[[infoDic objectForKey:@"id"] intValue]];
            NSMutableArray *dbArray = [plMod getList];
            if ([dbArray count] > 0) {
                [plMod updateDB:dict];
            } else {
                [plMod insertDB:dict];
            }

            // 海报
            NSArray *arrPic = [infoDic objectForKey:@"pics"];

            for (NSDictionary *picDic in arrPic) {
                [plpMod insertDB:picDic];
            }
            
            // 产品图片
            NSArray *arrPartnerPic = [infoDic objectForKey:@"partner_pics"];

            for (NSDictionary *picDic in arrPartnerPic) {
                [plppMod insertDB:picDic];
            }
		}
        
        //保证数据只有20条
        plMod.orderBy = @"id";
        plMod.orderType = @"desc";
        NSMutableArray *plItems = [plMod getList];
        for (int i = [plItems count] - 1; i > 19; i--) {
            NSDictionary *plDic = [plItems objectAtIndex:i];
            NSString *plId = [plDic objectForKey:@"id"];
            
            plMod.where = [NSString stringWithFormat:@"id = '%@'",plId];
            [plMod deleteDBdata];
            
            plpMod.where = [NSString stringWithFormat:@"preactivity_id = '%@'",plId];
            [plpMod deleteDBdata];
            
            plppMod.where = [NSString stringWithFormat:@"preactivity_id = '%@'",plId];
            [plppMod deleteDBdata];
        }
        
        //更新版本号
        [Common updateVersion:PREACTIVITY_LIST_COMMAND_ID withVersion:newVer withDesc:@"优惠活动版本号"];
	}
	
    [plMod release];
    [plpMod release];
    [plppMod release];
    
    return timeArr;
}

// 优惠活动列表接口  更多
+ (NSMutableArray *)parsePreactivity_list_more:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"preactivitys"];
    
    NSString *time = [resultDic objectForKey:@"updatetime"];
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:time,listArray, nil];
    
    return arr;
}

// 优惠活动详情
+ (NSMutableArray *)parsePreactivity_detail:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSDictionary *dict = [resultDic objectForKey:@"preactivitys"];
    
    if (dict.count == 0) {
        return nil;
    }
    //更新数据
	NSMutableArray *listArray = [NSMutableArray arrayWithObject:dict];
    
    return listArray;
}

// 参加优惠活动
+ (NSMutableArray *)parsePreactivity_join:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           [resultDic objectForKey:@"ret"],
                           [resultDic objectForKey:@"billno"],
                           [resultDic objectForKey:@"url"],
                           [resultDic objectForKey:@"promotion_id"],
                           [resultDic objectForKey:@"intro"], nil];
    
    return arr;
}

// 优惠活动猜你喜欢
+ (NSMutableArray *)parsePreactivityGuess_like:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"pics"];
    
    return listArray;
}

// 统计
+ (NSMutableArray *)parseCount:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSString *str = [NSString stringWithFormat:@"%d",[[resultDic objectForKey:@"ret"] intValue]];
    
    if (str.length == 0) {
        return nil;
    }
    // 更新数据
	NSMutableArray *listArray = [NSMutableArray arrayWithObject:str];
    
    return listArray;
}

// 优惠券可用商店地图
+ (NSMutableArray *)parsePreactivity_map:(NSDictionary *)resultDic getVersion:(int*)ver
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"shops"];
    
    return listArray;
}

// 会员登录
+ (NSMutableArray *)parseLogin:(NSDictionary *)resultDic{
    
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
	
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    if (resultDic) {

        [arry addObject:resultDic];
        
        //创建模型
        member_info_model *memMod = [[member_info_model alloc] init];
        
        //更新数据
        NSDictionary *listDic = [resultDic objectForKey:@"userInfo"];
        
        NSLog(@"listDic==%@",listDic);
        memMod.where = nil;
        
        //保存数据
        if ([[resultDic objectForKey:@"ret"]intValue]==1)
        {

                memMod.where = [NSString stringWithFormat:@"id = %d",[[listDic objectForKey:@"id"] intValue]];
                NSLog(@"id =%d",[[listDic objectForKey:@"id"] intValue]);
                NSMutableArray *dbArray = [memMod getList];
                if ([dbArray count] > 0)
                {
                    [memMod updateDB:listDic];
                }
                else
                {
                    [memMod insertDB:listDic];
                }
            //登陆成功后会员参加过的优惠活动
            promotions_id_model *proMod = [[promotions_id_model alloc]init];
            [proMod deleteDBdata];
            NSString *promotionsId = [listDic objectForKey:@"promotions_id"];
            if (![promotionsId isEqualToString:@""]) {
                NSArray *promotionArray = [promotionsId componentsSeparatedByString:@","];
                if ([promotionArray count] > 0) {
                    for (int i = 0; i < [promotionArray count]; i ++) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [listDic objectForKey:@"id"],@"userId",
                                             [promotionArray objectAtIndex:i],@"promotions_id",
                                             nil];
                        [proMod insertDB:dic];
                    }
                }
            }
            
            RELEASE_SAFE(proMod);
            
            //登陆成功后会员喜欢的商品ID插入表
            member_likeshop_model *likeShop = [[member_likeshop_model alloc]init];
            [likeShop deleteDBdata];
            
            NSString *produtsId = [listDic objectForKey:@"produts_id"];
            if (![produtsId isEqualToString:@""]) {
                NSArray *produtsArray = [produtsId componentsSeparatedByString:@","];
                if ([produtsArray count] > 0) {
                    for (int i = 0; i < [produtsArray count]; i ++) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [listDic objectForKey:@"id"],@"userId",
                                              [produtsArray objectAtIndex:i],@"produts_id",
                                              nil];
                        [likeShop insertDB:dic];
                    }
                }
            }
            
            RELEASE_SAFE(likeShop);
            
            //登陆成功后会员喜欢的资讯ID插入表
            member_likeinformation_model *likeMsg = [[member_likeinformation_model alloc]init];
            [likeMsg deleteDBdata];
            
            NSString *newsId = [listDic objectForKey:@"news_id"];

            if (![newsId isEqualToString:@""]) {
                NSArray *newssArray = [newsId componentsSeparatedByString:@","];
                if ([newssArray count] > 0) {
                    for (int i = 0; i < [newssArray count]; i ++) {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [listDic objectForKey:@"id"],@"userId",
                                               [newssArray objectAtIndex:i],@"news_id",
                                               nil];
                        [likeMsg insertDB:dic];
                    }
                }
            }
            RELEASE_SAFE(likeMsg);
        }
        
        
        [memMod release];
        
        return arry;
    }else{
        return nil;
    }
}

// 注册获取验证码
+ (NSMutableArray *)parseRegisterGetauthcode:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    [arry addObject:resultDic];
    return arry;
}


// 会员注册
+ (NSMutableArray *)parseRegister:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
	
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    if (resultDic) {

        [arry addObject:resultDic];
        
        //创建模型
        member_info_model *memMod = [[member_info_model alloc] init];
        
        
        //更新数据
        NSDictionary *listDic = [resultDic objectForKey:@"userInfo"];
        
        
        memMod.where = nil;
        
        //保存数据
        if ([[resultDic objectForKey:@"ret"]intValue]==1)
        {
            
            memMod.where = [NSString stringWithFormat:@"id = %d",[[listDic objectForKey:@"id"] intValue]];
            NSLog(@"id =%d",[[listDic objectForKey:@"id"] intValue]);
            NSMutableArray *dbArray = [memMod getList];
            if ([dbArray count] > 0)
            {
                [memMod updateDB:listDic];
            }
            else
            {
                [memMod insertDB:listDic];
            }
            
        }

        [memMod release];

        return arry;
    }else{
        return nil;
    }

}

//会员注销
+ (NSMutableArray *)parseLogout:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    [arry addObject:resultDic];
    return arry;
}

//会员修改密码
+ (NSMutableArray *)parseUpdatePwd:(NSDictionary *)resultDic
{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    [arry addObject:resultDic];
    return arry;
}

//会员获取验证码
+ (NSMutableArray *)parseGetauthcode:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    [arry addObject:resultDic];
    return arry;
}

//会员头像上传
+ (NSMutableArray *)parseUploaderImage:(NSDictionary *)resultDic{
    
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    [arry addObject:resultDic];
    return arry;

}

//会员中心个人信息接口
+ (NSMutableArray *)parseUserinfo:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    NSLog(@"%@",resultDic);
    if (resultDic) {
        [arry addObject:resultDic];
    }
    
    return arry;
}


//会员中心删除喜欢接口
+ (NSMutableArray *)parseDelLike:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    NSLog(@"%@",resultDic);
    if (resultDic) {
        [arry addObject:resultDic];
    }
    
    return arry;
}



//会员中心预订中作废预订接口
+ (NSMutableArray *)parseOrderCancel:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    NSLog(@"%@",resultDic);
    if (resultDic) {
        [arry addObject:resultDic];
    }
    
    return arry;
}


//会员中心我赞过的商品接口
+ (NSMutableArray *)parseShopLikes:(NSDictionary *)resultDic{
    
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
      
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"product"];
	
//    //创建数据库模型
//    member_shoplikes_model *shoplikesMod = [[member_shoplikes_model alloc] init];
//    member_shoplikePic_model *plpMod = [[member_shoplikePic_model alloc] init];
//   
//    
//    shoplikesMod.where = nil;
//	plpMod.where=nil;
//    
//	//保存数据
//	if ([listArray count] > 0) {
//
//		for (int i = 0; i < [listArray count]; i++ ) {
//            
//            NSDictionary *infoDic = [listArray objectAtIndex:i];
//
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [infoDic objectForKey:@"id"],@"id",
//                                  [infoDic objectForKey:@"product_id"],@"product_id",
//                                  [infoDic objectForKey:@"catalog_id"],@"catalog_id",
//                                  [infoDic objectForKey:@"name"],@"name",
//                                  [infoDic objectForKey:@"image"],@"image",
//                                  [infoDic objectForKey:@"sku"],@"sku",
//                                  [infoDic objectForKey:@"stock"],@"stock",
//                                  [infoDic objectForKey:@"content"],@"content",
//                                  [infoDic objectForKey:@"product_model"],@"product_model",
//                                  [infoDic objectForKey:@"like_sum"],@"like_sum",
//                                  [infoDic objectForKey:@"sale_sum"],@"sale_sum",
//                                  [infoDic objectForKey:@"comment_sum"],@"comment_sum",
//                                  [infoDic objectForKey:@"is_promotion"],@"is_guess_like",
//                                  [infoDic objectForKey:@"position"],@"position",
//                                  [infoDic objectForKey:@"big_show"],@"big_show",
//                                  [infoDic objectForKey:@"hot"],@"hot",
//                                  [infoDic objectForKey:@"hot_time"],@"hot_time",
//                                  [infoDic objectForKey:@"created"],@"created",
//                                  nil];
//            
//            shoplikesMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
//            NSMutableArray *dbArray = [shoplikesMod getList];
//            if ([dbArray count] > 0) {
//                [shoplikesMod updateDB:dict];
//            } else {
//                [shoplikesMod insertDB:dict];
//            }
//            
//            
//            //图片
//            NSArray *arrPic = [infoDic objectForKey:@"pics"];
//    
//            
//            for (NSDictionary *picDic in arrPic) {
//                plpMod.where = [NSString stringWithFormat:@"product_id = %d",[[picDic objectForKey:@"product_id"] intValue]];
//                NSMutableArray *dbArray2 = [plpMod getList];
//                if ([dbArray2 count] > 0) {
//                    [plpMod updateDB:picDic];
//                } else {
//                    [plpMod insertDB:picDic];
//                }
//			}
//            
//		}
//	}
//	
//    //保证数据只有20条
//    shoplikesMod.orderBy = @"id";
//    shoplikesMod.orderType = @"desc";
//    NSMutableArray *plItems = [shoplikesMod getList];
//    for (int i = [plItems count] - 1; i > 19; i--) {
//        NSDictionary *plDic = [plItems objectAtIndex:i];
//        NSString *plId = [plDic objectForKey:@"id"];
//        
//        shoplikesMod.where = [NSString stringWithFormat:@"id = '%@'",plId];
//        [shoplikesMod deleteDBdata];
//        
//        NSArray *arrPic = [plDic objectForKey:@"pics"];
//    
//        for (NSDictionary *picDic in arrPic) {
//            plpMod.where = [NSString stringWithFormat:@"product_id = %d",[[picDic objectForKey:@"product_id"] intValue]];
//            [plpMod deleteDBdata];
//        }
//
//    }
//    
//	
//    [shoplikesMod release];
//    [plpMod release];

    return listArray;
}

//会员中心我赞过的商品接口 加载更多
+ (NSMutableArray *)parseShopMoreLikes:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"product"];
    
    NSLog(@"product====%@---%d",listArray,[listArray count]);
    
    return listArray;
}

//会员中心我赞过的资讯接口
+ (NSMutableArray *)parseMessageLikes:(NSDictionary *)resultDic{
    
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"news"];
	
    //重新封装下发的格式
    NSMutableArray *arry = [[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i = 0; i < [listArray count]; i ++) {
          NSMutableDictionary *shoplikeDic = [listArray objectAtIndex:i];
          
          NSArray * imgArry = [shoplikeDic objectForKey:@"pics"];
          NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [shoplikeDic objectForKey:@"id"],@"new_id",
                                      [shoplikeDic objectForKey:@"music"],@"music",
                                      [shoplikeDic objectForKey:@"title"],@"title",
                                      [shoplikeDic objectForKey:@"content"],@"content",
                                      [shoplikeDic objectForKey:@"picture"],@"picture",
                                      [shoplikeDic objectForKey:@"comment_sum"],@"comment_sum",
                                      [shoplikeDic objectForKey:@"recommend"],@"recommend",
                                      [shoplikeDic objectForKey:@"created"],@"created",
                                      [shoplikeDic objectForKey:@"like_sum"],@"like_sum",
                                      [shoplikeDic objectForKey:@"news_created"],@"news_created",
                                      nil];
        NSArray *mediaArr = [shoplikeDic objectForKey:@"media"];
            [dict setObject:mediaArr forKey:@"media"];
            [dict setObject:imgArry forKey:@"pics"];
            [arry addObject:dict];
      }

//    //创建数据库模型
//    member_msglikes_model *msglikesMod = [[member_msglikes_model alloc] init];
//    member_msglikePic_model *plpMod = [[member_msglikePic_model alloc] init];
//
//    
//    msglikesMod.where = nil;
//	
//	//保存数据
//	if ([listArray count] > 0) {
//        
//		for (int i = 0; i < [listArray count]; i++ ) {
//            
//            NSDictionary *infoDic = [listArray objectAtIndex:i];
//            
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [infoDic objectForKey:@"id"],@"new_id",
//                                  [infoDic objectForKey:@"title"],@"title",
//                                  [infoDic objectForKey:@"content"],@"content",
//                                  [infoDic objectForKey:@"picture"],@"picture",
//                                  [infoDic objectForKey:@"comment_sum"],@"comment_sum",
//                                  [infoDic objectForKey:@"recommend"],@"recommend",
//                                  [infoDic objectForKey:@"created"],@"created",
//                                  [infoDic objectForKey:@"like_sum"],@"like_sum",
//                                  [infoDic objectForKey:@"news_created"],@"news_created",
//                                  nil];
//            
//            msglikesMod.where = [NSString stringWithFormat:@"new_id = %d",[[infoDic objectForKey:@"id"] intValue]];
//            NSMutableArray *dbArray = [msglikesMod getList];
//            if ([dbArray count] > 0) {
//                [msglikesMod updateDB:dict];
//            } else {
//                [msglikesMod insertDB:dict];
//            }
//            
//            //图片
//            NSArray *arrPic = [infoDic objectForKey:@"pics"];
//            
//            for (NSDictionary *picDic in arrPic) {
//                plpMod.where = [NSString stringWithFormat:@"new_id = %d",[[picDic objectForKey:@"new_id"]intValue]];
//                NSMutableArray *dbArray = [plpMod getList];
//                if ([dbArray count] > 0) {
//                    [plpMod updateDB:picDic];
//                } else {
//                    [plpMod insertDB:picDic];
//                }
//			}
//            
//		}
//	}
//	
//    //保证数据只有20条
//    msglikesMod.orderBy = @"new_id";
//    msglikesMod.orderType = @"desc";
//    NSMutableArray *plItems = [msglikesMod getList];
//    for (int i = [plItems count] - 1; i > 19; i--) {
//        NSDictionary *plDic = [plItems objectAtIndex:i];
//        NSString *plId = [plDic objectForKey:@"new_id"];
//        
//        msglikesMod.where = [NSString stringWithFormat:@"new_id = %@",plId];
//        [msglikesMod deleteDBdata];
//        
//        plpMod.where = [NSString stringWithFormat:@"new_id = %@",plId];
//        [plpMod deleteDBdata];
//        
//    }
//    
//	
//    [msglikesMod release];
//    [plpMod release];
    
    return [arry autorelease];
}

//会员中心我赞过的资讯接口 加载更多
+ (NSMutableArray *)parseMessageMoreLikes:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"news"];
    
    NSLog(@"news====%@---%d",listArray,[listArray count]);
    
    //重新封装下发的格式
    NSMutableArray *arry = [[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i = 0; i < [listArray count]; i ++) {
        NSMutableDictionary *shoplikeDic = [listArray objectAtIndex:i];
        
        NSArray * imgArry = [shoplikeDic objectForKey:@"pics"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [shoplikeDic objectForKey:@"id"],@"new_id",
                                     [shoplikeDic objectForKey:@"title"],@"title",
                                     [shoplikeDic objectForKey:@"content"],@"content",
                                     [shoplikeDic objectForKey:@"picture"],@"picture",
                                     [shoplikeDic objectForKey:@"comment_sum"],@"comment_sum",
                                     [shoplikeDic objectForKey:@"recommend"],@"recommend",
                                     [shoplikeDic objectForKey:@"created"],@"created",
                                     [shoplikeDic objectForKey:@"like_sum"],@"like_sum",
                                     [shoplikeDic objectForKey:@"news_created"],@"news_created",
                                     nil];
        
        [dict setObject:imgArry forKey:@"pics"];
        
        [arry addObject:dict];
    }
    
    return [arry autorelease];
}

//会员中心我的评论接口
+ (NSMutableArray *)parseShopComment:(NSDictionary *)resultDic{
    
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"products_comment"];
	
    NSLog(@"listArray==%@-count-%d",listArray,[listArray count]);
    
    
    
    //创建数据库模型
//    member_shopcomment_model *shopCommentMod = [[member_shopcomment_model alloc] init];
//    member_shopcommentPic_model *plpMod = [[member_shopcommentPic_model alloc] init];
//    
//    shopCommentMod.where = nil;
//	
//	//保存数据
//	if ([listArray count] > 0) {
//        
//		for (int i = 0; i < [listArray count]; i++ ) {
//            
//            NSDictionary *infoDic = [listArray objectAtIndex:i];
//   
//                                              
//            NSDictionary *dicts = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [infoDic objectForKey:@"comment_created"],@"comment_created",
//                                  [infoDic objectForKey:@"content"],@"content",
//                                  [infoDic objectForKey:@"user_name"],@"user_name",
//                                  [infoDic objectForKey:@"id"],@"id",
//                                  [infoDic objectForKey:@"product_id"],@"product_id",
//                                  [infoDic objectForKey:@"comment_id"],@"comment_id",
//                                  [infoDic objectForKey:@"catalog_id"],@"catalog_id",
//                                  [infoDic objectForKey:@"name"],@"name",
//                                  [infoDic objectForKey:@"image"],@"image",
//                                  [infoDic objectForKey:@"stock"],@"stock",
//                                  [infoDic objectForKey:@"sku"],@"sku",
//                                  [infoDic objectForKey:@"comment_content"],@"comment_content",
//                                  [infoDic objectForKey:@"product_model"],@"product_model",
//                                  [infoDic objectForKey:@"like_sum"],@"like_sum",
//                                  [infoDic objectForKey:@"sale_sum"],@"sale_sum",
//                                  [infoDic objectForKey:@"comment_sum"],@"comment_sum",
//                                  [infoDic objectForKey:@"position"],@"position",
//                                  [infoDic objectForKey:@"subsidy"],@"subsidy",
//                                  [infoDic objectForKey:@"created"],@"created",
//                                  [infoDic objectForKey:@"favorite_sum"],@"favorite_sum",
//                                  nil];
//            
//
//            shopCommentMod.where = [NSString stringWithFormat:@"comment_id=%d",[[infoDic objectForKey:@"comment_id"] intValue]];
//            NSMutableArray *dbArray = [shopCommentMod getList];
//            NSLog(@"dbArray==%@",dbArray);
//            if ([dbArray count] > 0) {
//                [shopCommentMod updateDB:dicts];
//            } else {
//                [shopCommentMod insertDB:dicts];
//            }
//            
//            //图片
//            NSDictionary *picDic = [infoDic objectForKey:@"pics"];
//        
//            plpMod.where = [NSString stringWithFormat:@"img_path = '%@'",[picDic objectForKey:@"img_path"]];
//            NSMutableArray *dbArray2 = [plpMod getList];
//            if ([dbArray2 count] > 0) {
//                [plpMod updateDB:picDic];
//            } else {
//                [plpMod insertDB:picDic];
//            }
//		}
//	}
//	
//    //保证数据只有20条
//    shopCommentMod.where = nil;
//    shopCommentMod.orderBy = @"comment_id";
//    shopCommentMod.orderType = @"asc";
//    NSMutableArray *plItems = [shopCommentMod getList];
//    for (int i = [plItems count] - 1; i > 19; i--) {
//        NSDictionary *plDic = [plItems objectAtIndex:i];
//        NSString *plId = [plDic objectForKey:@"comment_id"];
//        
//        shopCommentMod.where = [NSString stringWithFormat:@"comment_id = %@",plId];
//        [shopCommentMod deleteDBdata];
//        
//        plpMod.where = [NSString stringWithFormat:@"id = %@",plId];
//        [plpMod deleteDBdata];
//        
//    }
//    
//	
//    [shopCommentMod release];
//    [plpMod release];
//    
//    return nil;
    
    return listArray;
}

//会员中心我评论的商品接口 加载更多
+ (NSMutableArray *)parseShopMoreComment:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"products_comment"];
    
    NSLog(@"products_comment====%@---%d",listArray,[listArray count]);
    
    return listArray;
}

//会员中心我的资讯评论接口
+ (NSMutableArray *)parseMsgComment:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray2 = [resultDic objectForKey:@"news_comment"];
	
    NSLog(@"news_comment==%@",listArray2);
    
    
    //创建数据库模型
//    member_msgcomment_model *newsCommentMod = [[member_msgcomment_model alloc] init];
//    member_msgcommentPic_model *picsMod = [[member_msgcommentPic_model alloc] init];
//
//    newsCommentMod.where = nil;
//	
//	//保存数据
//	if ([listArray2 count] > 0) {
//        
//		for (int i = 0; i < [listArray2 count]; i++ ) {
//            
//            NSDictionary *infoDic2 = [listArray2 objectAtIndex:i];
//            
//            NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [infoDic2 objectForKey:@"comment_id"],@"comment_id",
//                                   [infoDic2 objectForKey:@"comment_created"],@"comment_created",
//                                   [infoDic2 objectForKey:@"comment"],@"comment",
//                                   [infoDic2 objectForKey:@" user_name"],@"user_name",
//                                   [infoDic2 objectForKey:@"new_id"],@"new_id",
//                                   [infoDic2 objectForKey:@"image"],@"image",
//                                   [infoDic2 objectForKey:@"title"],@"title",
//                                   [infoDic2 objectForKey:@"content"],@"content",
//                                   [infoDic2 objectForKey:@"comment_sum"],@"comment_sum",
//                                   [infoDic2 objectForKey:@"recommend"],@"recommend",
//                                   [infoDic2 objectForKey:@"news_created"],@"news_created",
//                                   nil];
//            
//            newsCommentMod.where = [NSString stringWithFormat:@"comment_id = %d",[[infoDic2 objectForKey:@"comment_id"] intValue]];
//            NSMutableArray *dbArray = [newsCommentMod getList];
//            if ([dbArray count] > 0) {
//                [newsCommentMod updateDB:dict2];
//            } else {
//                [newsCommentMod insertDB:dict2];
//            }
//            
//            //图片
//            NSArray *arrPic = [infoDic2 objectForKey:@"pics"];
//            
//            for (NSDictionary *picDic in arrPic) {
//                picsMod.where = [NSString stringWithFormat:@"product_id = %d",[[picDic objectForKey:@"product_id"] intValue]];
//                NSMutableArray *dbArray = [picsMod getList];
//                if ([dbArray count] > 0) {
//                    [picsMod updateDB:picDic];
//                } else {
//                    [picsMod insertDB:picDic];
//                }
//			}
//            
//		}
//	}
//	
//    //保证数据只有20条
//    newsCommentMod.where=nil;
//    newsCommentMod.orderBy = @"comment_id";
//    newsCommentMod.orderType = @"desc";
//    NSMutableArray *plItem = [newsCommentMod getList];
//    NSLog(@"plItem=%@",plItem);
//    for (int i = [plItem count] - 1; i > 19; i--) {
//        NSDictionary *plDic = [plItem objectAtIndex:i];
//        NSString *plId = [plDic objectForKey:@"comment_id"];
//        
//        newsCommentMod.where = [NSString stringWithFormat:@"comment_id = %@",plId];
//        [newsCommentMod deleteDBdata];
//        
////        picsMod.where = [NSString stringWithFormat:@"id = %@",plId];
////        [picsMod deleteDBdata];
//        
//    }
//    
//	
//    [newsCommentMod release];
//    [picsMod release];
//
//    return nil;
    
    return listArray2;
}

//会员中心我评论的资讯接口 加载更多
+ (NSMutableArray *)parseMsgMoreComment:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"news_comment"];
    
    NSLog(@"news_comment====%@---%d",listArray,[listArray count]);
    
    return listArray;
}


//会员中心全部预订接口
+ (NSMutableArray *)parseOrderlist:(NSDictionary *)resultDic
{

    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"order"];
	
    NSLog(@"allOrderlistArray=%@",resultDic);
    
    //创建数据库模型
//    member_orderdetail_list_model *orderTetail = [[member_orderdetail_list_model alloc] init];
//    
//    orderTetail.where = nil;
//	
//	//保存数据
//	if ([listArray count] > 0) {
//        
//		for (int i = 0; i < [listArray count]; i++ ) {
//            
//            NSDictionary *infoDic = [listArray objectAtIndex:i];
//            
//            NSLog(@"product_id==%@",[infoDic objectForKey:@"product_id"]);
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [infoDic objectForKey:@"id"],@"id",
//                                   [infoDic objectForKey:@"order_sn"],@"order_sn",
//                                   [infoDic objectForKey:@"name"],@"name",
//                                   [infoDic objectForKey:@"reserve_time"],@"reserve_time",
//                                   [infoDic objectForKey:@"promotion_id"],@"promotion_id",
//                                   [infoDic objectForKey:@"discount"],@"discount",
//                                   [infoDic objectForKey:@"money"],@"money",
//                                   [infoDic objectForKey:@"pay_money"],@"pay_money",
//                                   [infoDic objectForKey:@"province"],@"province",
//                                   [infoDic objectForKey:@"address"],@"address",
//                                   [infoDic objectForKey:@"zipcode"],@"zipcode",
//                                   [infoDic objectForKey:@"mobile"],@"mobile",
//                                   [infoDic objectForKey:@"city"],@"city",
//                                   [infoDic objectForKey:@"created"],@"created",
//                                   [infoDic objectForKey:@"delivery_type"],@"delivery_type",
//                                   [infoDic objectForKey:@"invoice_type"],@"invoice_type",
//                                   [infoDic objectForKey:@"invoice_title"],@"invoice_title",
//                                   [infoDic objectForKey:@"remark"],@"remark",
//                                   [infoDic objectForKey:@"audit"],@"audit",
//                                   [infoDic objectForKey:@"cancel_time"],@"cancel_time",
//                                   [infoDic objectForKey:@"product_id"],@"product_id",
//                                   [infoDic objectForKey:@"shopName"],@"shopName",
//                                   nil];
//            
//            orderTetail.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
//            NSMutableArray *dbArray = [orderTetail getList];
//            NSLog(@"数据库dbArray=%@",dbArray);
//            if ([dbArray count] > 0) {
//                [orderTetail updateDB:dict];
//            } else {
//                [orderTetail insertDB:dict];
//            }
//            
//            
//            //更新数据
//            NSArray *listArray2 = [infoDic objectForKey:@"products"];
//            
//            NSLog(@"listArray2222==%@==count%d",listArray2,[listArray2 count]);
//            
//            //创建数据库模型
//            member_allorder_list_model *allMod = [[member_allorder_list_model alloc] init];
//            member_allorder_listPic_model *picsMod = [[member_allorder_listPic_model alloc] init];
//            
//            allMod.where = nil;
//            
//            //保存数据
//            if ([listArray2 count] > 0) {
//                
////                for (int j = 0; i < [listArray2 count]; i++ ) {
////                    
//                    NSDictionary *infoDic2 = [listArray2 objectAtIndex:0];
//                    
//                    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
//                                           [infoDic objectForKey:@"id"],@"id",
//                                           [infoDic2 objectForKey:@"product_id"],@"product_id",
//                                           [infoDic2 objectForKey:@"catalog_id"],@"catalog_id",
//                                           [infoDic2 objectForKey:@"name"],@"name",
//                                           [infoDic2 objectForKey:@"image"],@"image",
//                                           [infoDic2 objectForKey:@"stock"],@"stock",
//                                           [infoDic2 objectForKey:@"content"],@"content",
//                                           [infoDic2 objectForKey:@"product_model"],@"product_model",
//                                           [infoDic2 objectForKey:@"like_sum"],@"like_sum",
//                                           [infoDic2 objectForKey:@"sale_sum"],@"sale_sum",
//                                           [infoDic2 objectForKey:@"comment_sum"],@"comment_sum",
//                                           [infoDic2 objectForKey:@"position"],@"position",
//                                           [infoDic2 objectForKey:@"created"],@"created",
//                                           nil];
//        \
//                    allMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"]intValue]];
//                    NSMutableArray *dbArray2 = [allMod getList];
//                    NSLog(@"dbArray2%@",dbArray2);
//                    if ([dbArray2 count] > 0) {
//                        [allMod updateDB:dict2];
//                    } else {
//                        [allMod insertDB:dict2];
//                    }
//            
//                    //图片
//                    NSArray *arrPic = [infoDic2 objectForKey:@"pics"];
//                    
//                    for (NSDictionary *picDic in arrPic) {
//                        picsMod.where = [NSString stringWithFormat:@"product_id = %d",[[picDic objectForKey:@"product_id"] intValue]];
//                        NSMutableArray *dbArray3 = [picsMod getList];
//                        if ([dbArray3 count] > 0) {
//                            [picsMod updateDB:picDic];
//                        } else {
//                            [picsMod insertDB:picDic];
//                        }
////                    }
//                }
//            }
//            //保证数据只有20条
//            allMod.orderBy = @"id";
//            allMod.orderType = @"desc";
//            NSMutableArray *plItem2 = [allMod getList];
//            for (int i = [plItem2 count] - 1; i > 19; i--) {
//                NSDictionary *plDic = [plItem2 objectAtIndex:i];
//                NSString *plId = [plDic objectForKey:@"id"];
//                
//                allMod.where = [NSString stringWithFormat:@"id = %@",plId];
//                [allMod deleteDBdata];
//                
//                picsMod.where = [NSString stringWithFormat:@"product_id = %@",plId];
//                [picsMod deleteDBdata];
//                
//            }
//            [allMod release];
//            [picsMod release];
//
//            
//        }
//    }
//	
//    //保证数据只有20条
//    orderTetail.orderBy = @"id";
//    orderTetail.orderType = @"desc";
//    NSMutableArray *plItem = [orderTetail getList];
//    for (int i = [plItem count] - 1; i > 19; i--) {
//        NSDictionary *plDic = [plItem objectAtIndex:i];
//        NSString *plId = [plDic objectForKey:@"id"];
//        
//        orderTetail.where = [NSString stringWithFormat:@"id = %@",plId];
//        [orderTetail deleteDBdata];
//        
//    }
//
//        
//    [orderTetail release];
 
    return listArray;
}

//会员中心预订中取消预订接口
+ (NSMutableArray *)parseCancelOrderlist:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"order"];
	
    NSLog(@"cancelOrderlistArray=%@",resultDic);
    

    //创建数据库模型
//    member_orderdetail_list_model *orderTetail = [[member_orderdetail_list_model alloc] init];
//    
//    orderTetail.where = nil;
//	
//	//保存数据
//	if ([listArray count] > 0) {
//        
//		for (int i = 0; i < [listArray count]; i++ ) {
//            
//            NSDictionary *infoDic = [listArray objectAtIndex:i];
//            
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [infoDic objectForKey:@"id"],@"id",
//                                  [infoDic objectForKey:@"order_sn"],@"order_sn",
//                                  [infoDic objectForKey:@"name"],@"name",
//                                  [infoDic objectForKey:@"reserve_time"],@"reserve_time",
//                                  [infoDic objectForKey:@"promotion_id"],@"promotion_id",
//                                  [infoDic objectForKey:@"discount"],@"discount",
//                                  [infoDic objectForKey:@"money"],@"money",
//                                  [infoDic objectForKey:@"pay_money"],@"pay_money",
//                                  [infoDic objectForKey:@"province"],@"province",
//                                  [infoDic objectForKey:@"shopName"],@"shopName",
//                                  [infoDic objectForKey:@"address"],@"address",
//                                  [infoDic objectForKey:@"mobile"],@"mobile",
//                                  [infoDic objectForKey:@"city"],@"city",
//                                  [infoDic objectForKey:@"created"],@"created",
//                                  [infoDic objectForKey:@"audit"],@"audit",
//                                  [infoDic objectForKey:@"delivery_type"],@"delivery_type",
//                                  [infoDic objectForKey:@"invoice_type"],@"invoice_type",
//                                  [infoDic objectForKey:@"invoice_title"],@"invoice_title",
//                                  [infoDic objectForKey:@"invoice_name"],@"invoice_name",
//                                  [infoDic objectForKey:@"remark"],@"remark",
//                                  [infoDic objectForKey:@"product_id"],@"product_id",
//                                  nil];
//            
//            orderTetail.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
//            NSMutableArray *dbArray = [orderTetail getList];
//            if ([dbArray count] > 0) {
//                [orderTetail updateDB:dict];
//            } else {
//                [orderTetail insertDB:dict];
//            }
//            
//            
//            //更新数据
//            NSArray *listArray2 = [infoDic objectForKey:@"products"];
//            
//            NSLog(@"cancelOrderlistArray2==%@",listArray2);
//            
//            //创建数据库模型
//            member_allorder_list_model *allMod = [[member_allorder_list_model alloc] init];
//            member_allorder_listPic_model *picsMod = [[member_allorder_listPic_model alloc] init];
//            
//            allMod.where = nil;
//            
//            //保存数据
//            if ([listArray2 count] > 0) {
//                
//                for (int i = 0; i < [listArray2 count]; i++ ) {
//                
//                    NSDictionary *infoDic2 = [listArray2 objectAtIndex:i];
//                
//                NSLog(@"infoDic2=====%@",infoDic2);
//                
//                    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
//                                           [infoDic objectForKey:@"id"],@"id",
//                                           [infoDic2 objectForKey:@"product_id"],@"product_id",
//                                           [infoDic2 objectForKey:@"catalog_id"],@"catalog_id",
//                                           [infoDic2 objectForKey:@"name"],@"name",
//                                           [infoDic2 objectForKey:@"image"],@"image",
//                                           [infoDic2 objectForKey:@"sku"],@"sku",
//                                           [infoDic2 objectForKey:@"stock"],@"stock",
//                                           [infoDic2 objectForKey:@"content"],@"content",
//                                           [infoDic2 objectForKey:@"product_model"],@"product_model",
//                                           [infoDic2 objectForKey:@"like_sum"],@"like_sum",
//                                           [infoDic2 objectForKey:@"sale_sum"],@"sale_sum",
//                                           [infoDic2 objectForKey:@"comment_sum"],@"comment_sum",
//                                           [infoDic2 objectForKey:@"position"],@"position",
//                                           [infoDic2 objectForKey:@"subsidy"],@"subsidy",
//                                           [infoDic2 objectForKey:@"created"],@"created",
//                                           nil];
//                    
//                    
//                    allMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
//                    NSMutableArray *dbArray = [allMod getList];
//                    if ([dbArray count] > 0) {
//                        [allMod updateDB:dict2];
//                    } else {
//                        [allMod insertDB:dict2];
//                    }
//                    
//                    //图片
//                    NSArray *arrPic = [infoDic2 objectForKey:@"pics"];
//                    
//                    for (NSDictionary *picDic in arrPic) {
//                        picsMod.where = [NSString stringWithFormat:@"id = %d",[[picDic objectForKey:@"id"] intValue]];
//                        NSMutableArray *dbArray = [picsMod getList];
//                        if ([dbArray count] > 0) {
//                            [picsMod updateDB:picDic];
//                        } else {
//                            [picsMod insertDB:picDic];
//                        }
//                    }
//                }
//            }
//            //保证数据只有20条
//            allMod.orderBy = @"id";
//            allMod.orderType = @"desc";
//            NSMutableArray *plItem2 = [allMod getList];
//            for (int i = [plItem2 count] - 1; i > 19; i--) {
//                NSDictionary *plDic = [plItem2 objectAtIndex:i];
//                NSString *plId = [plDic objectForKey:@"id"];
//                
//                allMod.where = [NSString stringWithFormat:@"id = %@",plId];
//                [allMod deleteDBdata];
//                
//                picsMod.where = [NSString stringWithFormat:@"id = %@",plId];
//                [picsMod deleteDBdata];
//                
//            }
//            [allMod release];
//            [picsMod release];
//            
//            
//        }
//    }
//	
//    //保证数据只有20条
//    orderTetail.orderBy = @"id";
//    orderTetail.orderType = @"desc";
//    NSMutableArray *plItem = [orderTetail getList];
//    for (int i = [plItem count] - 1; i > 19; i--) {
//        NSDictionary *plDic = [plItem objectAtIndex:i];
//        NSString *plId = [plDic objectForKey:@"id"];
//        
//        orderTetail.where = [NSString stringWithFormat:@"id = %@",plId];
//        [orderTetail deleteDBdata];
//        
//    }
//    
//    
//    [orderTetail release];
//    
//    return nil;
    
    return listArray;
}

//会员中心预订中全部预订接口 加载更多
+ (NSMutableArray *)parseOrderMorelist:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"order"];
	
    NSLog(@"moreOrderlistArray=%@",resultDic);
    
    return listArray;
}

//会员中心预订中取消预订接口 加载更多
+ (NSMutableArray *)parseCancelOrderMorelist:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"order"];
	
    NSLog(@"moreCancelOrderlistArray=%@",resultDic);
    
    return listArray;
}
//会员中心我的售后服务接口
+ (NSMutableArray *)parseMyAfterService:(NSDictionary *)resultDic{
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
	
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    [arry addObject:resultDic];
    
    if (resultDic) {
        
        //创建模型
        member_after_service_model *memMod = [[member_after_service_model alloc] init];
        
        
        //更新数据
        NSArray *listArray = [resultDic objectForKey:@"after_erver"];
        
        
        memMod.where = nil;
        for (int i=0; i<[listArray count]; i++) {
        
            NSDictionary *listDic=[listArray objectAtIndex:i];
            
            memMod.where = [NSString stringWithFormat:@"id = %d",[[listDic objectForKey:@"id"] intValue]];
            NSLog(@"id =%d",[[listDic objectForKey:@"id"] intValue]);
            NSMutableArray *dbArray = [memMod getList];
            if ([dbArray count] > 0)
            {
                [memMod updateDB:listDic];
            }
            else
            {
                [memMod insertDB:listDic];
            }
            
        }
        
        
        [memMod release];
        
    }
    
    return arry;
    
}

//会员中心我的售后服务详情接口
+ (NSMutableArray *)parseMyServiceDetail:(NSDictionary *)resultDic{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSLog(@"%@",resultDic);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //更新数据
	NSArray *listArray = [resultDic objectForKey:@"aftersaletracks"];
    
    //创建数据库模型
    afterservice_detail_model *alMod = [[afterservice_detail_model alloc] init];
    
	//保存数据
	if ([listArray count] > 0) {
     
		for (int i = 0; i < [listArray count]; i++ ) {
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            
            alMod.where = [NSString stringWithFormat:@"track_time = %d",[[infoDic objectForKey:@"track_time"] intValue]];
            NSMutableArray *dbArray = [alMod getList];
            if ([dbArray count] > 0) {
                [alMod updateDB:infoDic];
            } else {
                [alMod insertDB:infoDic];
            }
		}
	}
	
    //保证数据只有20条
    alMod.where = nil;
    alMod.orderBy = @"id";
    alMod.orderType = @"desc";
    NSMutableArray *plItems = [alMod getList];
    for (int i = [plItems count] - 1; i > 19; i--) {
        NSDictionary *plDic = [plItems objectAtIndex:i];
        NSString *plId = [plDic objectForKey:@"id"];
        
        alMod.where = [NSString stringWithFormat:@"id = %@",plId];
        [alMod deleteDBdata];
    }
	
    [alMod release];
    
    [pool release];
    
    return nil;
}


//会员中心删除收货地址接口
+ (NSMutableArray *)parseDelAddress:(NSDictionary *)resultDic{
    
    NSMutableArray *arry=[NSMutableArray arrayWithCapacity:0];
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    NSLog(@"%@",resultDic);
    if (resultDic) {
        [arry addObject:resultDic];
    }
    
    return arry;
}


//百宝箱关于我们接口
+ (NSMutableArray *)parseAboutUs:(NSDictionary *)resultDic getVersion:(int*)ver{
    *ver = NO_UPDATE;
    
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];infoHeight
    NSLog(@"======%@",resultDic);
    NSDictionary *listDic = [resultDic objectForKey:@"about"];
	
    about_us_model *aboutMod=[[about_us_model alloc]init];
    
    if ([listDic count] > 0) {
        
        *ver = NEED_UPDATE;
        
        NSMutableArray *dbArray = [aboutMod getList];
        
            if ([dbArray count] > 0) {
                [aboutMod updateDB:listDic];
            } else {
                [aboutMod insertDB:listDic];
            }
        
    }
    RELEASE_SAFE(aboutMod);
    
    NSMutableArray *aboutArray = [[[NSMutableArray alloc]init]autorelease];
    
    [aboutArray addObject:resultDic];
    
    return aboutArray;
     
}

//百宝箱应用推荐接口
+ (NSMutableArray *)parseRecommendApp:(NSDictionary *)resultDic getVersion:(int*)ver{
    
//    *ver = NO_UPDATE;
    
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    NSLog(@"======%@",resultDic);
    //更新数据
    NSMutableArray *recommendApp = [[[NSMutableArray alloc]init]autorelease];

    [recommendApp addObject:resultDic];
    
//	NSArray *listArray = [resultDic objectForKey:@"recommends"];
//    NSString *adsVer = [resultDic objectForKey:@"ad_ver"];
//    NSString *appVer = [resultDic objectForKey:@"app_ver"];
//    
//    NSLog(@"listArray==%@",listArray);
//    //创建数据库模型
//    recommend_app_model *alMod = [[recommend_app_model alloc] init];
//    alMod.where=nil;
//
//    //删除的应用数据
//	NSString *delsString = [resultDic objectForKey:@"recommend_dels"];
//	
//	//删除数据
//	if (![delsString isEqualToString:@""] && delsString != nil)
//	{
//        *ver = NEED_UPDATE;
//        
//        alMod.where = [NSString stringWithFormat:@"id in (%@)",delsString];
//        [alMod deleteDBdata];
//	}
//    
//    alMod.where=nil;
//	//保存数据
//	if ([listArray count] > 0) {
//        
//        
//        *ver = NEED_UPDATE;
//		for (int i = 0; i < [listArray count]; i++ ) {
//            
//            NSDictionary *infoDic = [listArray objectAtIndex:i];
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  adsVer,@"adsVer",
//                                  appVer,@"appVer",
//                                  [infoDic objectForKey:@"created"],@"created",
//                                  [infoDic objectForKey:@"id"],@"id",
//                                  [infoDic objectForKey:@"intro"],@"intro",
//                                  [infoDic objectForKey:@"iphone_url"],@"iphone_url",
//                                  [infoDic objectForKey:@"name"],@"name",
//                                  [infoDic objectForKey:@"picture"],@"picture",
//                                  [infoDic objectForKey:@"position"],@"position",
//                                  [infoDic objectForKey:@"ver"],@"ver",
//                                  nil];
//            
//            
//            NSLog(@"dict%@",dict);
////            alMod.where = nil;
//            alMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic objectForKey:@"id"] intValue]];
//            NSMutableArray *dbArray = [alMod getList];
//            NSLog(@"dbArray%@",dbArray);
//            
//            if ([dbArray count] > 0) {
//                [alMod updateDB:dict];
//            } else {
//                [alMod insertDB:dict];
//            }
//       
//		}
//        
//	}
//	
//    //更新数据
//	NSArray *adsArray = [resultDic objectForKey:@"ads"];
//    
//    //创建数据库模型
//    recommend_app_ads_model *adsMod = [[recommend_app_ads_model alloc] init];
//    
//    //删除的应用数据
//	NSString *delsAds = [resultDic objectForKey:@"ad_dels"];
//	
//	//删除数据
//	if (![delsAds isEqualToString:@""] && delsAds != nil)
//	{
//        *ver = NEED_UPDATE;
//        
//        adsMod.where = [NSString stringWithFormat:@"id in (%@)",delsAds];
//        [adsMod deleteDBdata];
//	}
//    
//	//保存数据
//	if ([adsArray count] > 0) {
//        
//        if ([[adsMod getList]count]>[adsArray count]) {
//            [adsMod deleteDBdata];
//        }
//        
//		for (int i = 0; i < [adsArray count]; i++ ) {
//            
//            NSDictionary *infoDic2 = [adsArray objectAtIndex:i];
//            adsMod.where = nil;
//            adsMod.where = [NSString stringWithFormat:@"id = %d",[[infoDic2 objectForKey:@"id"] intValue]];
//            
//            NSMutableArray *dbArray2 = [adsMod getList];
//            
//            if ([dbArray2 count] > 0) {
//                [adsMod updateDB:infoDic2];
//            } else {
//                [adsMod insertDB:infoDic2];
//            }
//
//		}
//	}
    
    //保证数据只有20条
//    alMod.orderBy = @"position";
//    alMod.orderType = @"desc";
//    NSMutableArray *plItems = [alMod getList];
//    for (int i = [plItems count] - 1; i > 19; i--) {
//        NSDictionary *plDic = [plItems objectAtIndex:i];
//        NSString *plId = [plDic objectForKey:@"id"];
//        
//        alMod.where = [NSString stringWithFormat:@"id = %@",plId];
//        [alMod deleteDBdata];
//    }
//	
//    [alMod release];
    return recommendApp;
}

//百宝箱应用推荐接口 加载更多
+ (NSMutableArray *)parseMoreRecommendApp:(NSDictionary *)resultDic getVersion:(int*)ver{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    //更新数据
	NSMutableArray *listArray = [resultDic objectForKey:@"recommends"];

    return listArray;
}


//百宝箱发送留言反馈
+ (NSMutableArray*)parseSendFeedbackResult:(NSDictionary *)resultDic
{
	//NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    
    [resultArray addObject:resultDic];
    
	return [resultArray autorelease];
}

//百宝箱留言反馈列表
+ (NSMutableArray *)parseFeecbackList:(NSDictionary *)resultDic withId:(int)user_Id withShop:(int)shop_id
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
	NSMutableArray *listArray = [resultDic objectForKey:@"feedback"];
    
    //创建模型
    feedback_list_model *fbMod = [[feedback_list_model alloc] init];
    
    fbMod.where = [NSString stringWithFormat:@"type = %d and userId = %d and shopId = %d",1,user_Id,shop_id];  //type=1 是评论成功的数据，type=2 是评论失败的数据, type=3 是正在发送的数据
    [fbMod deleteDBdata];
    fbMod.where = nil;
    
    //保存数据
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count]; i++ )
		{
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:[listArray objectAtIndex:i]];
            
            [infoDic setObject:[NSNumber numberWithInt:user_Id] forKey:@"userId"];
            [infoDic setObject:[NSNumber numberWithInt:1] forKey:@"type"];
            [infoDic setObject:[NSNumber numberWithInt:shop_id] forKey:@"shopId"];
			[fbMod insertDB:infoDic];
		}
	}
    
    fbMod.orderBy = @"created";
    fbMod.orderType = @"desc";
    NSMutableArray *plItems = [fbMod getList];
    for (int i = [plItems count] - 1; i > 19; i--) {
        NSDictionary *plDic = [plItems objectAtIndex:i];
        NSString *plId = [NSString stringWithFormat:@"%d",[[plDic objectForKey:@"created"] intValue]];
        
        fbMod.where = [NSString stringWithFormat:@"created = %@ and userId = %d and shopId = %d",plId,user_Id,shop_id];
        [fbMod deleteDBdata];
    }
    
    [fbMod release];
    
    [pool release];
    
    return nil;
}

//百宝箱留言反馈列表 more
+ (NSMutableArray *)parseFeecbackListMore:(NSDictionary *)resultDic withId:(int)user_Id withShop:(int)shop_id
{
    //NSDictionary *resultDic = [jsonResult objectFromJSONString];
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
	NSMutableArray *listArray = [resultDic objectForKey:@"feedback"];
    
    //保存数据
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count]; i++ )
		{
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:[listArray objectAtIndex:i]];
            
            [infoDic setObject:[NSNumber numberWithInt:user_Id] forKey:@"userId"];
            [infoDic setObject:[NSNumber numberWithInt:1] forKey:@"type"];
            [infoDic setObject:[NSNumber numberWithInt:shop_id] forKey:@"shopId"];
			
            [resultArray addObject:infoDic];
		}
	}

    return resultArray;
}
@end
