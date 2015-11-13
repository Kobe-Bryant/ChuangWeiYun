//
//  boxViewController.m
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import "boxViewController.h"
#import "WeiboBindViewController.h"
#import "RecommendAppViewController.h"
#import "AboutUsViewController.h"
#import "FeedbackViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "imageDownLoadInWaitingObject.h"
#import "Encry.h"
#import "downloadParam.h"
#import "callSystemApp.h"
#import "UIImageScale.h"
#import "ServiceViewController.h"
#import "BaiduMapViewController.h"
#import "alertView.h"
#import "AfterSaleViewController.h"
#import "Global.h"
#import "apns_model.h"
#import "autopromotion_model.h"
#import "grade_model.h"
#import "PopShareView.h"
#import "PfShare.h"
#import "member_info_model.h"
#import "CustomTabBar.h"
#import "PopLoctionHelpView.h"
#import "apns_model.h"
#import "CityLoction.h"
#import "boxView.h"

@interface boxViewController ()

@end

@implementation boxViewController

@synthesize mainScrollView;
@synthesize introductionView;
@synthesize moreView;
@synthesize spinner;
@synthesize listArray   =_listArray;
@synthesize progressHUD =_progressHUD;
@synthesize gradeArray  =_gradeArray;
@synthesize updateArray =_updateArray;
@synthesize shareButton;
@synthesize shareLabel;

#define bgColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]

- (void)viewWillAppear:(BOOL)animated{
    //设备令牌的评分地址为空隐藏评论按钮
    grade_model *gradeMod=[[grade_model alloc]init];
    self.gradeArray = [gradeMod getList];
    RELEASE_SAFE(gradeMod);
    
    NSLog(@"gradeArray=%@",self.gradeArray);
    
    if ([self.gradeArray count]!=0){
        if ([[[self.gradeArray objectAtIndex:0]objectForKey:@"iphone_url"] isEqualToString:@""]) {
            self.shareButton.hidden = YES;
            self.shareLabel.hidden = YES;
            self.shareButton.enabled = NO;
        }else{
            self.shareButton.hidden = NO;
            self.shareLabel.hidden = NO;
            self.shareButton.enabled = YES;
        }
    }else{
        self.shareButton.hidden = YES;
        self.shareLabel.hidden = YES;
        self.shareButton.enabled = NO;
    }
    
    NSString *_shopIdStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"isFeedbackMsg"];
    if (_shopIdStr != nil && [_shopIdStr intValue] > 0) {
        UIImage *image = [UIImage imageCwNamed:@"icon_num.png"];
        numView = [[UIImageView alloc] initWithImage:image];
        CGRect rectf =  CGRectMake(15 + iconBgWidth , 15, iconBgWidth, iconBgHeight);
        numView.frame = CGRectMake(rectf.origin.x - image.size.width + 5 ,rectf.origin.y, image.size.width, image.size.height);
        [self.moreView addSubview:numView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KCWViewBgColor;
    
    iconWidth  = 48.0f;
    iconHeight = 48.0f;
    
    iconBgWidth  = 57.0f;
    iconBgHeight = 57.0f;
    
    _listArray  = [[NSMutableArray alloc] init];
    _gradeArray = [[NSMutableArray alloc]init];
    _updateArray= [[NSMutableArray alloc]init];

    UIScrollView *tempMainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height)];
	tempMainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
	tempMainScrollView.pagingEnabled = NO;
	tempMainScrollView.showsHorizontalScrollIndicator = NO;
	tempMainScrollView.showsVerticalScrollIndicator = NO;
	tempMainScrollView.bounces = YES;
    self.mainScrollView = tempMainScrollView;
    [self.view addSubview:self.mainScrollView];
    [tempMainScrollView release];
    
    //介绍视图
    UIView *tempIntroductionView = [[UIView alloc] initWithFrame:CGRectZero];
    tempIntroductionView.backgroundColor = [UIColor clearColor];
    self.introductionView = tempIntroductionView;
    [self.mainScrollView addSubview:tempIntroductionView];
    [tempIntroductionView release];
    
    //更多功能视图
    UIView *tempMoreView = [[UIView alloc] initWithFrame:CGRectZero];
    tempMoreView.backgroundColor = [UIColor clearColor];
    self.moreView = tempMoreView;
    [self.mainScrollView addSubview:tempMoreView];
    [tempMoreView release];
    
    autopromotion_model *updateMod=[[autopromotion_model alloc]init];
    self.updateArray = [updateMod getList];
    NSLog(@"=====%@",self.updateArray);
    RELEASE_SAFE(updateMod);
    
    [self update];
    
    NSString *tipTitle=@"";
    if ([self.updateArray count]!=0) {
        tipTitle=[NSString stringWithFormat:@"%@",[[self.updateArray objectAtIndex:0]objectForKey:@"remark"]];
    }
    
    _popUpdateView = [[PopCheckUpdateView alloc] initWithTitle:VERSIONTITLE andContent:tipTitle andBtnTitle:@"稍后提醒我" andTitle:@"立即更新"];
    _popUpdateView.delegate = self;
    
    
    _popCommentView = [[PopUpdateVerView alloc]init:@"马上去评分" andBtnTitle:@"好" andTitle:@"不好"];
    _popCommentView.delegate = self;
    
    _popClearChche = [[PopClearChcheView alloc]init:@"确定清除缓存?" andBtnTitle:@"确定" andTitle:@"取消"];
    _popClearChche.delegate = self;
    
