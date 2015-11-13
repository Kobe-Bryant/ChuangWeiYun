//
//  UpdatepwdViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "UpdatepwdViewController.h"
#import "MBProgressHUD.h"
#import "RegexKitLite.h"
#import "Common.h"
#import "Global.h"
#import "member_info_model.h"
#import "system_config_model.h"
#import "PopUpdatePwdSucceedView.h"
#import "NSString+DES.h"

@interface UpdatepwdViewController ()

@end

@implementation UpdatepwdViewController
@synthesize userName = _userName;
@synthesize userPwd = _userPwd;
@synthesize authCode = _authCode;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"重置密码";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLoadView];
    
    _popUpdateView = [[PopUpdatePwdSucceedView alloc]init];
 
}
//视图创建
- (void)createLoadView{
    _userName = [[UITextField alloc]initWithFrame:CGRectMake(10, 20, 170, 40)];
    [_userName setBorderStyle:UITextBorderStyleLine];
    [_userName setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]];
    [_userName setKeyboardType:UIKeyboardTypeNumberPad];
    [_userName setBackgroundColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1]];
    [_userName setPlaceholder:@" 请输入手机号码"];
    _userName.delegate=self;
    _userName.layer.cornerRadius=3;
    _userName.layer.borderWidth=1;
    _userName.layer.borderColor=[UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
    [_userName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_userName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:_userName];
    
    _getAuthCodeBtn = [[UIButton alloc]initWithFrame:CGRectMake(190, 20, 120, 40)];
    [_getAuthCodeBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1]];
    [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getAuthCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getAuthCodeBtn addTarget:self action:@selector(getAuthCode) forControlEvents:UIControlEventTouchUpInside];
    _getAuthCodeBtn.layer.cornerRadius=3;
    [self.view addSubview:_getAuthCodeBtn];
    
    _mainView = [[UIView alloc]initWithFrame:CGRectMake(10, 80, 300, 88)];
    [self.view addSubview:_mainView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height)style:UITableViewStylePlain];
    _tableView.scrollEnabled=NO;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.layer.borderWidth=0.3;
    _tableView.layer.cornerRadius=3;
    _tableView.layer.borderColor=[UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
    [_mainView addSubview:_tableView];
    
    _confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 185, 300, 44)];
    _confirmBtn.layer.cornerRadius=3;
    [_confirmBtn setTitle:@"确  认" forState:UIControlStateNormal];
    [_confirmBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1]];
    [_confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmBtn];
    
}

- (void)dealloc
{
    RELEASE_SAFE(_userName);
    RELEASE_SAFE(_authCode);
    RELEASE_SAFE(_userPwd);
    RELEASE_SAFE(_getAuthCodeBtn);
    RELEASE_SAFE(_confirmBtn);
    RELEASE_SAFE(_mainView);
    RELEASE_SAFE(_tableView);
    RELEASE_SAFE(_showPwdBtn);
    RELEASE_SAFE(_popUpdateView);
    [_timer invalidate];
    _timer=nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private method
- (void)getAuthCode{
    [_userName resignFirstResponder];

    if (_userName.text.length == 0) {
        
        [self checkProgressHUD:@"手机号码不能为空" andImage:nil];
	}else if (!(_userName.text.length == 11)||![Common phoneNumberChecking:_userName.text]) {
        
        [self checkProgressHUD:@"请输入正确的手机号码" andImage:nil];
	}else{
        
        _getAuthCodeBtn.enabled=NO;
        _getAuthCodeBtn.backgroundColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.9];
        num=30;
        _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateAuthCode) userInfo:nil repeats:YES];
        
        [self accessAuthCodeService];
       
    }
}
//提交
- (void)confirm{
    [self finishAction];
}

- (void)checkProgressHUD:(NSString *)value andImage:(UIImage *)img{
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center=CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = value;
    [self.view addSubview:progressHUDTmp];
    [self.view bringSubviewToFront:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];
    RELEASE_SAFE(progressHUDTmp);
    
}

