//
//  LoginViewController.m
//  cw
//
//  Created by yunlai on 13-8-28.
//
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "Common.h"
#import "Global.h"
#import "system_config_model.h"
#import "UpdatepwdViewController.h"
#import "cwAppDelegate.h"
#import "member_info_model.h"
#import "member_likeshop_model.h"
#import "member_likeinformation_model.h"
#import "UIImageView+LBBlurredImage.h"
#import "NSString+DES.h"
#import "CustomTabBar.h"
#import "RegisterViewControllerFirst.h"

#define kleftwidth 10
#define kcontrolheight 40


@interface LoginViewController ()
{
    UIView *coverView;
}
@end

@implementation LoginViewController

@synthesize userNameField=_userNameField;
@synthesize userPwdField=_userPwdField;
@synthesize mbProgressHUD=_mbProgressHUD;
@synthesize progressHUD=_progressHUD;
@synthesize memberCenter=_memberCenter;
@synthesize headImageView=_headImageView;
@synthesize img=_img;
@synthesize scaleImage=_scaleImage;
@synthesize delegate;
@synthesize cwStatusType;
@synthesize cwBackType;
@synthesize isShowPassWord=_isShowPassWord;

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    if (cwBackType == LoginBackShareBack) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    NSArray *curLocArray = [remember getList];
    RELEASE_SAFE(remember);
    
    
	//进入会员模块判断是否自动登录
    BOOL autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoLogin"];
	if (([Global sharedGlobal].isLogin == YES && [curLocArray count]!=0)  || (autoLogin == YES  && [curLocArray count]!=0)) {

		_memberCenter.view.hidden = NO;
        
		[_memberCenter viewAppearAction];
        
    } else {
        //输入框记录账号和密码
        [self textFeildInitvalue];
       
    }
    
    [_isShowPassWord setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if (cwBackType == LoginBackShareBack) {
//        [self.navigationController setNavigationBarHidden:YES animated:NO];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];

    [self loginView];
    
    if (IOS_7) {
        [Common iosCompatibility:self];
    }
}

//创建视图
- (void)loginView{

    _mainView = [[UIView alloc]initWithFrame:CGRectMake(kleftwidth, 22, 300, 88)];
    [self.view addSubview:_mainView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _mainView.frame.size.width, _mainView.frame.size.height)style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.layer.borderWidth = 0.3;
    _tableView.layer.cornerRadius = 3;
    _tableView.layer.borderColor = [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
    [_mainView addSubview:_tableView];
    
    
    _forgetPwd = [[UIButton alloc]initWithFrame:CGRectMake(210, 115, 100, 25)];
    [_forgetPwd setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [_forgetPwd setBackgroundColor:[UIColor clearColor]];
    [_forgetPwd setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
    [_forgetPwd addTarget:self action:@selector(forgetPwdClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_forgetPwd];
    
    _loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(kleftwidth, 168, 300, kcontrolheight)];
    [_loginBtn setTitle:@"登    录" forState:UIControlStateNormal];
    _loginBtn.layer.cornerRadius = 3;
    [_loginBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1]];
    if (_loginBtn.state == UIControlStateHighlighted) {
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:50/255.0 green:96/255.0 blue:188/255.0 alpha:1]];
    }
    [_loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    _registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(kleftwidth, 245, 300, kcontrolheight)];
    [_registerBtn setTitle:@"免费注册" forState:UIControlStateNormal];
    _registerBtn.layer.cornerRadius = 3;
    if (_registerBtn.state == UIControlStateHighlighted) {
        [_registerBtn setBackgroundColor:[UIColor colorWithRed:132/255.0 green:194/255.0 blue:41/255.0 alpha:1]];
    }
    [_registerBtn setBackgroundColor:[UIColor colorWithRed:152/255.0 green:205/255.0 blue:50/255.0 alpha:1]];
    [_registerBtn addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerBtn];
    
    _memberCenter = [[memberViewController alloc] init];
    _memberCenter.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	_memberCenter.loginCtl = self;
	_memberCenter.delegate = self;
	[self.view addSubview:_memberCenter.view];
    _memberCenter.view.hidden = YES;
    
}


- (void)dealloc
{
    RELEASE_SAFE(_mainView);
    RELEASE_SAFE(_tableView);
    RELEASE_SAFE(_userPwdField);
    RELEASE_SAFE(_userNameField);
    RELEASE_SAFE(_forgetPwd);
    RELEASE_SAFE(_isShowPassWord);
    RELEASE_SAFE(_loginBtn);
    RELEASE_SAFE(_registerBtn);
    RELEASE_SAFE(_memberCenter);
    RELEASE_SAFE(_mbProgressHUD);
    RELEASE_SAFE(_progressHUD);
 
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
#pragma mark - private Method


//是否显示密码
- (void)isShowPassWordMothed{
    [self resign];

    if (!isShowPwd) {
        [_userPwdField setSecureTextEntry:NO];
        [_isShowPassWord setImage:[UIImage imageCwNamed:@"icon_eyes_login.png"] forState:UIControlStateNormal];
        isShowPwd=YES;
    }else{
        [_userPwdField setSecureTextEntry:YES];
        [_isShowPassWord setImage:[UIImage imageCwNamed:@"icon_eyes_login_click.png"] forState:UIControlStateNormal];
        isShowPwd=NO;
    }
}
// 放弃第一响应者
- (void)resign{
    [_userNameField resignFirstResponder];
    [_userPwdField resignFirstResponder];
}

// 忘记密码
- (void)forgetPwdClick{
  
    [self resign];
    UpdatepwdViewController *updatePwdCtl = [[UpdatepwdViewController alloc]init];
    [self.navigationController pushViewController:updatePwdCtl animated:YES];
    RELEASE_SAFE(updatePwdCtl);
}

// 登录
- (void)loginClick{
    [self resign];
    [self loginAction];

}
// 注册
- (void)registerClick{
    [self resign];
    RegisterViewControllerFirst *registerC = [[RegisterViewControllerFirst alloc]init];
    [self.navigationController pushViewController:registerC animated:YES];
    
    RELEASE_SAFE(registerC);
}

// 触摸屏幕隐藏键盘
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self resign];
}

