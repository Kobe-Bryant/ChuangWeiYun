//
//  homeViewController.m
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import "homeViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "IconPictureProcess.h"
#import "cloudLoadingView.h"
#import "ad_model.h"
#import "adView.h"
#import "scanViewController.h"
#import "cwAppDelegate.h"
#import "BaiduMapViewController.h"
//#import "InformationsViewController.h"
#import "preferentialViewController.h"
#import "ServiceViewController.h"
#import "add_content_model.h"
#import "AppCatListViewController.h"
#import "InformationDetailViewController.h"
#import "ShopDetailsViewController.h"
#import "browserViewController.h"
#import "PfDetailViewController.h"
#import "BackViewController.h"
#import "CustomTabBar.h"
#import "ad_log_model.h"
#import "PopLoctionHelpView.h"
#import "CityLoction.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CityChooseViewController.h"

#define bgWidth 106.0f
#define bgHeight 106.0f

@interface homeViewController ()
{
    CitySubbranchEnum subbranchEnum;    // dufu add 2013.10.24
    NSDictionary *listDic;
}
@property (retain, nonatomic) NSDictionary *listDic;
@end

@implementation homeViewController
@synthesize cloudLoading;
@synthesize mainScrollView;
@synthesize bannerScrollView;
@synthesize pageControll;
@synthesize contentView;
@synthesize myImgViewArray;
@synthesize adItems;
@synthesize tagsItems;
@synthesize itemViewArr;
@synthesize isEditing;
@synthesize listDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green: 0.9 blue: 0.9 alpha:1.0];
    
    bannerWidth = self.view.frame.size.width;
    bannerHeight = 240.0f;
    
    iconWidth = 55.0f;
    iconHeight = 55.0f;
    
    NSMutableArray *tempMyImgViewArray = [[NSMutableArray alloc] init];
    self.myImgViewArray = tempMyImgViewArray;
    [tempMyImgViewArray release];
    
    itemViewArr = [[NSMutableArray alloc] init];
    
    //主体
    UIScrollView *tmpScroll = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width, self.view.frame.size.height - 44.0f - 49.0f)];
    tmpScroll.contentSize = CGSizeMake(self.view.frame.size.width, tmpScroll.frame.size.height);
    tmpScroll.pagingEnabled = NO;
    tmpScroll.showsHorizontalScrollIndicator = NO;
    tmpScroll.showsVerticalScrollIndicator = NO;
    tmpScroll.delegate = self;
    self.mainScrollView = tmpScroll;
    [tmpScroll release];
    [self.view addSubview:self.mainScrollView];
    
    //下拉更新
//	_refreshHeaderView = nil;
//	_reloading = NO;
//	EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.mainScrollView.bounds.size.height, self.view.frame.size.width, self.mainScrollView.bounds.size.height)];
//	view.delegate = self;
//	[self.mainScrollView addSubview:view];
//	_refreshHeaderView = view;
//	[view release];
//	[_refreshHeaderView refreshLastUpdatedDate];
	
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(KUIScreenWidth / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    //网络请求
    [self accessItemService];
    
    _isShow = NO;
    
    if (IOS_7) {
        [Common iosCompatibility:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isShow == YES) {
        showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - KDownBarHeight - 30, 320, 30)];
        showLabel.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7];
        showLabel.text = @"长按图标可以删除添加的便民服务";
        showLabel.font = [UIFont systemFontOfSize:14.0f];
        showLabel.textColor = [UIColor whiteColor];
        showLabel.textAlignment = UITextAlignmentCenter;
        [[UIApplication sharedApplication].delegate.window addSubview:showLabel];
        
        [self performSelector:@selector(removeShowLabel) withObject:nil afterDelay:2];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (subbranchEnum == CitySubbranchHomeServiceList){
        subbranchEnum = CitySubbranchNormal;
        [self library];
    }else if (subbranchEnum == CitySubbranchHomeService) {
        [self catList:self.listDic];
    }else if (subbranchEnum == CitySubbranchHomePreferent) {
        subbranchEnum = CitySubbranchNormal;
        [self news];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isShow = NO;
    
    [self removeShowLabel];
}

- (void)removeShowLabel
{
    [showLabel removeFromSuperview];
}

//添加banner
-(void)addBannerScrollView
{
    XLCycleScrollView *tempBannerScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0.0f , 0.0f , bannerWidth , bannerHeight)];
    if (self.adItems.count > 1) {
        tempBannerScrollView.isAutoPlay = YES;
    } else {
        tempBannerScrollView.isAutoPlay = NO;
    }
    tempBannerScrollView.isResponseTap = NO;
    tempBannerScrollView.delegate = self;
    tempBannerScrollView.datasource = self;
    self.bannerScrollView = tempBannerScrollView;
    [tempBannerScrollView release];
    [self.mainScrollView addSubview:self.bannerScrollView];
    
}

