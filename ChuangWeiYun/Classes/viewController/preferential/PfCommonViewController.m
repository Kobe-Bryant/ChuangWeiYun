//
//  PfCommonViewController.m
//  cw
//
//  Created by yunlai on 13-8-28.
//
//

#import "PfCommonViewController.h"
#import "Common.h"
#import "PfImageView.h"
#import "QRCodeGenerator.h"
#import "PreferentialObject.h"
#import "IconPictureProcess.h"
#import "FileManager.h"
#import "Global.h"
#import "MBProgressHUD.h"
#import "cloudLoadingView.h"
#import "shop_near_list_model.h"
#import "dqxx_model.h"
#import "BaiduMapViewController.h"
#import "favorable_list_pic_model.h"
#import "ShopDetailsViewController.h"

#define PfComLeftRightW     10.f
#define PfComDownUpH        10.f
#define PfComInfoViewH      70.f

#define PfComFontSize12     10.f
#define PfComFontSize17     17.f
#define PfComFontSize20     20.f
#define pfCodeImageVWH      120.f   // 二维码的宽高

@interface PfCommonViewController ()
{
    UIView *_frontView;
    UIView *_backView;
    UIView *_bgView;
    
    BOOL flipflag;      // 翻页标识符
    
    NSMutableArray *dataArr;
    cloudLoadingView *cloudLoading;
}

@property (retain, nonatomic) NSMutableArray *dataArr;

@end

@implementation PfCommonViewController

@synthesize codeID;
@synthesize codeUrl;
@synthesize dict;
@synthesize dataArr;
@synthesize pfCommon;
@synthesize relationArr;
@synthesize intro;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self viewLoad];
    
    [self accessMapGetLongitudeService];
}

// 视图加载
- (void)viewLoad
{
    self.view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight);
    self.view.backgroundColor = [UIColor blackColor];
    
    _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    _bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [_bgView addGestureRecognizer:tap];
    [tap release], tap = nil;
    
    _frontView = [[UIView alloc]initWithFrame:self.view.bounds];
    _frontView.backgroundColor = [UIColor clearColor];
    _frontView.hidden = NO;
    [_bgView addSubview:_frontView];
    
    _backView = [[UIView alloc]initWithFrame:self.view.bounds];
    _backView.backgroundColor = [UIColor clearColor];
    _backView.hidden = YES;
    [_bgView addSubview:_backView];
    
    [self createFrontView];
    
    [self createBackView];
    
    //添加loading图标
    if (cloudLoading == nil) {
        cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
        [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    }
    [self.view addSubview:cloudLoading];
    
    //ioS7适配 chenfeng14.2.9 add
    if(IOS_7){
        self.view.bounds = CGRectMake(0,-20, self.view.frame.size.width, self.view.frame.size.height);
        [Common iosCompatibility:self];
    }
}

