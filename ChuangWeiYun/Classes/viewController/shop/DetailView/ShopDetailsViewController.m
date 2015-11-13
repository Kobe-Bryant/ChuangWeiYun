//
//  ShopDetailsViewController.m
//  cw
//
//  Created by yunlai on 13-8-15.
//
//

#import "ShopDetailsViewController.h"
#import "PopShareView.h"
#import "Common.h"
#import "Global.h"
#import "PopLikeView.h"
#import "member_likeshop_model.h"
#import "PopGuideView.h"
#import "shop_list_model.h"
#import "member_info_model.h"
#import "cloudLoadingView.h"
#import "apns_model.h"
#import "FileManager.h"
#import "MBProgressHUD.h"
#import "shop_log_model.h"
#import "PfShare.h"
#import "dqxx_model.h"
#import "NetworkFail.h"
#import "shop_near_list_model.h"
#import "NullstatusView.h"
#import "CustomTabBar.h"

@interface ShopDetailsViewController () <NetworkFailDelegate>
{
    int selectIndex;
    BOOL isLogin;
    cloudLoadingView *cloudLoading;
    
    BOOL mapFlag;
    NSMutableDictionary *likeDict;
    BOOL skipFlag;
    
    LoginBack loginBack;
    
    NetworkFail *failView;
    
    NullstatusView *nullView;
    
    NSMutableArray *shopList;
    
    BOOL shareFlag;
    
    BOOL islikes;
    
    BOOL isLikeing;
}

@property (retain, nonatomic) WeiboView *commentView;
@property (retain, nonatomic) NSMutableDictionary *likeDict;
@property (retain, nonatomic) NSMutableArray *shopList;

@end

@implementation ShopDetailsViewController

