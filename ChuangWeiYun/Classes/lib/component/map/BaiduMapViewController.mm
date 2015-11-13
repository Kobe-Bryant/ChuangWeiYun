////
////  BaiduMapViewController.m
////  information
////
////  Created by 来 云 on 13-10-23.
////  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
////
//
#import "BaiduMapViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "CurrentLocationAnnotation.h"
#import "CalloutMapAnnotation.h"
#import "callSystemApp.h"
#import "alertView.h"
#import "PopoverView.h"
#import "CustomAnnotation.h"
#import "MapAnnotation.h"
#import "MapAnnotationView.h"
#import "NetManager.h"
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "shop_near_list_model.h"
#import "system_config_model.h"
#import "IconDownLoader.h"
#import "IconPictureProcess.h"
#import "FileManager.h"
#import "EnterShopLookViewController.h"
#import "UIImageView+WebCache.h"
#import <math.h>
#import "CustomTabBar.h"
#import "popViewCell.h"
#import "sys/utsname.h"


typedef enum {
    MapNavEnumIOSSystem,
    MapNavEnumGoogleMaps,
    MapNavEnumIOSAmap,
    MapNavEnumBaiduMaps,
    MapNavEnumMax
} MapNavEnum;

static BOOL isShowGoogleMap=NO;
static BOOL isShowBaiduMap=NO;
static BOOL isShowGaodeMap=NO;
static BOOL isShowIosMap=NO;

const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;

#define NSNumericSearch 6.0

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface RouteAnnotation : NSObject <BMKAnnotation>
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘
    int _degree;
    NSString *_title;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (retain, nonatomic) NSString *title;

@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@synthesize coordinate = _coordinate;
@synthesize title = _title;

@end

@interface UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage(InternalMethod)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    CGSize rotatedSize = self.size;
    rotatedSize.width *= 2;
    rotatedSize.height *= 2;
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, degrees * M_PI / 180);
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@interface BaiduMapViewController ()
{
    int mapNumber;
    
    CLLocationCoordinate2D targetCoordate;
    CLLocationCoordinate2D _currCoordinate;
    CLLocationCoordinate2D _spaceCoordinate;
    
    BOOL firstPop;
}

@property (retain, nonatomic) NSString *city;
@property (retain, nonatomic) NSString *addr;
@property (retain, nonatomic) NSString *endcity;
// 线
@property (retain, nonatomic) BMKPolyline *bmkLine;
// 画线视图
@property (retain, nonatomic) BMKPolylineView *routeLineView;

@property (retain, nonatomic) BMKAnnotationView *currAnnotationView;

@end

@implementation BaiduMapViewController

@synthesize mapView     = _mapView;
@synthesize search      = _search;
@synthesize latitude    = _latitude;
@synthesize longitude   = _longitude;
@synthesize isEdit      = _isEdit;
@synthesize operation;
@synthesize dataDic;
@synthesize shopsArray;
@synthesize phoneNum;
@synthesize popverView;
@synthesize selectIndex;
@synthesize myShopArray;
@synthesize spinner;
@synthesize otherStatusTypeMap;
@synthesize city;
@synthesize addr;
@synthesize endcity;
@synthesize bmkLine;
@synthesize routeLineView;
@synthesize currAnnotationView;
@synthesize annotationForRemove;
@synthesize otherShopsArray;
@synthesize mapShowBtn;
@synthesize listShowBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    if (self.otherStatusTypeMap==StatusTypeMap || self.otherStatusTypeMap==StatusTypeServiceToMap) {
        self.navigationItem.title = @"定位";
    } else if (self.otherStatusTypeMap == StatusTypeNormal) {
        self.navigationItem.title = @"优惠劵可用分店";
    } else {
        self.navigationItem.title = @"附近的店";
    }
    
    preDistanceFromMyLocation = 0.0;
    selectIndex=0;
    firstPop = YES;
    
    NSLog(@"dataDic%@",self.dataDic);
    
    [self createMapView];

    [self updateTap];

    [self accessItemService];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _search.delegate = self;
    _geoSearch.delegate = self;
    
    [super viewWillAppear:animated];
    
    [_mapView setShowsUserLocation:YES];
    
    if (self.otherStatusTypeMap == StatusTypeMap) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

//解决了百度地图用户定位第二次进去的时候不显示问题
- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _search.delegate = nil;
    _geoSearch.delegate = nil;
    
    [_mapView setShowsUserLocation:NO];
    [super viewWillDisappear:animated];
    
    //页面消失时取消所有Perform执行的方法
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    //定位效果未完返回停止动画
    NSString *isStop = @"YES";
    [[NSNotificationCenter defaultCenter]postNotificationName:@"isStopAnimation" object:isStop];
}

// 添加地图数据
- (void)showAllShops
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    [array release];//add vincent
    
    [_mapView setShowsUserLocation:YES];

    [self showShops];
}

