//
//  CouponsViewController.m
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import "CouponsViewController.h"
#import "PfCommonViewController.h"
#import "CouponsCell.h"
#import "favorable_list_model.h"
#import "cloudLoadingView.h"
#import "Common.h"
#import "NetworkFail.h"
#import "PreferentialObject.h"
#import "MBProgressHUD.h"

@interface CouponsViewController () <UITableViewDataSource, UITableViewDelegate, NetworkFailDelegate>
{
    LoadTableView *_tableViewC;
    
    cloudLoadingView *cloudLoading;
    
    NetworkFail *failView;
}

@property (retain, nonatomic) LoadTableView *tableViewC;

@end

@implementation CouponsViewController

@synthesize tableViewC = _tableViewC;
@synthesize dataArr;
@synthesize cwStatusType;
@synthesize delegate;
@synthesize shopID;
@synthesize productID;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"[Global sharedGlobal].user_id = %@",[Global sharedGlobal].user_id);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (cwStatusType != StatusTypeMemberChoosePf) {
        self.title = @"选择优惠券";
    } else {
        self.title = @"我的优惠券";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self viewLoad];
    
    [self dataLoad];
    
    if (cwStatusType == StatusTypeMemberChoosePf) {
        _nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_coupons_default.png"]
                                                       andText:@"您还没有优惠劵哦~"];
    } else {
        _nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_coupons_default.png"]
                                                       andText:@"没有可用的优惠券\n试一试分享商品即得优惠券"];
    }
}

- (void)dataLoad
{
    if (cwStatusType == StatusTypeMemberChoosePf) {
        [self accessItemCouponsService];
    } else {
        // 得到可用的优惠券数据
        [self accessBookCouponsService];
    }
}

