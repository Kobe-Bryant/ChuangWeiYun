//
//  AboutUsViewController.m
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import "AboutUsViewController.h"
#import "about_us_model.h"
#import "callSystemApp.h"
#import "Global.h"
#import "Common.h"
#import "FileManager.h"
#import "NetworkFail.h"
#import "IconPictureProcess.h"
#import "shop_near_list_model.h"
#import "BaiduMapViewController.h"
#import "UIImageView+WebCache.h"
#import "YLLabelView.h"
#import "system_config_model.h"

@interface AboutUsViewController ()<NetworkFailDelegate>
{
    NetworkFail *failView;
}

@end

@implementation AboutUsViewController
@synthesize aboutArray=_aboutArray;
@synthesize shoplistArray=_shoplistArray;
@synthesize cloudLoading;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"关于我们";
    self.view.backgroundColor = KCWViewBgColor;
    
    _aboutArray = [[NSMutableArray alloc]init];
    _shoplistArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    kHeight = 130.0f;
    kWidth = 15.0f;
    kContentHeight = 0.0f;
    
    
    [self accessService];
    
    [self getshoplistData];
    
    [self loadDataView];
    
    
}

// 视图实例化创建
- (void)loadDataView{
    
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)];
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainScrollView];
    
    _companyLogo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, KUIScreenWidth, kHeight)];
    _companyLogo.backgroundColor = [UIColor clearColor];
    _companyLogo.contentMode=UIViewContentModeScaleAspectFit;
    [_mainScrollView addSubview:_companyLogo];
    
    kHeight+=25;
    
    //关于我们文字左右对齐
    _contentLabel = [[CWLabel alloc]initWithFrame:CGRectZero];
    _contentLabel.backgroundColor=[UIColor clearColor];
    UIColor *colorT = [[UIColor alloc]initWithRed:106.f/255.f green:106.f/255.f blue:106.f/255.f alpha:1.f];
    _contentLabel.textColor = colorT;//[UIColor colorWithRed:106.f/255.f green:106.f/255.f blue:106.f/255.f alpha:1.f];
    [colorT release];
//    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.font = [UIFont fontWithName:@"Arial" size:14];
  
    [_mainScrollView addSubview:_contentLabel];
    
    kHeight+=5;
    
}

// 获取附近的店数据
- (void)getshoplistData{
    shop_near_list_model *shoplist = [[shop_near_list_model alloc]init];
    shoplist.where = [NSString stringWithFormat:@"id = '%@'",[Global sharedGlobal].shop_id];
    self.shoplistArray  = [shoplist getList];
    NSLog(@"shoplistArray===%@",self.shoplistArray);
    
    RELEASE_SAFE(shoplist);
}

// 创建表格
- (void)createTableView{
    _contactTabelView = [[UITableView alloc]initWithFrame:CGRectZero];
    _contactTabelView.dataSource = self;
    _contactTabelView.delegate = self;
    _contactTabelView.scrollEnabled = NO;
    [_mainScrollView addSubview:_contactTabelView];

}

//背景图片拉伸
- (void)imageStretch:(float)height andType:(int)type{
    UIImageView *ImageView = [[UIImageView alloc]init];
    [ ImageView  setFrame:CGRectMake(0.0,height, 100.0, 16.0)];
    UIEdgeInsets ed = {1.0f, 0.2f, 0.2f, 7.5f};
    [ImageView setImage:[[UIImage imageNamed:@"tag_box.png"]resizableImageWithCapInsets:ed]];
    [_mainScrollView addSubview:ImageView];
    
    UILabel *contactLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100.0, 16.0)];
    contactLabel.backgroundColor = [UIColor clearColor];
    if (type==0) {
        contactLabel.text = @"简  介";
    }else{
        contactLabel.text = @"联系我们";
    }
    contactLabel.font = [UIFont systemFontOfSize:12];
    contactLabel.textAlignment = UITextAlignmentCenter;
    contactLabel.textColor = [UIColor whiteColor];
    
    [ImageView addSubview:contactLabel];
    RELEASE_SAFE(contactLabel);
    RELEASE_SAFE(ImageView);
}

//动态获取内容的高度
- (CGFloat)getTheHeight:(NSString *)contentStr
{
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = CGSizeMake(KUIScreenWidth-20,2000);
    CGSize labelsize = [contentStr sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];

    return labelsize.height;
}