// 创建上Bar视图
- (void)createUpBarView:(UIView *)view
{
    CGFloat width = 0.f;
    
    UIImageView *upImageV = [[UIImageView alloc]initWithFrame:CGRectMake(PfComLeftRightW, 0.f, KUIScreenWidth - 2*PfComLeftRightW, KUpBarHeight)];
    upImageV.userInteractionEnabled = YES;
    upImageV.image = [UIImage imageCwNamed:@"coupons_top_bar.png"];
    [view addSubview:upImageV];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(width, 0.f, 50.f, KUpBarHeight);
    if (IOS_7) {//chenfeng2014.2.9 add
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
    }
    [leftBtn setImage:[UIImage imageCwNamed:@"return.png"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageCwNamed:@"return_click.png"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [upImageV addSubview:leftBtn];
    
    width += 50.f;
    
    UILabel *upLable = [[UILabel alloc]initWithFrame:CGRectMake(width, 0.f, CGRectGetWidth(upImageV.frame) - 2*width, KUpBarHeight)];
    upLable.backgroundColor = [UIColor clearColor];
    upLable.textColor = [UIColor whiteColor];
    upLable.textAlignment = NSTextAlignmentCenter;
    upLable.text = @"优惠券";
    [upImageV addSubview:upLable];
    
    width += CGRectGetWidth(upLable.frame);
    [upLable release], upLable = nil;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(width, 0.f, 50.f, KUpBarHeight);
    [rightBtn setImage:[UIImage imageCwNamed:@"icon_mark.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [upImageV addSubview:rightBtn];
    
    [upImageV release], upImageV = nil;
}

// 创建FrontView中间信息视图
- (void)createInfoView:(UIView *)view
{    
    PfImageView *infoImageV = [[PfImageView alloc]initWithFrame:CGRectMake(PfComLeftRightW, KUpBarHeight, KUIScreenWidth - 2*PfComLeftRightW, PfComInfoViewH)];
    infoImageV.userInteractionEnabled = YES;
    infoImageV.image = [UIImage imageCwNamed:@"bg_coupons_item.png"];
    infoImageV.moneylabel.text = [NSString stringWithFormat:@"¥%d",[[self.dict objectForKey:@"discount"] intValue]];
    infoImageV.titellabel.text = [self.dict objectForKey:@"title"];
    infoImageV.startlabel.text = [PreferentialObject getTheDate:[[self.dict objectForKey:@"start_date"] intValue] symbol:1];
    infoImageV.endlabel.text = [PreferentialObject getTheDate:[[self.dict objectForKey:@"end_date"] intValue] symbol:1];
    int start = [[self.dict objectForKey:@"start_date"] intValue];
    int end = [[self.dict objectForKey:@"end_date"] intValue];
    if ([[self.dict objectForKey:@"used"] intValue] == 1) {
        [infoImageV setImgViewImg:[UIImage imageCwNamed:@"consumption_coupons.png"] hide:NO];
    } else if (![PreferentialObject isPastDueDate:start end:end]) {
        [infoImageV setImgViewImg:[UIImage imageCwNamed:@"overdue_coupons.png"] hide:NO];
    } else {
        [infoImageV setImgViewImg:nil hide:YES];
    }

    [view addSubview:infoImageV];
    [infoImageV release], infoImageV = nil;
}

// 创建FrontView下面二维码视图
- (void)createFrontCodeView:(UIView *)view
{
    CGFloat height = KUIScreenHeight - KUpBarHeight - PfComInfoViewH - PfComDownUpH;
    CGFloat width = KUIScreenWidth - 2*PfComLeftRightW;
    
    UIImageView *downImageV = [[UIImageView alloc]initWithFrame:CGRectMake(PfComLeftRightW, KUpBarHeight + PfComInfoViewH, width, height)];
    downImageV.userInteractionEnabled = YES;
    downImageV.image = [[UIImage imageCwNamed:@"coupons_bottom_bg.png"] stretchableImageWithLeftCapWidth:10.f topCapHeight:20.f];
    [view addSubview:downImageV];
    
    UIView *codeView = [[UIView alloc]initWithFrame:CGRectMake(width/2 - pfCodeImageVWH/2, height/2 - pfCodeImageVWH/2 - 30.f, pfCodeImageVWH, pfCodeImageVWH)];
    codeView.backgroundColor = [UIColor whiteColor];
    [downImageV addSubview:codeView];
    
    NSString *qrstr = [NSString stringWithFormat:@"%@",self.codeUrl];
    UIImageView *codeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, 0.f, pfCodeImageVWH, pfCodeImageVWH)];
    codeImageView.image = [QRCodeGenerator qrImageForString:qrstr imageSize:codeImageView.bounds.size.width];
    [codeView addSubview:codeImageView];
    [codeImageView release], codeImageView = nil;

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, CGRectGetMaxY(codeView.frame), width, 40.f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = KCWSystemFont(19.f);
    label.text = [NSString stringWithFormat:@"NO.%@",self.codeID];
    [downImageV addSubview:label];
    [label release], label = nil;
    
    [codeView release], codeView = nil;
    [downImageV release], downImageV = nil;
}

// 创建BackView信息视图
- (void)createBackCodeView:(UIView *)view
{
    UIImageView *downImageV = [[UIImageView alloc]initWithFrame:CGRectMake(PfComLeftRightW, KUpBarHeight, KUIScreenWidth - 2*PfComLeftRightW, KUIScreenHeight - KUpBarHeight - PfComDownUpH)];
    downImageV.userInteractionEnabled = YES;
    downImageV.image = [[UIImage imageCwNamed:@"coupons_bottom_bg.png"] stretchableImageWithLeftCapWidth:10.f topCapHeight:20.f];
    [view addSubview:downImageV];
    
    CGFloat height = 50.f;
    CGFloat width = KUIScreenWidth - 2*PfComLeftRightW - 40.f;
    
    height += 30.f;
    
    NSArray *arr = [self.dict objectForKey:@"partner_pics"];
    NSLog(@"dufu arr.count = %d",arr.count);
    if (arr.count > 0) {
        if (_scrollView == nil) {
            if (arr.count > 2) {
                _scrollView = [[DoubleScrollView alloc]initWithFrame:CGRectMake(30.f, height, width, 150.f)];
                height += 150.f;
            } else {
                _scrollView = [[DoubleScrollView alloc]initWithFrame:CGRectMake(30.f, height, width, 120.f)];
                height += 120.f;
            }
           
            _scrollView.delegate = self;
            _scrollView.backgroundColor = [UIColor whiteColor];
            [view addSubview:_scrollView];
        }
    }
    
    NSString *content = [self.dict objectForKey:@"intro"];
    
    // 活动介绍
    UILabel *ssslabel = [[UILabel alloc]initWithFrame:CGRectMake(20.f, height, width, 20.f)];
    ssslabel.backgroundColor = [UIColor clearColor];
    ssslabel.textColor = [UIColor whiteColor];
    ssslabel.font = KCWSystemFont(16.f);
    [downImageV addSubview:ssslabel];
    
    height += 20.f;
    
    if (content.length > 0) {
        ssslabel.text = @"温馨提示 :";
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(20.f, height, width, KUIScreenHeight - KUpBarHeight - PfComDownUpH - height - 10.f)];
    scrollView.backgroundColor = [UIColor clearColor];
    [downImageV addSubview:scrollView];
    
    // 活动介绍内容
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = KCWSystemFont(14.f);
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    if (self.pfCommon == 0) {
        label.text = self.intro;
    } else {
        label.text = [self.dict objectForKey:@"intro"];
    }
    CGSize size = [label.text sizeWithFont:label.font
                         constrainedToSize:CGSizeMake(width, 1000.f)
                             lineBreakMode:NSLineBreakByCharWrapping];
    label.frame = CGRectMake(0.f, 0.f, width, size.height);
    [scrollView addSubview:label];
    scrollView.contentSize = CGSizeMake(0.f, size.height);
    [label release], label = nil;
    [ssslabel release], ssslabel = nil;
    
    [scrollView release], scrollView = nil;
    
    [downImageV release], downImageV = nil;
}

// 创建FrontView
- (void)createFrontView
{
    [self createUpBarView:_frontView];
    
    [self createInfoView:_frontView];
    
    [self createFrontCodeView:_frontView];
}

// 创建BackView
- (void)createBackView
{
    [self createUpBarView:_backView];
    
    [self createBackCodeView:_backView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_frontView release], _frontView = nil;
    [_backView release], _backView = nil;
    [_bgView release], _bgView = nil;
    if (_scrollView) {
        [_scrollView release], _scrollView = nil;
    }
    if (cloudLoading) {
        [cloudLoading release], cloudLoading = nil;
    }
    
    [super dealloc];
}

//动画切换
-(void)showViewWithAnimated:(BOOL)bl
{
    if (bl) {
        _frontView.hidden = YES;
        [UIView beginAnimations:nil context:_backView];
        [UIView setAnimationDuration:1];
        _backView.hidden = NO;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_bgView cache:YES];
        [UIView commitAnimations];
    } else {
        _backView.hidden = YES;
        [UIView beginAnimations:nil context:_frontView];
        [UIView setAnimationDuration:1];
        _frontView.hidden = NO;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_bgView cache:YES];
        [UIView commitAnimations];
    }
}

