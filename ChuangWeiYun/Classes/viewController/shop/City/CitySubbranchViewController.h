//
//  CitySubbranchViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "SubbranchCell.h"
#import "IconDownLoader.h"
#import "CityChooseViewController.h"
#import "CustomSearchBar.h"

typedef enum
{
    CitySubbranchNormal,        // 默认
    CitySubbranchHomeService,   // 首页便民服务
    CitySubbranchHomeServiceList,
    CitySubbranchHomePreferent, // 首页优惠活动
    CitySubbranchShop,          // 分店
    CitySubbranchMember,        // 会员注册
    CitySubbranchMore,          // 百宝箱留言反馈
    CitySubbranchNearShop,      // 附近的店列表 chenfeng 11.11
}CitySubbranchEnum;

@protocol CitySubbranchViewControllerDelegate;

@interface CitySubbranchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SubbranchCellDelegate, IconDownloaderDelegate,CityChooseViewControllerDelegate,CustomSearchBarDelegate>
{
    UITableView *_tableViewC;
    CustomSearchBar *searchBarC;
    
    NSMutableArray *dataArr;
    
    NSString *cityStr;
    
    CwStatusType cwStatusType;
    CitySubbranchEnum subbranchEnum;
    
    id <CitySubbranchViewControllerDelegate> delegate;
}

@property (retain, nonatomic) UITableView *tableViewC;
@property (retain, nonatomic) CustomSearchBar *searchBarC;
@property (retain, nonatomic) NSMutableArray *dataArr;
@property (retain, nonatomic) NSString *cityStr;
@property (assign, nonatomic) CwStatusType cwStatusType;
@property (assign, nonatomic) CitySubbranchEnum subbranchEnum;
@property (assign, nonatomic) id <CitySubbranchViewControllerDelegate> delegate;
@property (retain, nonatomic) UIButton      *mapShowBtn; //11.11 chenfeng
@property (retain, nonatomic) UIButton      *listShowBtn;//11.11 chenfeng
@end

@protocol CitySubbranchViewControllerDelegate <NSObject>

@optional
- (void)returnCitySubbranchID:(NSString *)shopName shopID:(NSString *)shopID;
- (void)chooseSubbranchInfo:(CitySubbranchEnum)subbranchEnum;

@end