//添加主内容 icon按钮
-(void)addContentView
{
    //先移出
    [self.contentView removeFromSuperview];

    UIView *tempContentView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , CGRectGetMaxY(self.bannerScrollView.frame), self.view.frame.size.width, 215.0f)];
    tempContentView.backgroundColor = [UIColor clearColor];
    self.contentView = tempContentView;
    [self.mainScrollView addSubview:self.contentView];
    [tempContentView release];
    
    //获取应用库数据 http://hkh.cn.yunlai.cn/userfiles/000/001/426/product/20130122/1314552708.jpg
    add_content_model *acModel = [[add_content_model alloc] init];
    acModel.orderBy = @"created";
    acModel.orderType = @"desc";
    self.tagsItems = [acModel getList];
    [acModel release];
    
    [self.itemViewArr removeAllObjects];

    //中间icon间隔
    CGFloat midIconWidth = 1.0f;//((self.view.frame.size.width - (3*iconWidth)) / 4);
    
    // =======================  添加第一排按钮  ========================
    /*
    //二维码扫描
    UIImage *codeImage = [UIImage imageCwNamed:@"icon_cloud_home.png"];
    
	UIButton *codeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	codeButton.frame = CGRectMake( midIconWidth , midIconWidth , bgWidth, bgHeight);
    codeButton.tag = 1;
	[codeButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:codeButton];
    codeButton.backgroundColor = [UIColor whiteColor];
    
    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(codeButton.frame.origin.x, CGRectGetMaxY(codeButton.frame) - 20.0f , codeButton.frame.size.width, 12.0f)];
	codeLabel.text = @"云拍";
	codeLabel.textColor = HOME_STR_COLOR;
	codeLabel.font = [UIFont systemFontOfSize:12.0f];
	codeLabel.textAlignment = UITextAlignmentCenter;
	codeLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:codeLabel];
	[codeLabel release];
    
    UIImageView *codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(midIconWidth + (bgWidth - iconWidth) * 0.5, 15, iconWidth, iconHeight)];
    codeImageView.image = codeImage;
    codeImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:codeImageView];
    [codeImageView release];
    
    //产品中心
    UIImage *hotImage = [UIImage imageCwNamed:@"icon_hot_home.png"];
    
	UIButton *hotButton = [UIButton buttonWithType:UIButtonTypeCustom];
	hotButton.frame = CGRectMake( CGRectGetMaxX(codeButton.frame) + midIconWidth , midIconWidth , bgWidth, bgHeight);
    hotButton.tag = 2;
	[hotButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:hotButton];
    hotButton.backgroundColor = [UIColor whiteColor];
    
    UILabel *hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(hotButton.frame.origin.x, CGRectGetMaxY(hotButton.frame) - 20.0f , hotButton.frame.size.width, 12.0f)];
	hotLabel.text = @"产品中心";
	hotLabel.textColor = HOME_STR_COLOR;
	hotLabel.font = [UIFont systemFontOfSize:12.0f];
	hotLabel.textAlignment = UITextAlignmentCenter;
	hotLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:hotLabel];
	[hotLabel release];
    
    UIImageView *hotImageView = [[UIImageView alloc] initWithFrame:CGRectMake( CGRectGetMaxX(codeButton.frame) + midIconWidth + (bgWidth - iconWidth) * 0.5, 15, iconWidth, iconHeight)];
    hotImageView.image = hotImage;
    hotImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:hotImageView];
    [hotImageView release];
    
    //附近的店
    UIImage *nearImage = [UIImage imageCwNamed:@"icon_map_home.png"];
    
	UIButton *nearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nearButton.frame = CGRectMake( CGRectGetMaxX(hotButton.frame) + midIconWidth , midIconWidth , bgWidth, bgHeight);
    nearButton.tag = 3;
	[nearButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:nearButton];
    nearButton.backgroundColor = [UIColor whiteColor];
    
    UILabel *nearLabel = [[UILabel alloc] initWithFrame:CGRectMake(nearButton.frame.origin.x, CGRectGetMaxY(nearButton.frame) - 20.0f , nearButton.frame.size.width, 12.0f)];
	nearLabel.text = @"附近的店";
	nearLabel.textColor = HOME_STR_COLOR;
	nearLabel.font = [UIFont systemFontOfSize:12.0f];
	nearLabel.textAlignment = UITextAlignmentCenter;
	nearLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:nearLabel];
	[nearLabel release];
    
    UIImageView *nearImageView = [[UIImageView alloc] initWithFrame:CGRectMake( CGRectGetMaxX(hotButton.frame) + midIconWidth + (bgWidth - iconWidth) * 0.5, 15, iconWidth, iconHeight)];
    nearImageView.image = nearImage;
    nearImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:nearImageView];
    [nearImageView release];
    
    // =======================  添加第二排按钮 , 支持多排  ========================
     
     //第一个 创维动态 还是固定的
     UIImage *newsImage = [UIImage imageCwNamed:@"icon_news_home.png"];
     
     UIButton *newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
     newsButton.frame = CGRectMake( midIconWidth , CGRectGetMaxY(codeButton.frame) + midIconWidth , bgWidth, bgHeight);
    newsButton.tag = 4;
     [newsButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
     [self.contentView addSubview:newsButton];
     newsButton.backgroundColor = [UIColor whiteColor];
     
     UILabel *newsLabel = [[UILabel alloc] initWithFrame:CGRectMake(newsButton.frame.origin.x, CGRectGetMaxY(newsButton.frame) - 20.0f , newsButton.frame.size.width, 12.0f)];
     newsLabel.text = @"活动资讯";
     newsLabel.textColor = HOME_STR_COLOR;
     newsLabel.font = [UIFont systemFontOfSize:12.0f];
     newsLabel.textAlignment = UITextAlignmentCenter;
     newsLabel.backgroundColor = [UIColor clearColor];
     [self.contentView addSubview:newsLabel];
     [newsLabel release];
    
    UIImageView *newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(midIconWidth + (bgWidth - iconWidth) * 0.5, CGRectGetMaxY(codeButton.frame) + midIconWidth + 15, iconWidth, iconHeight)];
    newsImageView.image = newsImage;
    newsImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:newsImageView];
    [newsImageView release];
    
    //第二个 售后服务 还是固定的
    UIImage *serviceImage = [UIImage imageCwNamed:@"icon_aftermarket_home.png"];
    
	UIButton *serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
	serviceButton.frame = CGRectMake( CGRectGetMaxX(newsButton.frame) + midIconWidth , CGRectGetMaxY(codeButton.frame) + midIconWidth , bgWidth, bgHeight);
    serviceButton.tag = 5;
	[serviceButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:serviceButton];
    serviceButton.backgroundColor = [UIColor whiteColor];
    
    UILabel *serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(serviceButton.frame.origin.x, CGRectGetMaxY(serviceButton.frame) - 20.0f , serviceButton.frame.size.width, 12.0f)];
	serviceLabel.text = @"售后服务";
	serviceLabel.textColor = HOME_STR_COLOR;
	serviceLabel.font = [UIFont systemFontOfSize:12.0f];
	serviceLabel.textAlignment = UITextAlignmentCenter;
	serviceLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:serviceLabel];
	[serviceLabel release];
    
    UIImageView *serviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(newsButton.frame) + midIconWidth + (bgWidth - iconWidth) * 0.5, CGRectGetMaxY(codeButton.frame) + midIconWidth + 15, iconWidth, iconHeight)];
    serviceImageView.image = serviceImage;
    serviceImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:serviceImageView];
    [serviceImageView release];
    */
    
    NSArray *titleArr = [[NSArray alloc] initWithObjects:@"云拍",@"产品中心",@"附近的店",@"优惠活动",@"售后服务", nil];
    NSArray *imgArr = [[NSArray alloc] initWithObjects:@"icon_cloud_home.png",@"icon_hot_home.png",@"icon_map_home.png",@"icon_news_home.png",@"icon_aftermarket_home.png", nil];

    int residueNum1 = 0;   //余数
    int divisibleNum1 = 0;     //整除数
    for (int i = 0; i < [titleArr count]; i ++)
    {
        residueNum1 = (i + 3) % 3;
        divisibleNum1 = (i + 3) / 3 - 1;
        
        //自适应宽度
        CGFloat fixMarginWidth = ((residueNum1 + 1) * midIconWidth) + (residueNum1 * bgWidth);
        
        //自适应高度
        CGFloat fixMarginHeight = midIconWidth + divisibleNum1 * (bgHeight + midIconWidth);
        
        ItemView *item;
        item = [[ItemView alloc] initWithFrame:CGRectMake(fixMarginWidth , fixMarginHeight , bgWidth , bgHeight) atIndex:i + 1 editable:NO];
        item.delegate = self;
        
        [self.contentView addSubview:item];
        
        item.nameLabel.text = [NSString stringWithFormat:@"%@",[titleArr objectAtIndex:i]];
        item.itemImageView.image = [UIImage imageCwNamed:[imgArr objectAtIndex:i]];
    }
    [titleArr release], titleArr = nil;
    [imgArr release], imgArr = nil;
    
    fixHeight =  1 + bgHeight;
    
    //===== 动态的 =====
    int tagsCount = [self.tagsItems count] + 1;
    int residueNum = 0;   //余数
    int divisibleNum = 0;     //整除数
    if (tagsCount > 0)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        for (int i = 0; i < tagsCount; i ++)
        {
            residueNum = (i + 2) % 3;
            divisibleNum = (i + 2) / 3;
            
            //自适应宽度
            CGFloat fixMarginWidth = ((residueNum + 1) * midIconWidth) + (residueNum * bgWidth);

            //自适应高度
            CGFloat fixMarginHeight = fixHeight + midIconWidth + (divisibleNum * (bgHeight + midIconWidth));
            
            ItemView *item;
            if (i != tagsCount - 1)
            {
                NSDictionary *tagsDic = [self.tagsItems objectAtIndex:i];
                
                item = [[ItemView alloc] initWithFrame:CGRectMake(fixMarginWidth , fixMarginHeight , bgWidth , bgHeight) atIndex: i + 1000 editable:YES];
                item.delegate = self;
                item.isEditing = NO;
                
                [self.contentView addSubview:item];
                
                item.nameLabel.text = [NSString stringWithFormat:@"%@",[tagsDic objectForKey:@"name"]];
                
                NSString *photoUrl = [tagsDic objectForKey:@"logo"];
                //NSString *photoUrl = @"http://i8.hexunimg.cn/2013-03-01/151615559.jpg";
                NSString *picName = [Common encodeBase64:(NSMutableData *)[photoUrl dataUsingEncoding: NSUTF8StringEncoding]];

                if (photoUrl.length > 1)
                {
                    UIImage *photo = [[FileManager getPhoto:picName] fillSize:CGSizeMake(iconWidth, iconHeight)];
                    if (photo.size.width > 2)
                    {
                        item.itemImageView.image = photo;
                    }
                    else
                    {
                        UIImage *imageIcon = [UIImage imageCwNamed:@"default_55x55.png"];
                        
                        item.itemImageView.image = imageIcon;

                        [[IconPictureProcess sharedPictureProcess] startIconDownload:photoUrl forIndexPath:[NSIndexPath indexPathForRow:i inSection:4] delegate:self];
                    }
                }
                else
                {
                    UIImage *imageIcon = [UIImage imageCwNamed:@"default_55x55.png"];
                    item.itemImageView.image = imageIcon;
                }
            }
            else
            {
                //最后加号
                item = [[ItemView alloc] initWithFrame:CGRectMake(fixMarginWidth , fixMarginHeight , bgWidth , bgHeight) atIndex: i + 1000 editable:NO];
                item.delegate = self;
                item.nameLabel.text = @"便民服务";
                item.itemImageView.image = [UIImage imageCwNamed:@"icon_add_home.png"];

                [self.contentView addSubview:item];
            }
            
            [self.itemViewArr addObject:item];
            [item release];
            
            [pool release];
        }
        
        //------控制添加的白色填充view
        int _value = 3 - [self.tagsItems count] % 3;
        if ([self.tagsItems count] > 0 && _value > 0) {
            NSArray *addArr = [self.contentView subviews];
            for (int n = 0; n < [addArr count]; n ++) {
                UIView *vi = [addArr objectAtIndex:n];
                if (vi.tag > 10000) {
                    [vi removeFromSuperview];
                }
            }
            
            ItemView *lastView = [self.itemViewArr lastObject];
            for (int j = 0; j < _value; j ++) {
                ItemView *item = [[ItemView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lastView.frame) + 1 + j * (bgWidth + 1),lastView.frame.origin.y, bgWidth , bgHeight) atIndex:10001 + j editable:NO];
                item.delegate = self;
                item.nameLabel.text = @"";
                item.itemImageView.image = [UIImage imageCwNamed:@""];
                
                [self.contentView addSubview:item];
                [item release];
            }
        }
        //-------
    }
    
    CGFloat floatTagsCount = [self.tagsItems count];
    CGFloat floatNum = ceil((floatTagsCount + 3.0) / 3.0);
    CGFloat contentViewHeigh = fixHeight + midIconWidth + (floatNum * (bgHeight + midIconWidth));
    
    //contentViewHeigh += self.view.frame.size.height <= 460.0f ? 0.0f : 88.0f;
    
    [self.contentView setFrame:CGRectMake( 0.0f , CGRectGetMaxY(self.bannerScrollView.frame), self.view.frame.size.width, contentViewHeigh)];
    
    //设置主体高度
    CGFloat yHeight = 0.0f;
    if (IOS_7) {
        yHeight = self.contentView.frame.size.height + 17;
    }else{
        yHeight = self.contentView.frame.size.height + 1;
    }
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.bannerScrollView.frame.size.height + yHeight);
    
    //iphone4默认不完全显示
    if (KUIScreenHeight <= 460.0f)
    {
        self.mainScrollView.contentOffset = CGPointMake(0.0f, 88.0f);
    }
}

