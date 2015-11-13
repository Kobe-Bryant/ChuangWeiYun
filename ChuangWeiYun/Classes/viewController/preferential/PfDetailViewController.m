//
//  PfDetailViewController.m
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "PfDetailViewController.h"
#import "PfDetailViewCell.h"
#import "PfCommonViewController.h"
#import "PopShareView.h"
#import "Common.h"
#import "Global.h"
#import "PopGuideView.h"
#import "PreferentialObject.h"
#import "cloudLoadingView.h"
#import "FileManager.h"
#import "apns_model.h"
#import "MBProgressHUD.h"
#import "preactivity_log_model.h"
#import "PfShare.h"
#import "NetworkFail.h"
#import "preactivity_list_model.h"
#import "promotions_id_model.h"

@interface PfDetailViewController () <MBProgressHUDDelegate, NetworkFailDelegate>
{
    int selectIndex;
    PopOtherUnionView *popOUView;
    UIButton *downBarbtn;
    cloudLoadingView *cloudLoading;
    MBProgressHUD *progressHUD;
    NetworkFail *failView;
    BOOL shareFlag;
    BOOL _isNavHide;
}

@property (retain, nonatomic) UIButton *downBarbtn;
@property (retain, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation PfDetailViewController

//@synthesize scrollViewC = _scrollViewC;
@synthesize dataArr;
@synthesize promotionId;
@synthesize clickRow;
@synthesize downBarbtn;
@synthesize progressHUD;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [[self.dataArr objectAtIndex:self.clickRow] objectForKey:@"title"];
    
    if (self.navigationController.navigationBarHidden) {
        _isNavHide = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        _isNavHide = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isNavHide) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectIndex = self.clickRow;

    [self viewLoad];
    
    [self dataLoad];

    if (![PopGuideView isInsertTable:Guide_Enum_PfLR]) {
        UIImage *img = nil;
        if (KUIScreenHeight > 500) {
            img = [UIImage imageCwNamed:@"left_right_pf2.png"];
        } else {
            img = [UIImage imageCwNamed:@"left_right_pf.png"];
        }
        PopGuideView *popGuideView = [[PopGuideView alloc]initWithImage:img index:Guide_Enum_PfLR];
        [popGuideView addPopupSubview];
        [popGuideView release], popGuideView = nil;
    }
}

