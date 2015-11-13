//
//  CitySubbranchViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "CitySubbranchViewController.h"
#import "cwAppDelegate.h"
#import "Common.h"
#import "Global.h"
#import "shop_near_list_model.h"
#import "CustomTabBar.h"
#import "callSystemApp.h"
#import "BaiduMapViewController.h"
#import "IconPictureProcess.h"
#import "FileManager.h"
#import "ShopObject.h"
#import "cloudLoadingView.h"
#import "system_config_model.h"
#import "NetworkFail.h"
#import "EnterShopLookViewController.h"
#import "search_list_model.h"


@interface CitySubbranchViewController () <NetworkFailDelegate>
{
    UIView *_downBar;
    UILabel *_downLabel;
    
    BOOL nextCity;
    cloudLoadingView *cloudLoading;
    
    NetworkFail *failView;
    NetworkFail *noCityView;
}

@property (retain, nonatomic) NSMutableArray *searchArr;

@end

@implementation CitySubbranchViewController

@synthesize tableViewC = _tableViewC;
@synthesize searchBarC;
@synthesize dataArr;
@synthesize cityStr;
@synthesize cwStatusType;
@synthesize subbranchEnum;
@synthesize delegate;
@synthesize mapShowBtn;
@synthesize listShowBtn;
@synthesize searchArr;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    nextCity = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 11.11 chenfeng
    if (cwStatusType == StatusTypeNearShop) {
        self.title = @"附近的店";
    }else{
        self.title = self.cityStr;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressLocation:) name:@"CityAddressLocation" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (nextCity) {
        if (cwStatusType == StatusTypeAPP) {
            return;
        }
        //11.11 chenfeng
        if (cwStatusType == StatusTypeNearShop) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }else{
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }else {
        if (cwStatusType == StatusTypeSelectSame) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
    }
    //ioS7适配 chenfeng14.2.9 add
    if(IOS_7){
        self.view.bounds = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
        [Common iosCompatibility:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self viewLoad];
    
    [self dataLoad];
    
    if (IOS_7) {
        [Common iosCompatibility:self];
    }
}

// 数据加载
- (void)dataLoad
{
    [self accessItemService];
}

// 加载视图
- (void)viewLoad
{
    self.view.backgroundColor = KCWViewBgColor;
    
    _tableViewC = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight - KUpBarHeight) style:UITableViewStylePlain];
    _tableViewC.dataSource = self;
    _tableViewC.delegate = self;
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableViewC];
    //[UIColor colorWithRed:0.f green:105.f/255.f blue:182.f/255.f alpha:1.f]
    
    if (cwStatusType != StatusTypeNearShop) {
        searchBarC = [[CustomSearchBar alloc]initWithColor:[UIColor whiteColor]
                                          bghighlightColor:[UIColor whiteColor]
                                               searchColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]
                                      searchhighlightColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]];
        searchBarC.placeholder = @"请输入实体店名称";
        searchBarC.delegate = self;
        _tableViewC.tableHeaderView = searchBarC;
    }
   

    [self createDownBar];
    
    //11.11 chenfeng
    if (cwStatusType == StatusTypeNearShop) {
        [self switchShow];
    }
}

