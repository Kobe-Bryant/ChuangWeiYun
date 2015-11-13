//
//  OrderDetailViewController.h
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "PopCancelOrderView.h"
#import "MBProgressHUD.h"
#import "OrderDetailCell.h"
#import "HttpRequest.h"
//#import "OrderListViewController.h"

@protocol OrderListViewDelegate;

@interface OrderDetailViewController : UIViewController<UITableViewDataSource,MBProgressHUDDelegate,PopCancelOrderDelegate,UITableViewDelegate,IconDownloaderDelegate,HttpRequestDelegate>
{
    //预订详情列表
    UITableView               *_tableView;
    //预订详情数据
    NSMutableDictionary       *_shopDic;
    //预订列表数据
    NSMutableDictionary       *_orderlistDic;
    //作废预订视图
    PopCancelOrderView        *_cancelView;
    //背景滑动
    UIScrollView              *_mainScrollView;
    
    CGFloat picWidth;
    CGFloat picHeight;
    //预订ID
    int _orderId;
    //产品ID
    int _productId;
    //选择那行预订
    int _clickIndex;
    
    id<OrderListViewDelegate>    delegate;
    
}
@property(nonatomic,assign) int orderId;
@property(nonatomic,assign) int productId;
@property(nonatomic,assign) int clickIndex;
@property(nonatomic,retain) NSMutableDictionary       *shopDic;
@property(nonatomic,retain) NSMutableDictionary       *orderlistDic;
@property(nonatomic,retain) MBProgressHUD             *progressHUD;
@property(nonatomic,retain) OrderDetailCell           *cancelOrderCell;
@property(nonatomic ,assign) id<OrderListViewDelegate>        delegate;
@end

@protocol OrderListViewDelegate <NSObject>

- (void)orderDelete:(BOOL)isHidden;

@end