//按钮点击事件
- (void)btnAction:(id)sender
{
    //UIButton *btn = (UIButton *)sender;
    ItemView *btn = (ItemView *)sender;
    
    // dufu  add  2013.10.18  备注：是否开启定位功能
    if (btn.tag != 1 && btn.tag != 5) {
        if (![Common isLoctionOpen] || ![Common isLoction]) {
            [Common MsgBox:@"定位未开启" messege:@"请在”设置->隐私->定位服务“中确认“定位”和“创维云GO”是否为开启状态" cancel:@"确定" other:@"帮助" delegate:self];
            return;
        }
    }

    switch (btn.tag) {
        case 1:
            [self goCode];
//        {
//            CityChooseViewController *cit = [[CityChooseViewController alloc]init];
//            [self.navigationController pushViewController:cit animated:YES];
//        }
            
            break;
        case 2:
            [self hotProduct];
            break;
        case 3:
            [self nearShop];
            break;
        case 4:
        {
            if (![[CityLoction defaultSingle] showLoctionView]) {
                return;
            }
            
            if (![self citySubbranchView:CitySubbranchHomePreferent]) {
                return;
            }
            
            [self news];
        }
            break;
        case 5:
            [self service];
            break;
            
        default:
            break;
    }
}

//二维码扫描
-(void)goCode
{
    ALAssetsLibrary *photoLibrary = [[ALAssetsLibrary alloc] init];//创建一个资产库的对象

    //使用多线程编程，异步block的使用
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            NSLog(@"group = %@",group);
            if (group == nil) {
                scanViewController *scanView = [[scanViewController alloc] init];
                [self.navigationController pushViewController:scanView animated:YES];
                [scanView release];
                return;
            }
        };

        //错误的操作
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            CGFloat currentVersion = [[UIDevice currentDevice].systemVersion floatValue];
            if (currentVersion > 6.0) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"照片不可访问"
                                                   message:@"为了保证上传能正常使用，请在[设置]->[隐私]->[相机]->[创维云GO]，打开照片访问！"
                                                  delegate:nil
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"照片不可访问"
                                                   message:@"为了保证上传能正常使用，请在[设置]->[隐私]->[照片]->[创维云GO]，打开照片访问！"
                                                  delegate:nil
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        };

        // 使用资产库的相关枚举的方法，使用block编程
        [photoLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                    usingBlock:assetGroupEnumerator
                                  failureBlock:assetGroupEnumberatorFailure];

        [pool release];
    });
}

