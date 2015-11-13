//
//  memberViewController.m
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import "memberViewController.h"
#import "MemberCenterCell.h"
#import "LikelistViewController.h"
#import "CommentViewController.h"
#import "OrderListViewController.h"
#import "UserInfoViewController.h"
#import "PreactivitylistViewController.h"
#import "AddressViewController.h"
#import "AfterServiceViewController.h"
#import "UIImageView+LBBlurredImage.h"
#import "cwAppDelegate.h"
#import "MBProgressHUD.h"
#import "Global.h"
#import "LoginViewController.h"
#import "imageDownLoadInWaitingObject.h"
#import "downloadParam.h"
#import "system_config_model.h"
#import "member_info_model.h"
#import "member_likeinformation_model.h"
#import "member_likeshop_model.h"
#import "CouponsViewController.h"
#import "AddressViewController.h"
#import "ChooseAddressViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "IconPictureProcess.h"
#import "NSString+DES.h"

@interface memberViewController ()

@end

@implementation memberViewController

@synthesize delegate;
@synthesize tableView = _tableView;
@synthesize loginCtl =_loginCtl;
@synthesize mbProgressHUD = _mbProgressHUD;
@synthesize iconDownLoad = _iconDownLoad;
@synthesize headPortrait = _headPortrait;
@synthesize imageDownloadsInProgress = _imageDownloadsInProgress;
@synthesize imageDownloadsInWaiting = _imageDownloadsInWaiting;
@synthesize user_id = _user_id;
@synthesize mainBgView = _mainBgView;

#pragma mark - lifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _userInfoArray = [[NSArray alloc]init];
        
        picHeight = 30.0f;
        picWidth = 30.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageDownloadsInWaiting = [[NSMutableArray alloc]init];
    _imageDownloadsInProgress = [[NSMutableDictionary alloc]init];
    
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    
    [self createMemberView];
}

