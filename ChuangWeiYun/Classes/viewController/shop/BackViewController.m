//
//  BackViewController.m
//  SideSlip
//
//  Created by yunlai on 13-8-5.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "BackViewController.h"
#import "product_cat_model.h"
#import "Common.h"
#import "FileManager.h"
#import "IconPictureProcess.h"
#import "products_center_model.h"
#import "HotProductsViewController.h"
#import "WaterFallViewController.h"
#import "NetworkFail.h"
#import "HttpRequest.h"

#define BackViewDataNum 100000

#define BackViewHeaderViewH 75.f

@interface BackViewController () <NetworkFailDelegate>
{
    NSInteger didselect;
    NSInteger endselect;
    
    NSInteger insertCount;
    NSInteger deleteCount;
    
    BOOL ifOpen;
    BOOL ifInsert;
    
    NSInteger selectSection;
    NSInteger oldSection;
    
    NSMutableArray *oldArr;
    
    NetworkFail *failView;
    UILabel *resultLabel;
    
    BOOL loaded;
}

// 选中的button 上面的imageView
@property (retain, nonatomic) UIImageView *fselectImageV;
@property (retain, nonatomic) UIImageView *bselectImageV;
@property (retain, nonatomic) NSMutableArray *oldArr;

@end

@implementation BackViewController

@synthesize tableViewC;
@synthesize dataArr;
@synthesize upBarView;
@synthesize twodataArr;
@synthesize fselectImageV;
@synthesize bselectImageV;
@synthesize oldArr;

@synthesize _statusType;
@synthesize cloudLoading;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (loaded) {
        if ([Global sharedGlobal].isRefShop) {
            [Global sharedGlobal].isRefShop = NO;
            [self accessItemService];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight);
    self.view.backgroundColor = [UIColor colorWithRed:222.f/255.f green:222.f/255.f blue:222.f/255.f alpha:1.f];
	
    [self viewLoad];
    
    [self dataLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCatMessage:) name:@"CatMessage" object:nil];
    
    //ioS7适配 chenfeng14.2.9 add
    if(IOS_7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        self.view.bounds = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
        
        [Common iosCompatibility:self];
        
    }
}

- (void)dataLoad
{
    didselect = BackViewDataNum;
    
    selectSection = BackViewDataNum;
    oldSection = BackViewDataNum;
    
    dataArr = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self accessItemService];
}

- (void)viewLoad
{
    if (_statusType == StatusTypeFromCenter) {
        self.title = @"产品中心";
    }else {
        [self createUpBar];
    }
}

// 添加tableView
- (void)addTableView
{
    int yValue = 0;
    int height = 0;
    if (_statusType == StatusTypeFromCenter) {
        if (IOS_7) {
            yValue = -20;
        }else{
            yValue = 0;
        }
        height = KUIScreenHeight - KUpBarHeight;
    }else {
        yValue = KUpBarHeight;
        height = KUIScreenHeight - yValue - KDownBarHeight;
    }
    
    if (_tableViewC == nil) {
        _tableViewC = [[UITableView alloc] initWithFrame:CGRectMake(0.f, yValue, KUIScreenWidth, height)];
        _tableViewC.backgroundColor = [UIColor colorWithRed:222.f/255.f green:222.f/255.f blue:222.f/255.f alpha:1.f];
        _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableViewC.dataSource = self;
        _tableViewC.delegate = self;
        [self.view addSubview:_tableViewC];
    } else {
        self.twodataArr = nil;
        didselect = BackViewDataNum;
        selectSection = BackViewDataNum;
        oldSection = BackViewDataNum;
        self.oldArr = nil;
        [_tableViewC reloadData];
    }
}