#pragma mark - 
- (void)leftBtnClick:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnClick:(UIButton *)btn
{
    BaiduMapViewController *baiduMap = [[BaiduMapViewController alloc]init];
    baiduMap.shopsArray = self.dataArr;
    baiduMap.otherStatusTypeMap = StatusTypeNormal;
    [self.navigationController pushViewController:baiduMap animated:YES];
    [baiduMap release], baiduMap = nil;
}

#pragma mark - UITapGestureRecognizer
- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    if (flipflag) {
        flipflag = NO;
        [self showViewWithAnimated:flipflag];
    } else {
        flipflag = YES;
        [self showViewWithAnimated:flipflag];
    }
}

#pragma mark - DoubleScrollViewDelegate
- (NSInteger)numberOfPages:(DoubleScrollView *)doubleScrollView
{
    NSArray *arr = [self.dict objectForKey:@"partner_pics"];

    return arr.count;
}

- (UIView *)pageReturnEachView:(DoubleScrollView *)doubleScrollView pageIndex:(NSInteger)index
{
    CGFloat offsetw = CGRectGetWidth(doubleScrollView.frame);
    CGFloat offseth = CGRectGetHeight(doubleScrollView.frame);
    
    //图片
    NSArray *arr = [self.dict objectForKey:@"partner_pics"];
    
    CGFloat width = (offsetw - 10.f)/2;
    CGFloat height = offseth - 30.f;
    if (arr.count <= 2) {
        height = offseth;
    } 
    CGFloat x = index * width + ((index + 1) / 2) * 10.f;
    CGFloat y = 0.f;
    
    DoubleView *view = [[[DoubleView alloc]initWithFrame:CGRectMake(x, y, width, height)] autorelease];
    view.backgroundColor = [UIColor whiteColor];
    view.delegate = self;

    if (arr.count > 0) {
        [view setTitleLabel:[[arr objectAtIndex:index] objectForKey:@"product_name"]];
        
        view.pro_id = [[arr objectAtIndex:index] objectForKey:@"product_id"];
        
        NSString *picUrl = [[arr objectAtIndex:index] objectForKey:@"img_path"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1) {
            UIImage *pic = [FileManager getPhoto:picName];
            
            if (pic.size.width > 2) {
                [view setImageView:pic];
            } else {
                [view setImageView:[UIImage imageCwNamed:@"default_320x180.png"]];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:10000];
                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
            }
        } else {
            [view setImageView:[UIImage imageCwNamed:@"default_320x180.png"]];
        }
    }
    
    return view;
}

