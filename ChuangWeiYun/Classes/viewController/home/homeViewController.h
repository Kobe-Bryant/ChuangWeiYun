//
//  homeViewController.h
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import <UIKit/UIKit.h>

#import "HttpRequest.h"
#import "myImageView.h"
#import "IconDownLoader.h"
#import "EGORefreshTableHeaderView.h"
#import "XLCycleScrollView.h"
#import "ItemView.h"
#import "AppCenterViewController.h"
#import "CitySubbranchViewController.h"

@class cloudLoadingView;

@interface homeViewController : UIViewController<UIScrollViewDelegate,HttpRequestDelegate,myImageViewDelegate,IconDownloaderDelegate,EGORefreshTableHeaderDelegate,XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,ItemViewDelegate,AppCenterViewDelegate, UIAlertViewDelegate, CitySubbranchViewControllerDelegate>
{
    cloudLoadingView *cloudLoading;
    UIScrollView *mainScrollView;
    XLCycleScrollView *bannerScrollView;
    UIPageControl *pageControll;
    UIView *contentView;
    NSMutableArray *myImgViewArray;
    NSArray *adItems;
    NSMutableArray *tagsItems;
    CGFloat bannerWidth;
    CGFloat bannerHeight;
    CGFloat iconWidth;
    CGFloat iconHeight;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    CGFloat fixHeight;
    
    BOOL _isShow;
    UILabel *showLabel;
}

@property(nonatomic,retain) cloudLoadingView *cloudLoading;
@property(nonatomic,retain) UIScrollView *mainScrollView;
@property(nonatomic,retain) XLCycleScrollView *bannerScrollView;
@property(nonatomic,retain) UIPageControl *pageControll;
@property(nonatomic,retain) UIView *contentView;
@property(nonatomic,retain) NSMutableArray *myImgViewArray;
@property(nonatomic,retain) NSArray *adItems;
@property(nonatomic,retain) NSMutableArray *tagsItems;
@property(nonatomic,retain) NSMutableArray *itemViewArr;
@property (assign, nonatomic) BOOL isEditing;

//添加banner
-(void)addBannerScrollView;

//添加主内容 icon按钮
-(void)addContentView;

//二维码扫描
-(void)goCode;

//热销商品
-(void)hotProduct;

//附近的店
-(void)nearShop;

//创维资讯
-(void)news;

//售后服务
-(void)service;

//应用库
-(void)library;

//网络获取数据
-(void)accessItemService;

//更新数据
-(void)update;

//回归常态
-(void)backNormal;

@end