- (void)dealloc
{
    RELEASE_SAFE(_companyLogo);
    RELEASE_SAFE(_mainScrollView);
    RELEASE_SAFE(_contentLabel);
    RELEASE_SAFE(_contactTabelView);
    RELEASE_SAFE(_shoplistArray);
    RELEASE_SAFE(_aboutArray);
    RELEASE_SAFE(cloudLoading);
    if (failView) {
        RELEASE_SAFE(failView);
    }
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}
// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessService];
    
}

// 拨打电话按钮
- (void)telPhoneClick{
    if ([self.shoplistArray count]!=0) {
        NSString *phone = [[self.shoplistArray objectAtIndex:0]objectForKey:@"manager_tel"];
        
        if (phone) {
            [callSystemApp makeCall:phone];
        }

    }
}

// 定位按钮
- (void)locationBtn{
    
    if ([self.shoplistArray count]!=0) {
        NSDictionary *dic= [NSDictionary dictionaryWithObjectsAndKeys:
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"latitude"],@"latitude",
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"longitude"],@"longitude",
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"name"],@"name",
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"manager_portrait"],@"manager_portrait",
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"shop_image"],@"shop_image",
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"manager_name"],@"manager_name",
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"manager_tel"],@"manager_tel",
                           [[self.shoplistArray objectAtIndex:0]objectForKey:@"address"],@"address",
                           nil];
        
        NSLog(@"==%@",dic);
        BaiduMapViewController *baiduMap = [[BaiduMapViewController alloc]init];
        baiduMap.otherStatusTypeMap = StatusTypeMap;
        baiduMap.dataDic = dic;
        [self.navigationController pushViewController:baiduMap animated:YES];
        RELEASE_SAFE(baiduMap);
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
    }
    if (indexPath.row==0) {
        UILabel *shopName = [[UILabel alloc]initWithFrame:CGRectMake(10, 3, 220, 45)];
        shopName.font = [UIFont systemFontOfSize:15];
        shopName.numberOfLines = 2;
        shopName.lineBreakMode = NSLineBreakByCharWrapping;
        shopName.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1];
        shopName.backgroundColor = [UIColor clearColor];
        if ([self.shoplistArray count]!=0) {
            shopName.text = [[self.shoplistArray objectAtIndex:0]objectForKey:@"name"];
        }
    
        [cell.contentView addSubview:shopName];
        RELEASE_SAFE(shopName);
        
        UILabel *shopManager = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 200, 25)];
        shopManager.font = [UIFont systemFontOfSize:12];
        shopManager.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1];
        shopManager.backgroundColor = [UIColor clearColor];
        
        if ([self.shoplistArray count]!=0) {
            shopManager.text = [NSString stringWithFormat:@"%@",[[self.shoplistArray objectAtIndex:0]objectForKey:@"manager_name"]];
        }
        [cell.contentView addSubview:shopManager];
        RELEASE_SAFE(shopManager);
        
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(249, 18, 1, 40)];
        line.backgroundColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1];
        [cell.contentView addSubview:line];
        RELEASE_SAFE(line);
        
        UIButton *telPhone = [[UIButton alloc]initWithFrame:CGRectMake(245, 10, 60, 60)];
        [telPhone setImage:[UIImage imageNamed:@"icon_phone_click.png"] forState:UIControlStateNormal];
        [telPhone setBackgroundColor:[UIColor clearColor]];
        [telPhone addTarget:self action:@selector(telPhoneClick) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:telPhone];
        RELEASE_SAFE(telPhone);
        
    }else{
        UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 230, 40)];
        address.font = [UIFont systemFontOfSize:12];
        address.textColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:106/255.0 alpha:1];
        address.backgroundColor = [UIColor clearColor];
        address.numberOfLines = 2;
        address.lineBreakMode = NSLineBreakByCharWrapping;
        if ([self.shoplistArray count]!=0) {
            address.text = [[self.shoplistArray objectAtIndex:0]objectForKey:@"address"];
        }
        [cell.contentView addSubview:address];
        RELEASE_SAFE(address);
        
        UIButton *location = [[UIButton alloc]initWithFrame:CGRectMake(245, -10, 60, 60)];
        [location setImage:[UIImage imageNamed:@"locate_click.png"] forState:UIControlStateNormal];
        [location addTarget:self action:@selector(locationBtn) forControlEvents:UIControlEventTouchUpInside];
        [location setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:location];
        RELEASE_SAFE(location);
        
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 85;
    }else{
        return 65;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self telPhoneClick];
    }else{
        [self locationBtn];
    }
}