#pragma mark - DoubleViewDelegate
- (void)doubleViewClick:(DoubleView *)doubleView pro_id:(NSString *)proid
{
    NSLog(@"proid = %@",proid);
    ShopDetailsViewController *shopView = [[ShopDetailsViewController alloc]init];
    shopView.productID = proid;
    shopView.cwStatusType = StatusTypePfDetail;
    [self.navigationController pushViewController:shopView animated:YES];
    [shopView release], shopView = nil;
}

#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width > 2.0)
		{
			// 保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
            [_scrollView reloadScrollView];
		}
        
        [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - netWork
// 网络请求可用优惠券商店
- (void)accessMapGetLongitudeService
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *reqUrl = @"index/getlongitude.do?param=";
        
        dqxx_model *dMod = [[dqxx_model alloc]init];
        dMod.where = [NSString stringWithFormat:@"DQXX02 = '%@'",[Global sharedGlobal].currCity];
        NSArray *arr = [dMod getList];
        [dMod release], dMod = nil;
        
        NSString *cityID = nil;
        if (arr.count > 0) {
            cityID = [NSString stringWithFormat:@"%d",[[[arr lastObject] objectForKey:@"DQXX01"] intValue]];
        }
        
        NSLog(@"self.dict = %@",self.dict);
        NSString *promotion_id = nil;
        if (self.pfCommon == 1) {
            promotion_id = [NSString stringWithFormat:@"%d",[[self.dict objectForKey:@"promotion_id"] intValue]];
        } else {
            promotion_id = [NSString stringWithFormat:@"%d",[[self.dict objectForKey:@"id"] intValue]];
        }
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           cityID,@"city_id",
                                           promotion_id,@"promotion_id", nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NetManager sharedManager]accessService:requestDic
                                                data:nil
                                             command:PREACTIVITY_MAP_COMMAND_ID
                                        accessAdress:reqUrl
                                            delegate:self
                                           withParam:nil];
        });
    });
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == PREACTIVITY_MAP_COMMAND_ID) {
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                if (resultArray.count > 0) {
                    self.dataArr = resultArray;
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
           [cloudLoading removeFromSuperview]; 
        });
    }
}
@end
