//
//  RegisterViewController.m
//  cw
//
//  Created by yunlai on 13-8-28.
//
//

#import "RegisterViewController.h"
#import "memberViewController.h"
#import "RegexKitLite.h"
#import "Encry.h"
#import "Common.h"
#import "NetManager.h"
#import "Global.h"
#import "member_info_model.h"
#import "system_config_model.h"
#import "NSString+DES.h"
#import "PopLoctionHelpView.h"
#import "CityLoction.h"
#import "UnderLineLabel.h"
#import "PopCheckUpdateView.h"

@interface RegisterViewController () <PopUpdateCheckDelegate>
{
    CitySubbranchEnum subbranchEnum;
    PopCheckUpdateView *_popUpdateView;
}
- (void)accessService;
- (BOOL)validateRegexPassword:(NSString *)password;

@end

@implementation RegisterViewController

@synthesize delegate;
@synthesize cwBackType;
@synthesize userPwdField = _userPwdField;
@synthesize authCode = _authCode;
@synthesize progressHUD = _progressHUD;
@synthesize userId=_userId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"注 册";
    self.view.backgroundColor = [UIColor whiteColor];

    [self loginView];
    
    UIImage *image = [[UIImage alloc ]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return" ofType:@"png"]];
    UIButton *barbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    barbutton.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    if (IOS_7) {//chenfeng2014.2.9 add
        barbutton.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
    }
    
    [barbutton addTarget:self action:@selector(popSelf:) forControlEvents:UIControlEventTouchUpInside];
    [barbutton setImage:image forState:UIControlStateNormal];
    UIImage *img = [[UIImage alloc ]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return_click" ofType:@"png"]];
    [barbutton setImage:img forState:UIControlStateHighlighted];
    [image release], image = nil;
    [img release], img = nil;
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:barbutton];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    [barBtnItem release], barBtnItem = nil;
}

- (void)popSelf:(UIButton *)btn
{
    NSString *tipTitle = @"验证码短信可能略有延迟，确定返回？";
    
    if (_popUpdateView == nil) {
        _popUpdateView = [[PopCheckUpdateView alloc] initWithTitle:@"温馨提示" andContent:tipTitle andBtnTitle:@"取消" andTitle:@"确定"];
        _popUpdateView.delegate = self;
    }
    [_popUpdateView addPopupSubview];
}