// 11.11 chenfeng
- (void)switchShow{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //navBar显示方式切换按钮
    UIView* operatButtonView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 80.0f , 44.0f )];
    
    UIButton *tempMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempMapButton.frame = CGRectMake(0.0f, 6.0f, 40.0f, 31.0f);
    [tempMapButton addTarget:self action:@selector(showMapShop) forControlEvents:UIControlEventTouchDown];
    [tempMapButton setImage:[UIImage imageCwNamed:@"icon_options_map_normal.png"] forState:UIControlStateNormal];
    [tempMapButton setImage:[UIImage imageCwNamed:@"icon_options_map_down.png"] forState:UIControlStateHighlighted];
    self.mapShowBtn = tempMapButton;
    [operatButtonView addSubview:self.mapShowBtn];
    
    UIButton *tempListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempListButton.frame = CGRectMake(40.0f, 6.0f, 40.0f, 31.0f);
    [tempListButton addTarget:self action:@selector(showListShop) forControlEvents:UIControlEventTouchDown];
    [tempListButton setImage:[UIImage imageCwNamed:@"icon_options_list_down.png"] forState:UIControlStateNormal];
    [tempListButton setImage:[UIImage imageCwNamed:@"icon_options_list_down.png"] forState:UIControlStateHighlighted];
    self.listShowBtn = tempListButton;
    [operatButtonView addSubview:self.listShowBtn];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:operatButtonView];
    barBtn.width = 65.0f;
    self.navigationItem.rightBarButtonItem = barBtn;
    RELEASE_SAFE(barBtn);
    RELEASE_SAFE(operatButtonView);
    
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 44.0f , 44.0f )];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = leftView.frame;
    [btn setImage:[UIImage imageCwNamed:@"return.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:btn];
    leftView.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftBtn;
    RELEASE_SAFE(leftBtn);
    RELEASE_SAFE(leftView);
    [pool release];
    
}

// 返回首页 11.11 chenfeng
- (void)backBtn{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 地图形式展示分店 11.11 chenfeng
- (void)showMapShop{
    NSLog(@"showMap");
    
    if (!self.mapShowBtn.selected)
    {
        
        [self.mapShowBtn setSelected:YES];
        [self.listShowBtn setSelected:NO];
        
    }
    
    [self.navigationController popViewControllerAnimated:NO];
    
}
// 列表形式展示分店 11.11 chenfeng
- (void)showListShop{
    NSLog(@"showListShop");
    
    if (!self.listShowBtn.selected)
    {
        [self.mapShowBtn setSelected:NO];
        [self.listShowBtn setSelected:YES];
    }
}


// 创建下bar 透明
- (void)createDownBar
{
    _downBar = [[UIView alloc]initWithFrame:CGRectMake(0.f, KUIScreenHeight - 2*KUpBarHeight, KUIScreenWidth, KUpBarHeight)];
    _downBar.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7f];
    [self.view addSubview:_downBar];
    
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(20.f, 10.f, 24.f, 24.f)];
    imgV.image = [UIImage imageCwNamed:@"icon_address_store.png"];
    [_downBar addSubview:imgV];
    [imgV release], imgV = nil;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUpBarHeight);
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_downBar addSubview:btn];
    
    _downLabel = [[UILabel alloc]initWithFrame:CGRectMake(54.f, 0.f, 250.f, KUpBarHeight)];
    _downLabel.backgroundColor = [UIColor clearColor];
    _downLabel.textColor = [UIColor whiteColor];
    _downLabel.font = KCWSystemFont(14.f);
    _downLabel.text = [Global sharedGlobal].locationAddress;
    [_downBar addSubview:_downLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_tableViewC release], _tableViewC = nil;
    [_downLabel release], _downLabel = nil;
    [_downBar release], _downBar = nil;
    [dataArr removeAllObjects];
    [dataArr release], dataArr = nil;
    [searchBarC release], searchBarC = nil;
    self.cityStr = nil;
    if (cloudLoading) {
        [cloudLoading release], cloudLoading = nil;
    }
    if (failView) {
        [failView release], failView = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CityAddressLocation" object:nil];
    [super dealloc];
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

// 网络请求刷新
- (void)accessUpdate:(NSMutableArray *)arr
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
        snlMod.where = [NSString stringWithFormat:@"city = '%@'",self.cityStr];
        NSMutableArray *arr1 = [snlMod getList];
        [snlMod release];

        [Global sharedGlobal].currCity = self.cityStr;
        
        self.dataArr = [ShopObject accordingToTheDistanceSorting:arr1 currentCoordate:[Global sharedGlobal].myLocation];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cloudLoading removeFromSuperview];
            
            if (![[arr lastObject] isEqual:CwRequestFail] || self.dataArr.count > 0) {
                if (self.dataArr.count == 0) {
                    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;

                    if ([[Global sharedGlobal].shop_state intValue] == 0) {
                        // 分店没有数据，请选择其他的城市
                        [self failViewCreate:CwTypeViewNoCity];
                    } 
                } else {
                    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    
                    if (failView != nil) {
                        [failView removeFromSuperview];
                    }
                }
                [_tableViewC reloadData];
            } else {
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
            }
        });
    });
    
    [pool release];
}

// 网络请求
- (void)accessItemService
{
    //添加loading图标
    if (cloudLoading == nil) {
        cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
        [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    }
    [self.view addSubview:cloudLoading];
    
    NSString *reqUrl = @"shoplist.do?param=";

    //self.cityStr = @"恩施州";
    [Global sharedGlobal].currCity = self.cityStr;
	NSLog(@"self.cityStr = %@",self.cityStr);
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Common getVersion:SUBBRANCH_COMMAND_ID
                                                     desc:[NSString stringWithFormat:@"分店列表版本号%@",self.cityStr]],@"ver",
                                       self.cityStr,@"city",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SUBBRANCH_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == SUBBRANCH_COMMAND_ID) {
        [self accessUpdate:resultArray];
    }
}