// 提示框
- (void)checkProgressHUD:(NSString *)valueText andImage:(UIImage *)img{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.delegate = self;
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = valueText;
    [self.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];

}
// 登录验证
- (void)loginAction
{
	[self resign];
	
	if (_userNameField.text.length == 0 || _userPwdField.text.length == 0) {

		[self checkProgressHUD:@"帐号和密码不能为空" andImage:nil];
	}else if (!(_userNameField.text.length == 11)) {
	
        [self checkProgressHUD:@"请输入正确的手机号码" andImage:nil];
	}else {
        MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
        progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y);
		self.mbProgressHUD = progressHUDTmp;
		[progressHUDTmp release];
		self.mbProgressHUD.delegate = self;
		self.mbProgressHUD.labelText = @"登录中...";
		[self.view addSubview:self.mbProgressHUD];
		[self.mbProgressHUD show:YES];
        
		[self accessService];
	}
    
    
}
//输入框记录账号和密码
- (void)textFeildInitvalue{
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = nil;
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    NSArray *curArray = [remember getList];
    
    remember.where = nil;
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
    NSArray *curArray2 = [remember getList];
    
    //解密本地密码保存输入框
    if ([curArray2 count]!=0) {
        NSString *decryptUseDES = [NSString decryptUseDES:[[curArray2 objectAtIndex:0]objectForKey:@"value"] key:@"1234567812345678"];
        _userPwdField.text = decryptUseDES;
        _userNameField.text = [[curArray objectAtIndex:0]objectForKey:@"value"];
 
    }
    
    remember.where = nil;
    RELEASE_SAFE(remember);
    
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
                UIImageView *userImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 40, 40)];
                userImgView.image = [UIImage imageCwNamed:@"icon_user_login.png"];
                [cell.contentView addSubview:userImgView];
                
                UILabel *sline = [[UILabel alloc]initWithFrame:CGRectMake(48, 12, 1, 20)];
                sline.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
                [cell.contentView addSubview:sline];
                
				UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(55, 0, 245, 44)];
                self.userNameField = nameText;
				self.userNameField.borderStyle = UITextBorderStyleNone;
                self.userNameField.placeholder = @" 请输入手机号码";
                self.userNameField.delegate=self;
                self.userNameField.tag = 1;
                self.userNameField.font = [UIFont systemFontOfSize:15];
				self.userNameField.backgroundColor =[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
				self.userNameField.keyboardType = UIKeyboardTypeNumberPad;
                [self.userNameField setClearButtonMode:UITextFieldViewModeWhileEditing];
				[self.userNameField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
				[cell.contentView addSubview:self.userNameField];
				RELEASE_SAFE(nameText);
				RELEASE_SAFE(userImgView);
                RELEASE_SAFE(sline);
                
                if (![Common phoneNumberChecking:self.userNameField.text]&&self.userNameField.text.length!=0) {
        
                    [self checkProgressHUD:@"请输入正确的手机号码" andImage:nil];
                }
            }break;
            case 1:
            {
                UIImageView *pwdImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 40, 40)];
                pwdImgView.image = [UIImage imageCwNamed:@"icon_lock_login.png"];
                [cell.contentView addSubview:pwdImgView];
                
                
                UILabel *sline = [[UILabel alloc]initWithFrame:CGRectMake(48, 12, 1, 20)];
                sline.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
                [cell.contentView addSubview:sline];
                
				UITextField *passwordText = [[UITextField alloc] initWithFrame:CGRectMake(55, 0, 245, 44)];
                self.userPwdField = passwordText;
				self.userPwdField.borderStyle = UITextBorderStyleNone;
                self.userPwdField.placeholder = @" 请输入密码";
                self.userPwdField.delegate=self;
                self.userPwdField.font = [UIFont systemFontOfSize:15];
				self.userPwdField.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
                [self.userPwdField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.userPwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
				[cell.contentView addSubview:self.userPwdField];
				self.userPwdField.secureTextEntry = YES;
				RELEASE_SAFE(passwordText);
                RELEASE_SAFE(pwdImgView);
                RELEASE_SAFE(sline);
                
                _isShowPassWord = [[UIButton alloc]initWithFrame:CGRectMake(255, 0, 44, 44)];
                [_isShowPassWord setBackgroundColor:[UIColor clearColor]];
                [_isShowPassWord setImage:[UIImage imageCwNamed:@"icon_eyes_login_click.png"] forState:UIControlStateNormal];
                [_isShowPassWord addTarget:self action:@selector(isShowPassWordMothed) forControlEvents:UIControlEventTouchUpInside];
                [_isShowPassWord setHidden:YES];
                if (_isShowPassWord.hidden == YES) {
                    self.userPwdField.frame = CGRectMake(55, 0, 245, 44);
                }else{
                    self.userPwdField.frame = CGRectMake(55, 0, 210, 44);
                }
                [cell.contentView addSubview:_isShowPassWord];
                isShowPwd = NO;
                
                [self textFeildInitvalue];
            }break;
				
            default:
                break;
        }
    }
	
	return cell;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resign];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.userPwdField) {
        if (_isShowPassWord.hidden == YES) {
            self.userPwdField.frame = CGRectMake(55, 0, 245, 44);
        }else{
            self.userPwdField.frame = CGRectMake(55, 0, 210, 44);
        }
    }
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.userPwdField.text = @"";
    if (textField == self.userNameField) {
        NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"RememberName",@"tag",
                                 @"",@"value",
                                 nil];
        
        system_config_model *remember = [[system_config_model alloc] init];
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
        [remember deleteDBdata];
        
        [remember insertDB:nameDic];
        
        remember.where = nil;
        
        NSDictionary *pwdDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"RememberPassword",@"tag",
                                @"",@"value",
                                nil];
        
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
        [remember deleteDBdata];
        [remember insertDB:pwdDic];
        RELEASE_SAFE(remember);
    }else if(textField == self.userPwdField){
        NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"RememberName",@"tag",
                                 self.userNameField.text,@"value",
                                 nil];
        
        system_config_model *remember = [[system_config_model alloc] init];
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
        [remember deleteDBdata];
        
        [remember insertDB:nameDic];
        
        remember.where = nil;
        
        NSDictionary *pwdDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"RememberPassword",@"tag",
                                @"",@"value",
                                nil];
        
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
        [remember deleteDBdata];
        [remember insertDB:pwdDic];
        RELEASE_SAFE(remember);
    }
    return YES;
}

