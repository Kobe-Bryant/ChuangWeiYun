//
//  WaterFallViewController.m
//  SideSlip
//
//  Created by yunlai on 13-8-9.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "WaterFallViewController.h"
#import "shop_list_model.h"
#import "ShopDetailsViewController.h"
#import "WaterListBigCell.h"
#import "WaterListSmallCell.h"
#import "FileManager.h"
#import "IconPictureProcess.h"
#import "ShopObject.h"
#import "Common.h"
#import "CityChooseViewController.h"
#import "PopGuideView.h"
#import "productsCenter_list_model.h"
#import "NetworkFail.h"
#import "shop_near_list_model.h"

@interface WaterFallViewController () <NetworkFailDelegate>
{
//    NSString *catTitle;
    
    NetworkFail *failView;
    
    NSString *title;
}

//@property (retain, nonatomic) NSString *catTitle;
@property (retain, nonatomic) NSString *title;

// UIButton按钮
- (void)btnRightClick:(UIButton *)btn;

@end

@implementation WaterFallViewController

@synthesize dataArr;
@synthesize waterArr;
//@synthesize catTitle;
@synthesize title;
@synthesize catID;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.statusType == StatusTypeFromCenter) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        if (self.title.length != 0) {
            [self setSubbranchLabelText:self.title];
            self.title = nil;
        }
    }
   
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataLoad];

    [self viewLoad];
    
    if (self.statusType != StatusTypeFromCenter) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(updateDataNotification:) name:UpdateWaterList object:nil];
        [center addObserver:self selector:@selector(updateDataMoreNotification:) name:UpdateWaterListMore object:nil];
        [center addObserver:self selector:@selector(pageOverNotification:) name:PageOverWaterTurn object:nil];
        [center addObserver:self selector:@selector(updateNameAndTitle:) name:@"NameAndTitle" object:nil];
        [center addObserver:self selector:@selector(updateTitle:) name:@"updateTitle" object:nil];
        
        if (![PopGuideView isInsertTable:Guide_Enum_ShopList]) {
            UIImage *img = nil;
            if (KUIScreenHeight > 500) {
                img = [UIImage imageCwNamed:@"shopList_guide2.png"];
            } else {
                img = [UIImage imageCwNamed:@"shopList_guide.png"];
            }
            PopGuideView *popGuideView = [[PopGuideView alloc]initWithImage:img index:Guide_Enum_ShopList];
            [popGuideView addPopupSubview];
            [popGuideView release], popGuideView = nil;
        }
    }
   
    
    //ioS7适配 chenfeng14.2.9 add
    if(IOS_7){
        self.view.bounds = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
        [Common iosCompatibility:self];
        
    }
}

- (void)dataLoad
{    
    if (self.statusType == StatusTypeFromCenter) {
        [self accessService:NO];
    }
}

- (void)viewLoad
{
    self.view.backgroundColor = KCWViewBgColor;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.tag = 'r';
    rightBtn.frame = CGRectMake(KUIScreenWidth - 50.f, 20.f, 50.f, KUpBarHeight);
    [rightBtn setImage:[UIImage imageCwNamed:@"list.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageCwNamed:@"list_click.png"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(btnRightClick:) forControlEvents:UIControlEventTouchUpInside];
    [upBarView addSubview:rightBtn];
    
    [pool release];
    
    if (self.statusType == StatusTypeFromCenter) {
        upBarView.hidden = YES;
        if (IOS_7) {
            _tableViewC.frame = CGRectMake(0.f, -20, KUIScreenWidth, KUIScreenHeight - KUpBarHeight);
        }else{
            _tableViewC.frame = CGRectMake(0.f, 0, KUIScreenWidth, KUIScreenHeight - KUpBarHeight);
        }
    }
    
    self.lfDelegate = self;
    
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewC.dataSource = self;
    _tableViewC.delegate = self;
    _tableViewC.loadDelegate = self;
    [_tableViewC reloadData];
}


- (void)dealloc
{
    [self.dataArr removeAllObjects];
    self.dataArr = nil;
    [self.waterArr removeAllObjects];
    self.waterArr = nil;
    
    if (failView) {
        [failView release], failView = nil;
    }
    [_nullView release], _nullView = nil;
    self.title = nil;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UpdateWaterList object:nil];
    [center removeObserver:self name:UpdateWaterListMore object:nil];
    [center removeObserver:self name:PageOverWaterTurn object:nil];
    [center removeObserver:self name:@"NameAndTitle" object:nil];
    [center removeObserver:self name:@"updateTitle" object:nil];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// 空视图
- (void)nullViewSuper:(int)flag
{
    if ([self.dataArr count] == 0) {
        if (self.statusType == StatusTypeFromCenter || self.statusType == StatusTypeHotShop) {
            _tableViewC.tableHeaderView = nil;
        }
        
        if (_nullView.superview == nil) {

            if (flag == 3) {
                _tableViewC.hidden = YES;
                
                UIButton *btn = (UIButton *)[upBarView viewWithTag:'r'];
                btn.hidden = YES;

                [self failViewCreate:CWTypeViewNoShop];//12.9chenfeng
            } else {
                _tableViewC.hidden = NO;
                
                UIButton *btn = (UIButton *)[upBarView viewWithTag:'r'];
                btn.hidden = NO;
                
                if (_nullView == nil) {
                    _nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_class_default.png"]
                                                                   andText:@"当前分类没有商品～"];
                }
            }
            
            [self.view addSubview:_nullView];
        }
    }else{
        searchBarC.userInteractionEnabled = YES;
        UIButton *btn = (UIButton *)[upBarView viewWithTag:'r'];
        btn.hidden = NO;
        
        if (failView) {
            [failView removeFromSuperviewSelf];
        }
        
        if (_nullView.superview) {
            _tableViewC.hidden = NO;
            
            [_nullView removeNullView];
        }
    }
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

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    if (self.statusType == StatusTypeFromCenter) {
        [self accessService:NO];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SendResquest object:[NSString stringWithFormat:@"%d",ListWaterViewType]];
    }
}