// 定位按钮
- (void)btnClick:(UIButton *)btn
{
    cwAppDelegate *app = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
    
    app.cityFlag = 1;
    
    [Global sharedGlobal].locManager.delegate = app;
    
    [[Global sharedGlobal].locManager startUpdatingLocation];

    _downLabel.text = @"正在重新确认您的位置...";
}

// 定位通知
- (void)addressLocation:(NSNotification *)notification
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    _downLabel.text = [Global sharedGlobal].locationAddress;
    NSLog(@"[Global sharedGlobal].currCity = %@",[Global sharedGlobal].currCity);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
        snlMod.where = [NSString stringWithFormat:@"city = '%@'",[Global sharedGlobal].currCity];
        NSMutableArray *arr = [snlMod getList];
        [snlMod release];
        
        self.dataArr = [ShopObject accordingToTheDistanceSorting:arr currentCoordate:[Global sharedGlobal].myLocation];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableViewC reloadData];
        });
    });
    
    [pool release];
}

// 进店看看 11.11 chenfeng
- (void)enterShop:(UIButton *)btn
{
    NSArray *arrayViewControllers = self.navigationController.viewControllers;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CustomTabBar *tabViewController = nil;
    
    NSDictionary *dict = [self.dataArr objectAtIndex:btn.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTitle"
                                                        object:[dict objectForKey:@"name"]];
    [Global sharedGlobal].shop_id = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"id"] intValue]];
    [Global sharedGlobal].isRefShop = YES;
    
    if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]]) {
        tabViewController = [arrayViewControllers objectAtIndex:0];
        
        UIButton *btn = (UIButton *)[tabViewController.view viewWithTag:90001];
        
        [tabViewController selectedTab:btn];
    }
    
    [self.navigationController popToViewController:tabViewController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchArr.count > 0) {
        return self.searchArr.count;
    } else {
        return self.dataArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    if (self.searchArr.count > 0) {
        dict = [self.searchArr objectAtIndex:indexPath.row];
        
        if (indexPath.row == self.searchArr.count - 1) {
            static NSString *str = @"cell1";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.textColor = [UIColor grayColor];
            
            cell.textLabel.text = [self.searchArr objectAtIndex:indexPath.row];
            
            return cell;
        } 
    } else {
        dict = [self.dataArr objectAtIndex:indexPath.row];
    }
    static NSString *str = @"cell";
    
    SubbranchCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[SubbranchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str]autorelease];
        // 11.11 chenfeng
        if (cwStatusType == StatusTypeNearShop) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell resetView:StatusTypeNearShop];
            [cell.enterShopBtn addTarget:self action:@selector(enterShop:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if (cwStatusType == StatusTypeNearShop) {
        cell.enterShopBtn.tag = indexPath.row;
    }
    
    cell.deleagte = self;
    
    [cell setCellContentAndFrame:dict];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        //图片
        NSString *picUrl = @"";//11.11 chenfeng
        if (cwStatusType == StatusTypeNearShop) {
            picUrl = [[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"manager_portrait"];
        }else{
            NSArray *arr = [[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"shop_image"] componentsSeparatedByString:@","];
            picUrl = [arr objectAtIndex:0];
        }
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1) {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setTimageView:pic];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cwStatusType == StatusTypeNearShop) {//11.11 chenfeng
                        [cell setTimageView:[UIImage imageCwNamed:@"portrait_member.png"]];
                    }else{
                        [cell setTimageView:[UIImage imageCwNamed:@"branch_default_store.png"]];
                    }
                    //if (tableView.dragging == NO && tableView.decelerating == NO) {
                        [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl
                                                                        forIndexPath:indexPath
                                                                            delegate:self];
                    //}
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cwStatusType == StatusTypeNearShop) {//11.11 chenfeng
                    [cell setTimageView:[UIImage imageCwNamed:@"portrait_member.png"]];
                }else{
                    [cell setTimageView:[UIImage imageCwNamed:@"branch_default_store.png"]];
                }
            });
        }
        [pool release];
    });
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    if (self.searchArr.count > 0) {
        if (indexPath.row == self.searchArr.count - 1) {
            return 50.f;
        }
        dict = [self.searchArr objectAtIndex:indexPath.row];
    } else {
        dict = [self.dataArr objectAtIndex:indexPath.row];
    }
    return [SubbranchCell getCellHeight:dict];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchArr.count > 0 && indexPath.row == self.searchArr.count - 1) {
        self.searchArr = nil;
        [tableView reloadData];
        return;
    } 
    
    nextCity = YES;
    NSDictionary *dict = nil;
    if (self.searchArr.count > 0) {
        dict = [self.searchArr objectAtIndex:indexPath.row];
    } else {
        dict = [self.dataArr objectAtIndex:indexPath.row];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        system_config_model *scMod = [[system_config_model alloc]init];
        scMod.where = [NSString stringWithFormat:@"tag ='%@'",SHOP_KEY];
        NSArray *arr = [scMod getList];
        
        NSDictionary *shopDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  SHOP_KEY,@"tag",
                                  [Global sharedGlobal].shop_id,@"value", nil];
        if (arr.count > 0) {
            [scMod updateDB:shopDict];
            if (![[[arr lastObject] objectForKey:@"value"] isEqualToString:[Global sharedGlobal].shop_id]) {
                [ShopObject cleanShopListDB];
            }
        } else {
            [scMod insertDB:shopDict];
        }
        [scMod release], scMod = nil;
        [pool release];
    });
    
    [Global sharedGlobal].currCity = self.cityStr;
    
    if (subbranchEnum != CitySubbranchNormal) {
        [Global sharedGlobal].shop_id = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"id"] intValue]];
        if(subbranchEnum == CitySubbranchMember) { //chenfeng 11.8 add
            if ([delegate respondsToSelector:@selector(chooseSubbranchInfo:)]) {
                [delegate chooseSubbranchInfo:subbranchEnum];
            }
            return;
        }else if(subbranchEnum == CitySubbranchNearShop) { //chenfeng 11.11 add
            if ([delegate respondsToSelector:@selector(chooseSubbranchInfo:)]) {
                [delegate chooseSubbranchInfo:subbranchEnum];
            }
            return;
        }else {
            if ([delegate respondsToSelector:@selector(chooseSubbranchInfo:)]) {
                [delegate chooseSubbranchInfo:subbranchEnum];
            }
        }
    } else {
        if ([delegate respondsToSelector:@selector(returnCitySubbranchID:shopID:)]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTitle"
                                                                object:[dict objectForKey:@"name"]];
            [delegate returnCitySubbranchID:[dict objectForKey:@"name"]
                                     shopID:[NSString stringWithFormat:@"%d",[[dict objectForKey:@"id"] intValue]]];
        }
    }
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[CustomTabBar class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 0.5f)];
    headerView.backgroundColor = [UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:248.f/255.f alpha:1.f];

    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 0.5f)];
    line.backgroundColor = [UIColor colorWithRed:221.f/255.f green:221.f/255.f blue:221.f/255.f alpha:1.f];
    [headerView addSubview:line];
    [line release], line = nil;
    
    return [headerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - SubbranchCellDelegate
// 拨打电话
- (void)subbranchCellClickBtnPhone:(SubbranchCell *)cell
{
    NSIndexPath *path = [_tableViewC indexPathForCell:cell];
    
    NSDictionary *dict = [self.dataArr objectAtIndex:path.row];

    NSString *phone = [dict objectForKey:@"manager_tel"];
    
    if (phone.length == 0) {
        NSLog(@"暂时没有电话");
    } else {
        [callSystemApp makeCall:phone];
    }
}
// 地图
- (void)subbranchCellClickBtnMap:(SubbranchCell *)cell
{
    NSIndexPath *path = [_tableViewC indexPathForCell:cell];
    
    NSDictionary *dict = [self.dataArr objectAtIndex:path.row];

    BaiduMapViewController *mapView = [[BaiduMapViewController alloc]init];
    mapView.otherStatusTypeMap = StatusTypeMap;
    mapView.dataDic = dict;
    [self.navigationController pushViewController:mapView animated:YES];
    [mapView release],mapView = nil;
}

- (void)subbranchCellClickHeadImg:(SubbranchCell *)cell
{
    if (cwStatusType == StatusTypeNearShop) {
        NSIndexPath *path = [_tableViewC indexPathForCell:cell];
        
        EnterShopLookViewController *enterShop=[[EnterShopLookViewController alloc]init];
        
        NSDictionary *dict = [self.dataArr objectAtIndex:path.row];
        
        NSString *pic = [dict objectForKey:@"manager_portrait"];
        
        if (![[dict objectForKey:@"shop_image"] isEqual:[NSNull null]]) {
            if (pic.length > 4) {
                enterShop.pics = [NSString stringWithFormat:@"%@,%@",pic,[dict objectForKey:@"shop_image"]];
            }
        } else {
            if (pic.length > 4) {
                enterShop.pics = [NSString stringWithFormat:@"%@",pic];
            }
        }
        
        if (enterShop.pics.length > 4) {
            [self.navigationController pushViewController:enterShop animated:YES];
        }
        
        RELEASE_SAFE(enterShop);
    }
}
#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        if (iconDownloader != nil)
        {
            if(iconDownloader.cardIcon.size.width > 2.0)
            {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
                
                UIImage *photo = iconDownloader.cardIcon;
                
                SubbranchCell *cell = (SubbranchCell *)[_tableViewC cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setTimageView:photo];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark ---  CityChooseViewControllerDelegate
- (void)returnChooseCityName:(NSString *)cityName
{
    self.title = cityName;
    self.cityStr = cityName;
    [self accessItemService];
}

#pragma mark --- NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService];
}

- (void)selectCity
{
    CityChooseViewController *choose = [[CityChooseViewController alloc] init];
    choose.delegate = self;
    [self.navigationController pushViewController:choose animated:YES];
    [choose release];
}

#pragma mark - CustomSearchBarDelegate
// 键盘弹出
- (void)textFieldSearchBarDidBeginEditing:(UITextField *)textField
{
    [self beginSearchBar];
    
    [searchBarC setShowCanelButton:YES blackBG:YES animation:YES];
}

- (void)textFieldSearchBarDidEndEditing:(UITextField *)textField
{
    [self endSearchBar];
    
    [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
}

// 搜索按钮
- (BOOL)textFieldSearchBarShouldSearch:(UITextField *)textField
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (textField.text.length > 20) {
        [Common MsgBox:@"提示" messege:@"您输入的字符太多" cancel:@"确定" other:nil delegate:nil];
    } else if (textField.text.length != 0) {
        
        if ([Common illegalCharacterChecking:textField.text]) {
            
            NSMutableArray *arr = [ShopObject searchShop:self.dataArr key:@"name" words:textField.text];
            
            if (arr.count != 0 && arr.count >= 1) {
                [self search_list_model:textField.text];
                
                self.searchArr = arr;
                
                [self.searchArr addObject:@"返回分店列表"];
                
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                
                [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
                
                _tableViewC.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight - KUpBarHeight);
                
                [_tableViewC reloadData];
                
                return YES;
            } else {
                [Common MsgBox:@"提示" messege:@"您输入的分店名称没有找到" cancel:@"确定" other:nil delegate:nil];
            }
        } else {
            [Common MsgBox:@"提示" messege:@"您输入的字符中包含特殊字符" cancel:@"确定" other:nil delegate:nil];
        }
    } else {
        [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
        
        return YES;
    }
    
    [pool release];
    
    return NO;
}

// 清楚按钮
- (BOOL)textFieldSearchBarShouldClear:(UITextField *)textField
{
    return YES;
}

// 搜索输入
- (BOOL)textFieldSearchBar:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

// 取消按钮
- (void)textFieldSearchBarClickCanelButton
{
    [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
}

// 返回的历史记录数据
- (NSArray *)clickSearchBar
{
    NSMutableArray *arrHistory = [NSMutableArray arrayWithCapacity:0];
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"type = 'cityshop'"];
    slMod.orderBy = @"id";
    slMod.orderType = @"desc";
    NSArray *arr = [slMod getList];
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dict = [arr objectAtIndex:i];
        [arrHistory addObject:[dict objectForKey:@"content"]];
    }
    [slMod release];
    return arrHistory;
}

// 清除历史记录
- (void)clearSearchBarHistory
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"type = 'cityshop'"];
    NSMutableArray *slItems = [slMod getList];
    
    for (int i = 0; i < [slItems count]; i++) {
        [slMod deleteDBdata];
    }
    [slMod release];
    
    [pool release];
}

// 数据插入删除操作
- (void)search_list_model:(NSString *)str
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"content = '%@'",str];
    NSArray *arr = [slMod getList];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str,@"content",@"cityshop",@"type", nil];
    if ([arr count] > 0) {
        [slMod updateDB:dict];
    } else {
        [slMod insertDB:dict];
    }
    // 保证数据只有5条
    slMod.where = @"type = 'cityshop'";
    slMod.orderBy = @"id";
    slMod.orderType = @"desc";
    NSMutableArray *slItems = [slMod getList];
    for (int i = [slItems count] - 1; i > 4; i--) {
        NSDictionary *slDic = [slItems objectAtIndex:i];
        NSString *slStr = [slDic objectForKey:@"id"];
        
        slMod.where = [NSString stringWithFormat:@"id = %@",slStr];
        [slMod deleteDBdata];
    }
    [slMod release];
    
    [pool release];
}
#pragma mark -
#pragma mark - 搜索框操作的一些方法
// 搜索框激活状态
- (void)beginSearchBar
{
    _tableViewC.scrollEnabled = NO;

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //_tableViewC.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight - KUpBarHeight);
}

// 搜索框去活状态
- (void)endSearchBar
{
    _tableViewC.scrollEnabled = YES;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