- (void)dealloc
{
    [_tableViewC release], _tableViewC = nil;
    [upBarView release], upBarView = nil;
    [dataArr release], dataArr = nil;
    [twodataArr release], twodataArr = nil;
    self.fselectImageV = nil;
    self.bselectImageV = nil;
    self.oldArr = nil;
    [cloudLoading release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CatMessage" object:nil];
    if (failView) {
        [failView release], failView = nil;
    }
    if (resultLabel) {
        [resultLabel release], resultLabel = nil;
    }
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// 判断有没有数据,显示不同的试图
- (void)isAddTableView
{
    if (self.dataArr.count == 0) {
        _tableViewC.hidden = YES;
    } else {
        _tableViewC.hidden = NO;
        [self addTableView];
    }
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService]; //hui add 11.18
}

#pragma mark - NSNotification
- (void)requestCatMessage:(NSNotification *)notification
{
    [self accessItemService];
}

// 创建上bar
- (void)createUpBar
{
    upBarView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUpBarHeight)];
    upBarView.backgroundColor = [UIColor colorWithRed:222.f/255.f green:222.f/255.f blue:222.f/255.f alpha:1.f];
    [self.view addSubview:upBarView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth-60.f, KUpBarHeight)];
    label.text = @"商品分类";
    label.font = KCWSystemFont(18.f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [upBarView addSubview:label];
    [label release], label = nil;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

// 网络请求刷新
- (void)accessUpdate
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        product_cat_model *pcMod = [[product_cat_model alloc]init];
        
        pcMod.where = [NSString stringWithFormat:@"ltrim(rtrim(parent_id)) = ltrim(rtrim(id))"];
        
        // 排序
        self.dataArr = [Common sortInt:[pcMod getList] field:@"position" sort:SortEnumDesc];
        
        NSDictionary *dict = nil;
        if (self.dataArr.count > 0) {
            dict = [self.dataArr objectAtIndex:0];
        }
        
        pcMod.where = [NSString stringWithFormat:@"parent_id = %@",[dict objectForKey:@"id"]];
        
        NSMutableArray *arr = [pcMod getList];
        
        [pcMod release];

        NSDictionary *removeDict = nil;
        for (NSDictionary *idDict in arr) {
            if ([[idDict objectForKey:@"id"] isEqualToString:[idDict objectForKey:@"parent_id"]]) {
                removeDict = idDict;
            }
        }
        
        if (removeDict.count > 0) {
            [arr removeObject:removeDict];
        }
        
        NSString *catid = nil;
        
        if (arr.count != 0) {
            dict = [arr objectAtIndex:0];
        }
        catid = [dict objectForKey:@"id"];
        NSLog(@"catid = %@",catid);
        
        if (catid.length == 0 || [catid isEqual:[NSNull null]]) {
            catid = @"123456789";
        } 

        dispatch_async(dispatch_get_main_queue(), ^{
           
            if ([catid isEqualToString:@"123456789"]) {
                if (resultLabel == nil) {
                    resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 60.f, KUIScreenWidth-60.f, 30.f)];
                    resultLabel.backgroundColor = [UIColor clearColor];
                    resultLabel.textAlignment = NSTextAlignmentCenter;
                    resultLabel.textColor = [UIColor grayColor];
                    resultLabel.text = @"当前分店暂无上架商品";
                    [self.view addSubview:resultLabel];
                } else {
                    resultLabel.hidden = NO;
                }
            } else {
                resultLabel.hidden = YES;
            }
            
            NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [dict objectForKey:@"name"],@"name", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NameAndTitle" object:object];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"catSendRequest" object:catid];
            
            [self isAddTableView];
        });
    });
    
    [pool release];
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

- (void)accessUpdateProducts:(NSMutableArray*)resultArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    
    products_center_model *pcMod = [[products_center_model alloc]init];
    
    pcMod.where = [NSString stringWithFormat:@"ltrim(rtrim(parent_id)) = ltrim(rtrim(id))"];
    
    // 排序
    self.dataArr = [Common sortInt:[pcMod getList] field:@"position" sort:SortEnumDesc];
    
    NSDictionary *dict = nil;
    
    if ([[resultArray lastObject] isEqual:CwRequestFail] && self.dataArr.count == 0){
        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoRequest];
        } else {
            // 当前网络不可用，请重新再试
            [self failViewCreate:CwTypeViewNoNetWork];
        }
    }else{
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
            // 服务器繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoService];
        } else {
            dict = [self.dataArr objectAtIndex:0];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"",@"id",
                                        @"",@"image",
                                        @"热销商品",@"name",
                                        @"",@"parent_id",
                                        @"",@"position",nil];
            [self.dataArr insertObject:dic atIndex:0];
            
            pcMod.where = [NSString stringWithFormat:@"parent_id = %@",[dict objectForKey:@"id"]];
            
            NSMutableArray *arr = [pcMod getList];

            NSDictionary *removeDict = nil;
            for (NSDictionary *idDict in arr) {
                if ([[idDict objectForKey:@"id"] isEqualToString:[idDict objectForKey:@"parent_id"]]) {
                    removeDict = idDict;
                }
            }
            
            if (removeDict.count > 0) {
                [arr removeObject:removeDict];
            }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isAddTableView];
            });
        }
    }
    [pcMod release];
    
    [pool release];
}