//    NSLog(@"系统字体：%@",[UIFont familyNames]);
    
    if (IOS_7) {
        [Common iosCompatibility:self];
    }
}



- (void)dealloc {
    
    self.mainScrollView = nil;
    self.introductionView = nil;
    self.moreView = nil;
    self.spinner = nil;
    RELEASE_SAFE(_listArray);
    RELEASE_SAFE(btnBgImageView);
    RELEASE_SAFE(_popUpdateView);
    RELEASE_SAFE(_gradeArray);
    RELEASE_SAFE(_updateArray);
    RELEASE_SAFE(_popClearChche);
    RELEASE_SAFE(shareLabel);
    RELEASE_SAFE(shareButton);
    [super dealloc];
}

// 关于我们
-(void)aboutUs
{
	AboutUsViewController *aboutUsDetail = [[AboutUsViewController alloc] init];
	[self.navigationController pushViewController:aboutUsDetail animated:YES];
	[aboutUsDetail release];
}

// 保修服务
-(void)afterService{
    AfterSaleViewController *service=[[AfterSaleViewController alloc]init];
    [self.navigationController pushViewController:service animated:YES];
    RELEASE_SAFE(service);
}

// 微博设置
-(void)weiboSet
{
	WeiboBindViewController *weibo=[[WeiboBindViewController alloc]init];
    [self.navigationController pushViewController:weibo animated:YES];
    RELEASE_SAFE(weibo);
}

// 留言反馈
-(void)feedback
{
    // dufu  add  2013.11.19  备注：是否开启定位功能
    if (![Common isLoctionOpen] || ![Common isLoction]) {
        [Common MsgBox:@"定位未开启" messege:@"请在”设置->隐私->定位服务“中确认“定位”和“创维云GO”是否为开启状态" cancel:@"确定" other:@"帮助" delegate:self];
        return;
    }
    
    if (![[CityLoction defaultSingle] showLoctionView]) {
        return;
    }
    
    if (![self citySubbranchView:CitySubbranchMore]) {
        return;
    }
    
    if ([Global sharedGlobal].isLogin == YES) {
        Login_FeedbackViewController *login_feedback = [[Login_FeedbackViewController alloc] init];
        login_feedback.delegate = self;
        [self.navigationController pushViewController:login_feedback animated:YES];
        [login_feedback release];
        
    }else {
        FeedbackViewController *feedbackDetail = [[FeedbackViewController alloc] init];
        [self.navigationController pushViewController:feedbackDetail animated:YES];
        [feedbackDetail release];
    }
}

// 推荐应用
-(void)recommendApp
{
    RecommendAppViewController *recommend=[[RecommendAppViewController alloc]init];
    [self.navigationController pushViewController:recommend animated:YES];
    RELEASE_SAFE(recommend);
}

// 清楚缓存
-(void)clearChche
{
    
    [_popClearChche addPopupSubview];
    
}