@synthesize scrollViewC = _scrollViewC;
@synthesize downBarView = _downBarView;
@synthesize dataArr;
@synthesize commentView;
@synthesize clickNum;
@synthesize productID;
@synthesize cwStatusType;
@synthesize delegate;
@synthesize likeDict;
@synthesize shopList;
@synthesize isEnd;
@synthesize shop_ID;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    mapFlag = NO;
    if (skipFlag) {
        skipFlag = NO;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.title = @"商品详情";
    
    if (loginBack == LoginBackOrderBack) {
        loginBack = LoginBackNomal;
//        [self skipOrderShopView];
        
    }else if (loginBack == LoginBackCommentBack) {
        loginBack = LoginBackNomal;
        
        WeiboView *weiboShare = [[WeiboView alloc]initWithString:@""];
        weiboShare.navController = self.navigationController;
        weiboShare.delegate = self;
        self.commentView = weiboShare;
        [weiboShare release];
        [self.commentView showWeiboView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (mapFlag) {
        return;
    }
    
    for (UIViewController *v in self.navigationController.viewControllers) {
        if ([v isKindOfClass:[CustomTabBar class]]) {
            CustomTabBar *tabbar = (CustomTabBar *)v;
            if (tabbar.selectedIndex == 1) {
                if (isLogin == NO) {
                    [self.navigationController setNavigationBarHidden:YES animated:YES];
                } else {
                    isLogin = NO;
                }
            }
        }
    }
    
//    if (cwStatusType == StatusTypeHotAD
//        || cwStatusType == StatusTypeHotShop
//        || cwStatusType == StatusTypeMemberShop
//        || cwStatusType == StatusTypePfDetail
//        || cwStatusType == StatusTypeFromCenter) {
//        
//    } else StatusTypePfDetail
    [self setLikeState];
    
    // 12.4chenfeng
    if (islikes) {
        NSNumber *selectRow = [NSNumber numberWithInt:selectIndex];
        if ([delegate respondsToSelector:@selector(isShopDelLikeSelectRow:)] && delegate) {
            [delegate performSelector:@selector(isShopDelLikeSelectRow:)withObject:selectRow];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    likeDict = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    if (self.cwStatusType == StatusTypeFromCenter  ||
        self.cwStatusType == StatusTypeHotShop     ||
        self.cwStatusType == StatusTypeHotAD       ||
        self.cwStatusType == StatusTypeMemberShop  ||
        self.cwStatusType == StatusTypeProductPush ||
        self.cwStatusType == StatusTypePfDetail) {
    } else {
        NSString *shopid = @"0";
        if (self.cwStatusType == StatusTypeMemberShopOrder) {
            shopid = self.shop_ID;
        } else {
            shopid = [Global sharedGlobal].shop_id;
        }
        shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
        snlMod.where = [NSString stringWithFormat:@"id = '%@'",shopid];
        NSMutableArray *arr = [snlMod getList];
        [snlMod release], snlMod = nil;
        self.shopList = arr;
    }
    
    selectIndex = self.clickNum;

    [self dataLoad];
    
    [self viewLoad];
    
    if (![PopGuideView isInsertTable:Guide_Enum_ShopLR]) {
        UIImage *img = nil;
        if (KUIScreenHeight > 500) {
            img = [UIImage imageCwNamed:@"left_right_shop2.png"];
        } else {
            img = [UIImage imageCwNamed:@"left_right_shop.png"];
        }
        PopGuideView *popGuideView = [[PopGuideView alloc]initWithImage:img index:Guide_Enum_ShopLR];
        [popGuideView addPopupSubview];
        [popGuideView release], popGuideView = nil;
    }
}

- (void)dataLoad
{
    if (self.dataArr.count == 0) {
        [self accessItemService];
    } else {
        // 点击商品次数
        [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
    }
}

- (void)viewLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    _scrollViewC = [[UITableScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight-KUpBarHeight-KDownBarHeight) clickIndex:self.clickNum pages:2];
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
    
    // 如果是会员中心进入到详情，需要隐藏这些数据
//    if (cwStatusType == StatusTypeMemberShop
//        || [[Global sharedGlobal].locationCity rangeOfString:[Global sharedGlobal].currCity].location == NSNotFound) {
//        _downBarView = [[DetailViewDownBar alloc]initWithFrame:CGRectMake(0.f, KUIScreenHeight-KDownBarHeight-KUpBarHeight, KUIScreenWidth, KDownBarHeight) type:SDButtonStateInfo]; //
//    } else {
        _downBarView = [[DetailViewDownBar alloc]initWithFrame:CGRectMake(0.f, KUIScreenHeight-KDownBarHeight-KUpBarHeight, KUIScreenWidth, KDownBarHeight) type:SDButtonStateDetail];
//    }
    [self setLikeState];
    [_downBarView setOrderBtnState:SDOrderBtnStateNO];
    _downBarView.delegate = self;
    [self.view addSubview:_downBarView];
    
    if (self.dataArr.count == 0) {
        _downBarView.hidden = YES;
    }
    
    [pool release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc
{
    NSLog(@"shopDetailsView dealloc......");
    
    [_scrollViewC release], _scrollViewC = nil;
    if (_downBarView) {
        [_downBarView release], _downBarView = nil;
    }
    [dataArr release], dataArr = nil;
    if (cloudLoading) {
        [cloudLoading release], cloudLoading = nil;
    }
    if (failView) {
        [failView release], failView = nil;
    }
    if (nullView) {
        RELEASE_SAFE(nullView);
    }
    
    self.productID = nil;
    [likeDict release], likeDict = nil;
    self.shopList = nil;
    [super dealloc];
}

- (void)popNavigation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    for (id cell in _scrollViewC.subviews) {
        if ([cell isKindOfClass:[ShopDetailsView class]]) {
            if (((ShopDetailsView *)cell).index == selectIndex) {
                [cell tableViewReloadData:nil shopList:nil type:ShopDetailsEnumReturn];
            } else {
                [cell tableViewReloadData:nil shopList:nil type:ShopDetailsEnumReturn];
            }
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [pool release];
}

// 得到member_likeshop信息
- (NSArray *)getMember_likeshop
{
    if (self.dataArr.count == 0) {
        return nil;
    }
    NSLog(@"self.dataArr = %@",self.dataArr);
    NSDictionary *dict = [self.dataArr objectAtIndex:selectIndex];
    NSString *pID = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"product_id"] intValue]];
    
    member_likeshop_model *mlMod = [[member_likeshop_model alloc]init];
    mlMod.where = [NSString stringWithFormat:@"produts_id = '%@'",pID];
    NSArray *arr = [mlMod getList];
    [mlMod release], mlMod = nil;
    
    if (![Global sharedGlobal].isLogin) {
        return nil;
    }
    
    return arr;
}
// 设置like状态
- (void)setLikeState
{
    NSArray *arr = [self getMember_likeshop];
    
    if (arr.count > 0
        || [[likeDict objectForKey:[NSString stringWithFormat:@"%d",selectIndex]] boolValue]) {
        [_downBarView setLikeBtnImageState:SDImageStateSure];
    } else {
        [_downBarView setLikeBtnImageState:SDImageStateCanel];
    }
}

// 设置orderbtn的状态
- (void)setOrderBtnState
{
    if (self.shopList.count > 0) {
        [_downBarView setOrderBtnState:SDOrderBtnStateNO];
    } else {
        [_downBarView setOrderBtnState:SDOrderBtnStateYes];
    }
}

// 分享按钮
- (void)btnRightClick:(UIButton *)btn
{
    if (!shareFlag) {
        NSString *infoid = [NSString stringWithFormat:@"%d",[[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"product_id"] intValue]];
        [Global sharedGlobal].info_id = infoid;
        if (self.cwStatusType == StatusTypeFromCenter) {
            [PfShare defaultSingle].getPf = Share_Get_Pf_ShopCen;
        } else {
            [PfShare defaultSingle].getPf = Share_Get_Pf_Shop;
        }
        [PfShare defaultSingle].share_gift = [[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"share_gift"] intValue];
        [[PopShareView defaultExample] showPopupView:self.navigationController delegate:self];
    }
}

// 刷新当前页
- (void)updateCurrPage:(NSMutableDictionary *)modDict type:(ShopDetailsEnum)type
{
    for (id cell in _scrollViewC.subviews) {
        if ([cell isKindOfClass:[ShopDetailsView class]]) {
            if (((ShopDetailsView *)cell).index == selectIndex) {
                [cell tableViewReloadData:modDict shopList:self.shopList type:type];
            }
        }
    }
}

// 更新商品表
- (void)updateShopListDB:(NSDictionary *)moddict
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *pid = [moddict objectForKey:@"product_id"];
    NSLog(@"pid = %@",pid);
    shop_list_model *slMod = [[shop_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"product_id = '%@'",pid];
    NSArray *arr = [slMod getList];
    if (arr.count > 0) {
        [slMod updateDB:moddict];
    }
    [slMod release], slMod = nil;
    
    [pool release];
}

// 赞数据更新
- (NSMutableDictionary *)likeDataUpdate:(BOOL)update
{
    NSLog(@"self.dataArr = %@",self.dataArr);
    // 赞数据
    NSMutableDictionary *modDict = [NSMutableDictionary dictionaryWithDictionary:[self.dataArr objectAtIndex:selectIndex]];
    [self.dataArr removeObjectAtIndex:selectIndex];
    
    int likeNum = [[modDict objectForKey:@"like_sum"] intValue];
    NSLog(@"dufu   ......     update = %d",update);
    if (update == YES) {
        [modDict setObject:[NSNumber numberWithInt:likeNum + 1] forKey:@"like_sum"];
    } else {
        [modDict setObject:[NSNumber numberWithInt:likeNum - 1] forKey:@"like_sum"];
    }
    
    [self.dataArr insertObject:modDict atIndex:selectIndex];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if ([Global sharedGlobal].isLogin) {
        // 会员表
        member_info_model *miMod = [[member_info_model alloc]init];
        miMod.where = [NSString stringWithFormat:@"id = '%@'",[Global sharedGlobal].user_id];
        NSArray *miArr = [miMod getList];
        
        // 赞过ID表
        NSString *pid = [modDict objectForKey:@"product_id"];
        member_likeshop_model *mlMod = [[member_likeshop_model alloc]init];
        mlMod.where = [NSString stringWithFormat:@"product_id = '%@'",pid];
        NSArray *mlArr = [mlMod getList];
        
        if (update) {
            // 增加赞数
            if (miArr.count > 0) {
                NSMutableDictionary *miDict = [miArr lastObject];
                int countlikes = [[miDict objectForKey:@"countlikes"] intValue];
                [miDict setObject:[NSString stringWithFormat:@"%d",countlikes + 1] forKey:@"countlikes"];
                [miMod updateDB:miDict];
            }
            
            // 增加id
            if (mlArr.count == 0) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [Global sharedGlobal].user_id,@"userId",
                                      pid,@"produts_id", nil];
                [mlMod insertDB:dict];
            }
        } else {
            // 减少赞数
            if (miArr.count > 0) {
                NSMutableDictionary *miDict = [miArr lastObject];
                int countlikes = [[miDict objectForKey:@"countlikes"] intValue];
                [miDict setObject:[NSString stringWithFormat:@"%d",countlikes - 1] forKey:@"countlikes"];
                [miMod updateDB:miDict];
            }
            
            // 减少id
            if (mlArr.count > 0) {
                [mlMod deleteDBdata];
            }
        }
        
        [mlMod release], mlMod = nil;
        [miMod release], miMod = nil;
    }
    
    [pool release];
    
    return modDict;
}

// 赞弹窗
- (void)poplikeWindow:(PopLikeEnum)type
{
    PopLikeView *poplike = [[PopLikeView alloc]init];
    [poplike addPopupSubviewType:type];
    [poplike release], poplike = nil;
}

// 跳转到预订页面
- (void)skipOrderShopView
{
    OrderShopViewController *orderShop = [[OrderShopViewController alloc]init];
    NSDictionary *dict = [self.dataArr objectAtIndex:selectIndex];
    NSLog(@"dataArr=%@",dict);
    orderShop.shopDict = dict;
    orderShop.shopList = self.shopList;
    orderShop.delegate = self;
    [self.navigationController pushViewController:orderShop animated:YES];
    [orderShop release];
}

#pragma mark - DetailViewDownBarDelegate
- (void)detailDownBarEvent:(SDButtonDB)sdButton
{
    switch (sdButton) {
        case SDButtonDBCommets:    // 评论
        {
            NSLog(@"SDButtonDBCommets.......");
            if (![Global sharedGlobal].isLogin) {
                isLogin = YES;
                LoginViewController *loginView = [[LoginViewController alloc]init];
                loginView.delegate = self;
                loginView.cwStatusType = StatusTypeMemberLogin;
                loginView.cwBackType = LoginBackCommentBack;
                [self.navigationController pushViewController:loginView animated:YES];
                [loginView release], loginView = nil;
            } else {
                WeiboView *weiboShare = [[WeiboView alloc]initWithString:@""];
                weiboShare.navController = self.navigationController;
                weiboShare.delegate = self;
                self.commentView = weiboShare;
                [weiboShare release];
                [self.commentView showWeiboView];
            }
        }
            break;
        case SDButtonDBOrder:       // 预订
        {
            if (![Global sharedGlobal].isLogin) {
                isLogin = YES;
                LoginViewController *loginView = [[LoginViewController alloc]init];
                loginView.cwStatusType = StatusTypeMemberLogin;
                loginView.delegate = self;
                loginView.cwBackType = LoginBackOrderBack;
                [self.navigationController pushViewController:loginView animated:YES];
                [loginView release], loginView = nil;
            } else {
                [self skipOrderShopView];
            }
        }
            break;
        case SDButtonDBLike:        // 喜欢
        {
            if (isLikeing) {
                [self progressHUD:@"您已经点过赞了哦" type:3];
                return;
            }
            islikes = 0;
            if ([self getMember_likeshop].count > 0
                || [[likeDict objectForKey:[NSString stringWithFormat:@"%d",selectIndex]] boolValue]) {
                [self accessItemCanelLikeService];
                islikes = 1;
            } else {
                [self accessItemLikeService];
                islikes = 0;
            } 
            
        }
            break;
        default:
            break;
    }
}

// 登陆成功后
#pragma makr - loginSuccessBackCtl
- (void)loginSuccessBackCtl:(LoginBack)cwBackType
{
    loginBack = cwBackType;
    NSLog(@"loginBack = %d",loginBack);
    
    if (cwStatusType != StatusTypeMemberShop) {
        [self setLikeState];
    }
}

#pragma mark - WeiboViewDelegate
- (void)weiboViewSendComment:(NSString *)text       // 评论
{
    [self accessItemCommentService:text];
}

#pragma mark - OrderShopViewControllerDelegate
- (void)orderShopViewSuccessNum                     // 预订成功
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (cwStatusType == StatusTypeNormal) {
            // 预订数据
            NSMutableDictionary *modDict = [self.dataArr objectAtIndex:selectIndex];
            int saleNum = [[modDict objectForKey:@"sale_sum"] intValue];
            [modDict setObject:[NSString stringWithFormat:@"%d",saleNum + 1] forKey:@"sale_sum"];
            
            // 会员表
            member_info_model *miMod = [[member_info_model alloc]init];
            miMod.where = [NSString stringWithFormat:@"id = '%@'",[Global sharedGlobal].user_id];
            NSArray *miArr = [miMod getList];
            if (miArr.count > 0) {
                // 增加预订数
                NSMutableDictionary *miDict = [miArr lastObject];
                int countorder = [[miDict objectForKey:@"countorder"] intValue];
                [miDict setObject:[NSString stringWithFormat:@"%d",countorder + 1] forKey:@"countorder"];
                [miMod updateDB:miDict];
            }
            [miMod release], miMod = nil;
            
            // 更新表
            [self updateShopListDB:modDict];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新当前页的评论
                [self updateCurrPage:modDict type:ShopDetailsEnumOrder];
            });
        }
    });
    
    [pool release];
}

