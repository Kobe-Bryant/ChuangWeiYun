//
//  Common.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#define PI 3.1415926

#import <Foundation/Foundation.h>
#import "UIImageScale.h"
#import "BMKMultiPoint.h"
#import "BMKOverlay.h"

typedef enum
{
    SortEnumAsc,    // 升序
    SortEnumDesc,   // 降序
}SortEnum;

typedef enum
{
    CountTypeProduct,        // 产品 统计
    CountTypeNew,            // 资讯 统计
    CountTypePreactivity,   // 优惠活动 统计
    CountTypeShop,          // 分点 统计
}CountType;

@interface Common : NSObject

//公共函数:
+ (BOOL) connectedToNetwork;
+ (NSString*) TransformJson:(NSMutableDictionary*)sourceDic withLinkStr:(NSString*)strurl;
+ (NSString*) encodeBase64:(NSMutableData*)data;
+ (NSString*) URLEncodedString:(NSString*)input;
+ (NSString*) URLDecodedString:(NSString*)input;
+ (NSNumber*) getVersion:(int)commandId;
+ (NSNumber*) getVersion:(int)commandId desc:(NSString *)desc;
+ (BOOL) updateVersion:(int)commandId withVersion:(int)version withDesc:(NSString*)desc;

+ (NSNumber*) getCatVersion:(int)commandId withId:(int)cat_Id;
+ (BOOL) updateCatVersion:(int)commandId withVersion:(int)version withId:(int)cat_Id withDesc:(NSString*)desc;

+ (NSString*) getSecureString:(NSString *)keystring;
+ (NSString*) getMacAddress;
+ (void) setActivityIndicator:(bool)isShow;
+ (double) lantitudeLongitudeToDist:(double)lon1 Latitude1:(double)lat1 long2:(double)lon2 Latitude2:(double)lat2;
+ (NSString*) sha1:(NSString*)input;

// 手机号码正则表达式
+ (BOOL)phoneNumberChecking:(NSString *)phone;

// 判断是否有非法字符正则表达式
+ (BOOL)illegalCharacterChecking:(NSString *)text;

// 错误提示
+ (void)MsgBox:(NSString *)title messege:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other delegate:(id)delegate;

// 判断定位功能是否开启
+ (BOOL)isLoctionOpen;

// 判断定位功能是否开启
+ (BOOL)isLoction;

// 创建缓存文件夹
+ (NSString *)pathInCacheDirectory:(NSString *)fileName;

// 会员中心赞，评论，预订，售后服务空状态的视图
+ (void)nullStatus:(UIImage *)images andText:(NSString *)value andShowView:(UIView *)view;

// 获取定位最近的分店ID
+ (NSString *)getShopNearID:(NSArray *)shopsArray andCurrentCoordate:(CLLocationCoordinate2D)cur;

// 注册后清空所有会员表数据
+ (void)clearAllDataBase;

// ios7适配兼容
+ (void)iosCompatibility:(UIViewController *)ctl;

/*
 *   满足于数组中字典按整数值排序
 *   arr    数组参数里面存放字典数组
 *   field  字典的字段，会根据此字段来读取数据
 *   sort   SortEnum为枚举类型  SortEnumAsc 升 SortEnumDesc 降
 */
+ (NSMutableArray *)sortInt:(NSMutableArray *)arr field:(NSString *)field sort:(SortEnum)sort;
+ (void)countObject:(NSString *)obj_id withType:(CountType)_type;

+ (BOOL)isLoctionAndEqual;
@end