#pragma mark - PopUpdateCheckDelegate
- (void)OKCheckUpdates
{
    [_popUpdateView closeView];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)loginView{
    
    UILabel *labelTip = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 40)];
    labelTip.backgroundColor = [UIColor clearColor];
    labelTip.font = [UIFont systemFontOfSize:15];
    labelTip.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:0.6];
    labelTip.text = [NSString stringWithFormat:@"包含验证码的短信已发送至%@",self.userId];
    [self.view addSubview:labelTip];
    RELEASE_SAFE(labelTip);
    
    _authCode = [[UITextField alloc]initWithFrame:CGRectMake(10, 50, 300, 40)];
    [_authCode setBorderStyle:UITextBorderStyleLine];
    [_authCode setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]];
    [_authCode setKeyboardType:UIKeyboardTypeNumberPad];
    [_authCode setBackgroundColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1]];
    [_authCode setPlaceholder:@" 输入收到的验证码"];
    _authCode.delegate=self;
    _authCode.layer.cornerRadius=3;
    _authCode.layer.borderWidth=1;
    _authCode.layer.borderColor=[UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
    [_authCode setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_authCode setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:_authCode];
    
//    _getAuthCodeBtn = [[UIButton alloc]initWithFrame:CGRectMake(190, 20, 120, 40)];
//    [_getAuthCodeBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1]];
//    [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//    [_getAuthCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_getAuthCodeBtn addTarget:self action:@selector(getAuthCode) forControlEvents:UIControlEventTouchUpInside];
//    _getAuthCodeBtn.layer.cornerRadius=3;
//    [self.view addSubview:_getAuthCodeBtn];
    
    
//    _mainView = [[UIView alloc]initWithFrame:CGRectMake(10, 70, 300, 88)];
//    [self.view addSubview:_mainView];
//    
//    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height)style:UITableViewStylePlain];
//    _tableView.scrollEnabled = NO;
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.layer.borderWidth = 0.3;
//    _tableView.layer.cornerRadius = 3;
//    _tableView.layer.borderColor = [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
//    [_mainView addSubview:_tableView];
    
    _getAuthCodeBtn = [[UnderLineLabel alloc] initWithFrame:CGRectMake(10, 105, 120, 20)];
    [_getAuthCodeBtn setBackgroundColor:[UIColor clearColor]];
    [_getAuthCodeBtn setTextColor:[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1]];
    _getAuthCodeBtn.font = [UIFont systemFontOfSize:15];
    _getAuthCodeBtn.shouldUnderline = YES;
    _getAuthCodeBtn.text = @"重发验证码";
    _getAuthCodeBtn.highlightedColor = [UIColor clearColor];
    [_getAuthCodeBtn addTarget:self action:@selector(getAuthCode)];
    [self.view addSubview:_getAuthCodeBtn];

    
    _userPwdField = [[UITextField alloc] initWithFrame:CGRectMake(10, 140, 300, 40)];
    _userPwdField.placeholder = @" 请输入密码";
    [_userPwdField setBorderStyle:UITextBorderStyleLine];
    _userPwdField.layer.cornerRadius=3;
    _userPwdField.layer.borderWidth=1;
    _userPwdField.layer.borderColor=[UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
    [_userPwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
    _userPwdField.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    [_userPwdField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:self.userPwdField];
    _userPwdField.secureTextEntry = YES;
    
    
    _registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 210, 300, 40)];
    [_registerBtn setTitle:@"注  册" forState:UIControlStateNormal];
    _registerBtn.layer.cornerRadius = 3;
    [_registerBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1]];
    [_registerBtn addTarget:self action:@selector(registerMember) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerBtn];
    
}

#pragma mark - private method

- (void)getAuthCode{
    [_authCode resignFirstResponder];
    [_userPwdField resignFirstResponder];
//    
//    if (_userName.text.length == 0) {
//        
//        [self checkProgressHUD:@"手机号码不能为空" andImage:nil];
//	}else if (!(_userName.text.length == 11)||![Common phoneNumberChecking:_userName.text]) {
//        
//        [self checkProgressHUD:@"请输入正确的手机号码" andImage:nil];
//	}else{
    
    [_getAuthCodeBtn setUserInteractionEnabled:NO];
        num=30;
        _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateAuthCode) userInfo:nil repeats:YES];
    
        [self accessAuthCodeService];
        
//    }
}

//获取验证码按钮
- (void)updateAuthCode{
    
    NSString *title=[NSString stringWithFormat:@"重发验证码(%d)",num];
    _getAuthCodeBtn.text = title;
    _getAuthCodeBtn.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:0.5];
    if (num==0) {
        [_timer invalidate];
        _timer=nil;
       [_getAuthCodeBtn setUserInteractionEnabled:YES];
        _getAuthCodeBtn.text = @"重发验证码";
        _getAuthCodeBtn.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1];
    }
    --num;
    
}

- (void)registerMember{
    // dufu  add  2013.11.19  备注：是否开启定位功能
    if (![Common isLoctionOpen] || ![Common isLoction]) {
        [Common MsgBox:@"定位未开启" messege:@"请在”设置->隐私->定位服务“中确认“定位”和“创维云GO”是否为开启状态" cancel:@"确定" other:@"帮助" delegate:self];
        return;
    }
    [self finishAction];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_authCode resignFirstResponder];
    [_userPwdField resignFirstResponder];
}

