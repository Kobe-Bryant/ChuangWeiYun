//
//  LikelistViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "MBProgressHUD.h"
#import "NullstatusView.h"
#import "cloudLoadingView.h"
#import "HttpRequest.h"
#import "ShopDetailsViewController.h"
#import "InformationDetailViewController.h"

@interface LikelistViewController : UIViewController<UITableViewDataSource,MBProgressHUDDelegate,UITableViewDelegate,IconDownloaderDelegate,HttpRequestDelegate,ShopDetailsViewControllerDelegate,InformationDetailViewDelegate>
{
    //赞中菜单视图
    UIView              *_menuView;
    //商品选择按钮
    UIButton            *_shopBtn;
    //资讯选择按钮
    UIButton            *_messageBtn;
    //菜单选择动画
    UILabel             *_lineLabel;
    //商品展示列表
    UITableView         *_shopTableView;
    //资讯展示列表
    UITableView         *_messageTableView;
    //会员ID
    int _userId;
    //商品喜欢列表数据
    NSMutableArray      *_shoplikeArray;
    //资讯喜欢列表数据
    NSMutableArray      *_msglikeArray;
    //资讯喜欢所有数据
    NSMutableDictionary *_msglikeDic;
//    //资讯喜欢的所有资讯数据数据
//    NSMutableArray      *_allMsglikeArray;
//    //资讯喜欢的所有商品数据数据
//    NSMutableArray      *_allShoplikeArray;
    
    //提示框
    MBProgressHUD       *_progressHUD;
    
    CGFloat picWidth;
    CGFloat picHeight;
    
    //是否允许加载更多
    BOOL _isAllowLoadingMore;
    //加载更多中
    BOOL _loadingMore;
    //加载更多缓冲控件
    UIActivityIndicatorView *indicatorView;
    //网络加载等待中
    cloudLoadingView        *cloudLoading;
    
    //空状态视图
    NullstatusView  *_nullView;
    
}
@property(nonatomic ,assign) int countlikes;
@property(nonatomic ,retain) NSMutableArray      *shoplikeArray;
@property(nonatomic ,retain) NSMutableArray      *msglikeArray;
@property(nonatomic ,retain) NSMutableDictionary *msglikeDic;
@property(nonatomic ,retain) MBProgressHUD       *progressHUD;
@property(nonatomic ,retain) NSMutableArray      *allMsglikeArray;
@property(nonatomic ,retain) NSMutableArray      *allShoplikeArray;
@property(nonatomic ,retain) cloudLoadingView    *cloudLoading;
@end