//限制输入框手机号码11位数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField ==self.userNameField && range.location ==0) {
 
        self.userPwdField.text = @"";
        NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"RememberName",@"tag",
                                 @"",@"value",
                                 nil];
        
        system_config_model *remember = [[system_config_model alloc] init];
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
        [remember deleteDBdata];
        
        [remember insertDB:nameDic];
        
        remember.where = nil;
        
        NSDictionary *pwdDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"RememberPassword",@"tag",
                                @"",@"value",
                                nil];
        
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
        [remember deleteDBdata];
        [remember insertDB:pwdDic];
        RELEASE_SAFE(remember);

    } else if (textField == self.userNameField && textField.text.length!=0) {
        
        if (range.location >= 11){
            
            [self checkProgressHUD:@"请输入11位的手机号码" andImage:nil];
            return NO;
        }
    }
    if (range.location == 0) {
        self.userPwdField.frame = CGRectMake(55, 0, 210, 44);
        _isShowPassWord.hidden = NO;
        
        NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"RememberName",@"tag",
                                 self.userNameField.text,@"value",
                                 nil];
        
        system_config_model *remember = [[system_config_model alloc] init];
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
        [remember deleteDBdata];
        
        [remember insertDB:nameDic];
        
        remember.where = nil;
        
        NSDictionary *pwdDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"RememberPassword",@"tag",
                                @"",@"value",
                                nil];
        
        remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
        [remember deleteDBdata];
        [remember insertDB:pwdDic];
        RELEASE_SAFE(remember);
        
    }
    
    
    return YES;
}

