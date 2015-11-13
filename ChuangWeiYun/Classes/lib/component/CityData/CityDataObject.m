//
//  CityDataObject.m
//  cw
//
//  Created by yunlai on 13-9-7.
//
//

#import "CityDataObject.h"
#import "PYMethod.h"
#import "dqxx_model.h"
#import "addressChoice_list_model.h"

@implementation CityDataObject

// 根据城市首字母排列数据
+ (NSMutableDictionary *)accordingFirstLetterGetCity
{
    dqxx_model *dMod = [[dqxx_model alloc]init];
    dMod.where = @"DQXX03 = '2'";
    NSArray *dModArr = [dMod getList];
    
    dMod.where = @"DQXX03 = '1'";
    NSArray *aModArr = [dMod getList];

    NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (dModArr.count > 0) {
        
        NSMutableArray *dqxxArr = [NSMutableArray arrayWithCapacity:0];
        
        if (aModArr.count > 0) {
            for (int i = 0; i < aModArr.count; i++) {
                int dqxxid = [[[aModArr objectAtIndex:i] objectForKey:@"DQX_DQXX01"] intValue];
                //NSLog(@"dqxxid = %d",dqxxid);
                dMod.where = [NSString stringWithFormat:@"DQX_DQXX01 = '%d90'",dqxxid];
                NSMutableArray *sModArr = [dMod getList];
                
                if (sModArr > 0) {
                    [dqxxArr addObjectsFromArray:sModArr];
                }
            }
        }
        
        NSMutableArray *cityArr = [NSMutableArray arrayWithCapacity:0];
        
        for (int i = 0; i < dModArr.count; i++) {
            NSDictionary *dict = [dModArr objectAtIndex:i];
            [cityArr addObject:[dict objectForKey:@"DQXX02"]];
        }
        //NSLog(@"dqxxArr = %@",dqxxArr);
        for (int i = 0; i < dqxxArr.count; i++) {
            NSDictionary *dict = [dqxxArr objectAtIndex:i];
            [cityArr addObject:[dict objectForKey:@"DQXX02"]];
        }

        for (int j = 0; j < cityArr.count; j++) {

            NSString *key = [PYMethod getPinYin:[[cityArr objectAtIndex:j] substringWithRange:NSMakeRange(0,1)]];
            
            if ([[mutDict allKeys] containsObject:key]) {
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                NSMutableArray *tmpArr = [mutDict objectForKey:key];
                [arr addObjectsFromArray:tmpArr];
                [arr addObject:[cityArr objectAtIndex:j]];
                [mutDict setObject:arr forKey:key];
            } else {
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                [arr addObject:[cityArr objectAtIndex:j]];
                [mutDict setObject:arr forKey:key];
            }
        }
    }
    
    [dMod release];
    
    return mutDict;
}

// 返回所有的省份和所对应的ID
+ (NSMutableArray *)getProvinces
{
    NSMutableArray *provincedict = [NSMutableArray arrayWithCapacity:0];
    
    addressChoice_list_model *alMod = [[addressChoice_list_model alloc]init];
    alMod.where = @"level = 1";
    NSMutableArray *alModArr = [alMod getList];
    [alMod release];
    
    NSMutableArray *tmpprovincedict = [NSMutableArray arrayWithCapacity:0];
    
    if (alModArr.count > 0) {
        for (int i = 0; i < alModArr.count; i++) {
            NSDictionary *dict = [alModArr objectAtIndex:i];
            NSString *pstr = [dict objectForKey:@"province"];
            [tmpprovincedict addObject:pstr];
        }
    }
    
    dqxx_model *dMod = [[dqxx_model alloc]init];
    dMod.where = @"DQXX03 = '1'";
    NSMutableArray *dModArr = [dMod getList];
    [dMod release];
    
    if (dModArr.count > 0) {
        for (int i = 0; i < dModArr.count; i++) {
            NSDictionary *dict = [dModArr objectAtIndex:i];
            NSString *pstr = [dict objectForKey:@"DQXX02"];
            [provincedict addObject:pstr];
        }
    }
    
    for (int i = 0; i < tmpprovincedict.count; i++) {
        NSString *tmp = [tmpprovincedict objectAtIndex:i];
        if ([provincedict indexOfObject:tmp] != NSNotFound) {
            int index = [provincedict indexOfObject:tmp];
            [provincedict exchangeObjectAtIndex:i withObjectAtIndex:index];
        }
    }

    return provincedict;
}