// 分享
#pragma mark - ShareAPIActionDelegate
- (NSDictionary *)shareApiActionReturnValue
{
    [Global sharedGlobal].countObj_id = [NSString stringWithFormat:@"%d",[[[self.dataArr objectAtIndex:selectIndex] objectForKey:@"id"] intValue]];
    [Global sharedGlobal]._countType = CountTypeProduct;
    
    NSString *url = nil;
    apns_model *aMod = [[apns_model alloc]init];
    NSArray *arr = [aMod getList];
    if (arr.count > 0) {
        NSDictionary *amodDict = [arr lastObject];
        url = [amodDict objectForKey:@"client_downurl"];
    }
    [aMod release], aMod = nil;
    
    NSDictionary *adict = [self.dataArr objectAtIndex:selectIndex];
    
    NSString *content = [NSString stringWithFormat:@"我刚刚预订了【%@】，真心不错，快来看看吧！%@ （分享自@创维云GO）",
                         [adict objectForKey:@"name"],
//                         [adict objectForKey:@"content"],
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
    NSLog(@"shareApiActionReturnValue  url = %@",url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          content, ShareContent,
                          url, ShareUrl,
                          [adict objectForKey:@"name"], ShareTitle,
                          pic, ShareImage, nil];
    
    return dict;
}

#pragma mark - UITableScrollViewDelagate
- (NSInteger)tableScrollViewNumberOfRow:(UITableScrollView *)tableScrollView
{
    return self.dataArr.count;
}

- (UITableScrollViewCell *)tableScrollView:(UITableScrollView *)tableScrollView viewForRowAtIndex:(NSInteger)index
{
    ShopDetailsView *cell = [tableScrollView dequeueRecycledPage];
    if (cell == nil) {
        
        cell = [[[ShopDetailsView alloc] initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight-KUpBarHeight-KDownBarHeight - 1)] autorelease];
        cell.navViewController = self.navigationController;
        cell.cwStatusType = self.cwStatusType;
        [cell createView];
    }
    
    cell.proID = self.productID;
    cell.delegate = self;
    cell.isEnd = self.isEnd;
    //    NSLog(@"self.productID = %@",self.productID);
    //    NSLog(@"cell.proID = %@",cell.proID);
    NSDictionary *dict = [self.dataArr objectAtIndex:index];
    
    NSLog(@"self.shopList ,.,. = %@",self.shopList);
    [cell tableViewReloadData:dict shopList:self.shopList type:ShopDetailsEnumNormal];
    
    return cell;
}