// 显示分店头像
- (void)showShops
{
    system_config_model *curLocation = [[system_config_model alloc] init];
    curLocation.where = [NSString stringWithFormat:@"tag ='%@'",@"latitude"];
    NSArray *curLoclatitude = [curLocation getList];
    
    curLocation.where = [NSString stringWithFormat:@"tag ='%@'",@"longitude"];
    NSArray *curLoclongitude = [curLocation getList];
    
    RELEASE_SAFE(curLocation);
    
    if ([curLoclatitude count] > 0&&[curLoclongitude count] > 0) {
        self.latitude = [[[curLoclatitude objectAtIndex:0]objectForKey:@"value"]doubleValue];
        self.longitude = [[[curLoclongitude objectAtIndex:0]objectForKey:@"value"]doubleValue];
    } else {
        return;
    }
    
    if ([shopsArray count] !=0 ) {
        if (self.otherStatusTypeMap == StatusTypeMap ||
            self.otherStatusTypeMap == StatusTypeServiceToMap) {
            
            if ([[self.dataDic objectForKey:@"longitude"] floatValue] != 0 &&
                [[self.dataDic objectForKey:@"latitude"]floatValue] != 0) {
                
                double lon = [[self.dataDic objectForKey:@"longitude"]doubleValue];
                double lat = [[self.dataDic objectForKey:@"latitude"]doubleValue];
                
                spanCoordate.latitude = lat;
                spanCoordate.longitude = lon;
                
                //计算定位位置最近的分店位置
                double currentDistanctFromMyLocation = [Common lantitudeLongitudeToDist:self.longitude Latitude1:self.latitude long2:lon Latitude2:lat];
                
                if (currentDistanctFromMyLocation < preDistanceFromMyLocation) {
                    spanCoordate.latitude = lat;
                    spanCoordate.longitude = lon;
                    NSLog(@"spanCoordate.longitude:%f",spanCoordate.longitude);
                    NSLog(@"spanCoordate.latitude:%f",spanCoordate.latitude);
                }
                preDistanceFromMyLocation = currentDistanctFromMyLocation;

                CurrentLocationAnnotation *annotation = [[CurrentLocationAnnotation alloc] initWithCoordinate:spanCoordate andTitle:@"title" andSubtitle:@"My subtitle" andImage:[self.dataDic objectForKey:@"manager_portrait"]];
                annotation.index = 0;
                
                [self performSelector:@selector(delayRunAddAnnotation:) withObject:annotation afterDelay:3];
                
                //其他页面进入地图弹出信息窗
                //程序运行第一次弹窗和下次进入程序的弹窗判断
        
                BMKAnnotationView *annotationView = [[[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationPin"] autorelease];

                BOOL hasShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"userLocationHasShow"];
                if (hasShow) {
                    [self performSelector:@selector(annotationViewBMK:) withObject:annotationView afterDelay:3];
                }
            }
        }
        else{
            if ([shopsArray count] > 0) {
                //添加各个分店在地图上的标注
                for (int i = 0; i < [shopsArray count]; i++) {
                    NSDictionary *dic = [shopsArray objectAtIndex:i];
                    NSString *title = [dic objectForKey:@"name"];
                    double lon = 0.0;
                    double lat = 0.0;
                    if ([dic objectForKey:@"latitude"] != nil) {
                        lon = [[dic objectForKey:@"longitude"] doubleValue];
                        lat = [[dic objectForKey:@"latitude"] doubleValue];
                    }
                    
                    CLLocationCoordinate2D coordate = {lat,lon};

                    double currentDistanctFromMyLocation = [Common lantitudeLongitudeToDist:self.longitude Latitude1:self.latitude long2:lon Latitude2:lat];
                    NSLog(@"currentDistanctFromMyLocation = %f",currentDistanctFromMyLocation);
                    if (i == 0) {
                        spanCoordate = coordate;
                        preDistanceFromMyLocation = currentDistanctFromMyLocation;
                    }
                    
                    if (currentDistanctFromMyLocation < preDistanceFromMyLocation) {
                        spanCoordate.latitude = lat;
                        spanCoordate.longitude = lon;
                        preDistanceFromMyLocation = currentDistanctFromMyLocation;
                    }
                    
                    CurrentLocationAnnotation *annotation = [[CurrentLocationAnnotation alloc] initWithCoordinate:coordate andTitle:title andSubtitle:@"My subtitle" andImage:[dic objectForKey:@"manager_portrait"]];
                    annotation.index = i;
                    annotation.imgaeUrl = [dic objectForKey:@"manager_portrait"];
                    
                    //添加分店位置标注
                    [self performSelector:@selector(delayRunAddAnnotation:) withObject:annotation afterDelay:3];
                }
            }
        }
    }

    _spaceCoordinate  = spanCoordate;

    CLLocationCoordinate2D pt=(CLLocationCoordinate2D){self.latitude, self.longitude};
    //CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.latitude+(_spaceCoordinate.latitude-self.latitude)/2, self.longitude+(_spaceCoordinate.longitude-self.longitude)/2};

    MapAnnotation *annotation = [[MapAnnotation alloc] initWithLatitude:self.latitude andLongitude:self.longitude andTitle:self.addr];
    //添加自己位置标注
    [_mapView addAnnotation:annotation];
    RELEASE_SAFE(annotation);
    
    //地图定位到我的位置
    NSLog(@"spanCoordate.longitude:%f",_spaceCoordinate.longitude);
    NSLog(@"spanCoordate.latitude:%f",_spaceCoordinate.latitude);
    NSLog(@"self.longitude:%f",self.longitude);
    NSLog(@"self.latitude:%f",self.latitude);
    NSLog(@"latitude:%f",_spaceCoordinate.latitude-self.latitude);
    NSLog(@"longitude:%f",_spaceCoordinate.longitude-self.longitude);
    
    BMKCoordinateRegion region = BMKCoordinateRegionMake(pt,BMKCoordinateSpanMake((_spaceCoordinate.latitude-self.latitude)*2, (_spaceCoordinate.longitude -self.longitude)*2));
    
    //地图显示区域范围
    [_mapView setRegion:region animated:NO];
}

//动画结束后添加分店标注
- (void)delayRunAddAnnotation:(CurrentLocationAnnotation *)annotation{
    [_mapView addAnnotation:annotation];

}

-(void)addShopAnnotation{
    [self removeLayerView];
    self.mapShowBtn.userInteractionEnabled = YES;
    self.listShowBtn.userInteractionEnabled = YES;
    
}

//点击定位
- (void)handleToMyLocation
{
    [_locService startUserLocationService];
    
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    RELEASE_SAFE(array); //add vincent
    
    [_mapView setShowsUserLocation:YES];
    
    firstPop = NO;
    
    [self performSelector:@selector(repositionAddShop) withObject:nil afterDelay:3];
        
    //添加我的位置标注

    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.latitude, self.longitude};

    NSLog(@"_spaceCoordinate=%f-%f",_spaceCoordinate.latitude,_spaceCoordinate.longitude);

    
    //地图定位到我的位置
    BMKCoordinateRegion region = BMKCoordinateRegionMake(pt, BMKCoordinateSpanMake((_spaceCoordinate.latitude-self.latitude)*2, (_spaceCoordinate.longitude-self.longitude)*2));

    [_mapView setRegion:region animated:NO];
    
//    if (self.otherStatusTypeMap!=StatusTypeMap || self.otherStatusTypeMap!=StatusTypeServiceToMap) {
//        [_mapView setZoomLevel:15];
//    }

    MapAnnotation *annotation = [[MapAnnotation alloc] initWithLatitude:self.latitude andLongitude:self.longitude andTitle:self.addr];
    
    NSLog(@"annotationannotation%@",annotation.title);
    
    [_mapView addAnnotation:annotation];
    RELEASE_SAFE(annotation);

    [self startAnimation];

}


// 点击定位按钮重新标注分店
- (void)repositionAddShop{
    if (self.otherStatusTypeMap==StatusTypeMap || self.otherStatusTypeMap==StatusTypeServiceToMap)
    {
        
        if ([[self.dataDic objectForKey:@"longitude"] floatValue]!=0&&[[self.dataDic objectForKey:@"latitude"]floatValue]!=0){
            double lon = 0.0;
            double lat = 0.0;
            if ([self.dataDic objectForKey:@"latitude"]!=nil) {
                lon = [[self.dataDic objectForKey:@"longitude"] doubleValue];
                lat = [[self.dataDic objectForKey:@"latitude"] doubleValue];
            }
            
            spanCoordate.latitude = lat;
            spanCoordate.longitude = lon;
            
            CurrentLocationAnnotation *annotation = [[CurrentLocationAnnotation alloc] initWithCoordinate:spanCoordate andTitle:@"title" andSubtitle:@"My subtitle" andImage:[self.dataDic objectForKey:@"manager_portrait"]];
            annotation.index = 0;
            [_mapView addAnnotation:annotation];
            
            //其他页面进入地图弹出信息窗
            BMKAnnotationView *annotationView = [[[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationPin"] autorelease];
            [annotation release]; // add vincent
            [self performSelector:@selector(annotationViewBMK:) withObject:annotationView afterDelay:0.5];
        }
    
    }else{
        if ([self.shopsArray count] > 0) {
            //添加各个商店在地图上的标注
            for (int i = 0; i < [self.shopsArray count]; i++) {
                NSDictionary *dic = [self.shopsArray objectAtIndex:i];
                NSString *title = [dic objectForKey:@"name"];
                double lon = 0.0;
                double lat = 0.0;
                if ([dic objectForKey:@"latitude"]!=nil) {
                    lon = [[dic objectForKey:@"longitude"] doubleValue];
                    lat = [[dic objectForKey:@"latitude"] doubleValue];
                }
                
                CLLocationCoordinate2D coordate = {lat,lon};

                double currentDistanctFromMyLocation = [Common lantitudeLongitudeToDist:self.longitude Latitude1:self.latitude long2:lon Latitude2:lat];
                
                if (i == 0) {
                    spanCoordate = coordate;
                    preDistanceFromMyLocation = currentDistanctFromMyLocation;
                }
                
                if (currentDistanctFromMyLocation < preDistanceFromMyLocation) {
                    spanCoordate.latitude = lat;
                    spanCoordate.longitude = lon;
                    preDistanceFromMyLocation = currentDistanctFromMyLocation;
                }

                CurrentLocationAnnotation *annotation = [[CurrentLocationAnnotation alloc] initWithCoordinate:coordate andTitle:title andSubtitle:@"My subtitle" andImage:[dic objectForKey:@"manager_portrait"]];
                annotation.index = i;
                annotation.imgaeUrl = [dic objectForKey:@"manager_portrait"];
                [_mapView addAnnotation:annotation];
                [annotation release], annotation = nil;
            }
        }
    }
}

// 将百度地图的坐标转为地球坐标
void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon)
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    *gg_lon = z * cos(theta) + 0.0006;
    *gg_lat = z * sin(theta) - 0.0005;
}

// 坐标转换
- (void)coordiateconvert
{
    double x_mars, y_mars, x_wgs, y_wgs;
    
    // baidu
	x_mars = targetCoordate.longitude;
	y_mars = targetCoordate.latitude;
    
    bd_decrypt(x_mars, y_mars, &x_wgs, &y_wgs);
    printf("Transform success, (%f,%f)-->(%f,%f)\n",x_mars,y_mars,x_wgs,y_wgs);
    
    targetCoordate.latitude = y_wgs;
    targetCoordate.longitude = x_wgs;
}

// 百度地图跳转
- (void)baiduMapsToJump
{
    NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%@&destination=%@&mode=driving&region=%@",[self.addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[[shopsArray objectAtIndex:selectIndex] objectForKey:@"address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@%@",self.addr,self.city);
    NSLog(@"baiduMapsToJump stringURL = %@",stringURL);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

// 高德地图跳转
- (void)iosaMapToJump
{
    [self coordiateconvert];
    
    NSDictionary *infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString *appName1 =[infoDict objectForKey:@"CFBundleDisplayName"];
    if (appName1.length == 0) {
        appName1 = [infoDict objectForKey:@"CFBundleName"];
    }
    
    NSString *stringURL = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=YunGoTempleate&sid=BGVIS1&slat=%f&slon=%f&sname=A&did=BGVIS2&dlat=%f&dlon=%f&dname=B&dev=0&m=0&t=0",[appName1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],self.latitude,self.longitude,targetCoordate.latitude,targetCoordate.longitude];

    NSLog(@"iosaMapToJump stringURL = %@",stringURL);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

// 谷歌地图跳转
- (void)googleMapsToJump
{
    [self coordiateconvert];
//    NSString *data = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f(%@)&center=%f,%f&directionsmode=&zoom=17",targetCoordate.latitude,targetCoordate.longitude,[[[shopsArray objectAtIndex:selectIndex] objectForKey:@"address"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],targetCoordate.latitude,targetCoordate.longitude];
    
    NSString *data = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&center=%f,%f&directionsmode=&zoom=17",targetCoordate.latitude,targetCoordate.longitude,targetCoordate.latitude,targetCoordate.longitude];
    
    NSLog(@"googleMapsToJump data = %@",data);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:data]];
}

// ios自带的地图跳转
- (void)iosMapSystemToJump
{
    [self coordiateconvert];
    //调用自带地图（定位）
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    //显示目的地坐标。画路线
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[[MKPlacemark alloc] initWithCoordinate:targetCoordate addressDictionary:nil] autorelease]];
    toLocation.name = [[shopsArray objectAtIndex:selectIndex] objectForKey:@"address"];
    
    NSArray  * values = [NSArray arrayWithObjects:
                         MKLaunchOptionsDirectionsModeDriving,
                         [NSNumber numberWithBool:YES],
                         [NSNumber numberWithInt:0],
                         nil];
    NSArray * keys = [NSArray arrayWithObjects:
                      MKLaunchOptionsDirectionsModeKey,
                      MKLaunchOptionsShowsTrafficKey,
                      MKLaunchOptionsMapTypeKey,nil];
    
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                   launchOptions:[NSDictionary dictionaryWithObjects:values forKeys:keys]];

    [toLocation release];
    
}
// 导航画线
- (void)searchPolyline
{
    NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
    for (int i = 0; i < array.count; i++) {
        if ([[array objectAtIndex:i] isKindOfClass:[RouteAnnotation class]]) {
            [_mapView removeAnnotation:[array objectAtIndex:i]];
        }
    }
    
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    RELEASE_SAFE(array);//add vincent
    [routeLineView release], routeLineView = nil;
    
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    start.pt = _currCoordinate;
    start.name = self.city;
    start.cityName = self.city;
    
    BMKPlanNode *end = [[BMKPlanNode alloc]init];
    end.pt = targetCoordate;
    end.name = self.endcity;
    end.name = self.endcity;
    
    BMKDrivingRoutePlanOption* drivingPlan = [[BMKDrivingRoutePlanOption alloc] init];
    drivingPlan.from = start;
    drivingPlan.to = end;
    
//    BOOL flag1 = [_search drivingSearch:start.name startNode:start endCity:end.name endNode:end];
    BOOL flag1 = [_search drivingSearch:drivingPlan];
    if (!flag1) {
        NSLog(@"search failed");
    }
    [start release];
    [end release];
    
    [drivingPlan release];
}

