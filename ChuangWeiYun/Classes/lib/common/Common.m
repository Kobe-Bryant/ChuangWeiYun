//
//  Common.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Common.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "SBJson.h"
#import "base64.h"
#import "Encry.h"
#import <CommonCrypto/CommonCryptor.h> 
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>  
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>
#import "version_model.h"
#import "cat_version_model.h"
#import "shop_near_list_model.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import "BMKMultiPoint.h"
#import "BMKOverlay.h"
#import "Global.h"
#import "member_after_service_model.h"
#import "member_allorder_list_model.h"
#import "member_allorder_listPic_model.h"
#import "member_likeinformation_model.h"
#import "member_likeshop_model.h"
#import "member_msgcomment_model.h"
#import "member_msgcommentPic_model.h"
#import "member_msglikePic_model.h"
#import "member_msglikes_model.h"
#import "member_orderdetail_list_model.h"
#import "member_shopcomment_model.h"
#import "member_shopcommentPic_model.h"
#import "member_shoplikePic_model.h"
#import "member_shoplikes_model.h"
#import "afterservice_detail_model.h"
#import "address_list_model.h"
#import "favorable_list_model.h"
#import "favorable_list_pic_model.h"
#import "address_list_model.h"
#import "preactivity_list_model.h"

#import "shop_log_model.h"
#import "product_log_model.h"
#import "news_log_model.h"
#import "preactivity_log_model.h"
#import "dqxx_model.h"

@implementation Common

+ (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (NSString*)TransformJson:(NSMutableDictionary*)sourceDic withLinkStr:(NSString*)strurl
{
	SBJsonWriter *writer = [[SBJsonWriter alloc]init];
	NSString *jsonConvertedObj = [writer stringWithObject:sourceDic];
	//NSLog(@"jsonConvertedObj:%@",jsonConvertedObj);
    [writer release];
	NSString *b64 = [Common encodeBase64:(NSMutableData *)[jsonConvertedObj dataUsingEncoding: NSUTF8StringEncoding]];
	NSString *urlEncode = [Common URLEncodedString:b64];
	NSString *reqStr = [NSString stringWithFormat:@"%@%@",strurl,urlEncode];
	//NSLog(@"req_string:%@",reqStr);
	return reqStr;
}

+ (NSString*)encodeBase64:(NSMutableData*)data
{
	size_t outputDataSize = EstimateBas64EncodedDataSize([data length]);
	Byte outputData[outputDataSize];
	Base64EncodeData([data bytes], [data length], outputData,&outputDataSize, YES);
	NSData *theData = [[NSData alloc]initWithBytes:outputData length:outputDataSize];//create a NSData object from the decoded data
	NSString *stringValue1 = [[NSString alloc]initWithData:theData encoding:NSUTF8StringEncoding];
	//NSLog(@"reqdata string base64 %@",stringValue1);
	[theData release];
	return [stringValue1 autorelease];
}

+ (NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString*)URLEncodedString:(NSString*)input
{  
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  
                                                                           (CFStringRef)input,  
                                                                           NULL,  
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),  
                                                                           kCFStringEncodingUTF8);  
    [result autorelease];  
    return result;  
}

+ (NSString*)URLDecodedString:(NSString*)input  
{  
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,  
                                                                                           (CFStringRef)input,  
                                                                                           CFSTR(""),  
                                                                                           kCFStringEncodingUTF8);  
    [result autorelease];  
    return result;    
}  

+ (double)lantitudeLongitudeToDist:(double)lon1 Latitude1:(double)lat1 long2:(double)lon2 Latitude2:(double)lat2
{
	double er = 6378137; // 6378700.0f;

	double radlat1 = PI*lat1 / 180.0f;
	double radlat2 = PI*lat2 / 180.0f;

	double radlong1 = PI*lon1 / 180.0f;
	double radlong2 = PI*lon2 / 180.0f;
    
	if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    
	if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    
	if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    
	if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    
	if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    
	if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west

	double x1 = er * cos(radlong1) * sin(radlat1);
	double y1 = er * sin(radlong1) * sin(radlat1);
	double z1 = er * cos(radlat1);
	double x2 = er * cos(radlong2) * sin(radlat2);
	double y2 = er * sin(radlong2) * sin(radlat2);
	double z2 = er * cos(radlat2);
    
	double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    
	//side, side, side, law of cosines and arccos
	double theta = acos((er*er+er*er-d*d)/(2*er*er));
	double dist  = theta*er;
    
	return dist;
}