- (void)tableScrollView:(UITableScrollView *)tableScrollView didSelectRowAtIndex:(NSInteger)index beforeIndex:(NSInteger)aindex
{
    NSLog(@"tableScrollView index = %d",index);
    selectIndex = index;
    
    if (cwStatusType != StatusTypeMemberShop) {
        [self setLikeState];
    }
    
    [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
}

#pragma mark - ShopDetailsViewDelegate
- (void)shopDetailsViewFlag:(BOOL)flag
{
    mapFlag = flag;
}


// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService];
}

#pragma mark - 网络请求自定义
// 网络请求商品
- (void)accessItemService
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    shareFlag = YES;
    //添加loading图标
    if (cloudLoading == nil) {
        cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
        [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    }
    [self.view addSubview:cloudLoading];

    NSString *reqUrl = @"product/detail.do?param=";
    
    NSString *shopId = nil;
    if (self.cwStatusType == StatusTypeFromCenter
        || self.cwStatusType == StatusTypeHotShop
        || self.cwStatusType == StatusTypeHotAD
        || self.cwStatusType == StatusTypeMemberShop
        || self.cwStatusType == StatusTypeProductPush
        || self.cwStatusType == StatusTypePfDetail) {
        shopId = @"0";
    } else {
        if (self.cwStatusType == StatusTypeMemberShopOrder) {
            shopId = self.shop_ID;
        } else if ([Global sharedGlobal].shop_id == nil) {
            shopId = @"0";
        }else {
            shopId = [Global sharedGlobal].shop_id;
        }
    }
	
    double lon = [Global sharedGlobal].myLocation.longitude;
    double lat = [Global sharedGlobal].myLocation.latitude;
    
    //NSLog(@"currCity ==== %@",[Global sharedGlobal].currCity);
    NSString *cityId = nil;
    dqxx_model *dqxxModel = [[dqxx_model alloc] init];
    dqxxModel.where = [NSString stringWithFormat:@"DQXX02 = '%@'",[Global sharedGlobal].currCity];
//    dqxxModel.where = [NSString stringWithFormat:@"DQXX02 = '%@'",@"重庆市"];
    NSArray *arr = [dqxxModel getList];
    NSLog(@"cityId  arr = %@",arr);
    if ([arr count] > 0) {
        cityId = [[arr lastObject] objectForKey:@"DQXX01"];
    }else {
        cityId = @"0";
    }
    
//    cityId = @"429004";

    dqxxModel.where = nil;
    [dqxxModel release];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shopId,@"shop_id",
                                       self.productID,@"product_id",
                                       [NSNumber numberWithDouble:lon],@"longitude",
                                       [NSNumber numberWithDouble:lat],@"latitude",
//                                       @"113.421934",@"longitude",
//                                       @"30.361655",@"latitude",
                                       cityId,@"city_id",nil];
    //    NSLog(@"== %@",requestDic);
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SHOP_DETAIL_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

