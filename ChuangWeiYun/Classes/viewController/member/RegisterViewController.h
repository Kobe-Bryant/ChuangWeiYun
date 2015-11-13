//
//  RegisterViewController.h
//  cw
//
//  Created by yunlai on 13-8-28.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "CitySubbranchViewController.h"
#import "UnderLineLabel.h"

typedef enum _registerBack{
    RegisterBackNomal = 0,
    RegisterBackOrderBack = 1,
    RegisterBackCommentBack = 2,
    
}RegisterBack;

@protocol registerViewDelegate <NSObject>

@optional
- (void)registerSuccess;

// 其他页面判断登录是否成功后返回其他页面
- (void)registerSuccessBackCtl:(RegisterBack)cwBackType;

@end

@interface RegisterViewController : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,CitySubbranchViewControllerDelegate,HttpRequestDelegate, UIAlertViewDelegate>
{
    //用户名输入框
    UITextField *_userName;
    //验证码输入框
    UITextField *_authCode;
    //获取验证码按钮
    UnderLineLabel    *_getAuthCodeBtn;
    //用户密码输入框
    UITextField   *_userPwdField;
    //背景视图
    UIView        *_mainView;
    //输入框表格
    UITableView   *_tableView;
    //注册按钮
    UIButton      *_registerBtn;
    //验证提示框
    MBProgressHUD *_progressHUD;
    //注册代理
    id <registerViewDelegate> delegate;
    
    RegisterBack cwBackType;
    
    //获取验证码倒计时
    NSTimer     *_timer;
    //获取验证码倒计时变量
    int num;
    
}
@property (nonatomic, assign) id<registerViewDelegate> delegate;
@property (nonatomic, retain) NSString      *userId; //发送验证码的手机号码
@property (nonatomic, retain) UITextField   *authCode;
@property (nonatomic, retain) UITextField   *userPwdField;
@property (nonatomic, retain) MBProgressHUD *progressHUD;
@property (nonatomic, assign) RegisterBack  cwBackType;

@end