- (void)viewLoad
{
    self.view.backgroundColor = KCWViewBgColor;

    _tableViewC = [[LoadTableView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight - KUpBarHeight) style:UITableViewStylePlain];
    _tableViewC.backgroundColor = [UIColor clearColor];
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewC.dataSource = self;
    _tableViewC.delegate = self;
    _tableViewC.loadDelegate = self;
    _tableViewC.isShowHeaderView = NO;
    _tableViewC.isShowFooterView = NO;
    [self.view addSubview:_tableViewC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_tableViewC release], _tableViewC = nil;
    self.dataArr = nil;
    if (cloudLoading) {
        [cloudLoading release], cloudLoading = nil;
    }
    if (failView) {
        [failView release], failView = nil;
    }
    RELEASE_SAFE(_nullView);
    [super dealloc];
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    if (self.shopID.length > 0) {
        [self accessBookCouponsService];
    } else {
        [self accessItemCouponsService];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"OrderAddressListCell";
    
    CouponsCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[CouponsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dict = [self.dataArr objectAtIndex:indexPath.row];
    
    [cell setCellContentAndFrame:dict];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    
    height = [CouponsCell getCellHeight];
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.dataArr objectAtIndex:indexPath.row];

    if (cwStatusType != StatusTypeMemberChoosePf) {
        if ([delegate respondsToSelector:@selector(getCouponsTitle:money:couponsid:)]) {
            [delegate getCouponsTitle:[dict objectForKey:@"title"] money:[[dict objectForKey:@"discount"] intValue] couponsid:[[dict objectForKey:@"id"] intValue]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        PfCommonViewController *pfCommonView = [[PfCommonViewController alloc]init];
        pfCommonView.codeID = [dict objectForKey:@"billno"];
        pfCommonView.codeUrl = [dict objectForKey:@"url"];
        pfCommonView.dict = dict;
        pfCommonView.pfCommon = 1;
        [self.navigationController pushViewController:pfCommonView animated:YES];
        [pfCommonView release], pfCommonView = nil;
    }
}

#pragma mark - network
// 立即抢购优惠券
- (void)accessBookCouponsService
{
    //添加loading图标
    if (cloudLoading == nil) {
        cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake(0.f , 0.f , 64.f , 43.f)];
        [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    }
    [self.view addSubview:cloudLoading];
    
    NSString *reqUrl = @"book/coupons.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       self.shopID,@"shop_id",
                                       self.productID,@"product_id",
                                       nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:BOOK_COUPONS_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 立即抢购 更多
- (void)accessItemBookMoreService
{
    NSString *reqUrl = @"book/coupons.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       self.shopID,@"shop_id",
                                       self.productID,@"product_id",
                                       [[self.dataArr lastObject] objectForKey:@"get_time"],@"get_time", nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:BOOK_COUPONS_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 我的优惠券
- (void)accessItemCouponsService
{
    //添加loading图标
    if (cloudLoading == nil) {
        cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake(0.f , 0.f , 64.f , 43.f)];
        [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    }
    [self.view addSubview:cloudLoading];
    
    NSString *reqUrl = @"member/favorablelist.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:FAVORABLE_LIST_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 我的优惠券 更多
- (void)accessItemCouponsMoreService
{
    NSString *reqUrl = @"member/favorablelist.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       [[self.dataArr lastObject] objectForKey:@"get_time"],@"get_time", nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:FAVORABLE_LIST_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
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

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

- (void)nullView
{
    if ([self.dataArr count] == 0) {
        if (_nullView.superview == nil) {
            [self.view addSubview:_nullView];
        }
    }else{
        if (_nullView.superview) {
            [_nullView removeNullView];
        }
    }
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == BOOK_COUPONS_COMMAND_ID) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    self.dataArr = resultArray;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [cloudLoading removeFromSuperview];
                if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                    if ([[resultArray lastObject] isEqual:CwRequestFail]) {
                        // 服务器繁忙，请重新再试
                        [self failViewCreate:CwTypeViewNoService];
                    } else {
                        if (self.dataArr.count >= 20) {
                            _tableViewC.isShowFooterView = YES;
                        } else {
                            _tableViewC.isShowFooterView = NO;
                        }
                        
                        _tableViewC.hidden = NO;
                        
                        [self nullView];
                        
                        [_tableViewC reloadData];
                    }
                } else {
                    _tableViewC.hidden = YES;
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
    } else if (commandid == BOOK_COUPONS_MORE_COMMAND_ID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    if (resultArray.count > 0) {
                        [self.dataArr addObjectsFromArray:resultArray];
                    }
                }
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadDataFinish];
                    if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                        [self progressHUD:KCWServerBusyPrompt type:3];
                    } else {
                        if (self.dataArr.count % 20 == 0 && resultArray.count != 0) {
                            _tableViewC.isShowFooterView = YES;
                        } else {
                            _tableViewC.isShowFooterView = NO;
                        }
                        
                        [_tableViewC reloadData];
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadDataFinish];
                    if ([Common connectedToNetwork]) {
                        [self progressHUD:KCWNetBusyPrompt type:0];
                    } else {
                        [self progressHUD:KCWNetNOPrompt type:3];
                    }
                });
            }
        });
    } else if (commandid == FAVORABLE_LIST_COMMAND_ID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            favorable_list_model *flMod = [[favorable_list_model alloc]init];
            NSMutableArray *arr = [flMod getList];
            [flMod release], flMod = nil;
            NSMutableArray *mArr = [PreferentialObject addPicToCouponsMutableArray:arr];
            // 降序排序
            self.dataArr = mArr;//[Common sortInt:mArr field:@"created" sort:SortEnumDesc];
            NSLog(@"self.dataArr = %@",self.dataArr);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [cloudLoading removeFromSuperview];
                
                if (self.dataArr.count >= 20) {
                    _tableViewC.isShowFooterView = YES;
                } else {
                    _tableViewC.isShowFooterView = NO;
                }
                
                if (![[resultArray lastObject] isEqual:CwRequestFail] || self.dataArr.count > 0) {
                    _tableViewC.hidden = NO;
                    
                    [self nullView];
                    
                    [_tableViewC reloadData];
                } else {
                    _tableViewC.hidden = YES;
                    if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                        // 服务器繁忙，请重新再试
                        [self failViewCreate:CwTypeViewNoService];
                    } else {
                        if ([Common connectedToNetwork]) {
                            // 网络繁忙，请重新再试
                            [self failViewCreate:CwTypeViewNoRequest];
                        } else {
                            // 当前网络不可用，请重新再试
                            [self failViewCreate:CwTypeViewNoNetWork];
                        }
                    }
                }
            });
        });
    } else if (commandid == FAVORABLE_LIST_MORE_COMMAND_ID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    [self.dataArr addObjectsFromArray:resultArray];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self loadDataFinish];
                    
                    if (self.dataArr.count % 20 == 0 && resultArray.count != 0) {
                        _tableViewC.isShowFooterView = YES;
                    } else {
                        _tableViewC.isShowFooterView = NO;
                    }
                    if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                        [self progressHUD:KCWServerBusyPrompt type:3];
                    } else {
                        [_tableViewC reloadData];
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadDataFinish];
                    if ([Common connectedToNetwork]) {
                        [self progressHUD:KCWNetBusyPrompt type:0];
                    } else {
                        [self progressHUD:KCWNetNOPrompt type:3];
                    }
                });
            }
        });
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tableViewC loadTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_tableViewC loadTableViewDidEndDragging:scrollView];
}

#pragma mark - loadTableViewDidScroll
- (void)loadTableViewDownRefresh:(LoadTableView *)tableView
{
    [self accessItemCouponsMoreService];
}

- (void)loadTableViewUpRefresh:(LoadTableView *)tableView {}

- (void)loadDataFinish
{
    [_tableViewC loadTableViewDidFinishedWithMessage:nil];
}

@end