- (void)dealloc
{
    RELEASE_SAFE(_userPwdField);
    RELEASE_SAFE(_authCode);
    RELEASE_SAFE(_registerBtn);
    RELEASE_SAFE(_progressHUD);
    if (_popUpdateView) {
        [_popUpdateView release], _popUpdateView = nil;
    }
    [_timer invalidate];
    _timer=nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
}

- (void)checkProgressHUD:(NSString *)value andImage:(UIImage *)img{
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = value;
    [self.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];
    RELEASE_SAFE(progressHUDTmp);
    
}

- (void)finishAction
{

	[_authCode resignFirstResponder];
	[_userPwdField resignFirstResponder];
    if (_authCode.text.length == 0) {
        
        [self checkProgressHUD:@"验证码不能为空" andImage:nil];
	}else if (!(_authCode.text.length == 6)) {
        
        [self checkProgressHUD:@"请输入6位数的验证码" andImage:nil];
	
	}else if (_userPwdField.text.length == 0) {
        
        [self checkProgressHUD:@"密码不能为空" andImage:nil];
        
    }else if ([self validateRegexPassword:_userPwdField.text] == NO) {
        
        [self checkProgressHUD:@"密码为6-20个英文字母或数字" andImage:nil];
	
    }else {
        [self citySubbranchView:CitySubbranchMember];
    }
        
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        PopLoctionHelpView *helpView = [[PopLoctionHelpView alloc]init];
        [helpView addPopupSubview];
        [helpView release], helpView = nil;
    }
}

- (void)accessAuthCodeService{
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        self.userId,@"mobile",
                                        nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_REGISTERAUTHCODE_COMMAND_ID accessAdress:@"member/sendmobileauthcode.do?param=" delegate:self withParam:nil];
}

- (void)accessService
{
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y+120);
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.delegate = self;
    self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    self.progressHUD.labelText = @"注册中，请稍等...";
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];

    
    NSString *url = @"member/regist.do?param=";
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
    
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         self.userId,@"username",
                                                        [Common sha1:_userPwdField.text],@"password",
                                                        [Global sharedGlobal].shop_id,@"shop_id",
                                                        _authCode.text,@"auth_code",
                                                        token,@"token",
                                                        nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_REGIST_COMMAND_ID accessAdress:url delegate:self withParam:nil];
    
    
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        
        int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
        NSLog(@"resultInt=%d",resultInt);
        switch (commandid) {
            case MEMBER_REGIST_COMMAND_ID:
            {
                if (resultInt == 0) {
                    [self performSelectorOnMainThread:@selector(error) withObject:nil waitUntilDone:NO];
                
                }else if (resultInt == 1) {
                    
                    [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
                    
                }else if (resultInt == 2) {
                    [self performSelectorOnMainThread:@selector(invalid) withObject:nil waitUntilDone:NO];
                
                }else if (resultInt == 3) {
                    [self performSelectorOnMainThread:@selector(isExistName) withObject:nil waitUntilDone:NO];
                    
                }else if (resultInt == 4) {
                    [self performSelectorOnMainThread:@selector(getAuthCodeTime) withObject:nil waitUntilDone:NO];
                    
                }
                else if (resultInt == 5) {
                    [self performSelectorOnMainThread:@selector(authCodeError) withObject:nil waitUntilDone:NO];
                    
                }
                
                else if (resultInt == -1) {
                    
                    [self performSelectorOnMainThread:@selector(CurShopClose) withObject:nil waitUntilDone:NO];
                    
                }
                
            }break;
            case MEMBER_REGISTERAUTHCODE_COMMAND_ID:
            {
                if (resultInt == 0) {
                    [self performSelectorOnMainThread:@selector(sendError) withObject:nil waitUntilDone:NO];
                    
                }else if (resultInt == 1) {
                    
                    [self performSelectorOnMainThread:@selector(sendSuccess:) withObject:resultArray waitUntilDone:NO];
                    
                }
                
            }break;
            default:
                break;
        }
    }else{
        self.progressHUD.hidden = YES;
        if (self.progressHUD!=nil) {
            [self.progressHUD removeFromSuperview];
        }
        
        
        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self checkProgressHUD:@"网络请求超时，请重试" andImage:nil];
        } else {
            // 当前网络不可用，请重新再试
            
            [self checkProgressHUD:KCWNetNOPrompt andImage:nil];
        }
    }
}