// 网络请求
- (void)accessItemService
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //添加loading图标
    cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    NSString *reqUrl = @"product/cataloglist.do?param=";
	
    int type = 0;
    int command_id = 0;
    NSString *shopId = nil;
    NSNumber *ver = nil;
    if (_statusType == StatusTypeFromCenter) {
        type = 0;
        command_id = PRODUCTS_CENTER_COMMAND_ID;
//        ver = [Common getVersion:PRODUCTS_CENTER_COMMAND_ID];
        ver = [NSNumber numberWithInt:0];
        shopId = @"0";
    }else { 
        type = 1;
        command_id = PRODUCT_CAT_COMMAND_ID;
        shopId = [Global sharedGlobal].shop_id;
        ver = [NSNumber numberWithInt:0];
    }
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       ver,@"ver",
                                       shopId,@"shop_id",
                                       [NSNumber numberWithInt:type],@"type",nil];
    
    NSLog(@"requestDic == %@",requestDic);
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:command_id
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

// 创建一级分类的视图
- (UIView *)createHeaderView:(NSInteger)index
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, BackViewHeaderViewH)] autorelease];
    view.backgroundColor = [UIColor whiteColor]; //11.15 chenfeng
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, BackViewHeaderViewH);
    button.tag = index;
    
    [button addTarget:self action:@selector(insertCell:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    if (selectSection == index) {
        button.selected = YES;
        [button setBackgroundColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]];
    }

    UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 1.f)];
    line1.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
    [view addSubview:line1];
    [line1 release],line1 = nil;
    
    NSDictionary *dict = [self.dataArr objectAtIndex:index];
    
    // 分类的图片
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(10.f, 3.f, 70.f, 70.f)];
    
    if (_statusType == StatusTypeFromCenter && index == 0) {
        imgV.image = [UIImage imageCwNamed:@"icon-hottv-store.png"];
    }else {
        //图片
        NSString *picUrl = [dict objectForKey:@"image"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1) {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2) {
                imgV.image = pic;
            } else {
                imgV.image = [UIImage imageCwNamed:@"categories_default.png"];
                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] delegate:self];
            }
        } else {
            imgV.image = [UIImage imageCwNamed:@"categories_default.png"];
        }
    }
    
    [view addSubview:imgV];
    [imgV release], imgV = nil;
    
    // name Label
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(100, 0.f, 150.f, BackViewHeaderViewH)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];
    label.font = KCWSystemFont(15.f);
    label.text = [dict objectForKey:@"name"];
    [view addSubview:label];
    [label release],label = nil;

    if (self.dataArr.count - 1 == index) {
        // 线
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, BackViewHeaderViewH-1, KUIScreenWidth, 1.f)];
        line.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
        [view addSubview:line];
        [line release],line = nil;
    }

    // image
    UIImage *img = [UIImage imageCwNamed:@"icon_front_store.png"];
    int xValue = 0;
    if (_statusType == StatusTypeFromCenter) {
        xValue = 310 - img.size.width;
    }else {
        xValue = 220.f;
    }
    
    UIImageView *_imageV = [[UIImageView alloc]initWithFrame:CGRectMake(xValue, BackViewHeaderViewH/2-img.size.height/2, img.size.width, img.size.height)];
    _imageV.image = img;
    [button addSubview:_imageV];
    [_imageV release],_imageV = nil;
    
    [pool release];
    
    return view;
}