//创建视图
- (void)createMemberView{
    
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)];
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.contentSize = CGSizeMake(KUIScreenWidth, KUIScreenHeight);
    _mainScrollView.scrollEnabled = NO;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainScrollView];
    
    
    if (self.view.frame.size.height < 500.f)
    {
        _mainScrollView.contentSize=CGSizeMake(KUIScreenWidth, KUIScreenHeight+80);
        _mainScrollView.scrollEnabled=YES;
    }
    
    _mainBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 150)];
    [_mainBgView setImage:[UIImage imageCwNamed:@"bg_member.png"]];
    [_mainBgView setContentMode:UIViewContentModeScaleAspectFill];
    [_mainBgView setClipsToBounds:YES];
    _mainBgView.userInteractionEnabled = YES;
    [_mainScrollView addSubview:_mainBgView];
    
    CGFloat bgFloat = _mainBgView.frame.size.height;
    //会员头像
    _headPortrait = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 70, 70)];
    _headPortrait.userInteractionEnabled = YES;
    _headPortrait.layer.masksToBounds = YES;
    _headPortrait.clipsToBounds = YES;
    _headPortrait.layer.cornerRadius = 35;
    _headPortrait.layer.borderColor = [UIColor whiteColor].CGColor;
    _headPortrait.layer.borderWidth = 2;
    [_mainBgView addSubview:_headPortrait];
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
	[_headPortrait addGestureRecognizer:tapGesture];
	tapGesture.delegate = self;
	[tapGesture release];
    
    //会员用户名
    _userName = [[UILabel alloc]initWithFrame:CGRectMake(100, 25, 150, 30)];
    _userName.font = [UIFont boldSystemFontOfSize:18];
    _userName.textColor = [UIColor whiteColor];
    _userName.backgroundColor = [UIColor clearColor];
    [_mainBgView addSubview:_userName];
    
    _likesBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, bgFloat-45, KUIScreenWidth/2-0.5, 45)];
    [_likesBtn setBackgroundColor:[UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:0.1]];
    [_likesBtn addTarget:self action:@selector(likeClick) forControlEvents:UIControlEventTouchUpInside];
    [_mainBgView addSubview:_likesBtn];
    
    UILabel *likes = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _likesBtn.frame.size.width, _likesBtn.frame.size.height/2)];
    likes.text = @"赞";
    likes.font = [UIFont systemFontOfSize:12];
    likes.textColor = [UIColor whiteColor];
    likes.backgroundColor = [UIColor clearColor];
    likes.textAlignment = NSTextAlignmentCenter;
    [_likesBtn addSubview:likes];
    RELEASE_SAFE(likes);
    
    _likesNum = [[UILabel alloc]initWithFrame:CGRectMake(0, _likesBtn.frame.size.height/2-5, _likesBtn.frame.size.width, _likesBtn.frame.size.height/2)];
    _likesNum.font = [UIFont boldSystemFontOfSize:15];
    _likesNum.textColor = [UIColor whiteColor];
    _likesNum.backgroundColor = [UIColor clearColor];
    _likesNum.textAlignment = NSTextAlignmentCenter;
    [_likesBtn addSubview:_likesNum];
  
    
    _commentBtn = [[UIButton alloc]initWithFrame:CGRectMake(KUIScreenWidth/2+0.5, bgFloat-45, KUIScreenWidth/2, 45)];
    [_commentBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_commentBtn setBackgroundColor:[UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:0.1]];
    [_commentBtn addTarget:self action:@selector(commentClick) forControlEvents:UIControlEventTouchUpInside];
    [_mainBgView addSubview:_commentBtn];
    
    UILabel *comment = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _likesBtn.frame.size.width, _likesBtn.frame.size.height/2)];
    comment.text = @"评论";
    comment.font = [UIFont systemFontOfSize:12];
    comment.textColor = [UIColor whiteColor];
    comment.backgroundColor = [UIColor clearColor];
    comment.textAlignment = NSTextAlignmentCenter;
    [_commentBtn addSubview:comment];
    RELEASE_SAFE(comment);
    
    _commentNum = [[UILabel alloc]initWithFrame:CGRectMake(0, _likesBtn.frame.size.height/2-5, _likesBtn.frame.size.width, _likesBtn.frame.size.height/2)];
    _commentNum.font = [UIFont boldSystemFontOfSize:15];
    _commentNum.textColor = [UIColor whiteColor];
    _commentNum.backgroundColor = [UIColor clearColor];
    _commentNum.textAlignment = NSTextAlignmentCenter;
    [_commentBtn addSubview:_commentNum];
  
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 175, 300, 44*4)style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.layer.borderColor = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1].CGColor;
    _tableView.layer.borderWidth = 1;
    _tableView.layer.cornerRadius = 3;
    [_mainScrollView addSubview:_tableView];
    
    _cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 44*4+200, 300, 40)];
    [_cancelBtn setTitle:@"注销当前帐号" forState:UIControlStateNormal];
    _cancelBtn.layer.cornerRadius = 3;
    [_cancelBtn setBackgroundColor:[UIColor colorWithRed:234/255.0 green:50/255.0 blue:43/255.0 alpha:1]];
    [_cancelBtn addTarget:self action:@selector(cancelMember) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_cancelBtn];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    RELEASE_SAFE(_mainScrollView);
    RELEASE_SAFE(_imageDownloadsInProgress);
    RELEASE_SAFE(_imageDownloadsInWaiting);
    RELEASE_SAFE(_iconDownLoad);
    RELEASE_SAFE(_mainBgView);
    RELEASE_SAFE(_headPortrait);
    RELEASE_SAFE(_tableView);
    RELEASE_SAFE(_likesBtn);
    RELEASE_SAFE(_commentBtn);
    RELEASE_SAFE(_cancelBtn);
    RELEASE_SAFE(_userName);
    RELEASE_SAFE(_likesNum);
    RELEASE_SAFE(_commentNum);
    RELEASE_SAFE(_loginCtl);
    RELEASE_SAFE(_userInfoArray);
    [super dealloc];
}