// 检查更新
- (void)fresh
{

    _popUpdateSucess=[[PopUpdateSucessView alloc]init];
    
    if ([self.updateArray count]!=0) {
        int appVer=[[[self.updateArray objectAtIndex:0]objectForKey:@"promote_ver"]intValue];
        NSLog(@"appVer====%d",appVer);
        
        if (appVer > CURRENT_APP_VERSION) {
            
            [_popUpdateView addPopupSubview];
        }else{
            [_popUpdateSucess addPopupSubview];
        }
        
    }else{
        [_popUpdateSucess addPopupSubview];
    }
    
}

// 评分
- (void)comment
{
    
   [_popCommentView addPopupSubview];

}

// 分享
- (void)share{
    [PfShare defaultSingle].getPf = Share_Get_Pf_Box;
    [PfShare defaultSingle].share_gift = 0;
    [[PopShareView defaultExample] showPopupView:self.navigationController delegate:self];
    
}

#pragma mark - boxBtnDelegate
- (void)clickBtn:(int)tagB{
    // 上部分
    boxView *v = (boxView *)[self.introductionView viewWithTag:tagB];
    
    switch (v.tag) {
        case 100:
            [self aboutUs];
            break;
        case 200:
            [self afterService];
            break;
        default:
            break;
    }
    // 下部分
    boxView *vMore = (boxView *)[self.moreView viewWithTag:tagB];
    switch (vMore.tag) {
        case 300:
            [self feedback];
            break;
        case 301:
            [self weiboSet];
            break;
        case 302:
            [self fresh];
            break;
        case 303:
            [self clearChche];
            break;
        case 304:
            [self recommendApp];
            break;
        case 305:
            [self share];
            break;
        case 306:
            [self comment];

            break;
        default:
            break;
    }
    
}

#pragma mark - ShareAPIActionDelegate
// 分享内容
- (NSDictionary *)shareApiActionReturnValue
{
    
//    apns_model *apnsMod = [[apns_model alloc]init];
//    NSArray *arr = [apnsMod getList];
//    RELEASE_SAFE(apnsMod);
//    
//    NSString *shareUrlStr=@"";
//    if ([arr count]!=0) {
//        shareUrlStr = [[arr objectAtIndex:0]objectForKey:@"client_downurl"];
//    }else{
//        shareUrlStr = @"";
//    }
    
    NSString *shareUrlStr = CLIENT_SHARE_LINK;//hui 12.21
    
    NSString *title=@"您身边的生活超市";
    NSString *contents=[NSString stringWithFormat:@"我正在使用一款非常不错的应用「创维云GO」，您身边的家电超市，享受全新的购物体验和售后服务，赶快来体验吧！%@",shareUrlStr];
 
    UIImage  *pic=[UIImage imageCwNamed:@"icon.png"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          contents, ShareContent,
                          title, ShareTitle,
                          pic, ShareImage,
                          shareUrlStr, ShareUrl,
                          nil];

    return dict;
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

#pragma mark - PopUpdateCheckDelegate
//确定检查更新弹窗和评分弹窗回调
- (void)OKCheckUpdates{

    [_popUpdateView closeView];
    NSString *updateUrl = [[self.updateArray objectAtIndex:0]objectForKey:@"url"];
    NSLog(@"%@",updateUrl);
    NSURL *url = [NSURL URLWithString:updateUrl];
    [[UIApplication sharedApplication]openURL:url];
    
}

// 确定去评分
- (void)OKCheckUpdate{
   
    [_popCommentView closeView];
    NSLog(@"马上评分");
    
    grade_model *gradeMod = [[grade_model alloc]init];
    self.gradeArray = [gradeMod getList];
    RELEASE_SAFE(gradeMod);
    
    NSLog(@"gradeArray111=%@",self.gradeArray);
    //设备令牌的评分地址为空隐藏评论按钮
    if ([self.gradeArray count]!=0) {
        NSString *strUrl = [[self.gradeArray objectAtIndex:0]objectForKey:@"iphone_url"];

        NSURL *url = [NSURL URLWithString:strUrl];
        NSLog(@"url==%@",url);
        [[UIApplication sharedApplication]openURL:url];
    }
 
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", @"itms-apps://itunes.apple.com/cn/app/guang-dian-bi-zhi/id511587202?mt=8"]]];
    
}

// 确定清除缓存
- (void)OKClearChche {
    [_popClearChche closeView];
    
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
         NSString *filepath = [FileManager getFilePath:@""];
         
         NSArray *fileListPic = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath: filepath error:nil];
         
         for(int i=0;i < [fileListPic count]; i++) {
             [FileManager removeFile:[fileListPic objectAtIndex:i]];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self checkProgressHUD:@"已清空缓存"];
         });
     });
}