// 请求成功后的回调
#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == PRODUCT_CAT_COMMAND_ID) {
        loaded = YES;
        [self accessUpdate];
    }else if (commandid == PRODUCTS_CENTER_COMMAND_ID) {
//        [self accessUpdateProducts:resultArray];
        [self performSelectorOnMainThread:@selector(accessUpdateProducts:) withObject:resultArray waitUntilDone:NO];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == didselect) {
        return self.twodataArr.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        cell.backgroundView = nil;
        UIColor *gradc = [UIColor colorWithRed:131.f/255.f green:131.f/255.f blue:131.f/255.f alpha:1.f];
        cell.contentView.backgroundColor = gradc;
        cell.textLabel.backgroundColor = gradc;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = KCWSystemFont(15.f);
        
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 50.f, KUIScreenWidth, 1.f)];
        line.backgroundColor = [UIColor colorWithRed:124.f/255.f green:124.f/255.f blue:124.f/255.f alpha:1.f];
        [cell addSubview:line];
        [line release],line = nil;
        
        //11.14 chenfeng
        UIColor *selectColor = [[UIColor alloc]initWithRed:0.0/255.0f green:106.0/255.0f blue:193.0/255.0f alpha:0.9];
        cell.selectedBackgroundView = [[[UIView alloc]initWithFrame:cell.frame] autorelease];
        cell.selectedBackgroundView.backgroundColor = selectColor;
        [selectColor release];
    }
    NSDictionary *dict = [self.twodataArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [dict objectForKey:@"name"];

    return cell;
}

#pragma mark - UITableViewDelegate
// 选中row执行的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *adict = [self.twodataArr objectAtIndex:indexPath.row];
    NSString *pid = [NSString stringWithFormat:@"%d",[[adict objectForKey:@"id"] intValue]];
    NSLog(@"twodataArr pid = %@",pid);
    
    NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:[adict objectForKey:@"name"],@"name", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NameAndTitle" object:object];
    if (_statusType == StatusTypeFromCenter) {
        WaterFallViewController *water = [[WaterFallViewController alloc] init];
        water.statusType = StatusTypeFromCenter;
        water.catID = pid;
        water.title = [adict objectForKey:@"name"];
        [self.navigationController pushViewController:water animated:YES];
        [water release];
    }else {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"catSendRequest" object:pid];
        [self.parentViewController performSelector:@selector(revealToggle:)];
    }
}

// 设置row的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == didselect) {
        return 50.f;
    }
    return 0;
}

// 设置header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return BackViewHeaderViewH;
}

// header 视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self createHeaderView:section];
}