#pragma mark - MenberCenterMainViewControllerDelegate
- (void)actionButtonIndex:(int)index imageView:(UIImageView *)imgView{
	self.headImageView = imgView;
	UIImagePickerController *myPicker  = [[UIImagePickerController alloc] init];
    myPicker.delegate = self;
    myPicker.editing = YES;
    switch (index) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                myPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
				myPicker.allowsEditing = YES;
                [self presentModalViewController:myPicker animated:YES];
            }
            break;
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
                myPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				myPicker.allowsEditing = YES;
                [self presentModalViewController:myPicker animated:YES];
            }
            
            break;
        default:
            break;
    }
	[myPicker release];
}

- (void)updateNavigationTitle{
    [Global sharedGlobal].isLogin = NO;
    self.tabBarController.title = @"登录";
    self.userPwdField.secureTextEntry = YES;
    isShowPwd = NO;
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
	if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
		
		[self dismissModalViewControllerAnimated:YES];
        
	}else {
		
		[picker dismissModalViewControllerAnimated:YES];
    }
    
    [Global sharedGlobal].isChangedImage = YES;
	cwAppDelegate *deleagte = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
	deleagte.headerImage = image;
	self.img = deleagte.headerImage;
    
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.frame = CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight);
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y);
    
    self.mbProgressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.mbProgressHUD.delegate = self;
    self.mbProgressHUD.labelText = @"正在上传...";
    [self.view addSubview:self.mbProgressHUD];
    [self.mbProgressHUD show:YES];
 
    //上传头像时tabbar是不可以点击的
    coverView = [[UIView alloc]initWithFrame:CGRectMake(0, KUIScreenHeight-50, KUIScreenWidth,80)];
    coverView.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:coverView];

    self.scaleImage = [self.img scaleToSize:CGSizeMake(60, 60)];
    NSData *pictureData = UIImageJPEGRepresentation(self.scaleImage,1);

    NSString *reqUrl = @"member/updateimgs.do?param=";
	
    NSLog(@"%@",[Global sharedGlobal].user_id);
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [Global sharedGlobal].user_id,@"user_id",
                                                                                   nil];
    
    [[NetManager sharedManager] accessService:requestDic data:pictureData command:MEMBER_UPDATEPIMAGE_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];

	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - accessService