- (void)dataLoad
{
    if (self.dataArr.count == 0) {
        [self accessItemDetailService];
    } else {
        // 点击优惠券纪录
        [self readAndWritePreactivityLog];
        
        [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
    }
}

- (void)viewLoad
{
    self.view.backgroundColor = KCWViewBgColor;
    
    [self addDownBar];
    
    _scrollViewC = [[UITableScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight-KUpBarHeight-KDownBarHeight) clickIndex:self.clickRow pages:2];
    _scrollViewC.bounces = YES;
    _scrollViewC.pagingEnabled = YES;
    _scrollViewC.dataSource = self;
    _scrollViewC.userInteractionEnabled = YES;
    _scrollViewC.showsHorizontalScrollIndicator = NO;
    _scrollViewC.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollViewC];
    
    UIImage *img = [UIImage imageCwNamed:@"share.png"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0.f, 0.f, img.size.width, img.size.height);
    [rightBtn setBackgroundImage:img forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageCwNamed:@"share_click.png"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(btnRightClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBar;
    [rightBar release], rightBar = nil;
    
    UIImage *image = [[UIImage alloc ]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return" ofType:@"png"]];
    UIButton *barbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    barbutton.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    if (IOS_7) {//chenfeng2014.2.9 add
        barbutton.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
    }
    
    [barbutton addTarget:self action:@selector(popNavigation) forControlEvents:UIControlEventTouchUpInside];
    [barbutton setImage:image forState:UIControlStateNormal];
    UIImage *img1 = [[UIImage alloc ]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return_click" ofType:@"png"]];
    [barbutton setImage:img1 forState:UIControlStateHighlighted];
    [image release], image = nil;
    [img1 release], img1 = nil;
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:barbutton];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    [barBtnItem release], barBtnItem = nil;
    
    [self setDownBarHide:[self.dataArr objectAtIndex:selectIndex]];
}

// 创建下bar
- (void)addDownBar
{
    UIView *downBar = [[UIView alloc]initWithFrame:CGRectMake(0.f, KUIScreenHeight-KUpBarHeight-KDownBarHeight, KUIScreenWidth, KDownBarHeight)];
    downBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:downBar];

    downBarbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downBarbtn.frame = CGRectMake(70.f, 4.f, 180.f, 40.f);
    [downBarbtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    downBarbtn.layer.cornerRadius = 5.f;
    [downBar addSubview:downBarbtn];
    
    [downBar release], downBar = nil;
}

// 设置downbar
- (void)setDownBarHide:(NSDictionary *)dict
{
//    BOOL state = [PreferentialObject isPastDueDate:[[dict objectForKey:@"start_date"] intValue]
//                                               end:[[dict objectForKey:@"end_date"] intValue]];
    
    if (self.dataArr.count == 0) {
        downBarbtn.hidden = YES;
    } else {
        downBarbtn.hidden = NO;
    }
    
    NSArray *arr = [self getMember_Promotions:dict];
    NSLog(@"setDownBarHide  arr = %@",arr);
    
    if ([[dict objectForKey:@"join_state"] intValue] == 1 || arr.count > 0) {
        [downBarbtn setBackgroundColor:[UIColor colorWithRed:147.f/255.f green:147.f/255.f blue:147.f/255.f alpha:0.f]];
        [downBarbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [downBarbtn setTitle:@"亲，您已参加过了哦" forState:UIControlStateNormal];
        downBarbtn.enabled = NO;
    } else if ([[dict objectForKey:@"discount"] intValue] == 0) {
        [downBarbtn setBackgroundColor:[UIColor colorWithRed:147.f/255.f green:147.f/255.f blue:147.f/255.f alpha:0.f]];
//        [downBarbtn setTitleColor:[UIColor colorWithRed:191.f/255.f green:191.f/255.f blue:191.f/255.f alpha:1.f] forState:UIControlStateNormal];
        [downBarbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        downBarbtn.frame = CGRectMake(60.f, 4.f, 200.f, 40.f);
        [downBarbtn setTitle:@"亲，可直接到店享受优惠" forState:UIControlStateNormal];
        downBarbtn.enabled = NO;
    } else {
        [downBarbtn setBackgroundColor:[UIColor colorWithRed:234.f/255.f green:50.f/255.f blue:43.f/255.f alpha:1.f]];
        [downBarbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [downBarbtn setTitle:@"马上获得优惠" forState:UIControlStateNormal];
        downBarbtn.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog(@"pfdetialview dealloc ......");
    [_scrollViewC release], _scrollViewC = nil;
    self.dataArr = nil;
    self.promotionId = nil;
    if (popOUView != nil) {
        [popOUView release], popOUView = nil;
    }
    if (cloudLoading) {
        [cloudLoading release], cloudLoading = nil;
    }
    if (failView) {
        [failView release], failView = nil;
    }
    self.progressHUD = nil;
    [super dealloc];
}

- (void)popNavigation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    for (id cell in _scrollViewC.subviews) {
        if ([cell isKindOfClass:[PfDetailViewCell class]]) {
            if (((PfDetailViewCell *)cell).index == selectIndex) {
                [cell tableViewReloadData:nil type:1];
            } else {
                [cell tableViewReloadData:nil type:1];
            }
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [pool release];
}

// 预订中
- (void)progress
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = @"预订中...";
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result type:(int)atype
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y + 120);
    
    UIImage *img = nil;
    if (atype == 1) {
        img = [UIImage imageCwNamed:@"icon_ok_normal.png"];
    } else if (atype == 0) {
        img = [UIImage imageCwNamed:@"icon_tip_normal.png"];
    }
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [self.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (self.progressHUD) {
        [progressHUD removeFromSuperview];
    }
}

// 我要参加
- (void)btnClick:(UIButton *)btn
{
    if ([Global sharedGlobal].isLogin) {
        if ([[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"is_partner"] intValue] == 1) {
            if (popOUView == nil) {
                popOUView = [[PopOtherUnionView alloc]init];
                popOUView.delegate = self;
            }
            [popOUView addPopupSubview];
        } else {
            [self accessItemJoinService];
        }
    } else {
        LoginViewController *loginView = [[LoginViewController alloc]init];
        loginView.cwStatusType = StatusTypeMemberLogin;
        loginView.cwBackType = LoginBackJoinBack;
        loginView.delegate = self;
        [self.navigationController pushViewController:loginView animated:YES];
        [loginView release], loginView = nil;
    }
}

// 登录回来逻辑处理
#pragma mark - LoginViewDelegate
- (void)loginSuccessBackCtl:(LoginBack)cwBackType
{
    [self setDownBarHide:[self.dataArr objectAtIndex:selectIndex]];
}

// 分享按钮
- (void)btnRightClick:(UIButton *)btn
{
    if (!shareFlag) {
        [PfShare defaultSingle].getPf = Share_Get_Pf_Pf;
        [PfShare defaultSingle].share_gift = 1;
        [Global sharedGlobal].info_id = [NSString stringWithFormat:@"%d",[[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"id"] intValue]];
        [[PopShareView defaultExample] showPopupView:self.navigationController delegate:self];
    }
}

// 分享内容
#pragma mark - ShareAPIActionDelegate
- (NSDictionary *)shareApiActionReturnValue
{
    [Global sharedGlobal].countObj_id = [NSString stringWithFormat:@"%d",[[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"id"] intValue]];
    [Global sharedGlobal]._countType = CountTypePreactivity;
    
    NSString *url = nil;
    apns_model *aMod = [[apns_model alloc]init];
    NSArray *arr = [aMod getList];
    if (arr.count > 0) {
        NSDictionary *amodDict = [arr lastObject];
        url = [amodDict objectForKey:@"client_downurl"];
    }
    [aMod release], aMod = nil;
    
    NSDictionary *adict = [self.dataArr objectAtIndex:selectIndex];
    NSString *content = [NSString stringWithFormat:@"【%@】，【%@】，更多详情：%@ （分享自@创维云GO）",
                         [adict objectForKey:@"title"],
                         [adict objectForKey:@"address"],
                         url];
    
    NSString *picUrl = [adict objectForKey:@"image"];
    NSString *picName = nil;
    if (picUrl.length > 0) {
        picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    }
    
    UIImage *pic = nil;
    if (picUrl.length > 1) {
        pic = [FileManager getPhoto:picName];
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          content, ShareContent,
                          url, ShareUrl,
                          [adict objectForKey:@"title"], ShareTitle,
                          pic, ShareImage, nil];
    
    return dict;
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemDetailService];
}

// 网络请求我要参加 异业联盟
#pragma mark - PopOtherUnionViewDelegate
- (void)getOtherUnionCoupons:(NSString *)code phone:(NSString *)phone
{
    NSString *reqUrl = @"joinpreactivity.do?param=";
    
    NSString *shopid = @"0";
    if ([Global sharedGlobal].shop_id.length != 0) {
        shopid = [Global sharedGlobal].shop_id;
    }
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       shopid,@"shop_id",
                                       [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"id"],@"info_id",
                                       code,@"identify_code",
                                       phone,@"mobile",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:PREACTIVITY_JOIN_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

#pragma mark - network request
// 网络请求我要参加
- (void)accessItemJoinService
{
    NSString *reqUrl = @"joinpreactivity.do?param=";
    
    NSString *shopid = @"0";

    if ([Global sharedGlobal].shop_id.length != 0) {
        shopid = [Global sharedGlobal].shop_id;
    }

    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"id"],@"info_id",
                                       shopid,@"shop_id",
                                       nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:PREACTIVITY_JOIN_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 网络请求活动详情
- (void)accessItemDetailService
{
    shareFlag = YES;
    //添加loading图标
    if (cloudLoading == nil) {
        cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
        [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    }
    [self.view addSubview:cloudLoading];
    
    NSString *reqUrl = @"member/preactivitydetail.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.promotionId,@"promotionId",
                                       [Global sharedGlobal].user_id,@"user_id",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:PREACTIVITY_DETAIL_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 更新优惠活动表
- (void)updateShopListDB:(NSDictionary *)moddict
{
    int pid = [[moddict objectForKey:@"id"] intValue];
    NSLog(@"pid = %d",pid);
    preactivity_list_model *plMod = [[preactivity_list_model alloc]init];
    plMod.where = [NSString stringWithFormat:@"id = '%d'",pid];
    NSArray *arr = [plMod getList];
    if (arr.count > 0) {
        [plMod updateDB:moddict];
    }
    [plMod release], plMod = nil;
}

// 是否参加数据更新
- (NSMutableDictionary *)joinDataUpdate
{
    // 赞数据
    NSMutableDictionary *modDict = [NSMutableDictionary dictionaryWithDictionary:[self.dataArr objectAtIndex:selectIndex]];
//    [self.dataArr removeObjectAtIndex:selectIndex];

    [modDict setObject:[NSNumber numberWithInt:1] forKey:@"join_state"];

//    [self.dataArr insertObject:modDict atIndex:selectIndex];
    [self.dataArr replaceObjectAtIndex:selectIndex withObject:modDict];
    
    int pid = [[modDict objectForKey:@"id"] intValue];
    promotions_id_model *piMod = [[promotions_id_model alloc]init];
    piMod.where = [NSString stringWithFormat:@"promotions_id = '%d' and userId = '%@'",pid,[Global sharedGlobal].user_id];
    NSArray *piArr = [piMod getList];
    if (piArr.count == 0) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [Global sharedGlobal].user_id,@"userId",
                              [NSNumber numberWithInt:pid],@"promotions_id", nil];
        [piMod insertDB:dict];
    }
    [piMod release], piMod = nil;

    return modDict;
}

// 得到member_likeshop信息
- (NSArray *)getMember_Promotions:(NSDictionary *)dict
{
    NSString *pID = [dict objectForKey:@"id"];
    
    promotions_id_model *piMod = [[promotions_id_model alloc]init];
    piMod.where = [NSString stringWithFormat:@"promotions_id = '%@' and userId = '%@'",pID,[Global sharedGlobal].user_id];
    NSArray *arr = [piMod getList];
    [piMod release], piMod = nil;
    
    if (![Global sharedGlobal].isLogin) {
        return nil;
    }
    
    return arr;
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (commandid == PREACTIVITY_JOIN_COMMAND_ID) {
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                [self progressHUD:KCWServerBusyPrompt type:0];
            } else {
                int ret = [[resultArray objectAtIndex:0] intValue];
                
                if (ret == 1) {
                    // 参加数据
                    NSMutableDictionary *modDict = [self joinDataUpdate];
                    
                    [self updateShopListDB:modDict];
                    
                    [self setDownBarHide:[self.dataArr objectAtIndex:selectIndex]];
                    
                    NSDictionary *dict = [self.dataArr objectAtIndex:selectIndex];
                    PfCommonViewController *pfCommonView = [[PfCommonViewController alloc]init];
                    pfCommonView.codeID = [resultArray objectAtIndex:1];
                    pfCommonView.codeUrl = [resultArray objectAtIndex:2];
                    pfCommonView.dict = dict;
                    pfCommonView.intro = [resultArray objectAtIndex:4];
                    pfCommonView.pfCommon = 0;
                    [self.navigationController pushViewController:pfCommonView animated:YES];
                    [pfCommonView release], pfCommonView = nil;
                } else if (ret == 0) {
                    if ([[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"is_partner"] intValue] == 1) {
                        [self progressHUD:@"验证码错误，请重新输入" type:0];
                    } else {
                        [self progressHUD:@"网络异常，请稍后再试" type:0];
                    }
                } else if (ret == 2){
                    [self progressHUD:@"您已经参加过了，请关注其他优惠活动" type:0];
                }
            } 
        } else {
            if ([Common connectedToNetwork]) {
                // 网络繁忙，请重新再试
                [self progressHUD:@"网络繁忙，参加失败，请稍后再试" type:3];
            } else {
                // 当前网络不可用，请重新再试
                [self progressHUD:KCWNetNOPrompt type:3];
            }
        }
    } else if (commandid == PREACTIVITY_DETAIL_COMMAND_ID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    if (resultArray.count > 0) {
                        self.dataArr = resultArray;
                        // 点击优惠券纪录
                        [self readAndWritePreactivityLog];
                        
                        [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [cloudLoading removeFromSuperview];
                
                if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                    if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                        self.title = @"优惠详情";
                        // 服务器繁忙，请重新再试
                        [self failViewCreate:CwTypeViewNoService];
                    } else {
                        shareFlag = NO;
                        _scrollViewC.hidden = NO;
                        // 重新刷新
                        [_scrollViewC reloadView];
                        // 设置下bar状态
                        [self setDownBarHide:[self.dataArr objectAtIndex:selectIndex]];
                        // 设置上bar文字
                        self.title = [[self.dataArr objectAtIndex:self.clickRow] objectForKey:@"title"];
                    }
                } else {
                    self.title = @"优惠详情";
                    if ([Common connectedToNetwork]) {
                        // 网络繁忙，请重新再试
                        [self failViewCreate:CwTypeViewNoRequest];
                    } else {
                        // 当前网络不可用，请重新再试
                        [self failViewCreate:CwTypeViewNoNetWork];
                    }
                }
            });
        });
    }
    
    [pool release];
}

#pragma mark - UITableScrollViewDelagate
- (NSInteger)tableScrollViewNumberOfRow:(UITableScrollView *)tableScrollView
{
    return self.dataArr.count;
}

//- (UITableScrollViewCell *)tableScrollView:(UITableScrollView *)tableScrollView viewForRowAtIndex:(NSInteger)index
//{
//    ShopDetailsView *cell = [tableScrollView dequeueRecycledPage];
//    if (cell == nil) {
//        
//        cell = [[[ShopDetailsView alloc] initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight-KUpBarHeight-KDownBarHeight - 1)] autorelease];
//        cell.navViewController = self.navigationController;
//        cell.cwStatusType = self.cwStatusType;
//        [cell createView];
//    }
//    
//    cell.proID = self.productID;
//    cell.delegate = self;
//    cell.isEnd = self.isEnd;
//    //    NSLog(@"self.productID = %@",self.productID);
//    //    NSLog(@"cell.proID = %@",cell.proID);
//    NSDictionary *dict = [self.dataArr objectAtIndex:index];
//    
//    NSLog(@"self.shopList ,.,. = %@",self.shopList);
//    [cell tableViewReloadData:dict shopList:self.shopList type:ShopDetailsEnumNormal];
//    
//    return cell;
//}


- (UITableScrollViewCell *)tableScrollView:(UITableScrollView *)tableScrollView viewForRowAtIndex:(NSInteger)index
{
    PfDetailViewCell *cell = [tableScrollView dequeueRecycledPage];
    if (cell == nil) {
        cell = [[[PfDetailViewCell alloc]initWithFrame:_scrollViewC.bounds] autorelease];
        cell.navViewController = self.navigationController;
        [cell createView];
    }
    
    NSDictionary *dict = [self.dataArr objectAtIndex:index];
 
    [cell tableViewReloadData:dict type:0];
    
    return cell;
}

- (void)tableScrollView:(UITableScrollView *)tableScrollView didSelectRowAtIndex:(NSInteger)index beforeIndex:(NSInteger)aindex
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSLog(@"index = %d",index);
    selectIndex = index;
    
    [self setDownBarHide:[self.dataArr objectAtIndex:selectIndex]];
    
    self.title = [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"title"];
    
    // 点击优惠券纪录
    [self readAndWritePreactivityLog];
    
    [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
    
    [pool release];
}

#pragma mark - 
// 读写preactivity log数据
- (void)readAndWritePreactivityLog
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        int plID = [[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"id"] intValue];
        
        preactivity_log_model *plMod = [[preactivity_log_model alloc]init];
        plMod.where = [NSString stringWithFormat:@"id = '%d'",plID];
        NSMutableArray *arr = [plMod getList];
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:plID],@"id",
                                     [NSNumber numberWithInt:1],@"visit_count",
                                     [NSNumber numberWithInt:0],@"share_sum",nil];
        if (arr.count > 0) {
            NSDictionary *dict = [arr lastObject];
            int count = [[dict objectForKey:@"visit_count"] intValue];
            [data setObject:[NSNumber numberWithInt:++count] forKey:@"visit_count"];
            [plMod updateDB:data];
        } else {
            [plMod insertDB:data];
        }
        
        [plMod release], plMod = nil;
        
        [pool release];
    });
}

@end