// 根据省份ID获取城市和所对应的ID
+ (NSMutableArray *)getCitys:(NSString *)province
{
    NSLog(@"province = %@",province);
    NSMutableArray *citydict = [NSMutableArray arrayWithCapacity:0];
    
    addressChoice_list_model *alMod = [[addressChoice_list_model alloc]init];
    alMod.where = [NSString stringWithFormat:@"level = 2 and province = '%@'",province];
    NSMutableArray *alModArr = [alMod getList];
    [alMod release];
    
    NSMutableArray *tmpcitydict = [NSMutableArray arrayWithCapacity:0];
    
    if (alModArr.count > 0) {
        for (int i = 0; i < alModArr.count; i++) {
            NSDictionary *dict = [alModArr objectAtIndex:i];
            NSString *pstr = [dict objectForKey:@"city"];
            [tmpcitydict addObject:pstr];
        }
    }
    
    dqxx_model *dMod = [[dqxx_model alloc]init];
    dMod.where = [NSString stringWithFormat:@"DQXX03 = '1' and DQXX02 = '%@'",province];
    NSMutableArray *dModArr = [dMod getList];
    
    int dqxxid = [[[dModArr lastObject] objectForKey:@"DQX_DQXX01"] intValue];
    
    dMod.where = [NSString stringWithFormat:@"DQX_DQXX01 = '%d'",dqxxid];
    NSMutableArray *cModArr = [dMod getList];
    
    dMod.where = [NSString stringWithFormat:@"DQX_DQXX01 = '%d90'",dqxxid];
    NSMutableArray *sModArr = [dMod getList];
    [dMod release];
    
    //NSMutableArray *csModArr = [NSMutableArray arrayWithArray:cModArr];
    [cModArr addObjectsFromArray:sModArr];
    if (cModArr.count > 0) {
        for (int i = 0; i < cModArr.count; i++) {
            NSDictionary *dict = [cModArr objectAtIndex:i];
            NSString *pstr = [dict objectForKey:@"DQXX02"];
            if ([[dict objectForKey:@"DQX_DQXX01"] intValue] != [[dict objectForKey:@"DQXX01"] intValue]) {
                [citydict addObject:pstr];
            }
        }
    }
    
    for (int i = 0; i < tmpcitydict.count; i++) {
        NSString *tmp = [tmpcitydict objectAtIndex:i];
        if ([citydict indexOfObject:tmp] != NSNotFound) {
            int index = [citydict indexOfObject:tmp];
            [citydict exchangeObjectAtIndex:i withObjectAtIndex:index];
        }
    }

    return citydict;
}

// 根据城市ID获取地区和所对应的ID
+ (NSMutableArray *)getAreas:(NSString *)city
{
    NSLog(@"city = %@",city);
    NSMutableArray *areadict = [NSMutableArray arrayWithCapacity:0];
    
    addressChoice_list_model *alMod = [[addressChoice_list_model alloc]init];
    alMod.where = [NSString stringWithFormat:@"level = 3 and city = '%@'",city];
    NSMutableArray *alModArr = [alMod getList];
    [alMod release];
    
    NSMutableArray *tmpareadict = [NSMutableArray arrayWithCapacity:0];
    
    if (alModArr.count > 0) {
        for (int i = 0; i < alModArr.count; i++) {
            NSDictionary *dict = [alModArr objectAtIndex:i];
            NSString *pstr = [dict objectForKey:@"city"];
            [tmpareadict addObject:pstr];
        }
    }
    
    dqxx_model *dMod = [[dqxx_model alloc]init];
    dMod.where = [NSString stringWithFormat:@"DQXX03 = '2' and DQXX02 = '%@'",city];
    NSMutableArray *dModArr = [dMod getList];

    dMod.where = [NSString stringWithFormat:@"DQX_DQXX01 = '%d'",
                  [[[dModArr lastObject] objectForKey:@"DQXX01"] intValue]];
    NSMutableArray *cModArr = [dMod getList];
    
    [dMod release];

    if (cModArr.count > 0) {
        for (int i = 0; i < cModArr.count; i++) {
            NSDictionary *dict = [cModArr objectAtIndex:i];
            NSString *pstr = [dict objectForKey:@"DQXX02"];
            [areadict addObject:pstr];
        }
    }
    
    for (int i = 0; i < tmpareadict.count; i++) {
        NSString *tmp = [tmpareadict objectAtIndex:i];
        if ([areadict indexOfObject:tmp] != NSNotFound) {
            int index = [areadict indexOfObject:tmp];
            [areadict exchangeObjectAtIndex:i withObjectAtIndex:index];
        }
    }

    return areadict;
}

@end
