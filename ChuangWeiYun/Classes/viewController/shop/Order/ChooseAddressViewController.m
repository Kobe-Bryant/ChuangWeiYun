//
//  ChooseAddressViewController.m
//  cw
//
//  Created by yunlai on 13-8-24.
//
//

#import "ChooseAddressViewController.h"
#import "AddAddressViewController.h"
#import "address_list_model.h"
#import "Common.h"
#import "Global.h"
#import "NetworkFail.h"
#import "MBProgressHUD.h"

@interface ChooseAddressViewController () <NetworkFailDelegate>
{
    NSIndexPath *selectIndexPath;
    NSIndexPath *deleteIndexPath;
    
    NetworkFail *failView;
}

@property (retain, nonatomic) NSIndexPath *selectIndexPath;
@property (retain, nonatomic) NSIndexPath *deleteIndexPath;

@end

@implementation ChooseAddressViewController

@synthesize tableViewC = _tableViewC;
@synthesize dataArr;
@synthesize cwStatusType;
@synthesize selectIndexPath;
@synthesize deleteIndexPath;
@synthesize delegate;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"收货地址";
    
    [self dataLoad];
    
    [_tableViewC reloadData];
    
    //chenfeng2013.10.15 add
    [self nullView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self viewLoad];
    
    //chenfeng2013.10.15 add
    _nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_address_default.png"] andText:@"您还没有留下收货地址哦~"];
    
}

// 排序  used为1 排第一
- (NSMutableArray *)addressListSort
{
    address_list_model *alMod = [[address_list_model alloc]init];
    NSMutableArray *arr = [alMod getList];
    [alMod release];
    if (arr.count > 0) {
        int index = 0;
        for (int i = 0; i < arr.count; i++) {
            if ([[[arr objectAtIndex:i] objectForKey:@"used"] intValue] == 1) {
                index = i;
                [arr exchangeObjectAtIndex:0 withObjectAtIndex:index];
                break;
            }
        }
    }
    
    return arr;
}

- (void)dataLoad
{
    dataArr = [[NSMutableArray alloc]initWithCapacity:0];

    self.dataArr = [self addressListSort];
    
    if (self.dataArr.count == 0) {
        [self accessItemService];
    }
}

- (void)viewLoad
{
    self.view.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f];
    
    _tableViewC = [[LoadTableView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight - KUpBarHeight) style:UITableViewStylePlain];
    _tableViewC.backgroundColor = [UIColor clearColor];
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewC.dataSource = self;
    _tableViewC.delegate = self;
    _tableViewC.loadDelegate = self;
    _tableViewC.isShowHeaderView = NO;
    _tableViewC.isShowFooterView = NO;
    [self.view addSubview:_tableViewC];
    
    UIImage *img = [UIImage imageCwNamed:@"add.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, img.size.width, img.size.height);
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageCwNamed:@"add_click.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(rightUpBarClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barBtn;
    [barBtn release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_tableViewC release], _tableViewC = nil;
    [dataArr release], dataArr = nil;
    if (failView) {
        [failView release], failView = nil;
    }
    RELEASE_SAFE(_nullView);
    [super dealloc];
}