// 网络请求评论
- (void)accessItemCommentService:(NSString *)str
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *reqUrl = @"member/comment.do?param=";
	
    NSString *shopID = @"0";
    if (self.cwStatusType == StatusTypeFromCenter
        || self.cwStatusType == StatusTypeHotShop
        || self.cwStatusType == StatusTypeHotAD
        || self.cwStatusType == StatusTypeMemberShop
        || self.cwStatusType == StatusTypeProductPush
        || self.cwStatusType == StatusTypePfDetail) {
        shopID = @"0";
    } else {
        if (self.cwStatusType == StatusTypeMemberShopOrder) {
            shopID = self.shop_ID;
        } else {
            if ([Global sharedGlobal].shop_id.length != 0) {
                shopID = [Global sharedGlobal].shop_id;
            }
        }
    }
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shopID,@"shop_id",
                                       @"1",@"type",
                                       [Global sharedGlobal].user_id,@"user_id",
                                       [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"product_id"],@"info_id",
                                       str,@"content",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:COMMENT_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

// 网络请求喜欢
- (void)accessItemLikeService
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *reqUrl = @"member/like.do?param=";
    
    isLikeing = YES;
    
	NSString *shopId = @"0";
    if (self.cwStatusType == StatusTypeFromCenter
        || self.cwStatusType == StatusTypeHotShop
        || self.cwStatusType == StatusTypeHotAD
        || self.cwStatusType == StatusTypeMemberShop
        || self.cwStatusType == StatusTypeProductPush
        || self.cwStatusType == StatusTypePfDetail) {
        shopId = @"0";
    } else {
        if (self.cwStatusType == StatusTypeMemberShopOrder) {
            shopId = self.shop_ID;
        } else {
            if ([Global sharedGlobal].shop_id != 0) {
                shopId = [Global sharedGlobal].shop_id;
            }
        }
    }
    
    NSMutableDictionary *requestDic = nil;
    if ([Global sharedGlobal].isLogin) {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      shopId,@"shop_id",
                      @"1",@"like_type",
                      [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"product_id"],@"relation_id",
                      [Global sharedGlobal].user_id,@"user_id",nil];
    } else {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      shopId,@"shop_id",
                      @"1",@"like_type",
                      [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"product_id"],@"relation_id",nil];
    }
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:LIKE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