+ (NSNumber*)getVersion:(int)commandId
{
    version_model *versionMod = [[version_model alloc] init];
    versionMod.where = [NSString stringWithFormat:@"command_id = %d",commandId];
    NSMutableArray *versionArray = [versionMod getList];
    [versionMod release];

    if ([versionArray count] > 0)
    {
        NSDictionary *versionDic = [versionArray objectAtIndex:0];
        return [NSNumber numberWithInt:[[versionDic objectForKey:@"ver"] intValue]];
    }

    return [NSNumber numberWithInt:0];
}

+ (NSNumber*)getVersion:(int)commandId desc:(NSString *)desc
{
    version_model *versionMod = [[version_model alloc] init];
    versionMod.where = [NSString stringWithFormat:@"command_id = %d and desc = '%@'",commandId,desc];
    NSMutableArray *versionArray = [versionMod getList];
    [versionMod release];

    if ([versionArray count] > 0)
    {
        NSDictionary *versionDic = [versionArray objectAtIndex:0];
        return [NSNumber numberWithInt:[[versionDic objectForKey:@"ver"] intValue]];
    }
    
    return [NSNumber numberWithInt:0];
}

+ (BOOL)updateVersion:(int)commandId withVersion:(int)version withDesc:(NSString*)desc
{
    version_model *versionMod = [[version_model alloc] init];
    
    //不存在 则插入 存在则更新
    versionMod.where = [NSString stringWithFormat:@"command_id = %d",commandId];
    NSMutableArray *versionArray = [versionMod getList];
    
    
    NSDictionary *versionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:commandId],@"command_id",
                                    [NSNumber numberWithInt:version],@"ver",
                                    desc,@"desc",
                                    nil];
    
    if ([versionArray count] > 0) {
        [versionMod updateDB:versionDic];
    } else {
        [versionMod insertDB:versionDic];
    }
    
    [versionMod release];
    return YES;
}

+ (NSNumber*)getCatVersion:(int)commandId withId:(int)cat_Id
{
    cat_version_model *versionMod = [[cat_version_model alloc] init];
    versionMod.where = [NSString stringWithFormat:@"command_id = %d and catId = %d",commandId,cat_Id];
    NSMutableArray *versionArray = [versionMod getList];
    [versionMod release];
    
    if ([versionArray count] > 0)
    {
        NSDictionary *versionDic = [versionArray objectAtIndex:0];
        return [NSNumber numberWithInt:[[versionDic objectForKey:@"ver"] intValue]];
    }
    
    return [NSNumber numberWithInt:0];
}

+ (BOOL)updateCatVersion:(int)commandId withVersion:(int)version withId:(int)cat_Id withDesc:(NSString*)desc
{
    cat_version_model *versionMod = [[cat_version_model alloc] init];
    
    //不存在 则插入 存在则更新
    versionMod.where = [NSString stringWithFormat:@"catId = %d",cat_Id];
    NSMutableArray *versionArray = [versionMod getList];
    
    
    NSDictionary *versionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:commandId],@"command_id",
                                [NSNumber numberWithInt:version],@"ver",
                                [NSNumber numberWithInt:cat_Id],@"catId",
                                desc,@"desc",
                                nil];
    
    if ([versionArray count] > 0)
    {
        [versionMod updateDB:versionDic];
    }
    else
    {
        [versionMod insertDB:versionDic];
    }
    
    [versionMod release];
    return YES;
}

+ (NSString*)getSecureString:(NSString *)keystring
{
	NSString *securekey = [Encry md5:keystring];
	return securekey;
}

#define	CTL_NET		4		/* network, see socket.h */
+ (NSString*)getMacAddress
{
	int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    //NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}
    
/* ========================================系统相关函数=============================================== */

+ (void)setActivityIndicator:(bool)isShow
{
	UIApplication *app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = isShow;
}

// 手机号码正则表达式
+ (BOOL)phoneNumberChecking:(NSString *)phone
{
//    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSString *regex = @"^(1)\\d{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:phone];
}

// 判断是否有非法字符正则表达式
+ (BOOL)illegalCharacterChecking:(NSString *)text
{
    NSString *regex = @"^([a-zA-Z0-9\u4E00-\u9FA5]{0,20})";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:text];
}

// 错误提示
+ (void)MsgBox:(NSString *)title messege:(NSString *)message cancel:(NSString *)cancel other:(NSString *)other delegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:delegate
                                         cancelButtonTitle:cancel
                                         otherButtonTitles:other,nil];
    [alert show];
    [alert release];
}