//产品中心
-(void)hotProduct
{
    BackViewController *center = [[BackViewController alloc] init];
    center._statusType = StatusTypeFromCenter;
    [self.navigationController pushViewController:center animated:YES];
    [center release];
}

//附近的店
-(void)nearShop
{
//    cwAppDelegate *cwApp = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
//    BaiduMapViewController *map = [[BaiduMapViewController alloc] init];
//    map.otherStatusTypeMap = StatusTypeFirstToMap;
//    [cwApp.navController pushViewController:map animated:YES];
//    [map release];
    
    BaiduMapViewController *map = [[BaiduMapViewController alloc] init];
    map.otherStatusTypeMap = StatusTypeFirstToMap;
    [self.navigationController pushViewController:map animated:YES];
    RELEASE_SAFE(map);
}

//优惠
-(void)news
{
//    InformationsViewController *info = [[InformationsViewController alloc] init];
//    [self.navigationController pushViewController:info animated:YES];
//    [info release];
    
    preferentialViewController *info = [[preferentialViewController alloc] init];
    [self.navigationController pushViewController:info animated:YES];
    [info release];
}

//售后服务
-(void)service
{
//    ServiceViewController *service = [[ServiceViewController alloc] init];
//    [self.navigationController pushViewController:service animated:YES];
//    [service release];
    NSString *url = @"http://cw.gg.pp.cc/index.html?open_id=oTJN9jswfEclgpgwqNXRxnKdp9pU";
    browserViewController *browser = [[browserViewController alloc] init];
    browser.isFromService = YES;
    browser.url = url;
    browser.webTitle = @"售后服务";
    [self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

//应用库
-(void)library
{
    AppCenterViewController *app = [[AppCenterViewController alloc] init];
    app.delegate = self;
    [self.navigationController pushViewController:app animated:YES];
    [app release];
}

//广告下滑动画
-(void)adDownAnimations
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:1];
    self.mainScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    [UIView commitAnimations];
}

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];

    if (iconDownloader != nil)
    {
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];

            
            if ([iconDownloader.indexPathInTableView section] <= 3)
            {
                [self.bannerScrollView reloadData];
            }
            else if([iconDownloader.indexPathInTableView section] == 4)
            {
                UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(iconWidth, iconHeight)];
                
                //按钮标签图片
                ItemView *item = (ItemView *)[self.contentView viewWithTag: [iconDownloader.indexPathInTableView row] + 1000];
                item.itemImageView.image = photo;
            }
		}
        
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
//网络获取数据
-(void)accessItemService
{
    NSString *reqUrl = @"index/adlist.do?param=";
	
    //NSString *verStr = [NSString stringWithFormat:@"%d",[[Common getVersion:OPERAT_AD_REFRESH] intValue]];
    NSString *verStr = @"0";
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       verStr,@"ver",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:OPERAT_AD_REFRESH accessAdress:reqUrl delegate:self withParam:nil];
}

