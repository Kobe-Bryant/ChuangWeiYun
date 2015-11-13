//
//  CityDataObject.h
//  cw
//
//  Created by yunlai on 13-9-7.
//
//

#import <Foundation/Foundation.h>

@interface CityDataObject : NSObject

// 根据城市首字母排列数据
+ (NSMutableDictionary *)accordingFirstLetterGetCity;

// 返回所有的省份和所对应的ID
+ (NSMutableArray *)getProvinces;

// 根据省份ID获取城市和所对应的ID
+ (NSMutableArray *)getCitys:(NSString *)provinceId;

// 根据城市ID获取地区和所对应的ID
+ (NSMutableArray *)getAreas:(NSString *)cityId;

@end