// 判断总定位功能是否开启
+ (BOOL)isLoctionOpen
{
//    if (IOS_VERSION<8.0) {
    if ([CLLocationManager locationServicesEnabled]) {
        return YES;
    } else {
        return NO;
    }
//    }else{
//        BOOL enable=[CLLocationManager locationServicesEnabled];
//        //是否具有定位权限
//        int status=[CLLocationManager authorizationStatus];
//        NSLog(@"status %d",status);
//        if(!enable || status<3){
//            //请求权限
//            [[Global sharedGlobal].locManager requestWhenInUseAuthorization];
//        }
//    }
//
//    return YES;

//    _instance.locationManager = [[CLLocationManager alloc] init];//创建位置管理器
//    _instance.locationManager.delegate=_instance;
//    _instance.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
//    _instance.locationManager.distanceFilter=100.0f;
//    _instance.updating=NO;
//    //定位服务是否可用
//    BOOL enable=[CLLocationManager locationServicesEnabled];
//    //是否具有定位权限
//    int status=[CLLocationManager authorizationStatus];
//    if(!enable || status<3){
//        //请求权限
//        [_instance.locationManager requestWhenInUseAuthorization];
//    }
}

// 判断定位功能是否开启
+ (BOOL)isLoction
{
    return [Global sharedGlobal].isLoction;
}

+ (NSString *)pathInCacheDirectory:(NSString *)fileName {
    //获取沙盒中缓存文件目录
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    //将传入的文件名加在目录路径后面并返回
    return [cacheDirectory stringByAppendingPathComponent:fileName];
}

// 会员赞，评论，预订列表空状态视图
+ (void)nullStatus:(UIImage *)images andText:(NSString *)value andShowView:(UIView *)views
{
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 155, 80, 80)];
    imgView.image=images;
    [views addSubview:imgView];
    [imgView release];
    
    UILabel *reminderText=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 30)];
    reminderText.center=views.center;
    reminderText.font=[UIFont systemFontOfSize:15];
    reminderText.backgroundColor=[UIColor clearColor];
    reminderText.textColor=[UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
    reminderText.text=value;
    reminderText.textAlignment=NSTextAlignmentCenter;
    [views addSubview:reminderText];
    [reminderText release], reminderText = nil;
}

// 获取定位最近的分店ID
+ (NSString *)getShopNearID:(NSArray *)shopsArray andCurrentCoordate:(CLLocationCoordinate2D)cur
{
    double preDistanceFromMyLocation = 100000000.f;
    
    NSString *shopId = nil;
    
    for (int j = 0; j < [shopsArray count]; j++) {
        
        NSDictionary *dicay = [shopsArray objectAtIndex:j];
        
        if ([dicay objectForKey:@"longitude"] && [dicay objectForKey:@"latitude"]) {
            double lon = [[dicay objectForKey:@"longitude"]doubleValue];
            double lat = [[dicay objectForKey:@"latitude"]doubleValue];
            
            double currentDistanctFromMyLocation = [Common lantitudeLongitudeToDist:cur.longitude Latitude1:cur.latitude long2:lon Latitude2:lat];
//            NSLog(@"currentDistanctFromMyLocation = %f",currentDistanctFromMyLocation);
//            NSLog(@"currentDistanctFromMyLocation = %@",[dicay objectForKey:@"name"]);
            
            if (currentDistanctFromMyLocation < preDistanceFromMyLocation) {
                
                preDistanceFromMyLocation = currentDistanctFromMyLocation;
                
                shopId = [NSString stringWithFormat:@"%d",[[dicay objectForKey:@"id"] intValue]];
            }
        }
    }
    
    return shopId;
}

