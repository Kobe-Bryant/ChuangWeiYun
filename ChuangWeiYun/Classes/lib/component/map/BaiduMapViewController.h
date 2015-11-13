//
//  BaiduMapViewController.h
//  information
//
//  Created by 来 云 on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
//#import "BMKSearch.h"
#import "BMKRouteSearch.h"
#import "PopoverView.h"
#import "Global.h"
#import "CmdOperation.h"
#import "HttpRequest.h"
#import "MapAnnotationView.h"
#import "IconDownLoader.h"
#import "IconPictureProcess.h"
#import "CitySubbranchViewController.h"

//@interface BaiduMapViewController : UIViewController <BMKMapViewDelegate,BMKSearchDelegate,PopoverViewDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,HttpRequestDelegate,IconDownloaderDelegate>
@interface BaiduMapViewController : UIViewController <BMKMapViewDelegate,BMKRouteSearchDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,PopoverViewDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,HttpRequestDelegate,IconDownloaderDelegate>
{
    BMKMapView      *_mapView;
//    BMKSearch       *_search;
    BMKRouteSearch       *_search;
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _geoSearch;
    
    double _latitude;
    double _longitude;
    
    BMKAnnotationView *annotationForRemove;
    BOOL _isEdit;
    
    NSArray     *shopsArray;
    NSString    *phoneNum;
    PopoverView *popverView;
    NSArray     *myShopArray;
    
    int selectIndex;
    int myShopIndex;
    
    UIActivityIndicatorView *spinner;
    double preDistanceFromMyLocation;
    CLLocationCoordinate2D spanCoordate;
    
    
    NSTimer *timer;
    CGPoint viewpoint;
    UIView  *locView;
    MapAnnotationView *annotiView;
    
    NSArray *arrayTest;
    
    //操作类型，分别为显示商铺，搜索地址，和用户自定义
    enum operateType{
        show_shops = 5,
        search_place,
        user_locate,
        show_custom_shops
    };
    int operation;
    
    //其他页面定位地图判断
    CwStatusType    otherStatusTypeMap;
    //其他页面定位地图数据
    NSDictionary    *dataDic;
    //其他页面定位地图数据
    NSArray         *otherShopsArray;
    
    UIImageView     *bgView;
    UIImageView     *imgHeadView;
    UIButton        *mapShowBtn;
    UIButton        *listShowBtn;
    
}
@property (retain, nonatomic) BMKMapView    *mapView;
//@property (retain, nonatomic) BMKSearch     *search;
@property (retain, nonatomic) BMKRouteSearch     *search;
@property (retain, nonatomic) NSString      *phoneNum;
@property (retain, nonatomic) NSArray       *shopsArray;
@property (retain, nonatomic) NSArray       *otherShopsArray;
@property (retain, nonatomic) PopoverView   *popverView;
@property (nonatomic, retain) NSArray       *myShopArray;
@property (nonatomic, retain) NSDictionary  *dataDic;
@property (retain, nonatomic) UIButton      *mapShowBtn;
@property (retain, nonatomic) UIButton      *listShowBtn;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) int operation;
@property (nonatomic, assign) CwStatusType otherStatusTypeMap;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) BMKAnnotationView *annotationForRemove;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int selectIndex;

- (void)handleToMyLocation;

@end

