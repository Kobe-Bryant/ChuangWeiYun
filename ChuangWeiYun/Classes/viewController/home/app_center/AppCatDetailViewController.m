//
//  AppCatDetailViewController.m
//  cw
//
//  Created by LuoHui on 13-9-5.
//
//

#import "AppCatDetailViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "callSystemApp.h"
#import "BaiduMapViewController.h"

#define kXSpace 10
#define kYSpace 10

@interface AppCatDetailViewController ()

@end

@implementation AppCatDetailViewController
@synthesize dataDic;
@synthesize titleStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dataDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.titleStr;
	self.view.backgroundColor = KCWViewBgColor;
    
    CGFloat picWidth = 60;
    CGFloat picHeight = 60;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kXSpace, kYSpace, 300, KUIScreenHeight - KUpBarHeight - kYSpace * 2)];
    bgView.layer.cornerRadius = 3;
    bgView.layer.masksToBounds = YES;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.borderColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0].CGColor;
    bgView.layer.borderWidth = 1;
    [self.view addSubview:bgView];
    
    NSString *picUrl = [dataDic objectForKey:@"picture"];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
    
    UIImageView *_cImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kXSpace + 5, kXSpace + 5, picWidth, picHeight)];
    _cImageView.backgroundColor = [UIColor clearColor];
    
    if (pic == nil) {
        _cImageView.image = [UIImage imageCwNamed:@"default_60x60.png"];
    }else {
        _cImageView.image = pic;
    }
    [bgView addSubview:_cImageView];
    [_cImageView release];
    
    UILabel *_cTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, _cImageView.frame.origin.y + 5, 140, 30)];
    _cTitleLabel.backgroundColor = [UIColor clearColor];
    _cTitleLabel.textColor = [UIColor darkTextColor];
    _cTitleLabel.text = [dataDic objectForKey:@"name"];
    _cTitleLabel.font = [UIFont systemFontOfSize:15.0f];
    [bgView addSubview:_cTitleLabel];
    [_cTitleLabel release];
    
    UILabel *_cNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, CGRectGetMaxY(_cTitleLabel.frame), 140, 20)];
    _cNameLabel.backgroundColor = [UIColor clearColor];
    _cNameLabel.textColor = [UIColor grayColor];
    _cNameLabel.text = [NSString stringWithFormat:@"联系人：%@",[dataDic objectForKey:@"linkman"]];
    _cNameLabel.font = [UIFont systemFontOfSize:13.0f];
    [bgView addSubview:_cNameLabel];
    [_cNameLabel release];
    
    UILabel *seperator = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cNameLabel.frame) + 10, _cImageView.frame.origin.y, 0.5, picHeight)];
    seperator.backgroundColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0];
    [bgView addSubview:seperator];
    [seperator release];
    
    UIImage *telImgNormal = [UIImage imageCwNamed:@"icon_phone.png"];
    UIImage *telImgClick = [UIImage imageCwNamed:@"icon_phone_click.png"];
    UIButton *phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneButton.frame = CGRectMake(260, (60 - telImgNormal.size.height) * 0.5 + 20, telImgNormal.size.width, telImgNormal.size.height);
    [phoneButton setImage:telImgNormal forState:UIControlStateNormal];
    [phoneButton setImage:telImgClick forState:UIControlStateHighlighted];
    [phoneButton addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phoneButton];
    
    UILabel *seperator1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 89, 300, 0.5)];
    seperator1.backgroundColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0];
    [bgView addSubview:seperator1];
    [seperator1 release];
    
    UILabel *_cAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(kXSpace + 5, 95, bgView.frame.size.width - 80, 50)];
    _cAddressLabel.backgroundColor = [UIColor clearColor];
    _cAddressLabel.textColor = [UIColor darkTextColor];
    _cAddressLabel.text = [dataDic objectForKey:@"address"];
    _cAddressLabel.numberOfLines = 2;
    _cAddressLabel.font = [UIFont systemFontOfSize:13.0f];
    [bgView addSubview:_cAddressLabel];
    [_cAddressLabel release];
    
    UIImage *addrImgNormal = [UIImage imageCwNamed:@"locate.png"];
    UIImageView *addrImgVi = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cAddressLabel.frame) + addrImgNormal.size.width * 0.5, (_cAddressLabel.frame.size.height - addrImgNormal.size.height) * 0.5 + _cAddressLabel.frame.origin.y, addrImgNormal.size.width, addrImgNormal.size.height)];
    addrImgVi.image = addrImgNormal;
    [bgView addSubview:addrImgVi];
    [addrImgVi release];
    
    UIButton *addrButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addrButton.frame = CGRectMake(10, 100, 300, 50);
    [addrButton addTarget:self action:@selector(addrAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addrButton];
    
    UILabel *seperator2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_cAddressLabel.frame) + 3, 300, 0.5)];
    seperator2.backgroundColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0];
    [bgView addSubview:seperator2];
    [seperator2 release];
    
    UITextView *_infoTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_cAddressLabel.frame) + 5, bgView.frame.size.width - 10, bgView.frame.size.height - CGRectGetMaxY(_cAddressLabel.frame) - 10)];
    _infoTextView.backgroundColor = [UIColor clearColor];
    _infoTextView.textColor = [UIColor darkTextColor];
    _infoTextView.text = [dataDic objectForKey:@"intro"];
    _infoTextView.editable = NO;
    _infoTextView.font = [UIFont systemFontOfSize:15.0f];
    [bgView addSubview:_infoTextView];
    [_infoTextView release];
    
    [bgView release];
}

- (void)dealloc
{
    [dataDic release];
    [titleStr release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- methods
- (void)addrAction
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                        [self.dataDic objectForKey:@"latitude"],@"longitude",
                        [self.dataDic objectForKey:@"longitude"],@"latitude",
                        [self.dataDic objectForKey:@"name"],@"name",
                        [self.dataDic objectForKey:@"picture"],@"manager_portrait",
                        @"",@"shop_image",
                        [self.dataDic objectForKey:@"linkman"],@"manager_name",
                        [self.dataDic objectForKey:@"tel"],@"manager_tel",
                        [self.dataDic objectForKey:@"address"],@"address",
                        nil];
    
    
    BaiduMapViewController *baiduMap = [[BaiduMapViewController alloc]init];
    baiduMap.otherStatusTypeMap = StatusTypeServiceToMap;
    baiduMap.dataDic = dic;
    [self.navigationController pushViewController:baiduMap animated:YES];
    [baiduMap release];
}

- (void)callAction
{
    NSString *phoneNum = [dataDic objectForKey:@"tel"];
    [callSystemApp makeCall:phoneNum];
}
@end