// 12.9 chenfeng
- (void)selectShop{
    CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
    citySubbranch.delegate = self;
    citySubbranch.cityStr = [Global sharedGlobal].currCity;
    citySubbranch.subbranchEnum = CitySubbranchNormal;
    citySubbranch.cwStatusType = StatusTypeSelectSame;
    [self.navigationController pushViewController:citySubbranch animated:YES];
    
    [citySubbranch release], citySubbranch = nil;
}

#pragma mark - notification
- (void)updateTitle:(NSNotification *)notification
{
    self.title = notification.object;
}

- (void)updateNameAndTitle:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;

    NSString *name = [dict objectForKey:@"name"];
    if (name.length != 0) {
        self.catTitle = name;
        
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
        });
    }
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    CGRect frame = self.view.bounds;
    frame.origin.y = 44.f;
    frame.size.height = self.view.bounds.size.height - 44.f;
    
    failView = [NetworkFail initCreateNetworkView:self.view frame:frame failView:failView delegate:self andType:cwTypeView];

    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
    
}

// 获取数据
- (void)updateDataNotification:(NSNotification *)notification
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        BOOL flag = NO;
        
        NSDictionary *notDict = notification.object;
        
        shop_list_model *slMod = [[shop_list_model alloc]init];
        
        NSNumber *catid = [notDict objectForKey:@"cat_ID"];
        
        slMod.where = [NSString stringWithFormat:@"catalog_id = '%d'",[catid intValue]];
        
        NSMutableArray *arr = [slMod getList];
        
        [slMod release];
        
        NSLog(@"arr water = %@",arr);

        if (arr.count % 20 == 0  && arr.count != 0) {
            flag = YES;
        } else {
            flag = NO;
        }

        self.dataArr = [Common sortInt:arr field:@"position" sort:SortEnumDesc];
        self.waterArr = [ShopObject listDataArrConversion:self.dataArr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _tableViewC.isShowFooterView = flag;

            [self loadDataFinish];
            
            if (([[notDict objectForKey:@"failFlag"] intValue] == 1 || [[notDict objectForKey:@"failFlag"] intValue] == 2)
                && self.dataArr.count == 0) {
                
                _tableViewC.hidden = YES;
                
                if (_nullView.superview) {
                    [_nullView removeNullView];
                }

                if ([[notDict objectForKey:@"failFlag"] intValue] == 2) {
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
            } else {
                _tableViewC.hidden = NO;
                
                if (failView) {
                    [failView removeFromSuperviewSelf];
                }
                [self nullViewSuper:[[notDict objectForKey:@"failFlag"] intValue]];
            }

            if ([[notDict objectForKey:@"bool"] boolValue]) {
                self.listViewType = ListWaterViewType;
                //if ([[notDict objectForKey:@"failFlag"] intValue] == 0) {
                    
                    [_tableViewC reloadData];
                //}
            }
        });
    });
    
    [pool release];
}

