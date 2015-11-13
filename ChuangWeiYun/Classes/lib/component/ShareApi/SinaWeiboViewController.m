//
//  SinaWeiboViewController.m
//  yunPai
//
//  Created by yunlai on 13-7-17.
//
//

#import "SinaWeiboViewController.h"
#import "Common.h"
#import "weibo_userinfo_model.h"
#import "MBProgressHUD.h"

@interface SinaWeiboViewController ()

@property (retain, nonatomic) NSString *accessToken;
@property (retain, nonatomic) NSString *userID;
@property (assign, nonatomic) int expiresTime;
@property (retain, nonatomic) NSString *userName;

@end

@implementation SinaWeiboViewController

@synthesize sinaWeibo;
@synthesize accessToken;
@synthesize userID;
@synthesize expiresTime;
@synthesize userName;
@synthesize delegate;
@synthesize isRequest=_isRequest;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"新浪微博";
    
    cwAppDelegate *appdelegate =  (cwAppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.delegate = self;
    
    sinaWeibo = [[SinaWeibo alloc]initWithAppKey:SinaAppKey appSecret:SinaAppSecret appRedirectURI:SINAredirectUrl andDelegate:self];
    sinaWeibo.superViewController = self;
    [sinaWeibo logIn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [sinaWeibo release], sinaWeibo = nil;
    [accessToken release], accessToken = nil;
    [userID release], userID = nil;
    
    [super dealloc];
}

- (void)writeDataToDB
{
    //userName TEXT,accessToken TEXT, \
    expiresTime INTEGER,weibo_open_time TEXT,secret TEXT,openKey TEXT
    NSDictionary *weiboDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    SINA,@"weiboType",
                                    self.userID,@"uid",
                                    self.userName,@"userName",
                                    self.accessToken,@"accessToken",
                                    [NSNumber numberWithInt: expiresTime],@"expiresTime",
                                    nil];

    weibo_userinfo_model *weiboMod = [[weibo_userinfo_model alloc] init];
    
    weiboMod.where = [NSString stringWithFormat:@"weiboType = '%@'",SINA];
    [weiboMod deleteDBdata];
    
    [weiboMod insertDB:weiboDic];
    
    [weiboMod release], weiboMod = nil;
    
    if (delegate != nil && [delegate respondsToSelector:@selector(oauthSinaSuccessIsFail:)]) {
        [delegate oauthSinaSuccessIsFail:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [self.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:10];
    [progressHUDTmp release];
}

#pragma mark APPlicationDelegate
- (BOOL)sinaHandleCallBack:(NSDictionary *)param
{
    NSURL *url = [param objectForKey:@"url"];
    return [sinaWeibo handleOpenURL:url];
}

#pragma mark - SinaWeiboDelegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate);
    
    [self progressHUD:@"授权中..."];
    
    self.accessToken = sinaWeibo.accessToken;
    self.userID = sinaWeibo.userID;
    self.expiresTime = [sinaWeibo.expirationDate timeIntervalSince1970];
    
    [sinaWeibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.userID, @"uid",nil]
                   httpMethod:@"GET"
                     delegate:self];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(sinaweiboLogInDidCancel:)]) {
            [delegate oauthSinaSuccessIsFail:NO];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    if (delegate != nil && [delegate respondsToSelector:@selector(oauthSinaSuccessIsFail:)]) {
        [delegate oauthSinaSuccessIsFail:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error {}

#pragma mark - SinaWeiboRequestDelegate
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSString *name = [result objectForKey:@"screen_name"];
        self.userName = name;
    }

    [self writeDataToDB];
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if (delegate != nil && [delegate respondsToSelector:@selector(sinaweiboLogInDidCancel:)]) {
        [delegate oauthSinaSuccessIsFail:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