- (void)rightUpBarClick:(UIButton *)btn
{
    AddAddressViewController *addAddress = [[AddAddressViewController alloc]init];
    addAddress.type = 1;
    [self.navigationController pushViewController:addAddress animated:YES];
    [addAddress release], addAddress = nil;
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

// 修改地址
#pragma mark - OrderAddressCellDelegate
- (void)modOrderAddressListCellBtn:(OrderAddressListCell *)acell
{
    address_list_model *alMod = [[address_list_model alloc]init];
    
    NSIndexPath *path = [_tableViewC indexPathForCell:acell];

    [acell set_bgViewborderColorState:YES];
    NSMutableDictionary *mutlDict = [self.dataArr objectAtIndex:path.row];
    [mutlDict setObject:@"1" forKey:@"used"];
    alMod.where = [NSString stringWithFormat:@"id = %d",[[mutlDict objectForKey:@"id"] intValue]];
    [alMod updateDB:mutlDict];

    if (self.selectIndexPath != nil) {
        OrderAddressListCell *selectcell = (OrderAddressListCell *)[_tableViewC cellForRowAtIndexPath:self.selectIndexPath];
        
        [selectcell set_bgViewborderColorState:NO];
        
        mutlDict = [self.dataArr objectAtIndex:self.selectIndexPath.row];
        [mutlDict setObject:@"0" forKey:@"used"];
        alMod.where = [NSString stringWithFormat:@"id = %d",[[mutlDict objectForKey:@"id"] intValue]];
        [alMod updateDB:mutlDict];
    }
    
    [alMod release];
    
    self.selectIndexPath = path;

    NSMutableDictionary *dict = [self.dataArr objectAtIndex:path.row];
    AddAddressViewController *addAddress = [[AddAddressViewController alloc]init];
    addAddress.type = 2;
    addAddress.addressDict = dict;
    [self.navigationController pushViewController:addAddress animated:YES];
    [addAddress release], addAddress = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"OrderAddressListCell";
    
    OrderAddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[OrderAddressListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.delegate = self;
    NSDictionary *dict = [self.dataArr objectAtIndex:indexPath.row];

    [cell setCellContentAndFrame:dict];
    
    if ([[dict objectForKey:@"used"] intValue] == 1) {
        self.selectIndexPath = indexPath;
        [cell set_bgViewborderColorState:YES];
    } else {
        [cell set_bgViewborderColorState:NO];
    }
    
    if ([self.selectIndexPath isEqual:indexPath]) {
        [cell set_bgViewborderColorState:YES];
        
        if ([delegate respondsToSelector:@selector(chooseAddressViewObject:)]) {
            NSMutableDictionary *dict = [self.dataArr objectAtIndex:self.selectIndexPath.row];
            [delegate chooseAddressViewObject:dict];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.dataArr objectAtIndex:indexPath.row];
    CGFloat height = [OrderAddressListCell getCellHeight:dict];
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popViewControllerAnimated:YES];//12.7 chenfeng
    
    if ([self.selectIndexPath isEqual:indexPath]) {
        return;
    }
    
    address_list_model *alMod = [[address_list_model alloc]init];

    OrderAddressListCell *cell = (OrderAddressListCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [cell set_bgViewborderColorState:YES];
    
    NSMutableDictionary *mutlDict = [self.dataArr objectAtIndex:indexPath.row];
    [mutlDict setObject:@"1" forKey:@"used"];
    alMod.where = [NSString stringWithFormat:@"id = %d",[[mutlDict objectForKey:@"id"] intValue]];
    [alMod updateDB:mutlDict];
    
    if (self.selectIndexPath != nil) {
        OrderAddressListCell *selectcell = (OrderAddressListCell *)[tableView cellForRowAtIndexPath:self.selectIndexPath];
        
        [selectcell set_bgViewborderColorState:NO];
        
        mutlDict = [self.dataArr objectAtIndex:self.selectIndexPath.row];
        [mutlDict setObject:@"0" forKey:@"used"];
        alMod.where = [NSString stringWithFormat:@"id = %d",[[mutlDict objectForKey:@"id"] intValue]];
        [alMod updateDB:mutlDict];
    }
    
    [alMod release];

    self.selectIndexPath = indexPath;
    
    if ([delegate respondsToSelector:@selector(chooseAddressViewObject:)]) {
        NSMutableDictionary *dict = [self.dataArr objectAtIndex:self.selectIndexPath.row];
        [delegate chooseAddressViewObject:dict];
    }
    
    
}

//删除的回调方法
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //判断 会员中心的我的收货地址可以删除 return yes 否则return no
    if (cwStatusType == StatusTypeMemberChooseAddress) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        int addressId=[[[self.dataArr objectAtIndex:indexPath.row]objectForKey:@"id"]intValue];
      
        [self accessDelAddressService:addressId];
        
        self.deleteIndexPath = indexPath;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删  除";
}

// 判断是否数据为空
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

#pragma mark - network
// 网络请求
- (void)accessItemService
{
    NSString *reqUrl = @"member/addresslist.do?param=";

    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",nil];

    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:ADDRESS_LIST_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

- (void)accessDelAddressService:(int)addressID
{
    NSString *reqUrl = @"deladdress.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       [NSString stringWithFormat:@"%d",addressID],@"id",
                                       nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:DEL_MEMBER_ADDRESS_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

- (void)accessItemMoreService
{
    NSString *reqUrl = @"member/addresslist.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       [[self.dataArr lastObject] objectForKey:@"created"],@"created",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:ADDRESS_LIST_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

// 网络请求成功后的数据解析
- (void)updateDataArr:(NSMutableArray *)arr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        self.dataArr = [self addressListSort];
        
        if (self.dataArr.count > 0 || ![[arr lastObject] isEqual:CwRequestFail]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _tableViewC.hidden = NO;
                [self nullView];
                [_tableViewC reloadData];
            });
        } else {
            // 错误处理
            dispatch_async(dispatch_get_main_queue(), ^{
                _tableViewC.hidden = YES;
                if ([[arr lastObject] isEqual:CwRequestTimeout]) {
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
            });
        }
    });
}

// 网络请求删除地址成功后的数据解析
- (void)deleteDataArr:(NSMutableArray *)arr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[arr lastObject] isEqual:CwRequestFail]) {
            address_list_model *alMod = [[address_list_model alloc]init];
            int addressId=[[[arr objectAtIndex:0]objectForKey:@"ret"]intValue];
            alMod.where=[NSString stringWithFormat:@"%d",addressId];
            [alMod deleteDBdata];
            [alMod release], alMod = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[arr lastObject] isEqual:CwRequestTimeout]) {
                    [self progressHUD:KCWServerBusyPrompt type:3];
                } else {
                    [self.dataArr removeObjectAtIndex:self.deleteIndexPath.row];
                    
                    [_tableViewC deleteRowsAtIndexPaths:@[self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    if ([self.selectIndexPath isEqual:self.deleteIndexPath]) {
                        self.selectIndexPath = nil;
                    }
                    
                    self.deleteIndexPath = nil;
                    
                    [self nullView];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([Common connectedToNetwork]) {
                    [self progressHUD:@"网络繁忙，删除失败，请稍后再试" type:0];
                } else {
                    [self progressHUD:KCWNetNOPrompt type:3];
                }
            });
        }
    });
}