- (void)viewAppearAction {
    
    //获取会员信息
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    NSArray *curLocArray = [remember getList];
    RELEASE_SAFE(remember);
    NSLog(@"curLocArray=%@",curLocArray);
    
    member_info_model *info=[[member_info_model alloc]init];
    NSLog(@"%d",self.user_id);
    if ([curLocArray count]!=0) {
        info.where = [NSString stringWithFormat:@"username ='%@'",[[curLocArray objectAtIndex:0]objectForKey:@"value"]];
        self.userInfoArray=[info getList];
        self.user_id=[[[self.userInfoArray objectAtIndex:0]objectForKey:@"id"]intValue];
        [Global sharedGlobal].user_id = [[self.userInfoArray objectAtIndex:0]objectForKey:@"id"];
        NSLog(@"userInfoArray--==%@",self.userInfoArray);
    }
   
    
    RELEASE_SAFE(info);
    if ([self.userInfoArray count]!=0) {
//        if (![[[self.userInfoArray objectAtIndex:0]objectForKey:@"real_name"]isEqualToString:@""]) {
            _userName.text=[[self.userInfoArray objectAtIndex:0]objectForKey:@"real_name"];
//        }else{
//            _userName.text=[[self.userInfoArray objectAtIndex:0]objectForKey:@"username"];
//        }
        
        _likesNum.text=[[self.userInfoArray objectAtIndex:0]objectForKey:@"countlikes"];
        _commentNum.text=[[self.userInfoArray objectAtIndex:0]objectForKey:@"countcomment"];
        
        
        //图片
        NSString *picUrl = [[self.userInfoArray objectAtIndex:0]objectForKey:@"portrait"];
        NSLog(@"picUrl===%@",picUrl);
        
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2)
            {
                _headPortrait.image = pic;
                
                //虚化图片
                [_mainBgView setImageToBlur:pic blurRadius:2 completionBlock:^(NSError *error) {
                    NSLog(@"The image has been setted");
                }];
                
            }
            else
            {

                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:nil delegate:self];
                
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"portrait_member.png"];
            _headPortrait.image = defaultPic;
            [_mainBgView setImage:[UIImage imageCwNamed:@"bg_member.png"]];
        }

    }
       
}

//会员头像修改
- (void)changeImage{
    UIActionSheet *action=[[UIActionSheet alloc] initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [action showInView:((cwAppDelegate *)[UIApplication sharedApplication].delegate).window];
	RELEASE_SAFE(action);
}

//赞
- (void)likeClick{
    LikelistViewController *likeCtl=[[LikelistViewController alloc]init];
    likeCtl.countlikes=[[[self.userInfoArray objectAtIndex:0]objectForKey:@"countlikes"]intValue];
    [self.loginCtl.navigationController pushViewController:likeCtl animated:YES];
    RELEASE_SAFE(likeCtl);
}
//评论
- (void)commentClick{
    CommentViewController *commentCtl=[[CommentViewController alloc]init];
    [self.loginCtl.navigationController pushViewController:commentCtl animated:YES];
    RELEASE_SAFE(commentCtl);
}
//预订
- (void)orderClick{
    
}

//注销会员
- (void)cancelMember{
    
//    [self accessService];
    
    if ([self.delegate respondsToSelector:@selector(updateNavigationTitle)]) {
        [self.delegate performSelector:@selector(updateNavigationTitle)];
    }
    
    //清除之前会员的表数据
    [Common clearAllDataBase];
    
    self.loginCtl.isShowPassWord.hidden=YES;
    //下次程序启动是否自动登录状态判断
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    NSArray *curArray = [remember getList];
    
    self.loginCtl.userNameField.text=[[curArray objectAtIndex:0]objectForKey:@"value"];
    
    
    remember.where=nil;
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
    NSArray *curArray2 = [remember getList];
    
    //注销后解密密码保存输入框
    NSString *decryptUseDES=[NSString  decryptUseDES:[[curArray2 objectAtIndex:0]objectForKey:@"value"] key:@"1234567812345678"];
    self.loginCtl.userPwdField.text= decryptUseDES;
    
    remember.where = nil;
    RELEASE_SAFE(remember);
    
	self.view.hidden = YES;
	[Global sharedGlobal].isLogin = NO;
    [Global sharedGlobal].user_id = nil;
	
    self.navigationItem.title = @"登录";
   
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

- (void)accessService
{
    NSString *url = @"member/logout.do?param=";
    
    NSLog(@"%@",[[self.userInfoArray objectAtIndex:0]objectForKey:@"id"]);
    
	NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[self.userInfoArray objectAtIndex:0]objectForKey:@"id"],@"username",
                                       nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_LOGOUT_COMMAND_ID accessAdress:url delegate:self withParam:nil];
    
    
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        
        int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
        NSLog(@"resultInt=%d",resultInt);
        switch (commandid) {
            case MEMBER_LOGOUT_COMMAND_ID:
            {
                if (resultInt == 0) {
                    [self performSelectorOnMainThread:@selector(error) withObject:nil waitUntilDone:NO];
                    
                }else if (resultInt == 1) {
                
                    [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
                    
                }                
            }break;
            default:
                break;
        }
    }else{
        
        UIImage *img = [UIImage imageCwNamed:@"icon_tip_normal.png"];
        [self checkProgressHUD:@"网络不给力" andImage:img];
        
    }
}

