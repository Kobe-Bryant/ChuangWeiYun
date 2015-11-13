//
//  ShopObject.m
//  cw
//
//  Created by yunlai on 13-9-11.
//
//

#import "ShopObject.h"
#import "search_list_model.h"
#import "shop_list_model.h"
#import "shop_list_pics_model.h"
#import "cat_version_model.h"
#import "Common.h"
#import "Global.h"

@implementation ShopObject

// 数据转化，瀑布流的大小图
+ (NSMutableArray *)listDataArrConversion:(NSMutableArray *)arr
{
    NSMutableArray *mutlArr = [NSMutableArray arrayWithCapacity:0];

    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    int stackRow = 0;
    int count = arr.count;
    if (count > 0) {
        for (int i = 0; i < count; i++) {
            NSMutableDictionary *dict = [arr objectAtIndex:i];

            if ([[dict objectForKey:@"big_show"] intValue] == 1) {
                //大图
                NSMutableArray *bigArray = [[NSMutableArray alloc]init];
                [bigArray addObject:[dict objectForKey:@"big_show"]];               //大图还是小图
                [bigArray addObject:[NSString stringWithFormat:@"%d",i]];           //原始数据行号
                [bigArray addObject:dict];
                [mutlArr addObject:bigArray];
                [bigArray release], bigArray = nil;
            } else {
                //小图
                if ([tempDict count] > 0) {
                    NSMutableArray *smallArray = [[NSMutableArray alloc]init];
                    [smallArray addObject:[dict objectForKey:@"big_show"]];             //大图还是小图
                    [smallArray addObject:[NSString stringWithFormat:@"%d",stackRow]];  //1原始数据行号
                    [smallArray addObject:tempDict];
                    [smallArray addObject:[NSString stringWithFormat:@"%d",i]];         //2原始数据行号
                    [smallArray addObject:dict];
                    [mutlArr addObject:smallArray];
                    [smallArray release], smallArray = nil;
                    tempDict = nil;
                } else {
                    tempDict = dict;
                    stackRow = i;
                }
            }
        }
        //如果最后多出一张小图 也需要显示
        if ([tempDict count] > 0)
        {
            NSMutableArray *smallArray = [[NSMutableArray alloc]init];
            [smallArray addObject:@"0"];                                                //大图还是小图
            [smallArray addObject:[NSString stringWithFormat:@"%d",stackRow]];          //1原始数据行号
            [smallArray addObject:tempDict];
            [mutlArr addObject:smallArray];
            [smallArray release], smallArray = nil;
        }
    }
    
    tempDict = nil; // [tempDict release], 
    
//    NSLog(@"mutlArr = %@",mutlArr);
    
    return mutlArr;
}

// 搜索表数据插入删除操作
+ (void)search_list_model:(NSString *)str
{
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"content = '%@'",str];
    NSArray *arr = [slMod getList];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str,@"content",@"shop",@"type", nil];
    if ([arr count] > 0) {
        [slMod updateDB:dict];
    } else {
        [slMod insertDB:dict];
    }
    // 保证数据只有5条
    slMod.where = @"type = 'shop'";
    slMod.orderBy = @"id";
    slMod.orderType = @"desc";
    NSMutableArray *slItems = [slMod getList];
    for (int i = [slItems count] - 1; i > 4; i--) {
        NSDictionary *slDic = [slItems objectAtIndex:i];
        NSString *slStr = [slDic objectForKey:@"id"];
        
        slMod.where = [NSString stringWithFormat:@"id = %@",slStr];
        [slMod deleteDBdata];
    }
    [slMod release];
}

// 得到最小的shu zi
+ (int)getArrMin:(NSMutableArray *)arr
{
    int getMin = 1000000;
    if (arr > 0) {
        for (NSDictionary *dict in arr) {
            int min = [[dict objectForKey:@"position"] intValue];
            if (getMin > min) {
                getMin = min;
            }
        }
    }
    return getMin;
}

// 城市列表按距离排序
+ (NSMutableArray *)accordingToTheDistanceSorting:(NSMutableArray *)arr currentCoordate:(CLLocationCoordinate2D)cur
{
    NSComparator cmptr = ^(id obj1, id obj2){
        double lon1 = [[obj1 objectForKey:@"longitude"]doubleValue];
        double lat1 = [[obj1 objectForKey:@"latitude"]doubleValue];
        double distanct1 = [Common lantitudeLongitudeToDist:cur.longitude Latitude1:cur.latitude long2:lon1 Latitude2:lat1];

        double lon2 = [[obj2 objectForKey:@"longitude"]doubleValue];
        double lat2 = [[obj2 objectForKey:@"latitude"]doubleValue];
        double distanct2 = [Common lantitudeLongitudeToDist:cur.longitude Latitude1:cur.latitude long2:lon2 Latitude2:lat2];
        
        if (distanct1 > distanct2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (distanct1 < distanct2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    if (arr.count == 0) {
        return nil;
    }
    NSMutableArray *mutlArr = [NSMutableArray arrayWithArray:[arr sortedArrayUsingComparator:cmptr]];
    NSMutableArray *addArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *dict in mutlArr) {
        double lon1 = [[dict objectForKey:@"longitude"]doubleValue];
        double lat1 = [[dict objectForKey:@"latitude"]doubleValue];
        
        if (lon1 == 0.000000 && lat1 == 0.000000) {
            [addArr addObject:dict];
        }
    }
    
    [mutlArr removeObjectsInArray:addArr];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    [array addObjectsFromArray:mutlArr];
    [array addObjectsFromArray:addArr];
    
    return array;
}

// 模糊匹配城市
+ (NSMutableArray *)searchCity:(NSMutableDictionary *)adict key:(NSArray *)allKey city:(NSString *)city
{
    if (city.length == 0) {
        return nil;
    }
    
    NSArray *arr = [NSArray arrayWithObjects:@"北京市",@"天津市",@"上海市",@"重庆市", nil];
    NSMutableArray *citys = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < arr.count; i++) {
        NSString *keyCity = [arr objectAtIndex:i];
        if ([keyCity rangeOfString:city].location != NSNotFound) {
            [citys addObject:keyCity];
        }
    }
    
    for (int i = 0; i < allKey.count; i++) {
        NSArray *arr = [adict objectForKey:[allKey objectAtIndex:i]];
        for (int j= 0; j < arr.count; j++) {
            NSString *keyCity = [arr objectAtIndex:j];
            if ([keyCity rangeOfString:city].location != NSNotFound) {
                [citys addObject:keyCity];
            }
        }
    }
    
    return citys;
}

// 模糊匹配分店
+ (NSMutableArray *)searchShop:(NSArray *)adict key:(NSString *)Key words:(NSString *)words
{
    if (words.length == 0) {
        return nil;
    }

    NSMutableArray *shops = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *dict in adict) {
        NSString *keyShop = [dict objectForKey:Key];
        if ([keyShop rangeOfString:words].location != NSNotFound) {
            [shops addObject:dict];
        }
    }
    
    return shops;
}

// 清除shop数据库
+ (void)cleanShopListDB
{
    shop_list_model *slMod = [[shop_list_model alloc] init];
    [slMod deleteDBdata];
    [slMod release], slMod = nil;
    
    shop_list_pics_model *slpMod = [[shop_list_pics_model alloc] init];
    [slpMod deleteDBdata];
    [slpMod release], slpMod = nil;
    
    cat_version_model *cvMod = [[cat_version_model alloc] init];
    [cvMod deleteDBdata];
    [cvMod release], cvMod = nil;
}

@end