//更新数据
-(void)update
{
    //取广告数据
    ad_model *adMod = [[ad_model alloc] init];
    adMod.orderBy = @"position";
    adMod.orderType = @"desc";
    self.adItems = [adMod getList];
    [adMod release];

    [self addBannerScrollView];
    
    //按钮标签
    if (![self.contentView isDescendantOfView:self.mainScrollView])
    {
        [self addContentView];
    }
    
    [self backNormal];
}

//回归常态
-(void)backNormal
{
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
	
	//下拉缩回
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
}

#pragma mark --- AppCenterViewDelegate 
- (void)addToContent:(BOOL)_isAdd
{
    [self addContentView];
    
    if (_isAdd == YES) {
        _isShow = YES;
    }else{
        _isShow = NO;
    }
}

#pragma mark - datasource
- (NSInteger)numberOfPages
{
    return [self.adItems count];
}

#pragma mark - UIView
- (UIView *)pageAtIndex:(XLCycleScrollView *)xlcScrollView viewForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    adView *view = [xlcScrollView dequeueReusableViewWithIndex:[indexPath section]];
    
    if (view == nil)
    {
        view = [[[adView alloc]  initWithFrame:CGRectMake(0.0f , 0.0f , bannerWidth , bannerHeight)] autorelease];
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if ([adItems count] > 0) {
        NSDictionary *adDic = [adItems objectAtIndex:[indexPath row]];
        
        //描述
        //view.descLabel.text = [adDic objectForKey:@"desc"];
        
        //图片
        view.picView.mydelegate = self;
        view.picView.imageId = [NSString stringWithFormat:@"%d",[indexPath row]];
        
        NSString *picUrl = [adDic objectForKey:@"picture"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(bannerWidth, bannerHeight)];
            if (pic.size.width > 2)
            {
                [view.picView stopSpinner];
                view.picView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
                
                view.picView.image = [defaultPic fillSize:CGSizeMake(bannerWidth, bannerHeight)];
                
                [view.picView stopSpinner];
                [view.picView startSpinner];
                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
            view.picView.image = [defaultPic fillSize:CGSizeMake(bannerWidth, bannerHeight)];
        }
    }
    [pool release];
    
    return view;
}


#pragma mark - click
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    //do nothing...
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        PopLoctionHelpView *helpView = [[PopLoctionHelpView alloc]init];
        [helpView addPopupSubview];
        [helpView release], helpView = nil;
    }
}

