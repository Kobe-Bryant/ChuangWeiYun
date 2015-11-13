//
//  PreferentialObject.m
//  cw
//
//  Created by yunlai on 13-9-12.
//
//

#import "PreferentialObject.h"
#import "preactivity_list_pics_model.h"
#import "preactivity_list_partner_pics_model.h"
#import "favorable_list_pic_model.h"
#import "Common.h"

@implementation PreferentialObject

// 是否置顶排序
+ (NSMutableArray *)istopListOrdering:(NSMutableArray *)arr
{
    NSMutableArray *mutlArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *topArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *overArr = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < arr.count; i++) {
        
        NSDictionary *dict = [arr objectAtIndex:i];
        
        int start = [[dict objectForKey:@"start_date"] intValue];
        int end = [[dict objectForKey:@"end_date"] intValue];
        
        if ([[dict objectForKey:@"is_top"] intValue] == 1
            && [PreferentialObject isPastDueDate:start end:end]) {
            [topArr addObject:dict];
        } else {
            if (![PreferentialObject isPastDueDate:start end:end]) {
                [overArr addObject:dict];
            }
        }
    }
    
    [arr removeObjectsInArray:topArr];
    [arr removeObjectsInArray:overArr];
    
    NSMutableArray *tmpTopArr = [Common sortInt:topArr field:@"id" sort:SortEnumDesc];
    //NSMutableArray *tmpOverArr = [Common sortInt:overArr field:@"id" sort:SortEnumDesc];
    NSMutableArray *tmpArr = [Common sortInt:arr field:@"id" sort:SortEnumDesc];
    
    [mutlArr addObjectsFromArray:tmpTopArr];
    [mutlArr addObjectsFromArray:tmpArr];
    //[mutlArr addObjectsFromArray:tmpOverArr];
    
    return mutlArr;
}

// 将数据库中的图片数据添加到字典中
+ (NSMutableArray *)addPicToMutableArray:(NSMutableArray *)arr
{
    NSMutableArray *mutlArr = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < arr.count; i++) {
        
        NSMutableDictionary *dict = [arr objectAtIndex:i];
        NSString *strID = [dict objectForKey:@"id"];
        
        preactivity_list_pics_model *plpMod = [[preactivity_list_pics_model alloc]init];
        plpMod.where = [NSString stringWithFormat:@"preactivity_id = '%@'",strID];
        NSArray *plpArr = [plpMod getList];
        [plpMod release], plpMod = nil;

        if (plpArr.count > 0) {
            [dict setObject:plpArr forKey:@"pics"];
        }
        
        preactivity_list_partner_pics_model *plppMod = [[preactivity_list_partner_pics_model alloc]init];
        plppMod.where = [NSString stringWithFormat:@"preactivity_id = '%@'",strID];
        NSArray *plppArr = [plppMod getList];
        [plppMod release], plppMod = nil;

        if (plppArr.count > 0) {
            [dict setObject:plppArr forKey:@"partner_pics"];
        }

        [mutlArr addObject:dict];
    }
    
    return mutlArr;
}

// 将我的优惠券数据库中的图片数据添加到字典中
+ (NSMutableArray *)addPicToCouponsMutableArray:(NSMutableArray *)arr
{
    NSMutableArray *mutlArr = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < arr.count; i++) {
        
        NSMutableDictionary *dict = [arr objectAtIndex:i];
        NSString *strID = [dict objectForKey:@"promotion_id"];
        
        favorable_list_pic_model *flpMod = [[favorable_list_pic_model alloc]init];
        flpMod.where = [NSString stringWithFormat:@"promotion_id = '%@'",strID];
        NSArray *flpArr = [flpMod getList];
        [flpMod release], flpMod = nil;
        
        if (flpArr.count > 0) {
            [dict setObject:flpArr forKey:@"partner_pics"];
        }
        
        [mutlArr addObject:dict];
    }
    
    return mutlArr;
}

