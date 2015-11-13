//
//  SearchResultViewController.m
//  cw
//
//  Created by yunlai on 13-8-19.
//
//

#import "SearchResultViewController.h"
#import "ProductListCell.h"
#import "search_list_model.h"
#import "IconPictureProcess.h"
#import "FileManager.h"
#import "ShopDetailsViewController.h"
#import "ShopObject.h"
#import "NetworkFail.h"
#import "cloudLoadingView.h"

@interface SearchResultViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
    
    cloudLoadingView *cloudLoading;
}

@property (retain, nonatomic) UILabel *resultLabel;

@end

@implementation SearchResultViewController

@synthesize tableViewC = _tableViewC;
@synthesize searchBarC = _searchBarC;
@synthesize dataArr;
@synthesize searchText;
@synthesize resultLabel;
@synthesize statusType;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.statusType == StatusTypeFromCenter) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

// 加载视图
- (void)viewLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableViewC = [[LoadTableView alloc]initWithFrame:CGRectMake(0.f, KUpBarHeight, KUIScreenWidth, KUIScreenHeight-KUpBarHeight)
                                                style:UITableViewStylePlain];
    _tableViewC.delegate = self;
    _tableViewC.dataSource = self;
    _tableViewC.loadDelegate = self;
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewC.isShowHeaderView = NO;
    _tableViewC.isShowFooterView = NO;
    [self.view addSubview:_tableViewC];
    
    _searchBarC = [[CustomSearchBar alloc]initWithColor:[UIColor whiteColor]
                                       bghighlightColor:[UIColor whiteColor]
                                            searchColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]
                                   searchhighlightColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]];
    _searchBarC.placeholder = @"请输入商品名称/描述";
    [_searchBarC setTextFieldText:self.searchText];
    _searchBarC.delegate = self;

    _searchBarC.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUpBarHeight);
    
    [self.view addSubview:_searchBarC];
    
    [_searchBarC setShowCanelButton:YES blackBG:NO animation:YES];
    
}

//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}

// 加载数据
- (void)dataLoad
{
    dataArr = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataLoad];
    
    [self viewLoad];
    
    [self accessItemService];
    
    //ioS7适配 chenfeng14.2.9 add
    if(IOS_7){
        self.view.bounds = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
        [Common iosCompatibility:self];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_tableViewC release], _tableViewC = nil;
    [_searchBarC release], _searchBarC = nil;
    [dataArr release], dataArr = nil;
    [searchText release], searchText = nil;
    if (resultLabel) {
        [resultLabel release], resultLabel = nil;
    }
    if (cloudLoading) {
        [cloudLoading release], cloudLoading = nil;
    }
    if (failView) {
        [failView release], failView = nil;
    }
    
    [super dealloc];
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService];
}

#pragma mark - network
// 网络请求
- (void)accessItemService
{
    //添加loading图标
    if (cloudLoading == nil) {
        cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
        [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    }
    [self.view addSubview:cloudLoading];
    
    resultLabel.hidden = YES;
    
    NSString *reqUrl = @"search.do?param=";
    
    NSString *shopid = @"0";
    if (self.statusType != StatusTypeFromCenter) {
        shopid = [Global sharedGlobal].shop_id;
    }
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shopid,@"shop_id",
                                       _searchBarC.searchTextField.text,@"keywords",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SEARCH_SHOP_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 网络更多请求
- (void)accessItemMoreService
{
    NSString *reqUrl = @"search.do?param=";
    
    NSString *shopid = @"0";
    if (self.statusType != StatusTypeFromCenter) {
        shopid = [Global sharedGlobal].shop_id;
    }
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shopid,@"shop_id",
                                       _searchBarC.searchTextField.text,@"keywords",
                                       [[self.dataArr lastObject] objectForKey:@"like_sum"],@"like_sum",
                                       [[self.dataArr lastObject] objectForKey:@"create"],@"create",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SEARCH_SHOP_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 网络请求成功后的数据解析
- (void)updateDataArr:(NSMutableArray *)arr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[arr lastObject] isEqual:CwRequestTimeout]) {
            if (arr.count > 0) {
                [self.dataArr addObjectsFromArray:arr];
            }
        } 
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadDataFinish];
            
            if ([[arr lastObject] isEqual:CwRequestTimeout]) {
                resultLabel.hidden = YES;
                // 服务器繁忙，请重新再试
                [self failViewCreate:CwTypeViewNoService];
            } else {
                if (self.dataArr.count == 0) {
                    if (resultLabel == nil) {
                        resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.f, KUpBarHeight, KUIScreenWidth, KUpBarHeight)];
                        resultLabel.text = @"没有找到您想要的结果";
                        resultLabel.backgroundColor = [UIColor clearColor];
                        resultLabel.textColor = [UIColor blackColor];
                        resultLabel.textAlignment = NSTextAlignmentCenter;
                        resultLabel.hidden = YES;
                        [self.view addSubview:resultLabel];
                    }
                    resultLabel.hidden = NO;
                } else {
                    resultLabel.hidden = YES;
                }
                if (self.dataArr.count % 20 == 0 && arr.count != 0) {
                    _tableViewC.isShowFooterView = YES;
                } else {
                    _tableViewC.isShowFooterView = NO;
                }
                
                [_tableViewC reloadData];
            }
        });
    });
}