#pragma mark - 图片滚动委托
- (void)imageViewTouchesEnd:(NSString *)imageId
{
    NSDictionary *adDic = [self.adItems objectAtIndex:[imageId intValue]];
    //NSLog(@"=== %@",adDic);
    int type = [[adDic objectForKey:@"link_type"] intValue];
    NSString *_infoId = [NSString stringWithFormat:@"%d",[[adDic objectForKey:@"relation_id"] intValue]];
    
    switch (type)
    {
        //站内资讯详情页
        case 1:
        {
            InformationDetailViewController *detail = [[InformationDetailViewController alloc] init];
            detail.inforId = _infoId;
            [self.navigationController pushViewController:detail animated:YES];
            [detail release];
        }
            break;
        //站内商品详情页
        case 2:
        {
            ShopDetailsViewController *view = [[ShopDetailsViewController alloc]init];
            view.productID = _infoId;
            view.cwStatusType = StatusTypeHotAD;
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
            break;
        //站内优惠活动详情页
        case 3:
        {
            NSString *url = [adDic objectForKey:@"url"];
            if (url.length > 0) {
                browserViewController *browser = [[browserViewController alloc] init];
                browser.url = url;
                [self.navigationController pushViewController:browser animated:YES];
                [browser release];
            }else {
                PfDetailViewController *pfDetailView = [[PfDetailViewController alloc]init];
                pfDetailView.promotionId = _infoId;
                [self.navigationController pushViewController:pfDetailView animated:YES];
                [pfDetailView release];
            }
        }
            break;
        //站内商品分类
        case 4:
        {
            // dufu  add  2013.10.18  备注：是否开启定位功能
            if (![Common isLoctionOpen] || ![Common isLoction]) {
                [Common MsgBox:@"定位未开启" messege:@"请在”设置->隐私->定位服务“中确认“定位”和“创维云GO”是否为开启状态" cancel:@"确定" other:@"帮助" delegate:self];
                return;
            }
            
            NSString *_catId = [NSString stringWithFormat:@"%@",[adDic objectForKey:@"relation_id"]];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"catSendRequest" object:_catId];
            
            NSArray *arrayViewControllers = self.navigationController.viewControllers;
            if ([[arrayViewControllers objectAtIndex:0] isKindOfClass:[CustomTabBar class]])
            {
                CustomTabBar *tabViewController = [arrayViewControllers objectAtIndex:0];
                
                UIButton *btn = (UIButton *)[tabViewController.view viewWithTag:90001];
                
                [tabViewController selectedTab:btn];
            }
        }
            break;
        //站外链接
        case 5:
        {
            browserViewController *browser = [[browserViewController alloc] init];
            browser.url = [adDic objectForKey:@"url"];
            [self.navigationController pushViewController:browser animated:YES];
            [browser release];
        }
            break;
        default:
            break;
    }
    // 点击广告图次数
    [self readAndWriteAdLog:_infoId];
}

- (void)imageViewDoubleTouchesEnd:(NSString *)imageId
{
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.mainScrollView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (scrollView == self.mainScrollView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if(scrollView == self.bannerScrollView.scrollView)
    {
        [self adDownAnimations];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mainScrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
    [self accessItemService];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - ItemViewDelegate
- (void)longPressStateBegan:(BOOL)isbool
{
    if ([self.tagsItems count] > 0) {
        for (ItemView *item in self.itemViewArr) {
            [item enableEditing:isbool];
        }
        self.isEditing = isbool;
    }
}

- (void)itemDidDeleted:(ItemView *) gridItem atIndex:(NSInteger)index{
    ItemView * item = [itemViewArr objectAtIndex:index];
    
    // 删除数据库中ID数据
    int infoId = [[[tagsItems objectAtIndex:index] objectForKey:@"id"] intValue];
    add_content_model *slMod = [[add_content_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"id = %d",infoId];
    [slMod deleteDBdata];
    slMod.where = nil;
    [slMod release];
    
    [itemViewArr removeObjectAtIndex:index];
    
    [tagsItems removeObjectAtIndex:index];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect lastFrame = item.frame;
        CGRect curFrame;
        for (int i=index; i < [itemViewArr count]; i++) {
            ItemView *temp = [itemViewArr objectAtIndex:i];
            curFrame = temp.frame;
            [temp setFrame:lastFrame];
            lastFrame = curFrame;
            [temp setTag:i + 1000];
        }
        [item setFrame:lastFrame];
    }];
    [item removeFromSuperview];
    item = nil;
    
    CGFloat floatTagsCount = [self.tagsItems count];
    
    if (floatTagsCount == 0) {
        self.isEditing = NO;
        
        ItemView *lastItem = [itemViewArr objectAtIndex:0];
        lastItem.isEditing = NO;
    }
    
    CGFloat floatNum = ceil((floatTagsCount + 3.0) / 3.0);
    CGFloat contentViewHeigh = bgHeight + 1 + 1 + (floatNum * (bgHeight + 1));
    
    [self.contentView setFrame:CGRectMake( 0.0f , CGRectGetMaxY(self.bannerScrollView.frame), self.view.frame.size.width, contentViewHeigh)];
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.bannerScrollView.frame.size.height + self.contentView.frame.size.height + 1);
    
    //------控制添加的白色填充view
    NSArray *addArr = [self.contentView subviews];
    for (int n = 0; n < [addArr count]; n ++) {
        UIView *vi = [addArr objectAtIndex:n];
        if (vi.tag > 10000) {
            [vi removeFromSuperview];
        }
    }
    
    int _value = 3 - [self.tagsItems count] % 3;
    if ([self.tagsItems count] > 0 && _value > 0) {
        ItemView *lastView = [self.itemViewArr lastObject];
        for (int j = 0; j < _value; j ++) {
            ItemView *item = [[ItemView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lastView.frame) + 1 + j * (bgWidth + 1),lastView.frame.origin.y, bgWidth , bgHeight) atIndex:10001 + j editable:NO];
            item.delegate = self;
            item.nameLabel.text = @"";
            item.itemImageView.image = [UIImage imageCwNamed:@""];
            
            [self.contentView addSubview:item];
            [item release];
        }
    }
    //--------
}

- (void)longPressStateEnded:(ItemView *)item withLocation:(CGPoint)point GestureRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    item.backgroundColor = [UIColor whiteColor];
    
    CGRect lastFrame = [self orginPointOfIndex:item.tag - 1000];
    [UIView animateWithDuration:0.2 animations:^{
        item.frame = lastFrame;
    }];
    
    [self dragItemViewUpdateDB];
}