//获取验证码按钮
- (void)updateAuthCode{

    NSString *title=[NSString stringWithFormat:@"重新获取( %d )",num];
    [_getAuthCodeBtn setTitle:title forState:UIControlStateNormal];
    if (num==0) {
        [_timer invalidate];
        _timer=nil;
        _getAuthCodeBtn.enabled=YES;
        [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _getAuthCodeBtn.backgroundColor=[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1];
    }
    --num;
    
}
//输入框验证
- (void)finishAction
{
	[_userName resignFirstResponder];
	[_userPwd resignFirstResponder];
    
	if (self.authCode.text.length == 0 || _userPwd.text.length == 0) {
        
        [self checkProgressHUD:@"验证码和密码不能为空" andImage:nil];
	}
    else if (self.userName.text.length == 0) {
        
        [self checkProgressHUD:@"请输入正确的手机号码" andImage:nil];
	}
    else if (!(self.authCode.text.length == 6)) {
	
        [self checkProgressHUD:@"请输入正确的验证码" andImage:nil];
	}
    else if ([self validateRegexPassword:_userPwd.text] == NO) {

        [self checkProgressHUD:@"密码为6-20个英文字母或数字" andImage:nil];
	} else {
        //网络请求
		[self accessService];
		
		MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
        progressHUDTmp.center=CGPointMake(self.view.center.x, self.view.center.y+120);
		self.progressHUD = progressHUDTmp;
		[progressHUDTmp release];
		self.progressHUD.delegate = self;
		self.progressHUD.labelText = @"修改中...";
		[self.view addSubview:self.progressHUD];
		[self.view bringSubviewToFront:self.progressHUD];
		[self.progressHUD show:YES];
	}
}
//密码正则表达式
- (BOOL)validateRegexPassword:(NSString *)password
{
    if (!password) {
        return FALSE;
    }
    return [password isMatchedByRegex:@"\\b[a-zA-Z0-9]{6,20}\\b"];
}

//是否显示密码
- (void)isShowPass{
    [_userPwd resignFirstResponder];
    [_userName resignFirstResponder];
    
    if (!isShowPwd) {
        [self.userPwd setSecureTextEntry:NO];
        [_showPwdBtn setImage:[UIImage imageCwNamed:@"icon_eyes_login.png"] forState:UIControlStateNormal];
        isShowPwd=YES;
    }else{
        [_showPwdBtn setImage:[UIImage imageCwNamed:@"icon_eyes_login_click.png"] forState:UIControlStateNormal];
        [self.userPwd setSecureTextEntry:YES];
        isShowPwd=NO;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_userPwd resignFirstResponder];
    [_userName resignFirstResponder];
    [self.authCode resignFirstResponder];
}

//限制输入框手机号码11位数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==self.userName) {
        if (range.location >= 11){
            [self checkProgressHUD:@"请输入11位的手机号码" andImage:nil];
            return NO;
        }
        return YES;
    }else if(textField==self.authCode){
        if (range.location > 6){
            return NO;
        }else{
            return YES;
        }
    }else{
    
        return YES;
    }
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
		cell.contentView.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
		switch (indexPath.row) {
            case 0:
            {
                
				_authCode = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 285, 44)];
				_authCode.borderStyle = UITextBorderStyleNone;
                _authCode.placeholder = @" 请输入验证码";
                _authCode.borderStyle = UITextBorderStyleNone;
                [_authCode setClearButtonMode:UITextFieldViewModeWhileEditing];
				_authCode.backgroundColor =[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
				_authCode.keyboardType = UIKeyboardTypeNumberPad;
				[_authCode setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
				[cell.contentView addSubview:_authCode];
		
				
            }break;
            case 1:
            {
				UITextField *passwordText = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 255, 44)];
                self.userPwd=passwordText;
				self.userPwd.borderStyle = UITextBorderStyleNone;
                self.userPwd.placeholder = @" 请输入密码";
                [self.userPwd setClearButtonMode:UITextFieldViewModeWhileEditing];
				self.userPwd.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
                [self.userPwd setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
				[cell.contentView addSubview:self.userPwd];
				self.userPwd.secureTextEntry = YES;
                isShowPwd=NO;
				RELEASE_SAFE(passwordText);
                
                _showPwdBtn=[[UIButton alloc]initWithFrame:CGRectMake(255, 0, 44, 44)];
                _showPwdBtn.backgroundColor=[UIColor clearColor];
                [_showPwdBtn setImage:[UIImage imageCwNamed:@"icon_eyes_login_click.png"] forState:UIControlStateNormal];
                [_showPwdBtn addTarget:self action:@selector(isShowPass) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:_showPwdBtn];
                
                
                
            }break;
				
            default:
                break;
        }
    }
	
	return cell;
}
#pragma mark - accessService