- (void)sendError:(NSMutableArray*)resultArray {
    [self exceptionDeals];
    
    [self checkProgressHUD:@"获取验证码超时,请重试" andImage:nil];
}

- (void)sendSuccess:(NSMutableArray*)resultArray {
    
}

- (void)success:(NSMutableArray*)resultArray {
    
	self.progressHUD.hidden = YES;
    if (self.progressHUD!=nil) {
        [self.progressHUD removeFromSuperview];
    }
	
    
    //清除之前会员的表数据
    [Common clearAllDataBase];

    // 获取userid  及  更改状态
    member_info_model *miMod = [[member_info_model alloc]init];
    miMod.where = [NSString stringWithFormat:@"username ='%@'",self.userId];
    NSArray *miArr = [miMod getList];

    if (miArr.count != 0) {
        NSDictionary *dict = [miArr objectAtIndex:0];
        
        [Global sharedGlobal].user_id = [dict objectForKey:@"id"];

    }
    NSLog(@"%@",[Global sharedGlobal].user_id);
    
    RELEASE_SAFE(miMod);
	
    //更改登录状态
    [Global sharedGlobal].isLogin = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //加密插入本地系统配置表
    [self insertConfigTable];
    
    //提示
    UIImage *img = [UIImage imageCwNamed:@"icon_smiling.png"];
    [self checkProgressHUD:@"恭喜您，注册成功" andImage:img];
    
    //跳转页面
    [self performSelector:@selector(jumpCtl) withObject:nil afterDelay:1];
    
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(registerSuccess)]) {
             [delegate registerSuccess];
        }
    }
}


- (void)insertConfigTable{
    NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"RememberName",@"tag",
                             self.userId,@"value",
                             nil];
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    [remember deleteDBdata];
    
    [remember insertDB:nameDic];
    
    remember.where = nil;
    
    //会员密码DES加密后保存
    NSString *encryptUseDES = [NSString encryptUseDES:_userPwdField.text key:@"1234567812345678"];
    
    NSDictionary *pwdDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"RememberPassword",@"tag",
                            encryptUseDES,@"value",
                            nil];

    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
    [remember deleteDBdata];
    
    [remember insertDB:pwdDic];
    
    remember.where = nil;
    
    NSArray *curLocArray = [remember getList];
    [remember release], remember = nil;
    
    NSLog(@"NSZombieEnabled: %s", getenv("NSZombieEnabled"));
    
    NSLog(@"%@name=%@",curLocArray,[[curLocArray objectAtIndex:0]objectForKey:@"value"]);
    NSLog(@"password=%@",[[curLocArray objectAtIndex:1]objectForKey:@"value"]);
}

// 注册成功后页面跳转
- (void)jumpCtl{
    // 其他页面转登录界面的返回
    NSArray *arr = self.navigationController.viewControllers;
    NSLog(@"[arr count]====%d",[arr count]);

    if ([arr count] == 2 || [arr count] == 3 ) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        return;
    }else if ([arr count] >= 4){
        [self.navigationController popToViewController:[arr objectAtIndex:arr.count-3] animated:YES];
        return;
    }
}

- (void)error
{
    [self exceptionDeals];
    
    [self checkProgressHUD:@"注册失败,请重试" andImage:nil];
}

- (void)invalid
{
    [self exceptionDeals];
    
    [self checkProgressHUD:@"非法参数，请重试" andImage:nil];
}

- (void)isExistName
{
    [self exceptionDeals];
    
    [self checkProgressHUD:@"该用户名已存在，请重新注册" andImage:nil];
    
}


