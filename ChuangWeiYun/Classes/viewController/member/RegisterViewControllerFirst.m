//
//  RegisterViewControllerFirst.m
//  cw
//
//  Created by yunlai on 13-12-12.
//
//

#import "RegisterViewControllerFirst.h"
#import "RegisterViewController.h"

@interface RegisterViewControllerFirst ()

@end

@implementation RegisterViewControllerFirst
@synthesize progressHUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

static int tag;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"注 册";
    self.view.backgroundColor = [UIColor whiteColor];
    tag = 0;
    
    _userName = [[UITextField alloc]initWithFrame:CGRectMake(10, 20, 300, 40)];
    [_userName setBorderStyle:UITextBorderStyleLine];
    [_userName setTextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]];
    [_userName setKeyboardType:UIKeyboardTypeNumberPad];
    [_userName setBackgroundColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1]];
    [_userName setPlaceholder:@"  请输入您的手机号码"];
    _userName.delegate=self;
    _userName.layer.cornerRadius=3;
    _userName.layer.borderWidth=1;
    _userName.layer.borderColor=[UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1].CGColor;
    [_userName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_userName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:_userName];
    
    UILabel *labelTip = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 300, 40)];
    labelTip.backgroundColor = [UIColor clearColor];
    labelTip.font = [UIFont systemFontOfSize:15];
    labelTip.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:0.6];
    labelTip.text = @"为了验证您的身份，我们将会发送短信验证码";
    [self.view addSubview:labelTip];
    [labelTip release], labelTip = nil;
    
    _nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 115, 300, 40)];
    [_nextBtn setBackgroundColor:[UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1]];
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    _nextBtn.layer.cornerRadius=3;
    [self.view addSubview:_nextBtn];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    [_userName resignFirstResponder];
}

- (void)dealloc
{
    RELEASE_SAFE(_userName);
    RELEASE_SAFE(_nextBtn);
    self.progressHUD = nil;
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextStep{
    [_userName resignFirstResponder];
    
    if (_userName.text.length == 0) {
        
        [self checkProgressHUD:@"手机号码不能为空" andImage:nil];
	}else if (!(_userName.text.length == 11)||![Common phoneNumberChecking:_userName.text]) {
        
        [self checkProgressHUD:@"请输入正确的手机号码" andImage:nil];
	}else{
        if (tag ==0) { //获取成功后不请求
            [self accessAuthCodeService];
        }else{
            RegisterViewController *registers = [[RegisterViewController alloc]init];
            registers.userId = _userName.text;
            [self.navigationController pushViewController:registers animated:YES];
            RELEASE_SAFE(registers);
        }

    }
}

- (void)checkProgressHUD:(NSString *)value andImage:(UIImage *)img{
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = value;
    [self.view addSubview:progressHUDTmp];
    [self.view bringSubviewToFront:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];
    RELEASE_SAFE(progressHUDTmp);
    
}
#pragma mark - UITextFieldDelegate
//限制输入框手机号码11位数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _userName) {
        if (range.location >= 11){
            [self checkProgressHUD:@"请输入11位的手机号码" andImage:nil];
            
            return NO;
        }
        return YES;
    }
       
    return YES;
}

- (void)accessAuthCodeService{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y+120);
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    self.progressHUD.labelText = @"发送中，请稍等...";
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
    
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        _userName.text,@"mobile",
                                        nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_REGISTERAUTHCODE_COMMAND_ID accessAdress:@"member/sendmobileauthcode.do?param=" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        
        int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
        NSLog(@"resultInt=%d",resultInt);
        switch (commandid) {
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
        [self.progressHUD removeFromSuperview];
        
        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self checkProgressHUD:@"网络请求超时，请重试" andImage:nil];
        } else {
            // 当前网络不可用，请重新再试
            
            [self checkProgressHUD:KCWNetNOPrompt andImage:nil];
        }
    }
}

- (void)sendError {
    [Global sharedGlobal].isLogin = NO;
    [Global sharedGlobal].user_id = nil;
    self.progressHUD.hidden = YES;
    [self.progressHUD removeFromSuperview];
    
    [self checkProgressHUD:@"获取验证码失败,请重试" andImage:nil];
}

- (void)sendSuccess:(NSMutableArray*)resultArray {
    tag = 1;
    
    self.progressHUD.hidden = YES;
    [self.progressHUD removeFromSuperview];
    
    RegisterViewController *registers = [[RegisterViewController alloc]init];
    registers.userId = _userName.text;
    [self.navigationController pushViewController:registers animated:YES];
    RELEASE_SAFE(registers);
    
}


@end