//创建介绍视图
-(void)createIntroductionView
{
    //顶部UI
    [self imageStretch:10.0];
    
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10 , 60, 16)];
	strLabel.text = @"创  维";
	strLabel.textColor = [UIColor whiteColor];
	strLabel.font = [UIFont systemFontOfSize:12.0f];
	strLabel.textAlignment = UITextAlignmentCenter;
	strLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:strLabel];
	[strLabel release];
    
    // 添加第一个 '关于我们' 按钮
    CGRect aboutRect = CGRectMake(15 , 27, iconBgWidth, iconBgHeight);
    boxView *aboutB = [[boxView alloc]initWithFrame:aboutRect andIcon:@"icon_about_box" andText:@"关于我们" andTag:100 delegate:self];
    [self.introductionView addSubview:aboutB];
    
    // 保修服务按钮
    CGRect serviceRect = CGRectMake(CGRectGetMaxX(aboutRect) +  20, 27, iconBgWidth, iconBgHeight);
    boxView *serviceB = [[boxView alloc]initWithFrame:serviceRect andIcon:@"icon_warranty_zbox" andText: @"保修服务" andTag:200 delegate:self];
    [self.introductionView addSubview:serviceB];
    

    CGFloat floatListCount = [self.listArray count];
    CGFloat floatNum = ceil((floatListCount + 1.0) / 4.0);
    CGFloat introductionHeigh = floatNum * 80.0f + 57.0f;
    
    [self.introductionView setFrame:CGRectMake(0.0f , 0.0f, 320.0f, introductionHeigh)];
}

//背景图片拉伸
- (void)imageStretch:(float)height{
    UIImageView *ImageView = [[UIImageView alloc]init];
    [ ImageView  setFrame:CGRectMake(0.0,height, 80.0, 16.0)];
    UIEdgeInsets ed = {1.0f, 0.2f, 0.2f, 7.5f};
    [ImageView setImage:[[UIImage imageNamed:@"tag_box.png"]resizableImageWithCapInsets:ed]];
    [self.view addSubview:ImageView];
    RELEASE_SAFE(ImageView);
}

//创建更多功能视图
-(void)createMoreView
{
    //顶部分割线
    UIImage *lineImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"小栏目背景" ofType:@"png"]];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f , 0.0f, lineImage.size.width, lineImage.size.height)];
    lineImageView.image = lineImage;
	[lineImage release];
	[self.view addSubview:lineImageView];
	
    [self imageStretch:130.0];
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130 , 60, 16)];
	strLabel.text = @"设  置";
	strLabel.textColor = [UIColor whiteColor];
	strLabel.font = [UIFont systemFontOfSize:12.0f];
	strLabel.textAlignment = UITextAlignmentCenter;
	strLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:strLabel];
	[strLabel release];
    [lineImageView release];
    
    //中间icon间隔
    CGFloat midIconWidth = ((self.view.frame.size.width - (4*iconBgWidth) - 30.0f) / 3);
 
    grade_model *gradeMod = [[grade_model alloc]init];
    self.gradeArray = [gradeMod getList];
    
    NSArray *imageArry=nil;
    NSArray *nameArry=nil;
    if ([self.gradeArray count]>0 &&[[[self.gradeArray objectAtIndex:0]objectForKey:@"iphone_url"] length]>0) {
        imageArry = [NSArray arrayWithObjects:@"icon_feedback_box",@"icon_binding_box",@"icon_updates_box",@"icon_cache_box",@"icon_recommend_box",@"icon_share_box",@"icon_score_box",nil];
        
        nameArry = [NSArray arrayWithObjects:@"留言反馈",@"微博绑定",@"检查更新",@"清除缓存",@"应用推荐",@"分享好友",@"去评个分",nil];

    }else{
        imageArry = [NSArray arrayWithObjects:@"icon_feedback_box",@"icon_binding_box",@"icon_updates_box",@"icon_cache_box",@"icon_recommend_box",@"icon_share_box",nil];
        
        nameArry = [NSArray arrayWithObjects:@"留言反馈",@"微博绑定",@"检查更新",@"清除缓存",@"应用推荐",@"分享好友",nil];

    }
    RELEASE_SAFE(gradeMod);

    
    CGRect  rect;
    for (int i=0; i<[nameArry count]; i++) {
        if (i==0) {
            rect = CGRectMake(15, 15, iconBgWidth, iconBgHeight);
        }
        else if (i < 4 && i >0) {
            rect = CGRectMake(midIconWidth + CGRectGetMaxX(rect), 15, iconBgWidth, iconBgHeight);
        }
        else if (i == 4){
            rect = CGRectMake(15 , iconBgHeight + 55, iconBgWidth, iconBgHeight);
        }
        else if (i < 8 && i >4){
            rect = CGRectMake(midIconWidth + CGRectGetMaxX(rect) , iconBgHeight + 55, iconBgWidth, iconBgHeight);
        }
        
        boxView *bView = [[boxView alloc]initWithFrame:rect andIcon:[imageArry objectAtIndex:i] andText:[nameArry objectAtIndex:i] andTag:300+i delegate:self];
        [self.moreView addSubview:bView];
        
    }
    
    
    //消息数通知
