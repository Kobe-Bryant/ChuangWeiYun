//
//  OrderListViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "PopCancelOrderView.h"
#import "MBProgressHUD.h"
#import "NullstatusView.h"
#import "cloudLoadingView.h"
#import "AllOrderCell.h"
#import "HttpRequest.h"
#import "Global.h"
#import "OrderDetailViewController.h"


@interface OrderListViewController : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,PopCancelOrderDelegate,OrderListViewDelegate,HttpRequestDelegate>
{
    //菜单选择视图
    UIView                  *_menuView;
    //所有预订按钮
    UIButton                *_allOrderBtn;
    //取消的预订按钮
    UIButton                *_cancelBtn;
    //菜单选择动画
    UILabel                 *_lineLabel;
    //作废预订按钮
    UIButton                *_cancelOrderBtn;
    //所有预订列表
    UITableView             *_shopTableView;
    //取消预订列表
    UITableView             *_messageTableView;

    //所有预订详情数据
    NSMutableArray          *_orderShopArray;
    //详情预订图片
    NSArray                 *_shopImageArray;
    //取消的预订详情数据
    NSMutableArray          *_cancelShopArray;
    //空状态视图
    NullstatusView          *_nullView;
    NullstatusView          *_nullView2;
    CGFloat picWidth;
    CGFloat picHeight;
    
    //作废预订弹出框
    PopCancelOrderView      *_cancelView;
    
    //上拉加载更多
    BOOL _isAllowLoadingMore;
    BOOL _loadingMore;
    UIActivityIndicatorView *indicatorView;
    //网络加载等待中
    cloudLoadingView        *cloudLoading;
    
    UIButton                *_cancelButton;
    
   
    
}
@property(nonatomic , retain) NSMutableArray     *orderShopArray;
@property(nonatomic , retain) NSArray            *shopImageArray;
@property(nonatomic , retain) NSMutableArray     *cancelShopArray;
@property(nonatomic , retain) MBProgressHUD      *progressHUD;
@property(nonatomic , retain) cloudLoadingView   *cloudLoading;
@property(nonatomic , retain) AllOrderCell       *orderCell;
@property(nonatomic , assign) CwStatusType       StatusType;
@end