- (void)success:(NSMutableArray*)resultArray {
    if ([self.delegate respondsToSelector:@selector(updateNavigationTitle)]) {
        [self.delegate performSelector:@selector(updateNavigationTitle)];
    }
    
    //清除之前会员的表数据
    [Common clearAllDataBase];
    
    self.loginCtl.isShowPassWord.hidden=YES;
    //下次程序启动是否自动登录状态判断
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
    NSArray *curArray = [remember getList];
    
    self.loginCtl.userNameField.text=[[curArray objectAtIndex:0]objectForKey:@"value"];
    
    
    remember.where=nil;
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberPassword"];
    NSArray *curArray2 = [remember getList];
    
    //注销后解密密码保存输入框
    NSString *decryptUseDES=[NSString decryptUseDES:[[curArray2 objectAtIndex:0]objectForKey:@"value"] key:@"1234567812345678"];
    self.loginCtl.userPwdField.text= decryptUseDES;
    
    remember.where = nil;
    RELEASE_SAFE(remember);
    
	self.view.hidden = YES;
	[Global sharedGlobal].isLogin = NO;
    [Global sharedGlobal].user_id = nil;
	
    self.navigationItem.title = @"登录";
    
}

- (void)error{
     [self checkProgressHUD:@"注销失败" andImage:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [delegate actionButtonIndex:buttonIndex imageView:self.headPortrait];

}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    MemberCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[MemberCenterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        if (IOS_7) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.afterView.image=[UIImage imageCwNamed:@"icon_left.png"];
		switch (indexPath.row) {
            case 0:
            {
                cell.labelText.text=@"个人信息";
				cell.imgView.image=[UIImage imageCwNamed:@"icon_personal_member.png"];
    
            }break;
            case 1:
            {
                cell.labelText.text=@"我的预订";
				cell.imgView.image=[UIImage imageCwNamed:@"icon-shop-member.png"];
                
            }break;
            case 2:
            {
                cell.labelText.text=@"我的优惠券";
                cell.imgView.image=[UIImage imageCwNamed:@"icon_coupons_member.png"];
                
            }break;
            case 3:
            {
                cell.labelText.text=@"我的收货地址";
                cell.imgView.image=[UIImage imageCwNamed:@"icon_address_member.png"];
                
            }break;
//            case 4:
//            {
//                cell.labelText.text=@"我的售后服务";
//                cell.imgView.image=[UIImage imageCwNamed:@"icon_service_member.png"];
//                
//            }break;
            default:
                break;
        }
    }
	
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {//个人信息
            UserInfoViewController *userInfo=[[UserInfoViewController alloc]init];
            userInfo.userInfoArray=self.userInfoArray;
            [self.loginCtl.navigationController pushViewController:userInfo animated:YES];
            RELEASE_SAFE(userInfo);
            
        }break;
        case 1:
        {//我的预订
            OrderListViewController *ordelCtl=[[OrderListViewController alloc]init];
            [self.loginCtl.navigationController pushViewController:ordelCtl animated:YES];
            RELEASE_SAFE(ordelCtl);

        }break;
        case 2:
        {//我的优惠劵
            CouponsViewController *couponCtl=[[CouponsViewController alloc]init];
            couponCtl.cwStatusType=StatusTypeMemberChoosePf;
            [self.loginCtl.navigationController pushViewController:couponCtl animated:YES];
            RELEASE_SAFE(couponCtl);
        }break;
        case 3:
        {//我的收货地址
            ChooseAddressViewController *addressCtl=[[ChooseAddressViewController alloc]init];
            addressCtl.cwStatusType=StatusTypeMemberChooseAddress;
            [self.loginCtl.navigationController pushViewController:addressCtl animated:YES];
            RELEASE_SAFE(addressCtl);
            
        }break;
//        case 4:
//        {//我的售后服务
//            AfterServiceViewController *afterService=[[AfterServiceViewController alloc]init];
//            [self.loginCtl.navigationController pushViewController:afterService animated:YES];
//            RELEASE_SAFE(afterService);
//                        
//        }break;
        default:
            break;
    }

    
}

#pragma mark - IconDownloaderDelegate
//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
            UIImage *photo = iconDownloader.cardIcon;

            _headPortrait.image = photo;
//            //虚化图片
            [_mainBgView setImageToBlur:photo blurRadius:2 completionBlock:^(NSError *error) {
                NSLog(@"The image has been setted---=-=-=");
            }];
            
		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}

- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
@end