// 网络请求
- (void)accessService
{
    
    NSString *reqUrl = @"member/login.do?param=";
	
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
    
    NSString *shopID = @"0";
    if ([Global sharedGlobal].shop_id.length > 0) {
        shopID = [Global sharedGlobal].shop_id;
    }
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        _userNameField.text,@"username",
                                           [Common sha1:_userPwdField.text],@"password",
                                                                      token,@"token",
                                                                     shopID,@"shop_id",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:MEMBER_LOGIN_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];

}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {// 判断是否有网络
        
        int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
        switch (commandid) {
            case MEMBER_LOGIN_COMMAND_ID:
            {
                if (resultInt==0) {
                    [self performSelectorOnMainThread:@selector(loginFail) withObject:nil waitUntilDone:NO];
                }else if (resultInt==1){
                    [self performSelectorOnMainThread:@selector(loginSuccess:) withObject:resultArray waitUntilDone:NO];
                }else if (resultInt==2){
                    [self performSelectorOnMainThread:@selector(loginError) withObject:nil waitUntilDone:NO];
                }else if (resultInt==3){
                    [self performSelectorOnMainThread:@selector(userInfoNoExist) withObject:nil waitUntilDone:NO];
                }
                
            }break;
                
            case MEMBER_UPDATEPIMAGE_COMMAND_ID:
            {
                
                if (resultInt==1) {
                
                    //上传成功后开辟子线程更新本地数据库头像路径
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        [self performSelectorOnMainThread:@selector(updateImageSuccess:) withObject:resultArray waitUntilDone:NO];
                        
                        //创建模型
                        member_info_model *memMod = [[member_info_model alloc] init];
                        
                        //更新数据
                        NSString *imagePath = [[resultArray objectAtIndex:0] objectForKey:@"protrait"];
                        NSDictionary *dicImage = [NSDictionary dictionaryWithObjectsAndKeys:imagePath,@"portrait", nil];
                        
                        memMod.where = nil;
                        memMod.where = [NSString stringWithFormat:@"id = %d",self.memberCenter.user_id];
                        NSLog(@"id =%d",self.memberCenter.user_id);
                        NSMutableArray *dbArray = [memMod getList];
                        if ([dbArray count] > 0)
                        {
                            [memMod updateDB:dicImage];
                        }
                        else
                        {
                            [memMod insertDB:dicImage];
                        }
                        
                        [memMod release];
                      
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //主线程更新UI
                            cwAppDelegate *deleagte = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
                            [self.memberCenter.headPortrait setImage:deleagte.headerImage];
                            
                            [self.memberCenter.mainBgView setImage:deleagte.headerImage];
                            [_memberCenter viewAppearAction];
                        });
                    });
                    
                    
                }else {
                    [self performSelectorOnMainThread:@selector(updateImageFail) withObject:nil waitUntilDone:NO];
                }
            }break;
            default:
                break;
        }
	}else{
        [coverView removeFromSuperview];
        [self.mbProgressHUD hide:YES];
        [self.mbProgressHUD removeFromSuperViewOnHide];

        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self checkProgressHUD:@"网络不给力" andImage:nil];
        } else {
            // 当前网络不可用，请重新再试

            [self checkProgressHUD:KCWNetNOPrompt andImage:nil];
        }
        
    }
    
	if (_progressHUD != nil) {
		[_progressHUD removeFromSuperViewOnHide];
	}
}
- (void)updateImageSuccess:(NSMutableArray*)resultArray
{
    [coverView removeFromSuperview];
    [self.mbProgressHUD hide:YES];
    [self.mbProgressHUD removeFromSuperViewOnHide];

    [self checkProgressHUD:@"上传成功" andImage:nil];
    NSLog(@"success");
}

-(void)updateImageFail{
    [coverView removeFromSuperview];
    [self.mbProgressHUD hide:YES];
    [self.mbProgressHUD removeFromSuperViewOnHide];
    [self checkProgressHUD:@"上传头像失败" andImage:nil];
}