// 获取数据  更多
- (void)updateDataMoreNotification:(NSNotification *)notification
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL flag = NO;
        
        NSDictionary *dict = notification.object;
        
        NSArray *arr = [dict objectForKey:@"data"];
        NSLog(@"arr.count = %d",arr.count);
        
        if ([[dict objectForKey:@"failFlag"] intValue] != 1 || [[dict objectForKey:@"failFlag"] intValue] != 2) {
            if (arr.count % 20 == 0  && arr.count != 0) {
                flag = YES;
            } else {
                flag = NO;
            }
            
            if (arr.count > 0) {
                [self.dataArr addObjectsFromArray:arr];
                self.waterArr = [ShopObject listDataArrConversion:self.dataArr];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _tableViewC.isShowFooterView = flag;
            
            [self loadDataFinish];
            
            if ([[dict objectForKey:@"bool"] boolValue]) {
                self.listViewType = ListWaterViewType;
                if ([[dict objectForKey:@"failFlag"] intValue] == 0) {
                    [_tableViewC reloadData];
                } else if ([[dict objectForKey:@"failFlag"] intValue] == 1) {
                    if ([Common connectedToNetwork]) {
                        // 网络繁忙，请重新再试
                        [self progressHUD:KCWNetBusyPrompt type:0];
                    } else {
                        // 当前网络不可用，请重新再试
                        [self progressHUD:KCWNetNOPrompt type:3];
                    }
                } else {
                    // 服务器繁忙，请重新再试
                    [self progressHUD:KCWServerBusyPrompt type:0];
                }
            }
        });
    });
    
    [pool release];
}

// 翻页刷新
- (void)pageOverNotification:(NSNotification *)notification
{
    self.listViewType = ListWaterViewType;
    [_tableViewC reloadData];
}

- (void)loadDataFinish
{
    [_tableViewC loadTableViewDidFinishedWithMessage:nil];
}

#pragma mark - UIButton
- (void)btnRightClick:(UIButton *)btn
{
    if ([delegate respondsToSelector:@selector(pageOverTurnView:)]) {
        [delegate pageOverTurnView:self];
    }
}

#pragma mark - ListFatherViewControllerDelegate
- (void)cityChoosePageTurn:(NSString *)shopName
{
    CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
    citySubbranch.delegate = self;
    citySubbranch.cityStr = [Global sharedGlobal].currCity;
    citySubbranch.subbranchEnum = CitySubbranchNormal;
    citySubbranch.cwStatusType = StatusTypeSelectSame;
    [self.navigationController pushViewController:citySubbranch animated:YES];
//    [self.navigationController presentModalViewController:citySubbranch animated:YES];
    [citySubbranch release], citySubbranch = nil;
}

#pragma mark - CitySubbranchViewControllerDelegate
- (void)returnCitySubbranchID:(NSString *)shopName shopID:(NSString *)shopID
{
    self.title = shopName;
    
    if (![[Global sharedGlobal].shop_id isEqualToString:shopID]) {
        [Global sharedGlobal].shop_id = shopID;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CatMessage" object:nil];
    }
    
    NSLog(@"[Global sharedGlobal].shop_id = %@",[Global sharedGlobal].shop_id);
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:SendResquest object:[NSString stringWithFormat:@"%d",ListWaterViewType]];
}

#pragma mark - loadTableViewDidScroll
- (void)loadTableViewDownRefresh:(LoadTableView *)tableView
{
    if (self.statusType == StatusTypeFromCenter) {
        [self accessServiceMore];
    }else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int position = [ShopObject getArrMin:self.dataArr];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%d",position],@"position",
                                  [NSString stringWithFormat:@"%d",ListWaterViewType],@"type", nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SendResquestMore object:dict];
            });
        });
    }
}