// 注册后清空所有之前会员表数据
+ (void)clearAllDataBase{
    member_after_service_model * afterMod=[[member_after_service_model alloc]init];
    [afterMod deleteDBdata];
    RELEASE_SAFE(afterMod);
    
    member_allorder_list_model *allorderMod=[[member_allorder_list_model alloc]init];
    [allorderMod deleteDBdata];
    RELEASE_SAFE(allorderMod);
    
    
    member_allorder_listPic_model *allOrderPicMod=[[member_allorder_listPic_model alloc]init];
    [allOrderPicMod deleteDBdata];
    RELEASE_SAFE(allOrderPicMod);
    
    
    member_likeinformation_model *likeInfoMod=[[member_likeinformation_model alloc]init];
    [likeInfoMod deleteDBdata];
    RELEASE_SAFE(likeInfoMod);
    
    member_likeshop_model *likeShopMod=[[member_likeshop_model alloc]init];
    [likeShopMod deleteDBdata];
    RELEASE_SAFE(likeShopMod);
    
    
    member_msgcomment_model *msgComMod=[[member_msgcomment_model alloc]init];
    [msgComMod deleteDBdata];
    RELEASE_SAFE(msgComMod);
    
    member_msgcommentPic_model *msgComPic=[[member_msgcommentPic_model alloc]init];
    [msgComPic deleteDBdata];
    RELEASE_SAFE(msgComPic);
    
    member_msglikePic_model *msglikcPic=[[member_msglikePic_model alloc]init];
    [msglikcPic deleteDBdata];
    RELEASE_SAFE(msglikcPic);
    
    member_msglikes_model *msglikeMod=[[member_msglikes_model alloc]init];
    [msglikeMod deleteDBdata];
    RELEASE_SAFE(msglikeMod);
    
    member_orderdetail_list_model *orderDetail=[[member_orderdetail_list_model alloc]init];
    [orderDetail deleteDBdata];
    RELEASE_SAFE(orderDetail);
    
    member_shopcomment_model *shopCom=[[member_shopcomment_model alloc]init];
    [shopCom deleteDBdata];
    RELEASE_SAFE(shopCom);
    
    member_shopcommentPic_model *shopComPic=[[member_shopcommentPic_model alloc]init];
    [shopComPic deleteDBdata];
    RELEASE_SAFE(shopComPic);
    
    member_shoplikePic_model *shopPic=[[member_shoplikePic_model alloc]init];
    [shopPic deleteDBdata];
    RELEASE_SAFE(shopPic);
    
    member_shoplikes_model *shoplikes=[[member_shoplikes_model alloc]init];
    [shoplikes deleteDBdata];
    RELEASE_SAFE(shoplikes);
    
    afterservice_detail_model *afterDetail=[[afterservice_detail_model alloc]init];
    [afterDetail deleteDBdata];
    RELEASE_SAFE(afterDetail);
    
    address_list_model *addresslist=[[address_list_model alloc]init];
    [addresslist deleteDBdata];
    RELEASE_SAFE(addresslist);
    
    favorable_list_model *favorable=[[favorable_list_model alloc]init];
    [favorable deleteDBdata];
    RELEASE_SAFE(favorable);
    
    favorable_list_pic_model *favorablePic=[[favorable_list_pic_model alloc]init];
    [favorablePic deleteDBdata];
    RELEASE_SAFE(favorablePic);
    
    address_list_model *addressl=[[address_list_model alloc]init];
    [addressl deleteDBdata];
    RELEASE_SAFE(addressl);
    
    preactivity_list_model *preactivity=[[preactivity_list_model alloc]init];
    [preactivity deleteDBdata];
    RELEASE_SAFE(preactivity);
    
}

/**
 * ios7适配兼容
 *
 *  @param ctl 视图控制器
 */
+ (void)iosCompatibility:(UIViewController *)ctl{
    if (IOS_7) {
        ctl.edgesForExtendedLayout = UIRectEdgeNone; ////视图控制器，四条边不指定
        ctl.extendedLayoutIncludesOpaqueBars = NO; //不透明的操作栏
        ctl.modalPresentationCapturesStatusBarAppearance = NO;
        ctl.navigationController.navigationBar.translucent = NO;
        ctl.tabBarController.tabBar.translucent = NO;
        ctl.automaticallyAdjustsScrollViewInsets = YES;
    }
}


/*
 *   满足于数组中字典按整数值排序
 *   arr    数组参数里面存放字典数组
 *   field  字典的字段，会根据此字段来读取数据
 *   sort   SortEnum为枚举类型  SortEnumAsc 升 SortEnumDesc 降
 */