// 检测用户手机安装那种地图，使其显示选择安装的地图
- (void)sheet
{
    [popverView dismiss];
    
    mapNumber = 0;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]
        || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]
        || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        if (!SYSTEM_VERSION_LESS_THAN(@"6.0")) {
            [sheet addButtonWithTitle:@"使用苹果自带地图导航"];
            mapNumber += 1;
            isShowIosMap=YES;
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            [sheet addButtonWithTitle:@"使用Google Maps导航"];
            mapNumber += 1;
            isShowGoogleMap=YES;
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            [sheet addButtonWithTitle:@"使用高德地图导航"];
            mapNumber += 1;
            isShowGaodeMap=YES;
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            [sheet addButtonWithTitle:@"使用百度地图导航"];
            mapNumber += 1;
            isShowBaiduMap=YES;
        }
        [sheet addButtonWithTitle:@"取消"];
        mapNumber += 1;
        sheet.cancelButtonIndex = sheet.numberOfButtons-1;
        [sheet showInView:self.view];
    } else {
        if (!SYSTEM_VERSION_LESS_THAN(@"6.0")) {
            [self iosMapSystemToJump];
        } else {
            [self searchPolyline];
        }
    }
    
    NSLog(@"mapNumber = %d",mapNumber);
}

// 导航按钮
- (void)buttonclick:(id)sender
{
    NSLog(@"buttonclick.....");
    [self sheet];
}