// 网络请求删除喜欢
- (void)accessItemCanelLikeService
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *reqUrl = @"member/dellike.do?param=";
	
    isLikeing = YES;
    
    NSMutableDictionary *requestDic = nil;
    
    if ([Global sharedGlobal].isLogin) {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"1",@"type",
                      [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"product_id"],@"relation_id",
                      [Global sharedGlobal].user_id,@"user_id",nil];
    } else {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"1",@"type",
                      [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"product_id"],@"relation_id",nil];
    }
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:MEMBER_SHOPDELLIKE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view
                                            frame:self.view.bounds
                                         failView:failView
                                         delegate:self
                                          andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
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

// 商品详情逻辑
- (void)didFinishShopDeletl:(NSMutableArray *)resultArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 是否下架
        BOOL publish = NO;
        
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            if (resultArray.count > 0) {
                [self.dataArr removeAllObjects];
                
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    NSDictionary *dict = [[resultArray lastObject] objectForKey:@"product"];
                    if (dict.count > 0) {
                        
                        publish = [[dict objectForKey:@"publish"] intValue];
                        
                        NSMutableArray *arr = [NSMutableArray arrayWithObjects:dict,nil];
                        self.dataArr = arr;
                        
                        if (self.cwStatusType == StatusTypeFromCenter
                            || self.cwStatusType == StatusTypeHotShop
                            || self.cwStatusType == StatusTypeHotAD
                            || self.cwStatusType == StatusTypeMemberShop
                            || self.cwStatusType == StatusTypeProductPush
                            || self.cwStatusType == StatusTypePfDetail) {
                            self.shopList = [[resultArray lastObject] objectForKey:@"shops"];
                        }
                        
                        [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cloudLoading removeFromSuperview];
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    _downBarView.hidden = YES;
                    _scrollViewC.hidden = YES;
                    nullView.hidden = YES;
                    // 服务器繁忙，请重新再试
                    [self failViewCreate:CwTypeViewNoService];
                } else {
                    
                    if (resultArray.count > 0 && self.dataArr.count > 0 && publish) {
                    //if (resultArray.count > 0 && self.dataArr.count > 0) {
                        shareFlag = NO;
                        _downBarView.hidden = NO;
                        [self setOrderBtnState];
                        _scrollViewC.hidden = NO;
                        nullView.hidden = YES;
                        [_scrollViewC reloadView];
                        
                        [self setLikeState];
                    } else {
                        _downBarView.hidden = YES;
                        _scrollViewC.hidden = YES;
                        if (nullView == nil) {
                            nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_goods_default.png"]
                                                                          andText:@"很抱歉您查看的商品不存在,可能已下架"];
                        }
                        nullView.hidden = NO;
                        [self.view addSubview:nullView];
                    }
                }
            } else {
                _downBarView.hidden = YES;
                _scrollViewC.hidden = YES;
                nullView.hidden = YES;
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
    
    [pool release];
}

