//
//  PreferentialObject.h
//  cw
//
//  Created by yunlai on 13-9-12.
//
//

#import <Foundation/Foundation.h>

@interface PreferentialObject : NSObject

// 是否置顶排序
+ (NSMutableArray *)istopListOrdering:(NSMutableArray *)arr;

// 将数据库中的图片数据添加到字典中
+ (NSMutableArray *)addPicToMutableArray:(NSMutableArray *)arr;

// 将我的优惠券数据库中的图片数据添加到字典中
+ (NSMutableArray *)addPicToCouponsMutableArray:(NSMutableArray *)arr;

// 得到最后的天数，小时除外
+ (NSString *)getTheLastDays:(int)startDate end:(int)endDate;

/*  @rel  得到字符串格式的日期     getTheDate
 *  @date  int
 *  @symbol 有三种方式 type 0 1 2
 *  @type 0 为 例  2013/02/04
 *  @type 1 为 例  2013-02-04
 *  @type 2 为 例  2013年02月04日
 *  @type 3 为 例  yyyy-MM-dd hh:mm:ss
 */
+ (NSString *)getTheDate:(int)date symbol:(int)type;

/*  @rel  得到字符串格式的日期     getTypeDate
 *  @date  NSDate
 *  @symbol 有三种方式 type 0 1 2
 *  @type 0 为 例  2013/02/04
 *  @type 1 为 例  2013-02-04
 *  @type 2 为 例  2013年02月04日
 *  @type 3 为 例  yyyy-MM-dd hh:mm:ss
 */
+ (NSString *)getTypeDate:(NSDate *)date symbol:(int)type;

// 得到nsdate,解决8小时
+ (NSDate *)getdateDate:(NSDate *)date;

// 查看时间是否过期
+ (BOOL)isPastDueDate:(int)startDate end:(int)endDate;

// 得到统计时间戳
+ (NSString *)getDateCount:(NSDate *)date;

@end