- (void)loginSuccess:(NSMutableArray*)resultArray
{
	self.mbProgressHUD.hidden = YES;
	
    [Global sharedGlobal].isLogin = YES;
    //下次程序启动是否自动登录状态判断
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.tabBarController.title = @"会员中心";
    
    NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"RememberName",@"tag",
                                                _userNameField.text,@"value",
                                                                  nil];
    
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    [remember deleteDBdata];
    
    [remember insertDB:nameDic];
    
    remember.where = nil;
    
  
    NSString *encryptUseDES = [NSString encryptUseDES:_userPwdField.text key:@"1234567812345678"];
    
    NSDictionary *pwdDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"RememberPassword",@"tag",
                            encryptUseDES,@"value",
                            nil];
    
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
    [remember deleteDBdata];
    [remember insertDB:pwdDic];

    
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    NSArray *curLocArray = [remember getList];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
    NSArray *curLocArray2 = [remember getList];

    NSLog(@"用户名：%@",[[curLocArray objectAtIndex:0]objectForKey:@"value"]);
    NSLog(@"加密密码：%@",[[curLocArray2 objectAtIndex:0]objectForKey:@"value"]);
    
    NSString *decryptUseDES = [NSString decryptUseDES:[[curLocArray2 objectAtIndex:0]objectForKey:@"value"] key:@"1234567812345678"];

    NSLog(@"解密密码：%@",decryptUseDES);

    member_info_model *memInfo = [[member_info_model alloc]init];
    memInfo.where = [NSString stringWithFormat:@"username = '%@'",[[curLocArray objectAtIndex:0]objectForKey:@"value"]];
    NSArray *infoArray = [memInfo getList];
    RELEASE_SAFE(memInfo);
    if ([infoArray count]!=0) {
        
        self.memberCenter.user_id = [[infoArray objectAtIndex:0] objectForKey:@"id"];
        [Global sharedGlobal].user_id = [[infoArray objectAtIndex:0] objectForKey:@"id"];
        self.memberCenter.userInfoArray = infoArray;
    }
    RELEASE_SAFE(remember);
    
    
	_userNameField.text = nil;
	_userPwdField.text = nil;
	
    //其他页面未登录状态转入，登录成功后返回当前页面
    if (cwStatusType == StatusTypeMemberLogin) {
        if (cwBackType != LoginBackNomal) {
            if ([delegate respondsToSelector:@selector(loginSuccessBackCtl:)]) {
                [delegate loginSuccessBackCtl:self.cwBackType];
            }
        }

        [self.navigationController popViewControllerAnimated:YES];

        return;
    }
    
	if (delegate != nil) {
        
		[self.navigationController popViewControllerAnimated:YES];
		[delegate loginWithResult:YES];
	}
	
    [Global sharedGlobal].isChangedImage = NO;
    self.memberCenter.view.hidden = NO;
    if ([infoArray count]!=0) {
        self.memberCenter.user_id = [[[infoArray objectAtIndex:0]objectForKey:@"id"]intValue];
    }
    
	[self.view bringSubviewToFront:self.memberCenter.view];
	[_memberCenter viewAppearAction];
    
//    //百宝箱留言消息通知 hui  add 11.9
//    int num = [[[infoArray objectAtIndex:0] objectForKey:@"count_message"]intValue];
//    if (num > 0) {
//        UIView *msgTipView = [[UIView alloc] initWithFrame:CGRectMake(302,1,17,17)];
//        msgTipView.tag = 22222;
//        
//        NSArray *arrayViewControllers = self.navigationController.viewControllers;
//        if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
//        {
//            CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
//            [tabViewController.customTab addSubview:msgTipView];
//            
//            if (tabViewController.selectedIndex == 4)
//            {
//                [[tabViewController.viewControllers objectAtIndex:4] viewWillAppear:YES];
//            }
//        }
//        
//        UIImage *msgImg = [UIImage imageCwNamed:@"icon_num.png"];
//        UIImageView *msgImageView = [[UIImageView alloc] initWithImage:msgImg];
//        msgImageView.frame = CGRectMake(0, 0, 17, 17);
//        msgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        [msgTipView addSubview:msgImageView];
//        [msgImageView release];
//        
//        [msgTipView release];
//    }
}

- (void)loginFail
{

	[self userPer];
    [self checkProgressHUD:@"服务器繁忙，登录失败" andImage:nil];
    
}

- (void)loginError{
    
    [self userPer];
    [self checkProgressHUD:@"用户名或密码错误" andImage:nil];
}

- (void)userInfoNoExist{
    [self userPer];
    [self checkProgressHUD:@"用户名不存在" andImage:nil];
}

- (void)userPer{
    [Global sharedGlobal].isLogin = NO;
    [Global sharedGlobal].user_id = nil;
	self.mbProgressHUD.hidden = YES;
    
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(loginWithResult:)]) {
            [delegate loginWithResult:NO];
        }
	}
}

#pragma mark - registerViewDelegate
- (void)registerSuccess{
    if ([delegate respondsToSelector:@selector(loginWithResult:)]) {
        [delegate loginWithResult:YES];
    }
}

@end