// 赞逻辑
- (void)didFinishLike:(NSMutableArray *)resultArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isLikeing = NO;
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                if (resultArray.count > 0) {
                    int state = [[resultArray lastObject] intValue];
                    if (state == 1) {
                        [likeDict setObject:[NSNumber numberWithBool:YES]
                                     forKey:[NSString stringWithFormat:@"%d",selectIndex]];
                        
                        // 赞数据
                        NSMutableDictionary *modDict = [self likeDataUpdate:YES];
                        
                        if (cwStatusType != StatusTypeHotAD
                            || cwStatusType != StatusTypeHotShop
                            || cwStatusType != StatusTypeMemberShop
                            || cwStatusType != StatusTypePfDetail) {
                            // 更新表
                            [self updateShopListDB:modDict];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // 赞弹窗
                            [self poplikeWindow:PopLikeEnumAdd];
                            
                            // 刷新当前页的赞状态
                            [self setLikeState];
                            
                            // 刷新当前页的赞数字
                            [self updateCurrPage:modDict type:ShopDetailsEnumLike];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self progressHUD:@"网络繁忙，请稍后再试" type:0];
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self progressHUD:@"网络繁忙，请稍后再试" type:0];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self progressHUD:KCWServerBusyPrompt type:0];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([Common connectedToNetwork]) {
                    [self progressHUD:@"网络繁忙，赞失败，请稍后再试" type:0];
                } else {
                    [self progressHUD:KCWNetNOPrompt type:3];
                }
            });
        }
    });
    
    [pool release];
}

