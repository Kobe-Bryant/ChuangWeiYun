//
//  preferentialViewController.m
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import "preferentialViewController.h"
#import "PfDetailViewController.h"
#import "PreferentialCell.h"
#import "preactivity_list_model.h"
#import "IconPictureProcess.h"
#import "FileManager.h"
#import "Common.h"
#import "PreferentialObject.h"
#import "Global.h"
#import "cloudLoadingView.h"
#import "NetworkFail.h"
#import "browserViewController.h"
#import "dqxx_model.h"
#import "MBProgressHUD.h"
#import "preactivity_log_model.h"
#import "NullstatusView.h"

@interface preferentialViewController () <NetworkFailDelegate>
{
    int updateTime;
    cloudLoadingView *cloudLoading;
    
    NetworkFail *failView;
    BOOL nextFlag;
}

@end

@implementation preferentialViewController

@synthesize tableViewC = _tableViewC;
@synthesize dataArr;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (nextFlag) {
        nextFlag = NO;
        
        preactivity_list_model *plMod = [[preactivity_list_model alloc]init];
        
        NSMutableArray *arr = [plMod getList];
        
        [plMod release];
        
        NSMutableArray *tmppArr = nil;
        
        if (arr.count > 0) {
            NSMutableArray *tmpArr = [PreferentialObject istopListOrdering:arr];
            tmppArr = [PreferentialObject addPicToMutableArray:tmpArr];
        }
        self.dataArr = tmppArr;
        
        [_tableViewC reloadData];
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

// 视图加载
- (void)viewLoad
{
    self.view.backgroundColor = KCWViewBgColor;
    
    self.title = @"优惠活动";
    
    _tableViewC = [[LoadTableView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight-KUpBarHeight) style:UITableViewStylePlain];
    _tableViewC.backgroundColor = [UIColor clearColor];
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewC.delegate = self;
    _tableViewC.dataSource = self;
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
    NSLog(@"pesdfsdfsdfsdfsdfsd dealloc ......");
    [_tableViewC release], _tableViewC = nil;
    self.dataArr = nil;
    
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

#pragma mark - network request
// 网络请求
- (void)accessItemService
{
    if (self.dataArr.count == 0) {
        //添加loading图标
        if (cloudLoading == nil) {
            cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
            [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
        }
        [self.view addSubview:cloudLoading];
    }

    NSString *reqUrl = @"preactivitylist.do?param=";
    
    NSMutableDictionary *requestDic = nil;
    if ([Global sharedGlobal].shop_id.length != 0) {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      [Global sharedGlobal].shop_id,@"shop_id",
                      [Global sharedGlobal].user_id,@"user_id",nil];
    } else {
        NSString *cityId = nil;
        dqxx_model *dqxxModel = [[dqxx_model alloc] init];
        dqxxModel.where = [NSString stringWithFormat:@"DQXX02 = '%@'",[Global sharedGlobal].currCity];
        NSArray *arr = [dqxxModel getList];
        if ([arr count] > 0) {
            cityId = [[arr objectAtIndex:0] objectForKey:@"DQXX01"];
        }else {
            cityId = @"0";
        }
        [dqxxModel release];
        
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"0",@"shop_id",
                      cityId,@"city",
                      [Global sharedGlobal].user_id,@"user_id",nil];
    }

    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:PREACTIVITY_LIST_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 网络请求 更多
- (void)accessItemMoreService
{
    NSString *reqUrl = @"preactivitylist.do?param=";
    
    NSMutableDictionary *requestDic = nil;
    if ([Global sharedGlobal].shop_id.length != 0) {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      [Global sharedGlobal].shop_id,@"shop_id",
                      [Global sharedGlobal].user_id,@"user_id",
                      [[self.dataArr lastObject] objectForKey:@"created"],@"created",
                      [NSString stringWithFormat:@"%d",updateTime],@"updatetime",
                      nil];
    } else {
        NSString *cityId = nil;
        dqxx_model *dqxxModel = [[dqxx_model alloc] init];
        dqxxModel.where = [NSString stringWithFormat:@"DQXX02 = '%@'",[Global sharedGlobal].currCity];
        NSArray *arr = [dqxxModel getList];
        if ([arr count] > 0) {
            cityId = [[arr objectAtIndex:0] objectForKey:@"DQXX01"];
        }else {
            cityId = @"0";
        }
        [dqxxModel release];
        
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"0",@"shop_id",
                      cityId,@"city",
                      [[self.dataArr lastObject] objectForKey:@"created"],@"created",
                      [NSString stringWithFormat:@"%d",updateTime],@"updatetime",
                      [Global sharedGlobal].user_id,@"user_id",nil];
    }
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:PREACTIVITY_LIST_MORE_COMMAND_ID
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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (commandid == PREACTIVITY_LIST_COMMAND_ID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    if (resultArray.count > 0) {
                        updateTime = [[resultArray objectAtIndex:0] intValue];
                    }
                }
            }

            preactivity_list_model *plMod = [[preactivity_list_model alloc]init];
            
            NSMutableArray *arr = [plMod getList];
            
            [plMod release];

            NSMutableArray *tmppArr = nil;
            
            if (arr.count > 0) {
                NSMutableArray *tmpArr = [PreferentialObject istopListOrdering:arr];
                tmppArr = [PreferentialObject addPicToMutableArray:tmpArr];
            }
            self.dataArr = tmppArr;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (arr.count >= 20) {
                    _tableViewC.isShowFooterView = YES;
                } else {
                    _tableViewC.isShowFooterView = NO;
                }
                [cloudLoading removeFromSuperview];
                
                if (![[resultArray lastObject] isEqual:CwRequestFail] || self.dataArr.count > 0) {
                    if (self.dataArr.count == 0) {
//                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 40)];
//                        label.text = @"还没有优惠活动哦~";
//                        label.backgroundColor = [UIColor clearColor];
//                        label.textColor = [UIColor darkTextColor];
//                        label.textAlignment = UITextAlignmentCenter;
//                        label.font = [UIFont systemFontOfSize:16.0f];
//                        [self.view addSubview:label];
//                        [label release];
                        NullstatusView *_nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_preferential_default.png"] andText:@"还没有优惠活动哦~"];
                        [self.view addSubview:_nullView];
                        [_nullView release];
                    }else {
                        _tableViewC.hidden = NO;
                        if (failView == nil) {
                            [failView removeFromSuperviewSelf];
                        }
                    }
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
    } else if (commandid == PREACTIVITY_LIST_MORE_COMMAND_ID) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *arr = nil;
            
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    if (resultArray.count > 0) {
                        updateTime = [resultArray objectAtIndex:0];
                        
                        arr = [resultArray objectAtIndex:1];
                        
                        if (arr.count > 0) {
                            [self.dataArr addObjectsFromArray:arr];
                            NSMutableArray *tmpArr = [PreferentialObject istopListOrdering:self.dataArr];
                            [self.dataArr removeAllObjects];
                            [self.dataArr addObjectsFromArray:tmpArr];
                        }
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self loadDataFinish];
                
                if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                    if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                        [self progressHUD:KCWServerBusyPrompt type:0];
                    } else {
                        if (dataArr.count % 20 == 0 && arr.count != 0) {
                            _tableViewC.isShowFooterView = YES;
                        } else {
                            _tableViewC.isShowFooterView = NO;
                        }
                        [_tableViewC reloadData];
                    }
                } else {
                    if ([Common connectedToNetwork]) {
                        // 网络繁忙，请重新再试
                        [self progressHUD:KCWNetBusyPrompt type:0];
                    } else {
                        // 当前网络不可用，请重新再试
                        [self progressHUD:KCWNetNOPrompt type:3];
                    }
                }
            });
        });
    }
    
    [pool release];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"PreferentialCell";
    
    PreferentialCell *cell = (PreferentialCell *)[tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[PreferentialCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dict = [self.dataArr objectAtIndex:indexPath.row];
    
    [cell setCellContentAndFrame:dict];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //图片
        NSString *picUrl = [dict objectForKey:@"image"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1) {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setBigImageView:pic];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setBigImageView:[UIImage imageCwNamed:@"default_320x180.png"]];
                    //if (tableView.dragging == NO && tableView.decelerating == NO) {
                        [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                    //}
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setBigImageView:[UIImage imageCwNamed:@"default_320x180.png"]];
            });
        }
    });
    
    [pool release];

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PreferentialCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSDictionary *adict = [self.dataArr objectAtIndex:indexPath.row];
    int type = [[adict objectForKey:@"promotion_type"] intValue];
    
    if (type == 5) {
        NSString *url = [adict objectForKey:@"url"];
        if (url.length > 0) {
            browserViewController *browser = [[browserViewController alloc] init];
            browser.url = url;
            [self.navigationController pushViewController:browser animated:YES];
            [browser release];
        }
        
        [self readAndWritePreactivityLog:adict];
    }else {
        nextFlag = YES;
        
        NSMutableArray *dataArrs = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in self.dataArr) {
            if ([[dict objectForKey:@"promotion_type"] intValue] != 5) {
                [dataArrs addObject:dict];
            }
        }
        
        int row = 0;
        for (int i = 0; i < dataArrs.count; i++) {
            NSDictionary *bdict = [dataArrs objectAtIndex:i];
            if ([bdict isEqualToDictionary:adict]) {
                row = i;
                break;
            }
        }
        
        PfDetailViewController *pfDetailView = [[PfDetailViewController alloc]init];
        pfDetailView.dataArr = dataArrs;
        pfDetailView.clickRow = row;
        [self.navigationController pushViewController:pfDetailView animated:YES];
        [pfDetailView release], pfDetailView = nil;
    }
    
    [pool release];
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
                
                PreferentialCell *cell = (PreferentialCell *)[_tableViewC cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setBigImageView:photo];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
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

- (void)readAndWritePreactivityLog:(NSDictionary *)dic
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int plID = [[dic objectForKey:@"id"] intValue];
        
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
    });
    
    [pool release];
}

@end