- (void)longPressStateMoved:(ItemView *)item withLocation:(CGPoint)point GestureRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    //NSLog(@"move--------");
    item.backgroundColor = [UIColor colorWithRed:0.8667 green:0.8667 blue:0.8667 alpha:1.0f];
    
    CGPoint _point = [recognizer locationInView:self.contentView];
    CGPoint pointInView = [recognizer locationInView:self.contentView];
    
    CGRect frame = item.frame;
    frame.origin.x = _point.x - point.x;
    frame.origin.y = _point.y - point.y;
    item.frame = frame;
    
    static BOOL animateing;
    int itemTag = item.tag - 1000;
    
    [self.contentView bringSubviewToFront:item];
    
    if (animateing) {
        return;
    }
    
    NSInteger toIndex = [self indexOfLocation:_point];
    NSInteger fromIndex = item.tag - 1000;
    //NSLog(@"fromIndex:%d toIndex:%d",fromIndex,toIndex);
    
    if (toIndex >= self.itemViewArr.count-1) {
        toIndex = self.itemViewArr.count-1;
        ItemView *temp = [self.itemViewArr objectAtIndex:toIndex];
        if (temp.isRemovable == NO) {
            toIndex--;
        }
        item.tag = toIndex + 1000;
    } else {
        item.tag = toIndex + 1000;
    }
    
    // 以下为将itemArray数组中的视图所在位置替换
    if (toIndex != fromIndex) {
        [UIView animateWithDuration:0.2 animations:^{
            animateing = YES;
            CGRect lastFrame = [self orginPointOfIndex:fromIndex];
            CGRect curFrame;
            
            int toTag = 0;
            int fromTag = 0;
            
            [self.itemViewArr removeObjectAtIndex:fromIndex];
            
            if (toIndex > fromIndex) {
                fromTag = itemTag;
                
                // 以下为将视图中的item视图所在位置替换
                for (int i = fromIndex; i < toIndex; i++) {
                    ItemView *temp = [self.itemViewArr objectAtIndex:i];
                    curFrame = temp.frame;
                    [temp setFrame:lastFrame];
                    lastFrame = curFrame;
                    [temp updateTag:i + 1000];
                    
                    // 以下为将主数组中的数据所在位置替换
                    toTag = i+1;
                    
                    [self dragItemViewFromSpringView:0 totag:toTag fromtag:fromTag];
                    
                    fromTag = i+1;
                }
            } else {
                toTag = itemTag;
                
                // 以下为将视图中的item视图所在位置替换
                for (int i = fromIndex-1; i >= toIndex; i--) {
                    ItemView *temp = [self.itemViewArr objectAtIndex:i];
                    curFrame = temp.frame;
                    [temp setFrame:lastFrame];
                    lastFrame = curFrame;
                    [temp updateTag:i+1 + 1000];
                    
                    // 以下为将主数组中的数据所在位置替换
                    fromTag = i;
                    
                    [self dragItemViewFromSpringView:0 totag:toTag fromtag:fromTag];
                    
                    toTag = i;
                }
            }
            
            [self.itemViewArr insertObject:item atIndex:toIndex];
            
        } completion:^(BOOL finished) {
            animateing = NO;
        }];
    }
    
    //翻页
    if (pointInView.y >= mainScrollView.frame.size.height - 50) {
        [mainScrollView scrollRectToVisible:CGRectMake(mainScrollView.frame.origin.x, mainScrollView.contentOffset.y + mainScrollView.frame.size.height, mainScrollView.frame.size.width,mainScrollView.frame.size.height) animated:YES];
    }else if (pointInView.y < mainScrollView.frame.size.height - 50) {
        [mainScrollView scrollRectToVisible:CGRectMake(mainScrollView.frame.origin.x,mainScrollView.frame.size.height - mainScrollView.contentOffset.y, mainScrollView.frame.size.width, mainScrollView.frame.size.height) animated:YES];
    }
}

- (void)clickItemView:(ItemView *)item
{
    if (isEditing) {
        for (ItemView *item in itemViewArr) {
            [item enableEditing:NO];
        }
        isEditing = NO;
    }else {
        //NSLog(@"item.tag == %d",item.tag);
        
        if (item.isRemovable == NO) {
            if (item.tag == [tagsItems count] + 1000) {
                // dufu  add  2013.11.19  备注：是否开启定位功能
                if (![Common isLoctionOpen] || ![Common isLoction]) {
                    [Common MsgBox:@"定位未开启" messege:@"请在”设置->隐私->定位服务“中确认“定位”和“创维云GO”是否为开启状态" cancel:@"确定" other:@"帮助" delegate:self];
                    return;
                }
                
                if (![[CityLoction defaultSingle] showLoctionView]) {
                    return;
                }
                
                if (![self citySubbranchView:CitySubbranchHomeServiceList]) {
                    return;
                }
                
                [self library]; //去应用库
            }else {
                [self btnAction:item];
            }
        }else {
            NSDictionary *dic = [tagsItems objectAtIndex:item.tag - 1000];
            
            int type = [[dic objectForKey:@"service_type"] intValue];
            if (type == 2) {
                NSString *url = [dic objectForKey:@"url"];
                if (url.length > 0) {
                    browserViewController *browser = [[browserViewController alloc] init];
                    browser.url = url;
                    [self.navigationController pushViewController:browser animated:YES];
                    [browser release];
                }
            }else {
                
                // dufu  add  2013.11.19  备注：是否开启定位功能
                if (![Common isLoctionOpen] || ![Common isLoction]) {
                    [Common MsgBox:@"定位未开启" messege:@"请在”设置->隐私->定位服务“中确认“定位”和“创维云GO”是否为开启状态" cancel:@"确定" other:@"帮助" delegate:self];
                    return;
                }
                
                if (![[CityLoction defaultSingle] showLoctionView]) {
                    return;
                }
                
                if (![self citySubbranchView:CitySubbranchHomeService]) {
                    return;
                }
                self.listDic = dic;
                
                [self catList:dic];
            }
        }
    }
}