// 网络请求成功后的数据解析
- (void)updateDataMoreArr:(NSMutableArray *)arr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[arr lastObject] isEqual:CwRequestTimeout]) {
            if (arr.count > 0) {
                [self.dataArr addObjectsFromArray:arr];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadDataFinish];
            
            if ([[arr lastObject] isEqual:CwRequestTimeout]) {
                [self progressHUD:KCWServerBusyPrompt type:0];
            } else {
                if (self.dataArr.count % 20 == 0 && arr.count != 0) {
                    _tableViewC.isShowFooterView = YES;
                } else {
                    _tableViewC.isShowFooterView = NO;
                }
                
                [_tableViewC reloadData];
            }
        });
    });
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
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

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == SEARCH_SHOP_COMMAND_ID) {
        
        [cloudLoading removeFromSuperview];
        
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            _tableViewC.hidden = NO;
            [self.dataArr removeAllObjects];
            [self updateDataArr:resultArray];
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
    } else if (commandid == SEARCH_SHOP_MORE_COMMAND_ID) {
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            [self updateDataArr:resultArray];
        } else {
            [self loadDataFinish];
            if ([Common connectedToNetwork]) {
                // 网络繁忙，请重新再试
                [self progressHUD:KCWNetBusyPrompt type:0];
            } else {
                // 当前网络不可用，请重新再试
                [self progressHUD:KCWNetNOPrompt type:3];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"ProductViewCell";
    
    ProductListCell *cell = (ProductListCell *)[tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[ProductListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dict = [self.dataArr objectAtIndex:indexPath.row];
    
    cell.statusType = self.statusType;
    
    [cell setCellContentAndFrame:dict];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //图片
        NSString *picUrl = [[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"image"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1) {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setCellViewImage:pic];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setCellViewImage:[UIImage imageCwNamed:@"default_70x53.png"]];
                    //if (tableView.dragging == NO && tableView.decelerating == NO) {
                        [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                    //}
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setCellViewImage:[UIImage imageCwNamed:@"default_70x53.png"]];
            });
        }
    });
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [ProductListCell getCellHeight];

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopDetailsViewController *view = [[ShopDetailsViewController alloc]init];
    if (self.statusType == StatusTypeFromCenter) {
        view.cwStatusType = StatusTypeFromCenter;
        view.productID = [NSString stringWithFormat:@"%d",[[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"product_id"] intValue]];
    } else {
        view.clickNum = indexPath.row;
        view.dataArr = self.dataArr;
    }
    view.cwStatusType = self.statusType;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
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

#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        if (iconDownloader != nil)
        {
            if(iconDownloader.cardIcon.size.width > 2.0)
            {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
                
                UIImage *photo = iconDownloader.cardIcon;

                ProductListCell *cell = (ProductListCell *)[_tableViewC cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setCellViewImage:photo];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark -
#pragma mark - 搜索框操作的一些方法
// 数据插入删除操作
- (void)search_list_model:(NSString *)str
{
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"content = '%@'",str];
    NSArray *arr = [slMod getList];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str,@"content",@"shop",@"type", nil];
    if ([arr count] > 0) {
        [slMod updateDB:dict];
    } else {
        [slMod insertDB:dict];
    }
    // 保证数据只有5条
    slMod.where = @"type = 'shop'";
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
}

#pragma mark - CustomSearchBarDelegate
// 键盘弹出
- (void)textFieldSearchBarDidBeginEditing:(UITextField *)textField {
    NSLog(@"begin");
}

// 搜索按钮
- (BOOL)textFieldSearchBarShouldSearch:(UITextField *)textField
{
    if (textField.text.length > 20) {
        [Common MsgBox:@"提示" messege:@"您输入的字符太多" cancel:@"确定" other:nil delegate:nil];
    } else if (textField.text.length != 0) {
        
        if ([Common illegalCharacterChecking:textField.text]) {
            [self search_list_model:textField.text];
            
            [self accessItemService];
            
            return YES;
        } else {
            [Common MsgBox:@"提示" messege:@"您输入的字符中包含特殊字符" cancel:@"确定" other:nil delegate:nil];
        }
    }
    
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
    [_searchBarC setShowCanelButton:NO blackBG:NO animation:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