+ (NSMutableArray *)sortInt:(NSMutableArray *)arr field:(NSString *)field sort:(SortEnum)sort
{
    NSComparator cmptr = ^(id obj1, id obj2){
        int value1 = [[obj1 objectForKey:field] intValue];
        int value2 = [[obj2 objectForKey:field] intValue];
        
        if (sort == SortEnumAsc) {
            if (value1 > value2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (value1 < value2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        } else {
            if (value1 < value2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (value1 > value2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }
    };
    
    if (arr.count == 0) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[arr sortedArrayUsingComparator:cmptr]];
    
    return array;
}

+ (void)countObject:(NSString *)obj_id withType:(CountType)_type
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        int _id = [obj_id intValue];
        if(_type == CountTypeProduct){
            product_log_model *plMod = [[product_log_model alloc]init];
            plMod.where = [NSString stringWithFormat:@"id = '%d'",_id];
            NSMutableArray *arr = [plMod getList];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:_id],@"id",
                                         [NSNumber numberWithInt:1],@"share_sum",nil];
            if (arr.count > 0) {
                NSDictionary *dict = [arr lastObject];
                
                int share = [[dict objectForKey:@"share_sum"] intValue];
                [data setObject:[NSNumber numberWithInt:++share] forKey:@"share_sum"];
                
                [plMod updateDB:data];
            } else {
                [plMod insertDB:data];
            }
            
            [plMod release], plMod = nil;
        }else if (_type == CountTypeNew){
            news_log_model *plMod = [[news_log_model alloc]init];
            plMod.where = [NSString stringWithFormat:@"id = '%d'",_id];
            NSMutableArray *arr = [plMod getList];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:_id],@"id",
                                         [NSNumber numberWithInt:1],@"share_sum",nil];
            if (arr.count > 0) {
                NSDictionary *dict = [arr lastObject];
                
                int share = [[dict objectForKey:@"share_sum"] intValue];
                [data setObject:[NSNumber numberWithInt:++share] forKey:@"share_sum"];
                
                [plMod updateDB:data];
            } else {
                [plMod insertDB:data];
            }
            
            [plMod release], plMod = nil;
        }else if (_type == CountTypePreactivity){
            preactivity_log_model *plMod = [[preactivity_log_model alloc]init];
            plMod.where = [NSString stringWithFormat:@"id = '%d'",_id];
            NSMutableArray *arr = [plMod getList];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:_id],@"id",
                                         [NSNumber numberWithInt:1],@"visit_count",
                                         [NSNumber numberWithInt:1],@"share_sum",nil];
            if (arr.count > 0) {
                NSDictionary *dict = [arr lastObject];
                
                int count = [[dict objectForKey:@"visit_count"] intValue];
                [data setObject:[NSNumber numberWithInt:count] forKey:@"visit_count"];
                
                int share = [[dict objectForKey:@"share_sum"] intValue];
                [data setObject:[NSNumber numberWithInt:++share] forKey:@"share_sum"];
                
                [plMod updateDB:data];
            } else {
                [plMod insertDB:data];
            }
            
            [plMod release], plMod = nil;
        }else if (_type == CountTypeShop){
            if(_id > 0){
                shop_log_model *slMod = [[shop_log_model alloc]init];
                slMod.where = [NSString stringWithFormat:@"id = '%d'",_id];
                NSMutableArray *arr = [slMod getList];
                
                NSString *cityId = nil;
                NSString *provinceId = nil;
                NSString *provinceName = nil;
                dqxx_model *dqxxModel = [[dqxx_model alloc] init];
                dqxxModel.where = [NSString stringWithFormat:@"DQXX02 = '%@'",[Global sharedGlobal].currCity];
                NSArray *cityArr = [dqxxModel getList];
                if ([cityArr count] > 0) {
                    cityId = [[cityArr objectAtIndex:0] objectForKey:@"DQXX01"];
                    provinceId = [[cityArr objectAtIndex:0] objectForKey:@"DQX_DQXX01"];
                    
                    dqxxModel.where = [NSString stringWithFormat:@"DQXX01 = '%@'",provinceId];
                    NSArray *arr1 = [dqxxModel getList];
                    if([arr1 count] > 0){
                        provinceName = [[arr1 objectAtIndex:0] objectForKey:@"DQXX02"];
                    }
                }else {
                    cityId = @"0";
                    provinceId = @"0";
                    provinceName = @"";
                }
                
                dqxxModel.where = nil;
                [dqxxModel release];
                
                NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
                
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInt:_id],@"id",
                                             [NSNumber numberWithInt:1],@"iphone_pv",
                                             provinceId,@"province_id",
                                             provinceName,@"province_name",
                                             cityId,@"city_id",
                                             [Global sharedGlobal].currCity,@"city_name",
                                             token,@"mac_addr",nil];
                if (arr.count > 0) {
                    NSDictionary *dict = [arr lastObject];
                    int count = [[dict objectForKey:@"iphone_pv"] intValue];
                    [data setObject:[NSNumber numberWithInt:++count] forKey:@"iphone_pv"];
                    [slMod updateDB:data];
                } else {
                    [slMod insertDB:data];
                }
                
                [slMod release], slMod = nil;
            }
        }
        
        [pool release];
    });
}

+ (BOOL)isLoctionAndEqual
{
    if ([Global sharedGlobal].locationCity.length != 0
        && [[Global sharedGlobal].locationCity rangeOfString:[Global sharedGlobal].currCity].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}
@end