// 取消赞逻辑
- (void)didFinishDellike:(NSMutableArray *)resultArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isLikeing = NO;
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                if (resultArray.count > 0) {
                    NSString *str = [NSString stringWithFormat:@"%d",[[[resultArray lastObject] objectForKey:@"ret"] intValue]];
                    if (str.length != 0) {
                        int state = [str intValue];
                        if (state == 1) {
                            NSString *pID = [[self.dataArr objectAtIndex:selectIndex] objectForKey:@"product_id"];
                            member_likeshop_model *mlMod = [[member_likeshop_model alloc]init];
                            mlMod.where = [NSString stringWithFormat:@"produts_id = '%@'",pID];
                            [mlMod deleteDBdata];
                            [mlMod release], mlMod = nil;
                            
                            [likeDict removeObjectForKey:[NSString stringWithFormat:@"%d",selectIndex]];
                            
                            // 赞数据
                            NSMutableDictionary *modDict = [self likeDataUpdate:NO];
                            
                            if (cwStatusType != StatusTypeHotAD
                                || cwStatusType != StatusTypeHotShop
                                || cwStatusType != StatusTypeMemberShop
                                || cwStatusType != StatusTypePfDetail) {
                                // 更新表
                                [self updateShopListDB:modDict];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // 赞弹窗
                                [self poplikeWindow:PopLikeEnumMinusAdd];
                                
                                // 刷新当前页的赞状态
                                [self setLikeState];
                                
                                // 刷新当前页的赞数字
                                [self updateCurrPage:modDict type:ShopDetailsEnumDelike];
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self progressHUD:@"取消赞失败" type:0];
                            });
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self progressHUD:@"取消赞失败" type:0];
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self progressHUD:@"取消赞失败" type:0];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self progressHUD:KCWServerBusyPrompt type:0];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([Common connectedToNetwork]) {
                    [self progressHUD:@"网络繁忙，取消赞失败，请稍后再试" type:0];
                } else {
                    [self progressHUD:KCWNetNOPrompt type:3];
                }
            });
        }
    });
    
    [pool release];
}

// 评论逻辑
- (void)didFinishComment:(NSMutableArray *)resultArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                if ([[resultArray lastObject] intValue] == 1) {
                    NSLog(@"self.dataArr = %@",self.dataArr);
                    // 评论数据
                    NSMutableDictionary *modDict = [NSMutableDictionary dictionaryWithDictionary:[self.dataArr objectAtIndex:selectIndex]];
                    [self.dataArr removeObjectAtIndex:selectIndex];
                    int commentNum = [[modDict objectForKey:@"comment_sum"] intValue] + 1;
                    [modDict setObject:[NSString stringWithFormat:@"%d",commentNum] forKey:@"comment_sum"];
                    [self.dataArr insertObject:modDict atIndex:selectIndex];
                    
                    // 会员表
                    member_info_model *miMod = [[member_info_model alloc]init];
                    miMod.where = [NSString stringWithFormat:@"id = '%@'",[Global sharedGlobal].user_id];
                    NSArray *miArr = [miMod getList];
                    if (miArr.count > 0) {
                        // 增加评论数
                        NSMutableDictionary *miDict = [miArr lastObject];
                        int countcomment = [[miDict objectForKey:@"countcomment"] intValue];
                        [miDict setObject:[NSString stringWithFormat:@"%d",countcomment + 1] forKey:@"countcomment"];
                        [miMod updateDB:miDict];
                    }
                    [miMod release], miMod = nil;
                    
                    // 更新表
                    [self updateShopListDB:modDict];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 刷新当前页的评论
                        [self updateCurrPage:modDict type:ShopDetailsEnumComment];
                        [self progressHUD:@"评论成功" type:1];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self progressHUD:@"评论失败" type:0];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self progressHUD:KCWServerBusyPrompt type:0];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([Common connectedToNetwork]) {
                    [self progressHUD:@"网络繁忙，评论失败，请稍后再试" type:0];
                } else {
                    [self progressHUD:KCWNetNOPrompt type:3];
                }
            });
        }
    });
    
    [pool release];
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == SHOP_DETAIL_COMMAND_ID) {                  // 商品详情
        [self didFinishShopDeletl:resultArray];
    } else if (commandid == LIKE_COMMAND_ID) {                  // 赞
        [self didFinishLike:resultArray];
    } else if (commandid == MEMBER_SHOPDELLIKE_COMMAND_ID) {    // 取消赞
        [self didFinishDellike:resultArray];
    } else if (commandid == COMMENT_COMMAND_ID) {               // 评论
        [self didFinishComment:resultArray];
    }
}

@end
