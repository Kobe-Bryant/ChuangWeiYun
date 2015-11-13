//
//  ProductListViewController.m
//  SideSlip
//
//  Created by yunlai on 13-8-9.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "ProductListViewController.h"
#import "shop_list_model.h"
#import "ProductListCell.h"
#import "Common.h"
#import "FileManager.h"
#import "IconPictureProcess.h"
#import "ShopDetailsViewController.h"
#import "ShopObject.h"
#import "CityChooseViewController.h"
#import "NetworkFail.h"
#import "shop_near_list_model.h"

@interface ProductListViewController () <NetworkFailDelegate>
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

@implementation ProductListViewController

@synthesize dataArr;
//@synthesize catTitle;
@synthesize title;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.title.length != 0) {
        [self setSubbranchLabelText:self.title];
        self.title = nil;
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataLoad];
    
    [self viewLoad];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateDataNotification:) name:UpdateProductList object:nil];
    [center addObserver:self selector:@selector(updateDataMoreNotification:) name:UpdateProductListMore object:nil];
    [center addObserver:self selector:@selector(pageOverNotification:) name:PageOverProductTurn object:nil];
    [center addObserver:self selector:@selector(updateNameAndTitle:) name:@"NameAndTitle" object:nil];
    
    [center addObserver:self selector:@selector(updateTitle:) name:@"updateTitle" object:nil];
    
    //ioS7适配 chenfeng14.2.9 add
    if(IOS_7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.view.bounds = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)dataLoad
{

}

- (void)viewLoad
{
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.tag = 'r';
    rightBtn.frame = CGRectMake(KUIScreenWidth - 50.f, 20.f, 50.f, KUpBarHeight);
    [rightBtn setImage:[UIImage imageCwNamed:@"grid.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageCwNamed:@"grid_click.png"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(btnRightClick:) forControlEvents:UIControlEventTouchUpInside];
    [upBarView addSubview:rightBtn];
    
    self.lfDelegate = self;
    
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewC.dataSource = self;
    _tableViewC.delegate = self;
    _tableViewC.loadDelegate = self;
    [_tableViewC reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self.dataArr removeAllObjects];
    self.dataArr = nil;
    
    if (failView) {
        [failView release], failView = nil;
    }
    [_nullView release], _nullView = nil;
    
    self.title = nil;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UpdateProductList object:nil];
    [center removeObserver:self name:UpdateProductListMore object:nil];
    [center removeObserver:self name:PageOverProductTurn object:nil];
    [center removeObserver:self name:@"NameAndTitle" object:nil];
    [center removeObserver:self name:@"updateTitle" object:nil];
    
    [super dealloc];
}

// 空视图
- (void)nullViewSuper:(int)flag
{
    if ([self.dataArr count] == 0) {
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
        UIButton *btn = (UIButton *)[upBarView viewWithTag:'r'];
        btn.hidden = NO;
        
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SendResquest object:[NSString stringWithFormat:@"%d",ListProductViewType]];
}

// 12.9chenfeng
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
        
        if (arr.count % 20 == 0  && arr.count != 0) {
            flag = YES;
        } else {
            flag = NO;
        }

        self.dataArr = [Common sortInt:arr field:@"position" sort:SortEnumDesc];
        
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
                self.listViewType = ListProductViewType;
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
        
        NSMutableArray *arr = [dict objectForKey:@"data"];
        
        if ([[dict objectForKey:@"failFlag"] intValue] != 1 || [[dict objectForKey:@"failFlag"] intValue] != 2) {
            if (arr.count % 20 == 0  && arr.count != 0) {
                flag = YES;
            } else {
                flag = NO;
            }
            
            if (arr.count > 0) {
                [self.dataArr addObjectsFromArray:arr];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            
            _tableViewC.isShowFooterView = flag;
            
            [self loadDataFinish];

            if ([[dict objectForKey:@"bool"] boolValue]) {
                self.listViewType = ListProductViewType;
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
    self.listViewType = ListProductViewType;
    [_tableViewC reloadData];
}

// 联网成功后的操作
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
}

#pragma mark - loadTableViewDidScroll
- (void)loadTableViewDownRefresh:(LoadTableView *)tableView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int position = [ShopObject getArrMin:self.dataArr];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%d",position],@"position",
                              [NSString stringWithFormat:@"%d",ListProductViewType],@"type", nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SendResquestMore object:dict];
        });
    });
}

- (void)loadTableViewUpRefresh:(LoadTableView *)tableView
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%d",ListProductViewType],@"Type", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SendResquest object:dict];
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
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSDictionary *dict = [self.dataArr objectAtIndex:indexPath.row];
    
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
    
    [pool release];

    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;

    height = [ProductListCell getCellHeight];

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopDetailsViewController *view = [[ShopDetailsViewController alloc]init];
    view.clickNum = indexPath.row;
    view.dataArr = self.dataArr;
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
                
                UIImage *photo = iconDownloader.cardIcon;

                ProductListCell *cell = (ProductListCell *)[_tableViewC cellForRowAtIndexPath:iconDownloader.indexPathInTableView];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setCellViewImage:photo];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
@end