- (void)buttonSetSelected:(UIButton *)sender
{
    if (sender.selected) {
        sender.selected = NO;
        [sender setBackgroundColor:[UIColor clearColor]];
    } else {
        sender.selected = YES;
        [sender setBackgroundColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]];
    }
}
// 插入操作
- (void)insertCell:(UIButton *)sender
{
    if (selectSection != sender.tag) {
        [self buttonSetSelected:sender];
        selectSection = sender.tag;
        if (selectSection != oldSection && oldSection != BackViewDataNum) {
            NSRange range = NSMakeRange(oldSection, 1);
            NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
            [_tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationNone];
        }
        oldSection = selectSection;
//    } else {
//        selectSection = BackViewDataNum;
//        oldSection = BackViewDataNum;
    }

    if (_statusType == StatusTypeFromCenter) {
        if (sender.tag == 0) {
            HotProductsViewController *hot = [[HotProductsViewController alloc] init];
            [self.navigationController pushViewController:hot animated:YES];
            [hot release];
        }else {
            products_center_model *pcMod = [[products_center_model alloc] init];
            
            NSDictionary *dict = [self.dataArr objectAtIndex:sender.tag];
            
            pcMod.where = [NSString stringWithFormat:@"parent_id = %@",[dict objectForKey:@"id"]];
            
            NSMutableArray *arr = [pcMod getList];
            
            [pcMod release];
            
            // 降序
            self.twodataArr = [Common sortInt:arr field:@"position" sort:SortEnumAsc];
            
            NSDictionary *removeDict = nil;
            for (int i = 0;i < self.twodataArr.count;i++) {
                NSDictionary *idDict = [self.twodataArr objectAtIndex:i];
                if ([[idDict objectForKey:@"id"] isEqualToString:[idDict objectForKey:@"parent_id"]]) {
                    removeDict = idDict;
                }
            }
            
            if (removeDict.count > 0) {
                [self.twodataArr removeObject:removeDict];
            }
            
            insertCount = self.twodataArr.count;
            endselect = sender.tag;
            self.bselectImageV = [sender.subviews lastObject];
            
            if (didselect == endselect) {
                [self didSelectCellRowFirstDo:NO nextDo:NO];
            } else{
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
            
            if (self.twodataArr.count == 0) {
                WaterFallViewController *water = [[WaterFallViewController alloc] init];
                water.statusType = StatusTypeFromCenter;
                water.catID = [dict objectForKey:@"id"];
                water.title = [dict objectForKey:@"name"];
                [self.navigationController pushViewController:water animated:YES];
                [water release];
            }
        }
    } else {
        product_cat_model *pcMod = [[product_cat_model alloc]init];
        
        NSDictionary *dict = [self.dataArr objectAtIndex:sender.tag];
        
        pcMod.where = [NSString stringWithFormat:@"parent_id = %@",[dict objectForKey:@"id"]];
        
        NSMutableArray *arr = [pcMod getList];
        
        [pcMod release];
        
        // 降序
        self.twodataArr = [Common sortInt:arr field:@"position" sort:SortEnumAsc];;
        
        NSDictionary *removeDict = nil;
        for (int i = 0;i < self.twodataArr.count;i++) {
            NSDictionary *idDict = [self.twodataArr objectAtIndex:i];
            if ([[idDict objectForKey:@"id"] isEqualToString:[idDict objectForKey:@"parent_id"]]) {
                removeDict = idDict;
            }
        }
        
        if (removeDict.count > 0) {
            [self.twodataArr removeObject:removeDict];
        }
        
        insertCount = self.twodataArr.count;
        endselect = sender.tag;
        
        self.bselectImageV = [sender.subviews lastObject];

        if (didselect == endselect) {
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            
        } else{
            [self didSelectCellRowFirstDo:NO nextDo:YES];
        }
        
        if (self.twodataArr.count == 0) {
            NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"name"],@"name", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NameAndTitle" object:object];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"catSendRequest" object:[dict objectForKey:@"id"]];
            [self.parentViewController performSelector:@selector(revealToggle:)];
            return;
        }
    }
}

// 选中header
- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    [_tableViewC beginUpdates];
    
    ifOpen = firstDoInsert;

    if (!ifOpen) {
        didselect = BackViewDataNum;

        if (self.oldArr.count != 0) {
            ifInsert = NO;
            
            [UIView animateWithDuration:0.18 animations:^{
                self.fselectImageV.image = [UIImage imageCwNamed:@"icon_front_store.png"];
            }];
            
            deleteCount = 0;
            [_tableViewC deleteRowsAtIndexPaths:self.oldArr withRowAnimation:UITableViewRowAnimationNone];
            
            self.oldArr = nil;
        }
    } else {
        didselect = endselect;

        NSInteger sum = deleteCount == 0 ? insertCount : deleteCount;
        NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 0; i < sum; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:didselect];
            [rowArray addObject:indexPath];
        }
        
        if (rowArray.count != 0) {
            ifInsert = YES;
            [UIView animateWithDuration:0.18 animations:^{
                self.bselectImageV.image = [UIImage imageCwNamed:@"icon_down_store.png"];
            }];
            
            self.fselectImageV = self.bselectImageV;
            deleteCount = insertCount;
            
            [_tableViewC insertRowsAtIndexPaths:rowArray withRowAnimation:UITableViewRowAnimationNone];
            
            self.oldArr = rowArray;
        }
    }
    
    [_tableViewC endUpdates];

    if (nextDoInsert) {
        [self didSelectCellRowFirstDo:YES nextDo:NO];
        
        return;
    }
    
    if (ifInsert) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:didselect];
        [_tableViewC scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        if (iconDownloader != nil) {
            if(iconDownloader.cardIcon.size.width > 2.0) {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
                
                NSRange range = NSMakeRange(iconDownloader.indexPathInTableView.section, 1);
                NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
        [pool release];
    });
}

- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}

@end