- (void)loadTableViewUpRefresh:(LoadTableView *)tableView
{
    if (self.statusType == StatusTypeFromCenter) {
        [self accessService:YES];
    }else {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%d",ListWaterViewType],@"Type", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SendResquest object:dict];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.waterArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSArray *arr = [self.waterArr objectAtIndex:indexPath.row];
    
    if ([[arr objectAtIndex:0] intValue] == 1) {   // 瀑布流大试图
        static NSString *bigStr = @"BigWaterViewCell";
        
        WaterListBigCell *cell = (WaterListBigCell *)[tableView dequeueReusableCellWithIdentifier:bigStr];
        
        if (cell == nil) {
            cell = [[[WaterListBigCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bigStr] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        if (self.statusType == StatusTypeFromCenter) { //hui add
            [cell setCellContentAndFrame:arr delegate:self fromCenter:YES];
        }else {
            [cell setCellContentAndFrame:arr delegate:self fromCenter:NO];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //图片
            NSString *picUrl = [[arr objectAtIndex:2] objectForKey:@"image"];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (picUrl.length > 1) {
                UIImage *pic = [FileManager getPhoto:picName];
                if (pic.size.width > 2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setCellViewImage:pic];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setCellViewImage:[UIImage imageCwNamed:@"banner_white_default.png"]];
                        //if (tableView.dragging == NO && tableView.decelerating == NO) {
                            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                        //}
                        NSLog(@"sdf,,,,,,,,------");
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setCellViewImage:[UIImage imageCwNamed:@"banner_white_default.png"]];
                });
            }
        });
        cell.backgroundColor = KCWViewBgColor;
        
        [pool release];
        return cell;
    } else {           // 瀑布流小试图
        static NSString *smallStr = @"SmallWaterViewCell";
        
        WaterListSmallCell *cell = (WaterListSmallCell *)[tableView dequeueReusableCellWithIdentifier:smallStr];
        
        if (cell == nil) {
            cell = [[[WaterListSmallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:smallStr] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        //[cell setCellContentAndFrame:arr delegate:self];
        if (self.statusType == StatusTypeFromCenter) { //hui add
            [cell setCellContentAndFrame:arr delegate:self fromCenter:YES];
        }else {
            [cell setCellContentAndFrame:arr delegate:self fromCenter:NO];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //图片
            int count = arr.count <= 3 ? 1 : 2;
            for (int i = 0; i < count; i++) {
                NSString *picUrl = nil;
                if (i == 0) {
                    picUrl = [[arr objectAtIndex:2] objectForKey:@"image"];
                } else {
                    picUrl = [[arr objectAtIndex:4] objectForKey:@"image"];
                }
                
                NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
                
                if (picUrl.length > 1) {
                    UIImage *pic = [FileManager getPhoto:picName];
                    if (pic.size.width > 2) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (i == 0) {
                                [cell setCellView1Image:pic];
                            } else {
                                [cell setCellView2Image:pic];
                            }
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (i == 0) {
                                [cell setCellView1Image:[UIImage imageCwNamed:@"commodity_white_default.png"]];
                            } else {
                                [cell setCellView2Image:[UIImage imageCwNamed:@"commodity_white_default.png"]];
                            }
                            NSLog(@"sdf,,,,,,,,00000");
                            //if (tableView.dragging == NO && tableView.decelerating == NO) {
                                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                            //}
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (i == 0) {
                            [cell setCellView1Image:[UIImage imageCwNamed:@"commodity_white_default.png"]];
                        } else {
                            [cell setCellView2Image:[UIImage imageCwNamed:@"commodity_white_default.png"]];
                        }
                    });
                }
            }
        });
        
        [pool release];
        return cell;
    }
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;

    NSArray *arr = [self.waterArr objectAtIndex:indexPath.row];
    
    if ([[arr objectAtIndex:0] intValue] == 1) {
        height = [WaterListBigCell getCellHeight];
    } else {
        height = [WaterListSmallCell getCellHeight];
    }
    
    return height;
}

#pragma mark - WaterCellViewDelegate
- (void)tapClickWaterCellView:(WaterCellView *)water
{
    ShopDetailsViewController *view = [[ShopDetailsViewController alloc]init];
    if (self.statusType == StatusTypeFromCenter) {
        view.cwStatusType = StatusTypeFromCenter;
        view.productID = [NSString stringWithFormat:@"%d",[[[self.dataArr objectAtIndex:water.tag] objectForKey:@"product_id"] intValue]];
    } else {
        view.clickNum = water.tag;
        view.dataArr = self.dataArr;
    }
    [self.navigationController pushViewController:view animated:YES];
    [view release];
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
                
                int rows = [_tableViewC numberOfRowsInSection:0];
                
                if (iconDownloader.indexPathInTableView.row >= rows) {
                    return;
                }
                
                NSLog(@"iconDownloader.indexPathInTableView.row = %d",iconDownloader.indexPathInTableView.row);
                NSLog(@"rows = %d",rows);
                NSLog(@"appImageDidLoad url = %@",url);
                
                UIImage *photo = iconDownloader.cardIcon;
                
                NSArray *arr = [self.waterArr objectAtIndex:iconDownloader.indexPathInTableView.row];
                
                if ([[arr objectAtIndex:0] intValue] == 1) {
                    WaterListBigCell *cell = (WaterListBigCell *)[_tableViewC cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setCellViewImage:photo];
                    });
                } else {
                    WaterListSmallCell *cell = (WaterListSmallCell *)[_tableViewC cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                    
                    if ([[[arr objectAtIndex:2] objectForKey:@"image"] isEqualToString:url]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell setCellView1Image:photo];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell setCellView2Image:photo];
                        });
                    }
                }
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
//hui add
#pragma mark ---- loading data
- (void)accessService:(BOOL)_fresh
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (_fresh == NO) {
        //添加loading图标
        cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
        [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
        self.cloudLoading = tempLoadingView;
        [self.view addSubview:self.cloudLoading];
        [tempLoadingView release];
    }
    
    self.isLoading = YES;
    
    NSString *reqUrl = @"productlist.do?param=";
	
    int shopId = 0;
    
    //NSString *verStr = [NSString stringWithFormat:@"%d",[[Common getCatVersion:PRODUCTS_CENTER_LIST_COMMAND_ID withId:[catID intValue]] intValue]];
    NSString *verStr = @"0";
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       verStr,@"ver",
                                       [NSNumber numberWithInt:shopId],@"shop_id",
                                       [NSString stringWithFormat:@"%@",catID],@"catalog_id",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:PRODUCTS_CENTER_LIST_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

- (void)accessServiceMore
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *position = [NSString stringWithFormat:@"%d",[ShopObject getArrMin:self.dataArr]];
    
    NSString *reqUrl = @"productlist.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"-1",@"ver",
                                       [NSNumber numberWithInt:0],@"shop_id",
                                       [NSString stringWithFormat:@"%@",catID],@"catalog_id",
                                       position,@"position", nil];

    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:PRODUCTS_CENTER_LIST_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