// 得到最后的天数，小时除外
+ (NSString *)getTheLastDays:(int)startDate end:(int)endDate
{
    // 解决时间差 8 小时问题
    NSDate *date = [NSDate date];
    NSDate *now_date = [PreferentialObject getdateDate:date];

    NSDate *start_date = [PreferentialObject getNSDate:startDate];

    NSDate *end_date = [PreferentialObject getNSDate:endDate];
    
    int secondsBetweenDates = 0;
    NSString *str = nil;
    
    if (NSOrderedAscending == [now_date compare:start_date]) {
        str = @"未开始";
    } else if (NSOrderedAscending == [now_date compare:end_date]) {
        secondsBetweenDates = [end_date timeIntervalSinceDate:now_date];
//        NSLog(@"secondsBetweenDates == %d",secondsBetweenDates);
        int num = secondsBetweenDates % (24*60*60) == 0 ? secondsBetweenDates/(24*60*60) : secondsBetweenDates/(24*60*60);
//        NSLog(@"num == %d",num);
        if (num < 3) {
            str = [NSString stringWithFormat:@"最后%d天",num+1];
        } else {
            str = @"正在进行";
        }
    } else {
        str = @"已结束";
    }

    return str;
}

/*  @rel  得到字符串格式的日期     getTheDate
 *  @date  int
 *  @symbol 有三种方式 type 0 1 2
 *  @type 0 为 例  2013/02/04
 *  @type 1 为 例  2013-02-04
 *  @type 2 为 例  2013年02月04日
 *  @type 3 为 例  yyyy-MM-dd hh:mm:ss
 */
+ (NSString *)getTheDate:(int)date symbol:(int)type
{
    NSDate *ndate = [NSDate dateWithTimeIntervalSince1970:date];

    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    if (type == 0) {
        [dateformatter setDateFormat:@"yyyy/MM/dd"];
    } else if (type == 1) {
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
    } else if (type == 2) {
        [dateformatter setDateFormat:@"yyyy年MM月dd日"];
    } else {
        [dateformatter setDateFormat:@"yyyy-MM-dd   hh:mm"];
    }
    
    NSString * dateStr = [dateformatter stringFromDate:ndate];
    
    [dateformatter release], dateformatter = nil;

    return dateStr;
}

/*  @rel  得到字符串格式的日期  getTypeDate
 *  @date  NSDate
 *  @symbol 有三种方式 type 0 1 2
 *  @type 0 为 例  2013/02/04
 *  @type 1 为 例  2013-02-04
 *  @type 2 为 例  2013年02月04日
 *  @type 3 为 例  yyyy-MM-dd hh:mm:ss
 */
+ (NSString *)getTypeDate:(NSDate *)date symbol:(int)type
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    if (type == 0) {
        [dateformatter setDateFormat:@"yyyy/MM/dd"];
    } else if (type == 1) {
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
    } else if (type == 2) {
        [dateformatter setDateFormat:@"yyyy年MM月dd日"];
    } else {
        [dateformatter setDateFormat:@"yyyy-MM-dd   hh:mm"];
    }
    
    NSString * dateStr = [dateformatter stringFromDate:date];
    
    [dateformatter release], dateformatter = nil;

    return dateStr;
}

// 得到nsdate
+ (NSDate *)getNSDate:(int)date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:date];
    NSInteger interval = [zone secondsFromGMTForDate:nowDate];
    NSDate *reDate = [nowDate dateByAddingTimeInterval:interval];
    
    return reDate;
}

// 得到nsdate,解决8小时
+ (NSDate *)getdateDate:(NSDate *)date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *reDate = [date dateByAddingTimeInterval:interval];

    return reDate;
}

// 查看时间是否过期
+ (BOOL)isPastDueDate:(int)startDate end:(int)endDate
{
    // 解决时间差 8 小时问题
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *now_date = [date dateByAddingTimeInterval:interval];

    NSDate *start_date = [PreferentialObject getNSDate:startDate];
    NSDate *end_date = [PreferentialObject getNSDate:endDate];
    
    BOOL state = NO;
    
    if (NSOrderedAscending == [now_date compare:start_date]) {
        state = NO;
    } else if (NSOrderedAscending == [now_date compare:end_date]) {
        state = YES;
    } else {
        state = NO;
    }
    
    return state;
}

// 

// 得到统计时间
+ (NSString *)getDateCount:(NSDate *)date
{
    //NSDate *now_date = [PreferentialObject getdateDate:date];
    
    NSString *dateStr = [NSString stringWithFormat:@"%d",(int)[date timeIntervalSince1970]];
    
    return dateStr;
}

@end
