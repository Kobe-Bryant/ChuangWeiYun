//
//  LoginViewController.h
//  cw
//
//  Created by yunlai on 13-8-28.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CmdOperation.h"
#import "Global.h"
#import "HttpRequest.h"
#import "memberViewController.h"
#import "RegisterViewController.h"

typedef enum _loginBack{
    LoginBackNomal = 0,
    LoginBackOrderBack      = 1,    // 预订登录
    LoginBackCommentBack    = 2,    // 评论登录
    LoginBackShareBack      = 3,    // 分享登录
    LoginBackJoinBack       = 4,    // 优惠活动我要参加登录
    
}LoginBack;

@protocol LoginViewDelegate <NSObject>

@optional
- (void)loginWithResult:(BOOL)isLoginSuccess;
// 其他页面判断登录是否成功后返回其他页面
- (void)loginSuccessBackCtl:(LoginBack)cwBackType;

@end


@interface LoginViewController : UIViewController<MBProgressHUDDelegate,memberCenterControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UINavigationBarDelegate,registerViewDelegate,UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,HttpRequestDelegate>
{
    //用户名输入框
    UITextField *_userNameField;
    //密码输入框
    UITextField *_userPwdField;
    //背景视图
    UIView      *_mainView;
    //输入框表格
    UITableView *_tableView;
    //是否显示密码
    UIButton    *_isShowPassWord;
    //忘记密码
    UIButton    *_forgetPwd;
    //登录
    UIButton    *_loginBtn;
    //注册
    UIButton    *_registerBtn;
    
    bool isShowPwd;
    //验证提示框
    MBProgressHUD *_mbProgressHUD;
	MBProgressHUD *_progressHUD;
    //会员中心视图
    memberViewController *_memberCenter;
    //登录代理
    id <LoginViewDelegate> delegate;
    //其他页面转入的状态类型判断
    CwStatusType cwStatusType;
    
    LoginBack cwBackType;
}

@property (nonatomic, retain) UITextField   *userNameField;
@property (nonatomic, retain) UITextField   *userPwdField;
@property (nonatomic, retain) UIButton      *isShowPassWord;
@property (nonatomic, retain) UIImageView   *headImageView;
@property (nonatomic, retain) UIImage       *img;
@property (nonatomic, retain) UIImage       *scaleImage;
@property (nonatomic, retain) MBProgressHUD *mbProgressHUD;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
@property (nonatomic, assign) CwStatusType  cwStatusType;
@property (nonatomic, retain) memberViewController *memberCenter;
@property (nonatomic, assign) id<LoginViewDelegate> delegate;
@property (nonatomic, assign) LoginBack cwBackType;

@end
