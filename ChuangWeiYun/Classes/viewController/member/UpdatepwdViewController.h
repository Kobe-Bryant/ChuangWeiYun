//
//  UpdatepwdViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "PopUpdatePwdSucceedView.h"

@protocol updatepwdDelegate <NSObject>

- (void)updatepwdSuccess;

@end

@interface UpdatepwdViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UITextFieldDelegate,HttpRequestDelegate>
{
    //用户名输入框
    UITextField *_userName;
    //验证码输入框
    UITextField *_authCode;
    //密码输入框
    UITextField *_userPwd;
    //获取验证码按钮
    UIButton    *_getAuthCodeBtn;
    //提交按钮
    UIButton    *_confirmBtn;
    //主视图
    UIView      *_mainView;
    //输入框表格
    UITableView *_tableView;
    //显示密码按钮
    UIButton    *_showPwdBtn;
    //获取验证码倒计时
    NSTimer     *_timer;
    //是否显示密码
    bool isShowPwd;
    //重置密码代理
    id <updatepwdDelegate> delegate;
    //获取验证码倒计时变量
    int num;
    //重置密码成功后提示框
    PopUpdatePwdSucceedView *_popUpdateView;
}
@property(nonatomic, retain) UITextField   *userName;
@property(nonatomic, retain) UITextField   *userPwd;
@property(nonatomic, retain) UITextField   *authCode;
@property(nonatomic, retain) MBProgressHUD *progressHUD;
@property (nonatomic, assign) id<updatepwdDelegate> delegate;

@end
