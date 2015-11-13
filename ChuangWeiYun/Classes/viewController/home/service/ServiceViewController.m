//
//  ServiceViewController.m
//  cw
//
//  Created by LuoHui on 13-8-31.
//
//

#import "ServiceViewController.h"
#import "UIImageScale.h"
#import <QuartzCore/QuartzCore.h>
#import "OnlineReserveViewController.h"
#import "callSystemApp.h"
#import "Global.h"

@interface ServiceViewController ()

@end

@implementation ServiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"售后服务";
    self.view.backgroundColor = KCWViewBgColor;
    
//	UIImage *telImgNormal = [UIImage imageCwNamed:@"phone.png"];
//    UIImage *telImgClick = [UIImage imageCwNamed:@"phone_click.png"];
//    UIButton *telButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    telButton.frame = CGRectMake(0.0f, 0.0f, telImgNormal.size.width, telImgNormal.size.height);
//    [telButton addTarget:self action:@selector(telAction) forControlEvents:UIControlEventTouchUpInside];
//    [telButton setImage:telImgNormal forState:UIControlStateNormal];
//    [telButton setImage:telImgClick forState:UIControlStateHighlighted];
//    
//    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:telButton];
//    self.navigationItem.rightBarButtonItem = rightBarButton;
//    RELEASE_SAFE(rightBarButton);
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20,320, 30)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor darkTextColor];
//    label.text = @"45分钟高端体验式服务标准";
//    label.textAlignment = UITextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:16.0f];
//    [self.view addSubview:label];
//    [label release];
//    
//    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label.frame) + 20, 320 - 40, 240)];
//    content.backgroundColor = [UIColor clearColor];
//    content.numberOfLines = 0;
//    content.lineBreakMode = UILineBreakModeWordWrap;
//    content.textColor = [UIColor darkGrayColor];
//    content.text = @"      所有上门服务工程师必须为用户提供不低于45分钟的体验式服务，整个服务过程接受广大用户的监督。安时达服务工程师在服务过程中必须完成安装服务、体验服务、保养服务三个部分。\n      安装服务细分为送货、开箱、通电、确定位置、打孔、安装、工具归置等23个步骤，约占25分钟；\n      体验服务为最重要的环节，分为电视伴侣、高清显示、网页浏览、在线影院、3D电影、延长保修及无尘钻孔8次体验，约占15分钟；\n      保养服务知识介绍、安全监测、清洁服务流程约占5分钟，\n      整个服务流程以“45”分钟服务流程卡为标准，以“95105555”服务热线为监督。";
//    content.font = [UIFont systemFontOfSize:13.0f];
//    [self.view addSubview:content];
//    [content release];
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height)];
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.delegate = self;
    [self.view addSubview:mainScrollView];
    
    if (KUIScreenHeight > 480) {
        mainScrollView.contentSize = CGSizeMake(320, 480);
    }else {
        mainScrollView.contentSize = CGSizeMake(320, 540);
    }
    
    UIImage *listImg = [UIImage imageCwNamed:@"pic_list.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - listImg.size.width) * 0.5, 20, listImg.size.width, listImg.size.height)];
    imgView.image = listImg;
    [mainScrollView addSubview:imgView];
    [imgView release];
    
    UIImage *btnImage = [UIImage imageCwNamed:@"blue-button.png"];
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goButton.frame = CGRectMake(15, CGRectGetMaxY(imgView.frame) + 20, 290, 44);
    [goButton setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:30 topCapHeight:15] forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(telAction) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:goButton];
    
    UIImage *telImg = [UIImage imageCwNamed:@"icon_service_call.png"];
    UIImageView *telImgView = [[UIImageView alloc] initWithFrame:CGRectMake(40, (44 - telImg.size.height) * 0.5, telImg.size.width, telImg.size.height)];
    telImgView.image = telImg;
    [goButton addSubview:telImgView];
    [telImgView release];
    
    UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(telImgView.frame) + 5, telImgView.frame.origin.y, goButton.frame.size.width - CGRectGetMaxX(telImgView.frame) - 5,  telImgView.frame.size.height)];
    telLabel.backgroundColor = [UIColor clearColor];
    telLabel.textColor = [UIColor whiteColor];
    telLabel.text = @"立即拨打售后服务热线";
    telLabel.font = [UIFont systemFontOfSize:16.0f];
    [goButton addSubview:telLabel];
    [telLabel release];
    
    UIView *reserveView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(goButton.frame) + 20, 300, 60)];
    reserveView.backgroundColor = [UIColor whiteColor];
    reserveView.layer.masksToBounds = YES;
    reserveView.layer.cornerRadius = 4;
    reserveView.layer.borderColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0].CGColor;
    reserveView.layer.borderWidth = 1;
    [mainScrollView addSubview:reserveView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, reserveView.frame.size.width - 40, 20)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor blackColor];
    label1.text = @"在线预约";
    label1.font = [UIFont systemFontOfSize:15.0f];
    [reserveView addSubview:label1];
    [label1 release];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(label1.frame) + 5, reserveView.frame.size.width - 40, 20)];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor blackColor];
    label2.text = @"提交您的售后服务信息";
    label2.font = [UIFont systemFontOfSize:12.0f];
    [reserveView addSubview:label2];
    [label2 release];
    
    UIImage *img = [UIImage imageCwNamed:@"icon_left.png"];
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(reserveView.frame.size.width - img.size.width - 10, (reserveView.frame.size.height - img.size.height) * 0.5, img.size.width, img.size.height)];
    leftView.image = img;
    [reserveView addSubview:leftView];
    RELEASE_SAFE(leftView);
    
    [reserveView release];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = reserveView.frame;
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:btn];
}

- (void)dealloc
{
    [mainScrollView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- LoginViewDelegate
- (void)loginWithResult:(BOOL)isLoginSuccess
{
    
}

#pragma mark --- methods
- (void)telAction
{
    [callSystemApp makeCall:SALE_SERVICE_PHONE_NUM];
}

- (void)btnAction
{
    //判断是否登录
    if ([Global sharedGlobal].isLogin == YES) {
        NSString *userid = [Global sharedGlobal].user_id;
        
        OnlineReserveViewController *online = [[OnlineReserveViewController alloc] initWithStyle:UITableViewStyleGrouped];
        online.userIdValue = userid;
        [self.navigationController pushViewController:online animated:YES];
        [online release];
    }else {
        LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        login.cwStatusType = StatusTypeMemberLogin;
        [self.navigationController pushViewController:login animated:YES];
        [login release];
    }
}
@end