#pragma mark - accessService

- (void)accessService{
    
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(KUIScreenWidth / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
	NSMutableDictionary *dicData = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"ver", nil];
    
	[[NetManager sharedManager]accessService:dicData
                                        data:nil
                                     command:ABOUTUS_COMMAND_ID
                                accessAdress:@"skyworth/about.do?param="
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

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        switch (commandid) {
            case ABOUTUS_COMMAND_ID:
            {
                [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
            }
                break;
                
            default:
                break;
        }

    
    }else{
        
        _mainScrollView.hidden = YES;
        //loading图标移除
        [self.cloudLoading removeFromSuperview];
        
        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoRequest];
        } else {
            // 当前网络不可用，请重新再试
            [self failViewCreate:CwTypeViewNoNetWork];
        }
    }
}

- (void)success:(NSMutableArray*)resultArray{
    
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    

    if ([[resultArray objectAtIndex:0] isEqual:@"cwRequestTimeout"]) {
        //服务器繁忙页面
        [self failViewCreate:CwTypeViewNoService];
        
        _mainScrollView.hidden = YES;

    }else{

        _mainScrollView.hidden = NO;
        
        [self imageStretch:140 andType:0];
        
        about_us_model *aboutMod=[[about_us_model alloc]init];
        self.aboutArray=[aboutMod getList];
        RELEASE_SAFE(aboutMod);
        
        NSLog(@"aboutArray==%@",self.aboutArray);
        if ([self.aboutArray count]!=0) {
            
            
            
            CGSize titleSize;
            NSString *textContent = [[self.aboutArray objectAtIndex:0]objectForKey:@"info"];
            
            system_config_model *figMod = [[system_config_model alloc]init];
            figMod.where = [NSString stringWithFormat:@"tag ='%@'",@"aboutUsHeight"];
            NSArray *heightArr = [figMod getList];
            
            RELEASE_SAFE(figMod);
            
            if ([heightArr count]==0) {
                
                //获取内容的动态高度
                titleSize = [YLLabelView height:textContent Font:14 Character:0.1 Line:6 Pragraph:5];
                
                [self insertDBHeight:[NSString stringWithFormat:@"%f",titleSize.height]];
                
            }else{
                
                titleSize.height = [[[heightArr objectAtIndex:0]objectForKey:@"value"] floatValue];
                NSLog(@"%f",titleSize.height);
            }
            
            [_contentLabel setText:textContent];
    
            
            _contentLabel.frame = CGRectMake(kWidth, kHeight, KUIScreenWidth-kWidth*2, titleSize.height +10);
            
            kHeight +=titleSize.height+15;
            
            if ([Global sharedGlobal].shop_id) {
                [self imageStretch:kHeight andType:1];
            }
            
            
            kHeight +=30;
            
            if ([Global sharedGlobal].shop_id) {
                [self createTableView];
                _mainScrollView.contentSize = CGSizeMake(0.f, kHeight + 130 + 55.f) ;
            }else{
            
                _mainScrollView.contentSize = CGSizeMake(0.f, kHeight + 20.f) ;
            }
            _contactTabelView.frame = CGRectMake(10, kHeight, KUIScreenWidth-20, 130);
            
            
            NSDictionary *aboutDic = [self.aboutArray objectAtIndex:0];
            NSString *picUrl = [aboutDic objectForKey:@"logo"];
            
            [_companyLogo setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageCwNamed:@"default_320x120.png"]];

        }
    }
}

- (void)insertDBHeight:(NSString *)height{
    NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"aboutUsHeight",@"tag",
                             height,@"value",
                             nil];
    system_config_model *remember = [[system_config_model alloc] init];
    remember.where = [NSString stringWithFormat:@"tag ='%@'",@"aboutUsHeight"];
    [remember deleteDBdata];
    
    [remember insertDB:nameDic];
    
    remember.where = nil;
    RELEASE_SAFE(remember);
}

@end
