//
//  ShopObject.h
//  cw
//
//  Created by yunlai on 13-9-11.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ShopObject : NSObject

// 数据转化，瀑布流的大小图
+ (NSMutableArray *)listDataArrConversion:(NSMutableArray *)arr;

// 搜索表数据插入删除操作
+ (void)search_list_model:(NSString *)str;

// 得到最小的数字
+ (int)getArrMin:(NSMutableArray *)arr;

// 城市列表按距离排序
+ (NSMutableArray *)accordingToTheDistanceSorting:(NSMutableArray *)arr currentCoordate:(CLLocationCoordinate2D)cur;

// 模糊匹配城市
+ (NSMutableArray *)searchCity:(NSMutableDictionary *)adict key:(NSArray *)allKey city:(NSString *)city;

// 模糊匹配分店
+ (NSMutableArray *)searchShop:(NSArray *)adict key:(NSString *)Key words:(NSString *)words;

// 清除shop数据库
+ (void)cleanShopListDB;

@end