// 定位按钮
- (void)createLocationView:(UIView *)InView{
    locView=[[[UIView alloc]initWithFrame:CGRectMake(10.0f, KUIScreenHeight-60.0f-44, 50.0f, 50.0f)] autorelease];
    locView.backgroundColor=[UIColor clearColor];
    
    operation = show_shops;
    
    if (operation == show_shops) {
        
        UIImage *locateImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_address_home" ofType:@"png"]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0f, 0.0f, locView.frame.size.width, locView.frame.size.height);
        [button addTarget:self action:@selector(handleToMyLocation) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:locateImage forState:UIControlStateNormal];
        [locView addSubview:button];
        RELEASE_SAFE(locateImage);
        
    }
    [InView addSubview:locView];
    
}
// 地图形式展示分店
- (void)showMapShop{
    NSLog(@"showMap");
    
    if (!self.mapShowBtn.selected)
    {
        
        [self.mapShowBtn setSelected:YES];
        [self.listShowBtn setSelected:NO];
        
    }
    [self handleToMyLocation];
    
}
// 列表形式展示分店
- (void)showListShop{
    NSLog(@"showListShop");
    
    if (!self.listShowBtn.selected)
    {
        [self.mapShowBtn setSelected:NO];
        [self.listShowBtn setSelected:YES];
    
    }
    [self citySubbranchView:CitySubbranchNearShop];
    
}

// 创建百度地图
- (void)createMapView{
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    _geoSearch.delegate = self;
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    
    _mapView = [[[BMKMapView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight)] autorelease];
    _mapView.delegate = self;
    _mapView.zoomLevel = 18;
    _mapView.mapType = BMKMapTypeStandard;
    [self.view addSubview:_mapView];
//    [_mapView release]; //add vincent
    
    _mapView.showsUserLocation = YES;
    
    [self createLocationView:self.view];
    
    _search = [[BMKRouteSearch alloc] init];
    _search.delegate = self;
    
    [self createChooseShow];
    
    if (self.otherStatusTypeMap == StatusTypeNormal){
        _mapView.zoomLevel = 18;
    }
    // 定位的时候不需要显示选择展示按钮
    if (self.otherStatusTypeMap==StatusTypeMap ||self.otherStatusTypeMap==StatusTypeServiceToMap || self.otherStatusTypeMap == StatusTypeNormal)
    {
        self.mapShowBtn.hidden = YES;
        self.listShowBtn.hidden = YES;
    }else{
        self.mapShowBtn.hidden = NO;
        self.listShowBtn.hidden = NO;
    }
}

// 创建分店选择展示按钮
- (void)createChooseShow{
    //navBar显示方式切换按钮
    UIView* operatButtonView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 80.0f , 44.0f )];
    
    UIButton *tempMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempMapButton.frame = CGRectMake(0.0f, 6.0f, 40.0f, 31.0f);
    [tempMapButton addTarget:self action:@selector(showMapShop) forControlEvents:UIControlEventTouchDown];
    [tempMapButton setImage:[UIImage imageCwNamed:@"icon_options_map_down.png"] forState:UIControlStateNormal];
    [tempMapButton setImage:[UIImage imageCwNamed:@"icon_options_map_down.png"] forState:UIControlStateHighlighted];
    self.mapShowBtn = tempMapButton;
    [operatButtonView addSubview:self.mapShowBtn];
    
    UIButton *tempListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempListButton.frame = CGRectMake(40.0f, 6.0f, 40.0f, 31.0f);
    [tempListButton addTarget:self action:@selector(showListShop) forControlEvents:UIControlEventTouchDown];
    [tempListButton setImage:[UIImage imageCwNamed:@"icon_options_list_normal.png"] forState:UIControlStateNormal];
    [tempListButton setImage:[UIImage imageCwNamed:@"icon_options_list_down.png"] forState:UIControlStateHighlighted];
    self.listShowBtn = tempListButton;
    [operatButtonView addSubview:self.listShowBtn];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:operatButtonView];
    [operatButtonView release], operatButtonView = nil;
    barBtn.width = 65.0f;
    self.navigationItem.rightBarButtonItem = barBtn;
    RELEASE_SAFE(barBtn);
}

// 切换分店选择页
- (void)citySubbranchView:(CitySubbranchEnum)asubbranchEnum
{
    CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
//        citySubbranch.delegate = self;
    citySubbranch.cityStr = [Global sharedGlobal].currCity;
    citySubbranch.subbranchEnum = asubbranchEnum;
    citySubbranch.cwStatusType = StatusTypeNearShop;
    [self.navigationController pushViewController:citySubbranch animated:NO];
    [citySubbranch release], citySubbranch = nil;
}

// 合成视图和图片方法
- (UIImage *)compoundImage:(UIImageView *)view andUrl:(NSString *)picUrl{
    
    [view setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageNamed:@"portrait_member.png"]];
    view.frame = CGRectMake(30, 30, 60, 60);
    // UIImageView转换为UIImage
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, view.layer.contentsScale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imgView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *defaultHead=[UIImage imageCwNamed:@"manager_default_home.png"];

    
    CGRect rect1=CGRectMake(0, 0, 120, 120);
    CGRect rect2=CGRectMake(30, 30, 60, 60);
    
    // 两张图片合成头像
    CGSize size = CGSizeMake(rect1.size.width, rect1.size.height);
    UIGraphicsBeginImageContext(size);
    [defaultHead drawInRect:rect1];
    [imgView drawInRect:rect2];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//     UIImage *defaultHead=[UIImage imageCwNamed:@"manager_default_home.png"];
//    
//     UIImage *resultingImage = defaultHead;
    
    
    return resultingImage;
}

#pragma mark - Animation
// 动画开始时创建覆盖层
- (void)createLayerView{
    _mapView.scrollEnabled=NO;
    locView.userInteractionEnabled=NO;
    
    UIButton *layerView=[[[UIButton alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)]autorelease];
    
    layerView.backgroundColor=[UIColor clearColor];
    layerView.enabled=NO;
    
    layerView.tag=101;
    [_mapView bringSubviewToFront:layerView];
    
}
// 删除动画覆盖层
- (void)removeLayerView{
    UIButton *layView=(UIButton *)[_mapView viewWithTag:101];
    layView.enabled=YES;
    [layView removeFromSuperview];
    _mapView.scrollEnabled=YES;
    _mapView.userInteractionEnabled=YES;
    locView.userInteractionEnabled=YES;
}
// 开始动画
- (void)startAnimation{
    [timer invalidate];
    [self createLayerView];
    [annotiView start];

    [self performSelector:@selector(addShopAnnotation) withObject:nil afterDelay:4];
    
    self.mapShowBtn.userInteractionEnabled = NO;
    self.listShowBtn.userInteractionEnabled = NO;
}
- (void)stopAnimation{
    [annotiView stop];
}

