//
//  CommentViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "NullstatusView.h"
#import "cloudLoadingView.h"
#import "HttpRequest.h"

@interface CommentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,UIScrollViewDelegate,HttpRequestDelegate>
{
    //上部菜单视图
    UIView              *_menuView;
    //商品选择按钮
    UIButton            *_shopBtn;
    //资讯选择按钮
    UIButton            *_messageBtn;
    //菜单选择动画
    UILabel             *_lineLabel;
    //商品评论列表
    UITableView         *_shopTableView;
    //资讯评论列表
    UITableView         *_messageTableView;
    //商品评论列表数据
    NSMutableArray      *_shopCommentArray;
    //资讯评论列表数据
    NSMutableArray      *_msgCommentArray;
    //资讯评论图片数据
    NSMutableDictionary *_msgCommentDic;

    
    //空状态视图
    NullstatusView      *_nullView;

    
    CGFloat picWidth;
    CGFloat picHeight;
    
    //上拉加载更多
    BOOL _isAllowLoadingMore;
    BOOL _loadingMore;
    UIActivityIndicatorView *indicatorView;
    //网络加载等待中
    cloudLoadingView        *cloudLoading;
}
@property(nonatomic ,retain) NSMutableArray      *shopCommentArray;
@property(nonatomic ,retain) NSMutableArray      *msgCommentArray;
@property(nonatomic ,retain) NSMutableDictionary *msgCommentDic;
@property(nonatomic ,retain) cloudLoadingView    *cloudLoading;
@end