// 网络请求更多成功后的数据解析
- (void)updateDataMoreArr:(NSMutableArray *)arr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[arr lastObject] isEqual:CwRequestFail]) {
            if (![[arr lastObject] isEqual:CwRequestTimeout]) {
                [self.dataArr addObjectsFromArray:arr];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[arr lastObject] isEqual:CwRequestTimeout]) {
                    [self progressHUD:KCWServerBusyPrompt type:3];
                } else {
                    [_tableViewC reloadData];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([Common connectedToNetwork]) {
                    [self progressHUD:KCWNetBusyPrompt type:0];
                } else {
                    [self progressHUD:KCWNetNOPrompt type:3];
                }
            });
        }
    });
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == ADDRESS_LIST_COMMAND_ID) {
        [self updateDataArr:resultArray];
    } else if (commandid == DEL_MEMBER_ADDRESS_COMMAND_ID){
        [self deleteDataArr:resultArray];
    } else if (commandid == ADDRESS_LIST_MORE_COMMAND_ID) {
        [self updateDataMoreArr:resultArray];
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
    [self accessItemMoreService];
}

- (void)loadTableViewUpRefresh:(LoadTableView *)tableView {}

- (void)loadDataFinish
{
    [_tableViewC loadTableViewDidFinishedWithMessage:nil];
}

@end