#pragma mark - BMK Map View Delegate
// 生成的覆盖物
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id)overlay
{
    if(overlay == bmkLine) {
        if(nil == routeLineView) {
            routeLineView = [[BMKPolylineView alloc] initWithPolyline:bmkLine];
            routeLineView.strokeColor = [UIColor colorWithRed:72.f/255.f green:153.f/255.f blue:216.f/255.f alpha:1.f];
            routeLineView.lineWidth = 5;
        }
        return routeLineView;
    }
    return nil;
}

// 返回驾乘结果
//- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error
//{
//	if (error == BMKErrorOk) {
//        //        NSLog(@"result.plans = %d",result.plans.count);
//		BMKRoutePlan* plan = (BMKRoutePlan*)[result.plans objectAtIndex:0];
//        //        NSLog(@"plan.routes = %d",plan.routes.count);
//        //        BMKRoute* routeplan = (BMKRoute*)[plan.routes objectAtIndex:0];
//        //        NSLog(@"routeplan.steps = %d",routeplan.steps.count);
//        //        NSLog(@"pointsCount = %d",routeplan.pointsCount);
//        
//		int index = 0;
//		for (int i = 0; i < 1; i++) {
//			BMKRoute* route = [plan.routes objectAtIndex:i];
//			for (int j = 0; j < route.pointsCount; j++) {
//				int len = [route getPointsNum:j];
//				index += len;
//			}
//		}
//        //        NSLog(@"index = %d",index);
//        
//		BMKMapPoint* points = new BMKMapPoint[index];
//		index = 0;
//		
//		for (int i = 0; i < 1; i++) {
//			BMKRoute* route = [plan.routes objectAtIndex:i];
//			for (int j = 0; j < route.pointsCount; j++) {
//				int len = [route getPointsNum:j];
//				BMKMapPoint* pointArray = (BMKMapPoint*)[route getPoints:j];
//				memcpy(points + index, pointArray, len * sizeof(BMKMapPoint));
//				index += len;
//			}
//			int size = route.steps.count;
//			for (int j = 0; j < size; j++) {
//				BMKStep* step = [route.steps objectAtIndex:j];
//				RouteAnnotation *item = [[RouteAnnotation alloc]init];
//				item.coordinate = step.pt;
//				item.title = step.content;
//				item.degree = step.degree * 30;
//				item.type = 4;
//				[_mapView addAnnotation:item];
//				[item release];
//			}
//		}
//        
//        //CLLocationCoordinate2D *coord = (CLLocationCoordinate2D*)malloc(sizeof(routeplan.points[0]));
//        bmkLine = [BMKPolyline polylineWithPoints:points count:index];
//        [_mapView setVisibleMapRect:[bmkLine boundingMapRect]];
//		[_mapView addOverlay:bmkLine];
//		delete []points;
//	}
//}

- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error{
//    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
//	[_mapView removeAnnotations:array];
//	array = [NSArray arrayWithArray:_mapView.overlays];
//	[_mapView removeOverlays:array];
	if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
		int size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                [item release];
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
                [item release];
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            [item release];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
                [item release];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
		bmkLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapView addOverlay:bmkLine]; // 添加路线overlay
		delete []temppoints;
	}
    
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == 0) {
        
        self.city = result.addressDetail.city;
        self.addr = result.address;
        NSLog(@"city.. = %@",self.city);
        NSLog(@"addr.. = %@",self.addr);

    }
}

// 返回地址信息搜索结果
//- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error
//{
//	if (error == 0) {
//        self.city = result.addressComponent.city;
//        self.addr = result.strAddr;
//        NSLog(@"city.. = %@",self.city);
//        NSLog(@"addr.. = %@",self.addr);
//
//    }
//}
//- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error
//{
//	if (error == 0) {
//        self.city = result.addressComponent.city;
//        self.addr = result.strAddr;
//        NSLog(@"city.. = %@",self.city);
//        NSLog(@"addr.. = %@",self.addr);
//        
//    }
//}

-(void) didUpdateUserLocation:(BMKUserLocation *)userLocation{
    [_locService stopUserLocationService];
    [_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
    
    self.latitude = userLocation.location.coordinate.latitude;
    self.longitude = userLocation.location.coordinate.longitude;
    
    NSLog(@"当前纬度：%f，当前经度：%f",self.latitude,self.longitude);
    
    NSDictionary *locLatitude = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"latitude",@"tag",
                                 [NSNumber numberWithDouble:self.latitude],@"value",
                                 nil];
    
    system_config_model *curLocation = [[system_config_model alloc] init];
    curLocation.where = [NSString stringWithFormat:@"tag ='%@'",@"latitude"];
    [curLocation deleteDBdata];
    
    [curLocation insertDB:locLatitude];
    
    NSDictionary *locLongitude = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"longitude",@"tag",
                                  [NSNumber numberWithDouble:self.longitude],@"value",
                                  nil];
    
    curLocation.where = [NSString stringWithFormat:@"tag ='%@'",@"longitude"];
    [curLocation deleteDBdata];
    
    [curLocation insertDB:locLongitude];
    
    curLocation.where = nil;
    NSArray *curLocArray = [curLocation getList];
    NSLog(@"curLocArray = %@",curLocArray);
    
    RELEASE_SAFE(curLocation);
    
    if (self.otherStatusTypeMap == StatusTypeMap ||
        self.otherStatusTypeMap == StatusTypeServiceToMap) {
        _currCoordinate = (CLLocationCoordinate2D){_spaceCoordinate.latitude,_spaceCoordinate.longitude};
    } else {
        _currCoordinate = userLocation.location.coordinate;
    }
    
    //    [_search reverseGeocode:userLocation.location.coordinate];
    BMKReverseGeoCodeOption* geoOption = [[BMKReverseGeoCodeOption alloc] init];
    geoOption.reverseGeoPoint = userLocation.location.coordinate;
    
    [_geoSearch reverseGeoCode:geoOption];
    
    [geoOption release];
    
    BOOL hasShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"userLocationHasShow"];
    if (!hasShow) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userLocationHasShow"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self showAllShops];
    }
}

// 用户位置更新后，会调用此函数
//- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation
//{
//    self.latitude = userLocation.location.coordinate.latitude;
//    self.longitude = userLocation.location.coordinate.longitude;
//    
//    NSLog(@"当前纬度：%f，当前经度：%f",self.latitude,self.longitude);

    //第一次显示地图的区域范围
//    CLLocationCoordinate2D pt=(CLLocationCoordinate2D){self.latitude, self.longitude};
//    
//    BMKCoordinateRegion region = BMKCoordinateRegionMake(pt, BMKCoordinateSpanMake(0.5, 0.5));
//    
//    BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
//    
//    [_mapView setRegion:adjustedRegion animated:NO];
    
    
//    // 定位后的百度经纬度转为城市地址
//    CLGeocoder *Geocoder=[[CLGeocoder alloc]init];
//    CLGeocodeCompletionHandler handler = ^(NSArray *place, NSError *error) {
//        for (CLPlacemark *placemark in place) {
//            NSString *cityStr=placemark.thoroughfare;
//            NSString *cityName=placemark.locality;
//            NSLog(@"街道地址:%@",cityStr);//获取街道地址
//            NSLog(@"当前城市cityName %@",cityName);//获取城市名
//            [Global sharedGlobal].locationCity = cityName;
//            break;
//        }
//    };
//    CLLocation *loc = [[CLLocation alloc] initWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
//    [Geocoder reverseGeocodeLocation:loc completionHandler:handler];
//    
    
