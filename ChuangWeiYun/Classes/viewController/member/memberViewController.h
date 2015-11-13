//
//  memberViewController.h
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "IconDownLoader.h"

@class LoginViewController;

@protocol memberCenterControllerDelegate <NSObject>

- (void)actionButtonIndex:(int)index imageView:(UIImageView *)imgView;

- (void)updateNavigationTitle;

@end


@interface memberViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,UIGestureRecognizerDelegate,IconDownloaderDelegate>
{
    //主视图上部背景图片
    UIImageView  *_mainBgView;
    //会员头像
    UIImageView  *_headPortrait;
    //会员中心下部列表
    UITableView  *_tableView;
    //会员中心背景滚动视图
    UIScrollView *_mainScrollView;
    //赞按钮
    UIButton     *_likesBtn;
    //评论按钮
    UIButton     *_commentBtn;
    //预订按钮
//    UIButton     *_orderlistBtn;
    //注销账号
    UIButton     *_cancelBtn;
    //用户名
    UILabel      *_userName;
    //赞总数
    UILabel      *_likesNum;
    //评论总数
    UILabel      *_commentNum;
    //预订总数
//    UILabel      *_orderNum;
    //用户信息数组
    NSArray      *_userInfoArray;
    //登录视图控制器
    LoginViewController *_loginCtl;
    //图片网络下载类
    IconDownLoader      *_iconDownLoad;
    NSMutableDictionary *_imageDownloadsInProgress;
    NSMutableArray      *_imageDownloadsInWaiting;
    //会员中心代理
    id <memberCenterControllerDelegate> delegate;
    
    //会员ID
    int _user_id;
    //图片宽高
    CGFloat picWidth;
    CGFloat picHeight;
}
@property(nonatomic, retain) UITableView         *tableView;
@property(nonatomic, retain) UIImageView         *headPortrait;
@property(nonatomic, retain) UIImageView         *mainBgView;
@property(nonatomic, retain) LoginViewController *loginCtl;
@property(nonatomic, retain) MBProgressHUD       *mbProgressHUD;
@property(nonatomic, retain) IconDownLoader      *iconDownLoad;
@property(nonatomic, assign) id <memberCenterControllerDelegate> delegate;
@property(nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic, retain) NSMutableArray      *imageDownloadsInWaiting;
@property(nonatomic, assign) int user_id;
@property(nonatomic, retain) NSArray             *userInfoArray;

-(void)viewAppearAction;

@end