// 请求成功后的回调
#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == PRODUCTS_CENTER_LIST_COMMAND_ID) {
        self.isLoading = NO;
        [self accessUpdate:resultArray];
    }
    else if (commandid == PRODUCTS_CENTER_LIST_MORE_COMMAND_ID) {
        [self accessUpdateMore:resultArray];
    }
}

- (void)accessUpdate:(NSMutableArray *)resultArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL flag = NO;
        
        productsCenter_list_model *slMod = [[productsCenter_list_model alloc]init];
        
        slMod.where = [NSString stringWithFormat:@"catalog_id = '%d'",[catID intValue]];
        
        NSMutableArray *arr = [slMod getList];
        
        [slMod release];
        
        if (arr.count % 20 == 0  && arr.count != 0) {
            flag = YES;
        } else {
            flag = NO;
        }
        
        self.dataArr = [Common sortInt:arr field:@"position" sort:SortEnumDesc];
        NSLog(@"arr water = %@",dataArr);
        self.waterArr = [ShopObject listDataArrConversion:self.dataArr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (![[resultArray lastObject] isEqual:CwRequestFail])
            {
                if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    // 服务器繁忙，请重新再试
                    searchBarC.userInteractionEnabled = NO;
                    [self failViewCreate:CwTypeViewNoService];
                }else {
                    
                    _tableViewC.isShowFooterView = flag;
                    
                    [self loadDataFinish];
                    
                    self.listViewType = ListWaterViewType;
                    
                    [self nullViewSuper:0];
                    [_tableViewC reloadData];
                }
            }else {
                if ([self.dataArr count] == 0) {
                    searchBarC.userInteractionEnabled = NO;
                    if ([Common connectedToNetwork]) {
                        // 网络繁忙，请重新再试
                        [self failViewCreate:CwTypeViewNoRequest];
                    } else {
                        // 当前网络不可用，请重新再试
                        [self failViewCreate:CwTypeViewNoNetWork];
                    }
                }else {
                    _tableViewC.isShowFooterView = flag;
                    
                    [self loadDataFinish];
                    
                    self.listViewType = ListWaterViewType;
                    
                    [self nullViewSuper:0];
                    [_tableViewC reloadData];
                }
            }
        });
    });
    
    [pool release];
}

- (void)accessUpdateMore:(NSMutableArray *)resultArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL flag = NO;
        
        NSArray *arr = resultArray;
        
        if (arr.count % 20 == 0  && arr.count != 0) {
            flag = YES;
        } else {
            flag = NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![[resultArray lastObject] isEqual:CwRequestFail])
            {
                if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    [self progressHUD:KCWServerBusyPrompt type:0];
                }else {
                    if (arr.count > 0) {
                        [self.dataArr addObjectsFromArray:arr];
                        self.waterArr = [ShopObject listDataArrConversion:self.dataArr];
                    }
                    
                    _tableViewC.isShowFooterView = flag;
                    
                    [self loadDataFinish];
                    
                    self.listViewType = ListWaterViewType;
                    [_tableViewC reloadData];
                }
            }else {
                [self progressHUD:KCWNetNOPrompt type:3];
                
                _tableViewC.isShowFooterView = YES;
                
                [self loadDataFinish];
                
                self.listViewType = ListWaterViewType;
                [_tableViewC reloadData];
            }
        });
    });
    
    [pool release];
}

@end