//    NSDictionary *locLatitude = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                        @"latitude",@"tag",
//                        [NSNumber numberWithDouble:self.latitude],@"value",
//                                                                      nil];
//    
//    system_config_model *curLocation = [[system_config_model alloc] init];
//    curLocation.where = [NSString stringWithFormat:@"tag ='%@'",@"latitude"];
//    [curLocation deleteDBdata];
//    
//    [curLocation insertDB:locLatitude];
//    
//    NSDictionary *locLongitude = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                        @"longitude",@"tag",
//                        [NSNumber numberWithDouble:self.longitude],@"value",
//                                                                       nil];
//    
//    curLocation.where = [NSString stringWithFormat:@"tag ='%@'",@"longitude"];
//    [curLocation deleteDBdata];
//    
//    [curLocation insertDB:locLongitude];
//    
//    curLocation.where = nil;
//    NSArray *curLocArray = [curLocation getList];
//    NSLog(@"curLocArray = %@",curLocArray);
//    
//    RELEASE_SAFE(curLocation);
//    
//    if (self.otherStatusTypeMap == StatusTypeMap ||
//        self.otherStatusTypeMap == StatusTypeServiceToMap) {
//        _currCoordinate = (CLLocationCoordinate2D){_spaceCoordinate.latitude,_spaceCoordinate.longitude};
//    } else {
//        _currCoordinate = userLocation.location.coordinate;
//    }
//    
////    [_search reverseGeocode:userLocation.location.coordinate];
//    BMKReverseGeoCodeOption* geoOption = [[BMKReverseGeoCodeOption alloc] init];
//    geoOption.reverseGeoPoint = userLocation.location.coordinate;
//    
//    _geoSearch = [[BMKGeoCodeSearch alloc] init];
//    _geoSearch.delegate = self;
//    [_geoSearch reverseGeoCode:geoOption];
//    
//    [geoOption release];
//    
//    BOOL hasShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"userLocationHasShow"];
//    if (!hasShow) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userLocationHasShow"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [self showAllShops];
//    }
//}

// 点击头像触发事件
- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    if (self.otherStatusTypeMap == StatusTypeMap            ||
        self.otherStatusTypeMap == StatusTypeServiceToMap   ||
        self.otherStatusTypeMap == StatusTypeNormal             ) {
        return;
    }
    
    [popverView dismiss];

    EnterShopLookViewController *enterShop=[[EnterShopLookViewController alloc]init];
    
    NSDictionary *dict = [shopsArray objectAtIndex:selectIndex];
    
    NSString *pic = [dict objectForKey:@"manager_portrait"];
    
    if (![[dict objectForKey:@"shop_image"] isEqual:[NSNull null]]) {
        if (pic.length > 4) {
            enterShop.pics = [NSString stringWithFormat:@"%@,%@",pic,[dict objectForKey:@"shop_image"]];
        }
    } else {
        if (pic.length > 4) {
            enterShop.pics = [NSString stringWithFormat:@"%@",pic];
        }
    }
    
    if (enterShop.pics.length > 4) {
        [self.navigationController pushViewController:enterShop animated:YES];
    }
   
    RELEASE_SAFE(enterShop);
}
// 选中分店头像弹窗视图
- (void)annotationViewBMK:(BMKAnnotationView *)view
{
    //将地图的经纬度坐标转换成所在视图的坐标
    CGPoint viewpoint1 = [_mapView convertCoordinate:view.annotation.coordinate toPointToView:self.view];
    
    CGPoint poppoint = CGPointMake(0.f, 0.f);
    
    if ([UIScreen mainScreen].applicationFrame.size.height > 500) {
        poppoint = CGPointMake(viewpoint1.x, viewpoint1.y);
    } else {
        poppoint = CGPointMake(viewpoint1.x, viewpoint1.y);
    }
    
    CGFloat totalHeight = 0.f;
    CGFloat totalwidth = 280.f;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, totalwidth, totalHeight)];
    containerView.backgroundColor=[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    if (imgHeadView == nil) {
        imgHeadView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        imgHeadView.layer.cornerRadius=25;
        imgHeadView.clipsToBounds=YES;
        imgHeadView.userInteractionEnabled = YES;
        
        // dufu add 2013.12.19 点击头像进店铺详情，加多一个单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [imgHeadView addGestureRecognizer:tap];
        [tap release], tap = nil;
    }
    
    if ([shopsArray count]!=0) {
        NSLog(@"count=%lu=count=%d",(unsigned long)[shopsArray count],selectIndex);
        NSDictionary *ay = [shopsArray objectAtIndex:selectIndex];

        //头像
        [self setHeadImage:ay andImgView:imgHeadView];
        
        [containerView addSubview:imgHeadView];
        
        
        UILabel *shopname = [[UILabel alloc] initWithFrame:CGRectMake(72.f, 10.f, totalwidth-75.f, 40.f)];
        shopname.font = [UIFont systemFontOfSize:13.f];
        shopname.numberOfLines=0;
        shopname.lineBreakMode=NSLineBreakByWordWrapping;
        shopname.backgroundColor = [UIColor clearColor];
        
        if (selectIndex < 1000) {
            shopname.text = [ay objectForKey:@"name"];
        }
        shopname.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [containerView addSubview:shopname];
        [shopname release];
        
        UILabel *managername = [[UILabel alloc] initWithFrame:CGRectMake(72.f, 41.f, totalwidth-40.f, 30.f)];
        managername.font = [UIFont systemFontOfSize:11.f];
        managername.backgroundColor = [UIColor clearColor];
        
        if (selectIndex < 1000) {
            managername.text = [ay objectForKey:@"manager_name"];
        }
        managername.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [containerView addSubview:managername];
        [managername release];
    }
    
    totalHeight += 70.f;
    
    CGFloat tableviewHeight=0.0;
    //只有在"附近的店"功能模块里，有"进店看看"功能。其余地方一律不显示进店看看按钮
    if ( self.otherStatusTypeMap==StatusTypeServiceToMap ||self.otherStatusTypeMap == StatusTypeMap || self.otherStatusTypeMap == StatusTypeNormal) {
        tableviewHeight = 87;
    }else{
        tableviewHeight = 130;
    }
    
    // 地址及电话
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(10.f, totalHeight, totalwidth-20, tableviewHeight) style:UITableViewStylePlain];
    tableview.backgroundColor = [UIColor whiteColor];
    tableview.scrollEnabled = NO;
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.backgroundView = nil;
    [containerView addSubview:tableview];
    [tableview release];
    
    //只有在"附近的店"功能模块里，有"进店看看"功能。其余地方一律不显示进店看看按钮
    if ( self.otherStatusTypeMap==StatusTypeServiceToMap ||self.otherStatusTypeMap == StatusTypeMap || self.otherStatusTypeMap == StatusTypeNormal) {
        totalHeight += 95.f;
    }else{
        totalHeight += 135.f;
    }
    
    // 导航
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(10.f, totalHeight, totalwidth-20.f, 40.f)];
    [button setTitle:@"开始导航" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [button addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    [containerView addSubview:button];
    
    totalHeight += 40.f;
    
    containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, totalHeight+10.f);
    
    if (selectIndex >= 0) {
            //[containerView autorelease]
        self.popverView = [PopoverView showPopoverAtPoint:poppoint inView:self.view withTitle:nil withContentView:containerView delegate:self];

    }
    [containerView release];
}