- (void)getAuthCodeTime
{
    [self exceptionDeals];
    
    [self checkProgressHUD:@"验证码使用超时，请重新获取" andImage:nil];
    
}

- (void)authCodeError
{
    [self exceptionDeals];
    
    [self checkProgressHUD:@"验证码错误，请重新获取" andImage:nil];
    
}

- (void)CurShopClose{
    //注册的分店已关闭提示用户
    [self exceptionDeals];
    
    [self checkProgressHUD:@"注册不成功" andImage:nil];
    
}


- (void)exceptionDeals{
    self.progressHUD.hidden = YES;
	[self.progressHUD removeFromSuperview];
    
    [Global sharedGlobal].isLogin = NO;
    [Global sharedGlobal].user_id = nil;
}

- (BOOL)validateRegexPassword:(NSString *)password
{
    if (!password) {
        return FALSE;
    }
    return [password isMatchedByRegex:@"\\b[a-zA-Z0-9]{6,20}\\b"];
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.contentView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
		switch (indexPath.row) {
            case 0:
            {
//                UIImageView *userImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 40, 40)];
//                userImgView.image = [UIImage imageCwNamed:@"icon_user_login.png"];
//                [cell.contentView addSubview:userImgView];
                
//				UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
//                self.authCode = nameText;
//				self.authCode.borderStyle = UITextBorderStyleNone;
//                self.authCode.placeholder = @" 请输入手机验证码";
//                self.authCode.delegate = self;
//                [self.authCode setClearButtonMode:UITextFieldViewModeWhileEditing];
//				self.authCode.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
//				self.authCode.keyboardType = UIKeyboardTypeNumberPad;
//				[self.authCode setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//				[cell.contentView addSubview:self.authCode];
//				RELEASE_SAFE(nameText);
//				RELEASE_SAFE(userImgView);
            }break;
            case 1:
            {
//                UIImageView *pwdImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 40, 40)];
//                pwdImgView.image = [UIImage imageCwNamed:@"icon_lock_login.png"];
//                [cell.contentView addSubview:pwdImgView];
                
//				UITextField *passwordText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
//                self.userPwdField = passwordText;
//				self.userPwdField.borderStyle = UITextBorderStyleNone;
//                self.userPwdField.placeholder = @" 请输入您的密码";
//                [self.userPwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
//				self.userPwdField.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
//                [self.userPwdField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//				[cell.contentView addSubview:self.userPwdField];
//				self.userPwdField.secureTextEntry = YES;
//				RELEASE_SAFE(passwordText);
//                RELEASE_SAFE(pwdImgView);
                
                
            }break;
				
            default:
                break;
        }
    }
	
	return cell;
}

#pragma mark - UITextFieldDelegate
//限制输入框手机号码11位数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField == _authCode) {
        if (range.location >= 6){
            [self checkProgressHUD:@"请输入6位的手机验证码" andImage:nil];
            
            return NO;
        }
        return YES;
    }
    
    return YES;
}

// 切换分店选择页
- (void)citySubbranchView:(CitySubbranchEnum)asubbranchEnum
{
    if ([Global sharedGlobal].shop_id.length == 0) {
        CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
        citySubbranch.delegate = self;
        citySubbranch.cityStr = [Global sharedGlobal].currCity;
        citySubbranch.subbranchEnum = asubbranchEnum;
        citySubbranch.cwStatusType = StatusTypeAPP;
        [self.navigationController pushViewController:citySubbranch animated:YES];
        [citySubbranch release], citySubbranch = nil;
       
    } else {
        [self accessService];
    }
}

// 切换分店选择页伪托
#pragma mark - CitySubbranchViewControllerDelegate
- (void)chooseSubbranchInfo:(CitySubbranchEnum)asubbranchEnum
{
    subbranchEnum = asubbranchEnum;
    [self.navigationController popViewControllerAnimated:YES];
    [self accessService];
}

@end