- (void)catList:(NSDictionary *)dict
{
    NSString *name = [dict objectForKey:@"name"];
    NSString *infoId = [dict objectForKey:@"id"];
    
    AppCatListViewController *appList = [[AppCatListViewController alloc] init];
    appList.navTitle = name;
    appList.catId = infoId;
    [self.navigationController pushViewController:appList animated:YES];
    [appList release];
}

- (NSInteger)indexOfLocation:(CGPoint)location{
    //NSLog(@"== %f == %f",location.x,location.y);
    NSInteger index;
    
    NSInteger row =  (location.y - fixHeight) / (bgHeight + 1);
    NSInteger col =  location.x / (bgWidth + 1);
    //NSLog(@"row == %d  col == %d",row,col);
    if (row == 0) {
        index = 0;
    }else {
        index = row * 3 + col - 2;
    }
    
    if (index >= [itemViewArr count] - 1) {
        return  -1;
    }
    
    return index;
}

//获得CGRect
- (CGRect)orginPointOfIndex:(NSInteger)index
{
    CGRect rect = CGRectZero;
    
    if (index > [itemViewArr count] - 1 || index < 0) {
        return rect;
    }else{
        NSInteger row = (index + 2) / 3;
        NSInteger col = (index + 2) % 3;
        
        rect.origin.x = 1 + col * (bgWidth + 1);
        rect.origin.y = row * (bgHeight + 1) + fixHeight + 1;
        rect.size.width = bgWidth;
        rect.size.height = bgHeight;
        
        return  rect;
    }
}

// 拖拽数据进行一些数据更新
- (void)dragItemViewFromSpringView:(int)page totag:(int)totag fromtag:(int)fromtag
{
    int tonum = totag;
    int fromnum = fromtag;

    NSMutableDictionary *toarr = [[tagsItems objectAtIndex:tonum] retain];
    NSInteger toCreateTime = [[toarr objectForKey:@"created"]integerValue];

    NSMutableDictionary *fromarr1 = [tagsItems objectAtIndex:fromnum];
    NSInteger fromCreateTime = [[fromarr1 objectForKey:@"created"]integerValue];

    [fromarr1 removeObjectForKey:@"created"];
    [fromarr1 setObject:[NSNumber numberWithInteger:toCreateTime] forKey:@"created"];

    [toarr removeObjectForKey:@"created"];
    [toarr setObject:[NSNumber numberWithInteger:fromCreateTime] forKey:@"created"];

    [tagsItems removeObjectAtIndex:tonum];
    
    [tagsItems insertObject:toarr atIndex:fromnum];
    
    [toarr release];
}

// 拖拽完成后，更新数据库
- (void)dragItemViewUpdateDB
{
    int count = [self.tagsItems count];
    
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *fromarr = [tagsItems objectAtIndex:i];
        int infoId = [[fromarr objectForKey:@"id"]integerValue];
        
        add_content_model *slMod = [[add_content_model alloc]init];
        slMod.where = [NSString stringWithFormat:@"id = %d",infoId];
        NSArray *arr = [slMod getList];
        
        if ([arr count] > 0) {
            [slMod updateDB:fromarr];
        } else {
            [slMod insertDB:fromarr];
        }
        
        [slMod release];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.cloudLoading = nil;
    self.mainScrollView.delegate = nil;
    self.mainScrollView = nil;
    self.bannerScrollView.delegate = nil;
    self.bannerScrollView = nil;
    self.pageControll = nil;
    self.contentView = nil;
    self.adItems = nil;
    _refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
}

- (void)dealloc
{
    self.cloudLoading = nil;
    self.mainScrollView.delegate = nil;
    self.mainScrollView = nil;
    self.bannerScrollView.delegate = nil;
    self.bannerScrollView = nil;
    self.pageControll = nil;
    self.contentView = nil;
    self.tagsItems = nil;
    _refreshHeaderView.delegate = nil;
	_refreshHeaderView = nil;
    [itemViewArr release];
    [super dealloc];
}


// dufu add 2013.10.24
#pragma mark - 
// 读写Ad log数据
- (void)readAndWriteAdLog:(NSString *)infoID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ad_log_model *alMod = [[ad_log_model alloc]init];
        alMod.where = [NSString stringWithFormat:@"id = '%@'",infoID];
        NSMutableArray *arr = [alMod getList];
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:[infoID intValue]],@"id",
                                     [NSNumber numberWithInt:1],@"click_count", nil];
        if (arr.count > 0) {
            NSDictionary *dict = [arr lastObject];
            int count = [[dict objectForKey:@"click_count"] intValue];
            [data setObject:[NSNumber numberWithInt:++count] forKey:@"click_count"];
            [alMod updateDB:data];
        } else {
            [alMod insertDB:data];
        }
        
        [alMod release], alMod = nil;
    });
}

// dufu add 2013.10.24
// 切换分店选择页
- (BOOL)citySubbranchView:(CitySubbranchEnum)asubbranchEnum
{
    if ([Global sharedGlobal].shop_id.length == 0) {
        CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
        citySubbranch.delegate = self;
        citySubbranch.cityStr = [Global sharedGlobal].currCity;
        citySubbranch.subbranchEnum = asubbranchEnum;
        citySubbranch.cwStatusType = StatusTypeAPP;
        [self.navigationController pushViewController:citySubbranch animated:YES];
        [citySubbranch release], citySubbranch = nil;
        return NO;
    } else {
        return YES;
    }
}

// dufu add 2013.10.24
// 切换分店选择页伪托
#pragma mark - CitySubbranchViewControllerDelegate
- (void)chooseSubbranchInfo:(CitySubbranchEnum)asubbranchEnum
{
    subbranchEnum = asubbranchEnum;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
@end