- (void)accessAuthCodeService{
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                _userName.text,@"mobile",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_AUTHCODE_COMMAND_ID accessAdress:@"member/generateauthcode.do?param=" delegate:self withParam:nil];
}

- (void)accessService{
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                _userName.text,@"mobile",
                                             [Common sha1:self.userPwd.text],@"password",
                                                         self.authCode.text,@"auth_code",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_UPDATEPWD_COMMAND_ID accessAdress:@"member/updatepw.do?param=" delegate:self withParam:nil];
    
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        
        int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
        NSLog(@"resultInt=%d",resultInt);
        switch (commandid) {
            case MEMBER_AUTHCODE_COMMAND_ID:
            {
                if (resultInt == 0) {
                    [self performSelectorOnMainThread:@selector(getAuthCodeError) withObject:nil waitUntilDone:NO];
                    
                }else if(resultInt == 1){
                    
                    [self performSelectorOnMainThread:@selector(getAuthCodeSuccess) withObject:nil waitUntilDone:NO];
                }else if(resultInt == 3){
                    
                    [self performSelectorOnMainThread:@selector(mobile) withObject:nil waitUntilDone:NO];
                }
                
            }break;
            case MEMBER_UPDATEPWD_COMMAND_ID:
            {
                if (resultInt == 0) {
                    [self performSelectorOnMainThread:@selector(error) withObject:nil waitUntilDone:NO];
                    
                }else if (resultInt == 1) {
                    
                    [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
                    
                }else if (resultInt == 3) {
                    
                    [self performSelectorOnMainThread:@selector(authError) withObject:nil waitUntilDone:NO];
                    
                }
                
            }break;
            default:
                break;
        }

    }else{
        
        UIImage *img = [UIImage imageCwNamed:@"icon_tip_normal.png"];
        
        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self checkProgressHUD:@"网络不给力" andImage:img];
        } else {
            // 当前网络不可用，请重新再试
            
            [self checkProgressHUD:KCWNetNOPrompt andImage:img];
        }
        
    }
}

// 获取验证码失败
- (void)getAuthCodeError {
    
    [Global sharedGlobal].isLogin = NO;
    [Global sharedGlobal].user_id = nil;
    
    [self checkProgressHUD:@"获取验证码失败" andImage:nil];
    
}
// 获取验证码成功
- (void)getAuthCodeSuccess{
 
}

- (void)mobile{
    
    [self checkProgressHUD:@"该手机号码还未注册会员，请注册登录" andImage:nil];

}

- (void)success:(NSMutableArray *)resultArray {
	self.progressHUD.hidden = YES;
	[self.progressHUD removeFromSuperview];
	
    [Global sharedGlobal].isLogin=NO;
    //下次程序启动是否自动登录状态判断
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //修改成功后弹出提示框
	[_popUpdateView addPopupSubview];
    

    [Global sharedGlobal].user_id = _userName.text;
    
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where=nil;
    
    NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"RememberName",@"tag",
                             _userName.text,@"value",
                             nil];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];

    [remember deleteDBdata];
    [remember insertDB:nameDic];
    //会员密码DES加密后保存修改
    NSString *encryptUseDES=[NSString encryptUseDES:_userPwd.text key:@"1234567812345678"];
    
    NSDictionary *pwdDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"RememberPassword",@"tag",
                            encryptUseDES,@"value",
                            nil];
    remember.where=nil;
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];

    [remember deleteDBdata];
    [remember insertDB:pwdDic];
    
    RELEASE_SAFE(remember);
    
    
    [self jumpCtl];
    
    if (delegate != nil) {
        [delegate updatepwdSuccess];
    }
}

- (void)jumpCtl{
    NSArray *arr = self.navigationController.viewControllers;
    NSLog(@"[arr count]====%d",[arr count]);
    if ([arr count] == 2 || [arr count] == 3) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }else if ([arr count] >= 4){
        [self.navigationController popToViewController:[arr objectAtIndex:arr.count-3] animated:YES];
        return;
    }
}

- (void)error
{
    [self errorHanding];

    [self checkProgressHUD:@"密码修改失败" andImage:nil];
}

- (void)authError{
    
    [self errorHanding];
    
    [self checkProgressHUD:@"验证码错误，密码重置失败" andImage:nil];
  
}

- (void)errorHanding{
    self.progressHUD.hidden = YES;
	[self.progressHUD removeFromSuperview];
    
    [Global sharedGlobal].isLogin = NO;
    [Global sharedGlobal].user_id = nil;
}

@end