// 选中标注事件
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if (!view.canShowCallout && [view.annotation isKindOfClass:[CurrentLocationAnnotation class]]) {
    
        if ([view.annotation isKindOfClass:[CurrentLocationAnnotation class]]) {
            self.annotationForRemove        = view;
            CurrentLocationAnnotation *atn  = (CurrentLocationAnnotation*)(view.annotation);
            NSLog(@"currentLocation.index%d:",atn.index);
            selectIndex                     = atn.index;
            targetCoordate                  = view.annotation.coordinate;
            
            NSLog(@"targetCoordate=%f-%f",targetCoordate.latitude,targetCoordate.longitude);
        }
        
        firstPop = YES;
        if ( self.otherStatusTypeMap==StatusTypeServiceToMap ||self.otherStatusTypeMap == StatusTypeMap || self.otherStatusTypeMap == StatusTypeNormal) {
            [self annotationViewBMK:view];
            
        }else{
            [self performSelector:@selector(annotationViewBMK:) withObject:view afterDelay:0.2];
        }
        
    }else {
        //显示自己的位置地址
        MapAnnotation *atn  = (MapAnnotation*)(view.annotation);
        atn.title = self.addr;
        
    }
    NSLog(@"select");
}

// 未选中标注事件
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
        
    NSLog(@"not-select");
}
/**
 *当mapView新添加annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 新添加的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    NSLog(@"新添加annotation");
    
}


/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView{
    NSLog(@"开始定位.....");
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView{
    NSLog(@"停止定位......");
}


#pragma mark -
#pragma mark Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( self.otherStatusTypeMap==StatusTypeServiceToMap) {
        return 2;
    }
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    popViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[popViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.contentLabel.numberOfLines = 2;
        cell.contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.contentLabel.font          = [UIFont systemFontOfSize:14.f];
        cell.selectionStyle          = UITableViewCellSelectionStyleNone;
        cell.contentLabel.textColor     = [UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
    }
    
    if (IOS_7) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    NSDictionary *ay;

    if (selectIndex < 1000 && selectIndex >= 0 && [shopsArray count]!=0) {
        ay = [shopsArray objectAtIndex:selectIndex];
        self.phoneNum = [ay objectForKey:@"manager_tel"];
        
        if (indexPath.row == 0) {
            cell.iconImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_phone_click"ofType:@"png"]];
            cell.contentLabel.text = [ay objectForKey:@"manager_tel"];
            
        } else if(indexPath.row == 1) {
            cell.iconImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"locate_click"ofType:@"png"]];
            if (![[ay objectForKey:@"address"] isEqual:[NSNull null]]) {
                cell.contentLabel.text = [ay objectForKey:@"address"];
            }
            
            
        }else {
            cell.iconImg.frame = CGRectMake(15, 10, 20, 20);
            cell.iconImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_look_store"ofType:@"png"]];
            cell.contentLabel.text = @"进店看看";
//            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 30, 30)];
//            img.image = [UIImage imageCwNamed:@"icon_look_store1.png"];
//            cell.accessoryView = img;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [callSystemApp makeCall:phoneNum];
    }else if(indexPath.row == 2) {
        [popverView dismiss];
        
        NSDictionary *dict = [shopsArray objectAtIndex:selectIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTitle"
                                                            object:[dict objectForKey:@"name"]];
        [Global sharedGlobal].shop_id = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"id"] intValue]];
        [Global sharedGlobal].isRefShop = YES;

        NSArray *arrayViewControllers = self.navigationController.viewControllers;
        if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]]) {
            CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
            
            UIButton *btn = (UIButton *)[tabViewController.view viewWithTag:90001];
            
            [tabViewController selectedTab:btn];
        }
        
        [self.navigationController setNavigationBarHidden:YES animated:NO];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIActionSheetDelegate
// 根据手机安装地图显示
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((mapNumber-1) == buttonIndex) {
        return;
    }
    
    NSLog(@"buttonIndex:%ld",(long)buttonIndex);
    if (!SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        //ios系统6.0以上判断
        switch (buttonIndex) {
            case MapNavEnumIOSSystem: {
                if (!SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                    [self iosMapSystemToJump];
                    break;
                }
            }
            case MapNavEnumGoogleMaps: {
                if (isShowGoogleMap==YES) {
                    [self googleMapsToJump];
                    return;
                }
                if (isShowGaodeMap==YES) {
                    [self iosaMapToJump];
                    return;
                }
                if (isShowBaiduMap==YES) {
                    [self baiduMapsToJump];
                }
            }
                break;
            case MapNavEnumIOSAmap: {

                if (isShowGaodeMap==YES&& isShowGoogleMap == YES) {
                    [self iosaMapToJump];
                    return;
                }
                
                if (isShowBaiduMap==YES) {
                    [self baiduMapsToJump];
                }
            }
                break;
            case MapNavEnumBaiduMaps: {
                if (isShowBaiduMap==YES) {
                    [self baiduMapsToJump];
                }
            }
                break;
            default:
                break;
        }
        
    }else{
        switch (buttonIndex+1) {
            case MapNavEnumGoogleMaps: {
                if (isShowGoogleMap==YES) {
                    [self googleMapsToJump];
                    return;
                }
                if (isShowGaodeMap==YES) {
                    [self iosaMapToJump];
                    return;
                }
                if (isShowBaiduMap==YES) {
                    [self baiduMapsToJump];
                }
            }
                break;
            case MapNavEnumIOSAmap: {
                if (isShowGaodeMap==YES&&isShowGoogleMap==YES) {
                    [self iosaMapToJump];
                    return;
                }
                if (isShowBaiduMap==YES) {
                    [self baiduMapsToJump];
                }
            }
                break;
            case MapNavEnumBaiduMaps: {
                if (isShowBaiduMap==YES) {
                    [self baiduMapsToJump];
                }
            }
                break;
            default:
                break;
        }
        
    }
    
}

#pragma mark - PopoverViewDelegate Methods
// 点击头像弹窗的代理
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    
    [popoverView showImage:[UIImage imageNamed:@"success"] withMessage:@"ok"];
    
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView {
    [self.annotationForRemove setSelected:NO];
}

// 地图添加分店标注调用
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 分店标注
    if ([annotation isKindOfClass:[CurrentLocationAnnotation class]]) {
        
        BMKAnnotationView *annotationView = [[[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationPin"] autorelease];
        annotationView.canShowCallout               = NO;
        annotationView.clipsToBounds                = YES;
        annotationView.layer.cornerRadius           = 29;
        annotationView.userInteractionEnabled       = YES;
        annotationView.frame=CGRectMake(0, 0, 60, 60);
        
        CurrentLocationAnnotation *currannotation   = annotation;
        
        bgView=[[UIImageView alloc]initWithFrame:CGRectZero];
        bgView.backgroundColor          = [UIColor clearColor];
        bgView.center                   = annotationView.center;
        bgView.layer.cornerRadius       = 29;
        bgView.clipsToBounds            = YES;
        bgView.userInteractionEnabled   = YES;

        NSString *picUrl= currannotation.imgaeUrl;
//        [bgView setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageNamed:@"portrait_member.png"]];
        
        NSLog(@"imgaeUrl===%@------%@",picUrl,currannotation.title);
        // 合成分店头像
        UIImage *headImg = [self compoundImage:bgView andUrl:picUrl];
        
        //判断iphone6 和plus     7.2是plus 和7.1是6
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        NSLog(@"platform = %@",platform);
        
        if([platform isEqualToString:@"iPhone7,2"] || [platform isEqualToString:@"iPhone7,1"]){
            bgView.frame = CGRectMake(10, 10, 20, 20);
        } else {
            bgView.frame = CGRectMake(14.5, 14.5, 31, 31);
        }
        bgView.layer.cornerRadius       = bgView.frame.size.height/2;
        bgView.clipsToBounds            = YES;

        
        // 设置分店头像
        if (currannotation.imgaeUrl.length!=0) {
            // 解决第一次显示头像问题
            [annotationView addSubview:bgView];
            annotationView.image = headImg;
            // dufu add 2013.12.12  用于视图释放
//            [bgView release],bgView = nil;
        }else{
            annotationView.image = [UIImage imageCwNamed:@"manager_default_home.png"];
           
        }
    
        if (_spaceCoordinate.latitude == currannotation.coordinate.latitude && _spaceCoordinate.longitude == currannotation.coordinate.longitude) {
            selectIndex = currannotation.index;
            if (firstPop == NO) {
                firstPop = YES;
                targetCoordate = currannotation.coordinate;
                self.annotationForRemove = annotationView;
            }
        }
    
        return annotationView;
        
    }else if ([annotation isKindOfClass:[RouteAnnotation class]]) {//导航标注
        BMKAnnotationView *KYview = [[[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"KYViewID"] autorelease];
        RouteAnnotation *item = annotation;
        
        KYview.image = [[UIImage imageNamed:@"icon_direction.png"] imageRotatedByDegrees:item.degree];
        KYview.canShowCallout = YES;
        
        return KYview;
    }else if ([annotation isKindOfClass:[MapAnnotation class]]){//自己的位置标注
        NSString *identifier=@"mapID";

        annotiView=(MapAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (nil==annotiView) {
            annotiView=[[[MapAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier]autorelease];
        }
        
        
        return annotiView;
        
    }else {
        return nil;
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //[_mapView setShowsUserLocation:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.city = nil;
    self.addr = nil;
//    if (_mapView) {
//        RELEASE_SAFE(_mapView);
//    }
    if (_search) {
        RELEASE_SAFE(_search);
    }
    if (_locService) {
        RELEASE_SAFE(_locService);
    }
    if (_geoSearch) {
        RELEASE_SAFE(_geoSearch);
    }
    RELEASE_SAFE(shopsArray);
    RELEASE_SAFE(annotationForRemove);
    RELEASE_SAFE(phoneNum);
    RELEASE_SAFE(popverView);
    RELEASE_SAFE(endcity);
    RELEASE_SAFE(routeLineView);
    RELEASE_SAFE(bmkLine);
    RELEASE_SAFE(arrayTest);
    
    RELEASE_SAFE(imgHeadView);

    firstPop = NO;
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
	[super dealloc];
}

- (void)updateTap
{
    if (self.otherStatusTypeMap == StatusTypeMap ||
        self.otherStatusTypeMap == StatusTypeServiceToMap) {
   
        self.shopsArray=[NSArray arrayWithObjects:self.dataDic, nil];

        NSLog(@"=======%@",self.shopsArray);
        
    } else {
        NSLog(@"优惠劵分店数据%@",self.shopsArray);
        
        if (self.otherStatusTypeMap != StatusTypeNormal) {
            //查找分店经纬度列表
            shop_near_list_model *nearShop=[[shop_near_list_model alloc]init];
            nearShop.where = [NSString stringWithFormat:@"city = '%@' and latitude != %d",[Global sharedGlobal].locationCity,0];
            self.shopsArray = [nearShop getList];
//            NSLog(@"附近的店分店数据=%@",self.shopsArray);
            RELEASE_SAFE(nearShop);
        }
    }
}

#pragma mark - HttpRequestDelegate
// 网络请求
- (void)accessItemService
{
    NSString *reqUrl = @"shoplist.do?param=";
    
	NSLog(@"locationCity = %@",[Global sharedGlobal].locationCity);
    
    NSString *citys=@"";
    if ([Global sharedGlobal].locationCity.length!=0) {
        citys = [Global sharedGlobal].locationCity;
    }else{
        citys = self.city;
    }
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Common getVersion:SUBBRANCH_COMMAND_ID
                                                     desc:[NSString stringWithFormat:@"分店列表版本号%@",
                                                           [Global sharedGlobal].locationCity]],@"ver",
                                                            citys,@"city",
                                                            nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SUBBRANCH_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        if (commandid == SUBBRANCH_COMMAND_ID) {
            [self getShopNearList];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                       message:@"网络不给力哦\n请检查您的网络"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        RELEASE_SAFE(alert);
    }
}

// 分店数据请求成功
- (void)getShopNearList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.otherStatusTypeMap==StatusTypeMap ||
            self.otherStatusTypeMap==StatusTypeServiceToMap) {
            self.shopsArray=[NSArray arrayWithObjects:self.dataDic, nil];
        } else {
            if (self.otherStatusTypeMap != StatusTypeNormal) {
                shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
                snlMod.where = [NSString stringWithFormat:@"city = '%@' and latitude != %d",[Global sharedGlobal].locationCity,0];
                
                self.shopsArray = [snlMod getList];
                NSLog(@"%@",self.shopsArray);
                
                [snlMod release];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0.3];

            [self showAllShops];
        });
    });
}

#pragma mark - IconDownloaderDelegate
//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
            UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(50, 50)];
            
            imgHeadView.image = photo;
            
		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
- (void)setHeadImage:(NSDictionary *)dic andImgView:(UIImageView *)imgView{
    //图片
    NSString *picUrl = [dic objectForKey:@"manager_portrait"];
    NSLog(@"picUrl==%@",picUrl);
    
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    
    if (picUrl.length > 1)
    {
        UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(50, 50)];
        if (pic.size.width > 2)
        {
            imgView.image = pic;
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"portrait_member.png"];
            imgView.image = [defaultPic fillSize:CGSizeMake(50, 50)];
            
            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:nil delegate:self];
        }
    }
    else
    {
        UIImage *defaultPic = [UIImage imageCwNamed:@"portrait_member.png"];
        imgView.image = [defaultPic fillSize:CGSizeMake(50, 50)];
    }
}

@end
