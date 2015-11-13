//
//  AfterSaleViewController.m
//  cw
//
//  Created by yunlai on 13-9-7.
//
//

#import "AfterSaleViewController.h"
#import "Common.h"
@interface AfterSaleViewController ()

@end

@implementation AfterSaleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"保修服务";
    self.view.backgroundColor = KCWViewBgColor;
	
    kWidth=15.0f;
    kHeight=20.0f;
    
    [self dataLoadView];

}

//背景图片拉伸
- (void)imageStretch:(float)height{
    UIImageView *ImageView=[[UIImageView alloc]init];
    [ ImageView  setFrame:CGRectMake(0.0,height, 135.0, 17.0)];
    UIEdgeInsets ed = {1.0f, 0.2f, 0.2f, 7.5f};
    [ImageView setImage:[[UIImage imageNamed:@"tag_box.png"]resizableImageWithCapInsets:ed]];
    [_mainScrollView addSubview:ImageView];
    RELEASE_SAFE(ImageView);
}

- (void)dataLoadView{
    
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)];
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainScrollView];
    
    [self imageStretch:20.0];
    _productService=[[UILabel alloc]initWithFrame:CGRectMake(0, kHeight, 135, 16)];
    _productService.backgroundColor=[UIColor clearColor];
    _productService.textColor=[UIColor whiteColor];
    _productService.text=@"一、上门服务时限";
    _productService.textAlignment=NSTextAlignmentCenter;
    _productService.font=[UIFont systemFontOfSize:12];
    [_mainScrollView addSubview:_productService];
    
    kHeight+=25;
    
    _serviceContent=[[CWLabel alloc]initWithFrame:CGRectMake(kWidth, kHeight, 290, 140)];
//    _serviceContent.numberOfLines = 0;
//    _serviceContent.lineBreakMode = NSLineBreakByWordWrapping;
    _serviceContent.backgroundColor=[UIColor clearColor];
//    _serviceContent.numberOfLines=0;
//    _serviceContent.lineBreakMode=NSLineBreakByWordWrapping;
    _serviceContent.textColor=[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1];
    _serviceContent.text=@"      1、市区24小时内上门服务，城市周边地区48小时内上门，乡镇及偏远农村地区电话预约上门时间。\n      2、新购机安装调试服务的上门时间从产品送至用户家并成功报安装后开始计算。";
    _serviceContent.font=[UIFont systemFontOfSize:14];
    
    [_mainScrollView addSubview:_serviceContent];
    
    kHeight+=140;
    
    [self imageStretch:kHeight];
    _repair=[[UILabel alloc]initWithFrame:CGRectMake(0, kHeight, 135, 16)];
    _repair.backgroundColor=[UIColor clearColor];
    _repair.textColor=[UIColor whiteColor];
    _repair.text=@"二、服务政策";
    _repair.textAlignment=NSTextAlignmentCenter;
    _repair.font=[UIFont systemFontOfSize:12];
    [_mainScrollView addSubview:_repair];
    
    kHeight+=25;
    
    _repairContent=[[CWLabel alloc]initWithFrame:CGRectMake(kWidth, kHeight, 290, 240)];
    _repairContent.backgroundColor=[UIColor clearColor];
    _repairContent.textColor=[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1];
    _repairContent.text=@"     保修服务：电视机整机保修一年，主要部件(包括液晶屏，逻辑组件，背光组件及高频调谐器)保修三年（注：所有直营店销售产品整机及主要部件均保修三年，直营店销售的配件及小家电产品均按照国家三包法进行保修，详情可咨询销售门店）\n    退换服务：经创维授权服务人员上门来检测(受理3天内)确认产品出现质量问题的，购机7天内可办理退换机服务。购机15天内可办理换机服务。";
//    _repairContent.numberOfLines=0;
//    _repairContent.lineBreakMode=NSLineBreakByWordWrapping;
    _repairContent.font=[UIFont systemFontOfSize:14];
    [_mainScrollView addSubview:_repairContent];
    
    kHeight+=250;
    
    [self imageStretch:kHeight];
    _repairCycle=[[UILabel alloc]initWithFrame:CGRectMake(0, kHeight, 135, 16)];
    _repairCycle.backgroundColor=[UIColor clearColor];
    _repairCycle.textColor=[UIColor whiteColor];
    _repairCycle.text=@"三、三包期标准";
    _repairCycle.textAlignment=NSTextAlignmentCenter;
    _repairCycle.font=[UIFont systemFontOfSize:12];
    [_mainScrollView addSubview:_repairCycle];
    
    kHeight+=25;
    
    _repairCycleContent=[[CWLabel alloc]initWithFrame:CGRectMake(kWidth, kHeight, 290, 180)];
    _repairCycleContent.backgroundColor=[UIColor clearColor];
    _repairCycleContent.textColor=[UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1];
    _repairCycleContent.text=@"    1、购机超过30天，未要求提供安装或调试服务的，三包有效期从开具有效发票日期开始计算。\n    2、购机30天内，经创维授权服务人员提供上门安装或调试服务的，三包有效期从《创维产品上门服务工作单》上的安装调试日期开始计算。";
//    _repairCycleContent.numberOfLines=0;
//    _repairCycleContent.lineBreakMode=NSLineBreakByWordWrapping;
    _repairCycleContent.font=[UIFont systemFontOfSize:14];
    [_mainScrollView addSubview:_repairCycleContent];
    
   
    _mainScrollView.contentSize = CGSizeMake(0.f, kHeight + 220) ;
    
}

- (void)dealloc
{
    RELEASE_SAFE(_productService);
    RELEASE_SAFE(_serviceContent);
    RELEASE_SAFE(_repair);
    RELEASE_SAFE(_repairContent);
    RELEASE_SAFE(_repairCycleContent);
    RELEASE_SAFE(_repairCycle);
    RELEASE_SAFE(_mainScrollView);
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
