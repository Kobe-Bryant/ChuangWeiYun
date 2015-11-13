//
//  WeiboBindViewController.m
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import "WeiboBindViewController.h"
#import "weibo_userinfo_model.h"

@interface WeiboBindViewController ()

@end

@implementation WeiboBindViewController
@synthesize sinaItems;
@synthesize tencentItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sinaItems=[[NSMutableArray alloc]init];
        tencentItems=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = KCWViewBgColor;
	self.title = @"微博绑定";
	
    
	BOOL isSetSina = [sinaItems count] != 0 ? YES : NO;
    
	BOOL isSetTencent = [tencentItems count] != 0 ? YES : NO;
	
	//新浪微博
	UIImageView *sinaBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 20.0f, 300.0f, 44.0f)];
	sinaBackGround.backgroundColor=[UIColor whiteColor];
	[self.view addSubview:sinaBackGround];
	
	UIImageView *sinaIconImage = [[UIImageView alloc]initWithFrame:CGRectMake(7.0f, 7.0f, 30.0f, 30.0f)];
    UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_sinaweibo_48" ofType:@"png"]];
	sinaIconImage.image = img;
    [img release];
	[sinaBackGround addSubview:sinaIconImage];
	[sinaIconImage release];
	
	UILabel *sinaLabel = [[UILabel alloc]initWithFrame:CGRectMake(45.0f, 0.0f, 150.0f, 44.0f)];
	sinaLabel.font = [UIFont systemFontOfSize:15];
	sinaLabel.tag = 11;
	sinaLabel.textColor = [UIColor colorWithRed:51.0f/255.0 green:51.0f/255.0 blue:51.0f/255.0 alpha:1.0];
	
	sinaLabel.textAlignment = UITextAlignmentLeft;
	sinaLabel.backgroundColor = [UIColor clearColor];
	[sinaBackGround addSubview:sinaLabel];
	[sinaLabel release];
	
	//开关
	_sinaSwitch = [[SevenSwitch alloc]initWithFrame:CGRectMake(240.0f, 27.5f, 50.0f, 27.0f)];
	_sinaSwitch.on = isSetSina;
	[_sinaSwitch addTarget:self action:@selector(sinaSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_sinaSwitch];
	[sinaBackGround release];
	
	//腾讯微博
	UIImageView *tencentBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 84.0f, 300.0f, 44.0f)];
	tencentBackGround.backgroundColor=[UIColor whiteColor];
	[self.view addSubview:tencentBackGround];
	
	UIImageView *tencentIconImage = [[UIImageView alloc]initWithFrame:CGRectMake(7.0f, 7.0f, 30.0f, 30.0f)];
    UIImage *img1 = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_txweibo_48" ofType:@"png"]];
	tencentIconImage.image = img1;
    [img1 release];
	[tencentBackGround addSubview:tencentIconImage];
	[tencentIconImage release];
	
	UILabel *tencentLabel = [[UILabel alloc]initWithFrame:CGRectMake(45.0f, 0.0f, 150.0f, 44.0f)];
	tencentLabel.font = [UIFont systemFontOfSize:15];
	tencentLabel.tag = 22;
	tencentLabel.textColor = [UIColor colorWithRed:51.0f/255.0 green:51.0f/255.0 blue:51.0f/255.0 alpha:1.0];
	
	tencentLabel.textAlignment = UITextAlignmentLeft;
	tencentLabel.backgroundColor = [UIColor clearColor];
	[tencentBackGround addSubview:tencentLabel];
	[tencentLabel release];
	
	//开关
	_tencentSwitch = [[SevenSwitch alloc]initWithFrame:CGRectMake(240.0f, 92.5f, 50.0f, 27.0f)];
	_tencentSwitch.on = isSetTencent;
	[_tencentSwitch addTarget:self action:@selector(tencentSwitchChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_tencentSwitch];
	[tencentBackGround release];

}


- (void)viewWillAppear:(BOOL)animated{
    
    //获取微博设置数据
    weibo_userinfo_model *weibo=[[weibo_userinfo_model alloc]init];
    weibo.where=[NSString stringWithFormat:@"weiboType='%@'",SINA];
    self.sinaItems =[weibo getList];
	
    weibo.where=nil;
    weibo.where=[NSString stringWithFormat:@"weiboType='%@'",TENCENT];
    self.tencentItems =[weibo getList];
    
    [weibo release];
    
	UILabel *sinaLabel = (UILabel *)[self.view viewWithTag:11];
	if (self.sinaItems.count != 0) {
		sinaLabel.text = [[sinaItems objectAtIndex:0] objectForKey:@"userName"];
		_sinaSwitch.on = YES;
	}else {
		sinaLabel.text = @"新浪微博";
		_sinaSwitch.on = NO;
	}
	
	UILabel *tencentLabel = (UILabel *)[self.view viewWithTag:22];
	if (self.tencentItems.count != 0) {
		tencentLabel.text =  [[tencentItems objectAtIndex:0] objectForKey:@"userName"];
		_tencentSwitch.on = YES;
	}else {
		tencentLabel.text = @"腾讯微博";
		_tencentSwitch.on = NO;
	}
}

//sina微博设置
- (void)sinaSwitchChanged:(id)sender
{
	UISwitch *sinaSwitch1 = sender;

    
	if (sinaSwitch1.isOn)
	{
		//授权
		SinaWeiboViewController *sina = [[SinaWeiboViewController alloc] init];
		sina.isRequest = NO;
		[self.navigationController pushViewController:sina animated:YES];
        [sina release], sina = nil;
	}
	else
	{
		//取消授权
		sinaSwitch1.on = NO;
        weibo_userinfo_model *weibo=[[weibo_userinfo_model alloc]init];
        weibo.where=[NSString stringWithFormat:@"weiboType='%@'",SINA];
        [weibo deleteDBdata];
        RELEASE_SAFE(weibo);
        
		UILabel *label = (UILabel *)[self.view viewWithTag:11];
		label.text = @"新浪微博";
		
	}
}

//tencent微博设置
- (void)tencentSwitchChanged:(id)sender
{
	UISwitch *tencentSwitch1 = sender;
	if (tencentSwitch1.isOn)
	{   //授权
		TencentWeiboViewController *tencent = [[TencentWeiboViewController alloc] init];
		tencent.isRequest = NO;
		[self.navigationController pushViewController:tencent animated:YES];
        [tencent release], tencent = nil;
	}
	else
	{   //取消授权
		tencentSwitch1.on = NO;
        
        weibo_userinfo_model *weibo=[[weibo_userinfo_model alloc]init];
        weibo.where=[NSString stringWithFormat:@"weiboType='%@'",TENCENT];
        [weibo deleteDBdata];
        
		UILabel *label = (UILabel *)[self.view viewWithTag:22];
		label.text = @"腾讯微博";
        
        RELEASE_SAFE(weibo);
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)oauthTencentSuccessIsFail:(BOOL)isSuccess{
    NSLog(@"腾讯微博授权失败");
}
- (void)oauthSinaSuccessIsFail:(BOOL)isSuccess{
    NSLog(@"新浪微博授权失败");
}
@end