//    if ([Global sharedGlobal].isLogin == YES) {
//        member_info_model *info = [[member_info_model alloc]init];
//        info.where = [NSString stringWithFormat:@"id ='%d'",[[Global sharedGlobal].user_id intValue]];
//        NSMutableArray *userInfoArray = [info getList];
//        [info release];
//        
//        int feedbackNum = [[[userInfoArray objectAtIndex:0] objectForKey:@"count_message"] intValue];
//        
//        if (feedbackNum > 0) {
//            UIImage *image = [UIImage imageCwNamed:@"icon_num.png"];
//            numView = [[UIImageView alloc] initWithImage:image];
//            numView.frame = CGRectMake(CGRectGetMaxX(feedbackButton.frame) - image.size.width + 5 ,feedbackButton.frame.origin.y, image.size.width, image.size.height);
//            [self.moreView addSubview:numView];
//        }
//    }
    
    CGFloat floatNum = ceil(6.0 / 4.0);
    CGFloat moreHeigh = floatNum * 80.0f + 37.0f;
    
    [self.moreView setFrame:CGRectMake(0.0f , CGRectGetMaxY(self.introductionView.frame), 320.0f, moreHeigh)];
    
}

- (void)update
{

    //创建介绍视图
    [self createIntroductionView];
    
    //更多功能按钮
    [self createMoreView];
    
    //设置总体高度
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.introductionView.frame.size.height + self.moreView.frame.size.height + 44.0f + 49.0f);
    
}

// 提示
- (void)checkProgressHUD:(NSString *)value{
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center=CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.delegate = self;
    progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = value;
    [self.view addSubview:progressHUDTmp];
    [self.view bringSubviewToFront:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];
    
}

// 切换分店选择页
- (BOOL)citySubbranchView:(CitySubbranchEnum)asubbranchEnum
{
    if ([Global sharedGlobal].shop_id.length == 0) {
        CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
        citySubbranch.delegate = self;
        citySubbranch.cityStr = [Global sharedGlobal].currCity;
        citySubbranch.subbranchEnum = asubbranchEnum;
        citySubbranch.cwStatusType = StatusTypeAPP;
        [self.navigationController pushViewController:citySubbranch animated:YES];
        [citySubbranch release], citySubbranch = nil;
        return NO;
    } else {
        return YES;
    }
}

// 切换分店选择页伪托
#pragma mark - CitySubbranchViewControllerDelegate
- (void)chooseSubbranchInfo:(CitySubbranchEnum)asubbranchEnum
{
    
}

#pragma mark -  Login_FeedbackViewControllerDelegate
// 网络请求
- (void)accessServiceItemsSuccess
{
    [numView removeFromSuperview];
    
    NSArray *arrayViewControllers = self.navigationController.viewControllers;
    if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
    {
        CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
        UIImageView *view = (UIImageView *)[tabViewController.view viewWithTag:22222];
        if (view != nil) {
            if (view) {
                [view removeFromSuperview];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isFeedbackMsg"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"isFeedbackShop"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

@end
