//
//  OrderDetailViewController.m
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import "OrderDetailViewController.h"
#import "OrderDetailCell.h"
#import "member_orderdetail_list_model.h"
#import "member_allorder_list_model.h"
#import "Common.h"
#import "Global.h"
#import "FileManager.h"
#import "PreferentialObject.h"
#import "IconPictureProcess.h"
#import "ShopDetailsViewController.h"

@interface OrderDetailViewController ()
{
    CGFloat ff;
    CGFloat remarkFont;
}
@end

@implementation OrderDetailViewController
@synthesize orderId;
@synthesize productId;
@synthesize clickIndex;
@synthesize cancelOrderCell;
@synthesize shopDic=_shopDic;
@synthesize orderlistDic=_orderlistDic;
@synthesize progressHUD=_progressHUD;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

static int btnTag=0;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title=@"预订详情";
    self.view.backgroundColor = KCWViewBgColor;
	
    _mainScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)];
    _mainScrollView.showsHorizontalScrollIndicator=NO;
    _mainScrollView.showsVerticalScrollIndicator=NO;
    _mainScrollView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_mainScrollView];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 800) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.layer.borderColor=[UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1].CGColor;
    _tableView.layer.borderWidth=1;
    _tableView.layer.cornerRadius=3;
    _tableView.backgroundColor=KCWViewBgColor;
    _tableView.separatorStyle=UITableViewCellSelectionStyleNone;
    _tableView.showsVerticalScrollIndicator=NO;
    [_mainScrollView addSubview:_tableView];
    
    picHeight=50.0f;
    picWidth=70.0f;
    
    _mainScrollView.contentSize=CGSizeMake(0.f, 650);
    
    _cancelView=[[PopCancelOrderView alloc]init];
    _cancelView.delegate=self;
    

    NSLog(@"==%@==%@",self.shopDic,self.orderlistDic);
    
}

- (void)dealloc
{
    RELEASE_SAFE(_shopDic);
    RELEASE_SAFE(_tableView);
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)cancelOrderClick:(UIButton *)btn{
    //获取点击的Btn的cell
    self.cancelOrderCell= (OrderDetailCell *)btn.superview.superview.superview;
    
    btnTag=btn.tag;
    [_cancelView addPopupSubview];
}

//动态获取内容的高度
- (CGFloat)getTheHeight:(NSString *)contentStr
{
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize size = CGSizeMake(200,2000);
    CGSize labelsize = [contentStr sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    
    return labelsize.height;
}

- (void)progressHud:(NSString *)valueText{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center=CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.delegate = self;
    progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示icon-信息.png"]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = valueText;
    [self.view addSubview:progressHUDTmp];
    [self.view bringSubviewToFront:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp  hide:YES afterDelay:1];
}

- (void)clickDetail{

    ShopDetailsViewController *shopDetail=[[ShopDetailsViewController alloc]init];
    shopDetail.cwStatusType = StatusTypeMemberShopOrder;
    shopDetail.shop_ID = [NSString stringWithFormat:@"%d",[[self.shopDic objectForKey:@"shop_id"] intValue]];
    NSArray *arr = [self.shopDic objectForKey:@"products"];
    shopDetail.productID = [NSString stringWithFormat:@"%d",[[[arr objectAtIndex:0] objectForKey:@"product_id"] intValue]];
    [self.navigationController pushViewController:shopDetail animated:YES];
    RELEASE_SAFE(shopDetail);
}

//收货地址中的直辖市去掉重复的名字
- (NSString *)isIncludeString:(NSString *)addressString{
    if([addressString rangeOfString:@"北京市"].location !=NSNotFound ||[addressString rangeOfString:@"天津市"].location !=NSNotFound||[addressString rangeOfString:@"上海市"].location !=NSNotFound||[addressString rangeOfString:@"重庆市"].location !=NSNotFound)
    {
        NSLog(@"yes");
        addressString = [addressString substringFromIndex:3];
    }
    else
    {
        NSLog(@"no");
    }
    
    return addressString;
}
//预订收货地址后台修改后region没返回省市，需判断添加
- (NSString *)addRegion:(NSString *)provinceString andCity:(NSString *)cityString andAddress:(NSString *)address{
    if([address rangeOfString:@"省"].location ==NSNotFound &&[address rangeOfString:@"市"].location ==NSNotFound && ![provinceString isEqualToString:cityString])//后台修改的不是直辖市
    {
        NSLog(@"yes");
        address = [NSString stringWithFormat:@"%@%@%@",provinceString,cityString,address];
        
    }else if([address rangeOfString:@"省"].location ==NSNotFound &&[address rangeOfString:@"市"].location ==NSNotFound)
    {
        address = [NSString stringWithFormat:@"%@%@",cityString,address];
    }
    else
    {
        NSLog(@"no");
    }
    
    return address;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * identifier=@"ident";
    OrderDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[[OrderDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    
    if ([self.shopDic count]!=0||[self.orderlistDic count]!=0) {
        

        cell.shopName.text=[self.shopDic objectForKey:@"shopName"];
        cell.amountLabel.text = [NSString stringWithFormat:@"%@",[self.shopDic objectForKey:@"amount"]];
        cell.shopTypeLabel.text=[NSString stringWithFormat:@"【%@】%@",[self.orderlistDic objectForKey:@"name"],[self.orderlistDic objectForKey:@"content"]];
        cell.shopPriceLabel.text=[NSString stringWithFormat:@"¥ %0.2f",[[self.shopDic objectForKey:@"money"] floatValue]];
        cell.orderNumLabel.text=[self.shopDic objectForKey:@"order_sn"];
        
        cell.orderTimeLabel.text=[PreferentialObject getTheDate:[[self.shopDic objectForKey:@"created"]intValue] symbol:3];
        
        if ([[self.shopDic objectForKey:@"pay_type"]intValue]==0) {
            cell.payLabel.text=@"到店付款";
        }else{
            cell.payLabel.text=@"货到付款";
        }
        
        cell.distriLabel.text=@"厂家物流";
        
        NSString *userName = [self.shopDic objectForKey:@"name"];
        NSString *mobile = [self.shopDic objectForKey:@"mobile"];
        NSString *province = [self.shopDic objectForKey:@"province"];
        NSString *city = [self.shopDic objectForKey:@"city"];
        
        NSString *str = [NSString stringWithFormat:@"%@%@%@",province,city,[self.shopDic objectForKey:@"region"]];
        NSString *region = [self isIncludeString:str];
        NSString *regionAddress = [self addRegion:province andCity:city andAddress:region];
        
        NSLog(@"regionAddress==%@",regionAddress);
        
        NSString *strAddress = [NSString stringWithFormat:@"%@%@  %@  %@",regionAddress,[self.shopDic objectForKey:@"address"],userName,mobile];
        
        //收货地址的自适应高度
//        CGFloat ff = [self getTheHeight:strAddress];
        
        if (![[self.shopDic objectForKey:@"remark"] isEqual:[NSNull null]]) {
            cell.remarkLabel.text = [self.shopDic objectForKey:@"remark"];
        }
        //备注的自适应高度
//        CGFloat remarkFont = [self getTheHeight:cell.remarkLabel.text];
        
        //有无优惠劵的判断显示，有则显示优惠劵
        if ([[self.shopDic objectForKey:@"discount"]floatValue]!=0.0) {
            NSLog(@"discount==%@",[self.shopDic objectForKey:@"discount"]);
            cell.couponLabel.text= [NSString stringWithFormat:@"￥%0.2f",[[self.shopDic objectForKey:@"discount"]floatValue]];
            
            cell.coupon.hidden=NO;
            cell.lineView2.hidden=NO;
            
            cell.cellBgView.frame = CGRectMake(10, 10, 300, 600+ff);
            _mainScrollView.contentSize=CGSizeMake(0.f, 680+ff);
            
            cell.receiviAddLabel.text=strAddress;
            
            cell.receiviAddLabel.frame = CGRectMake(95, 50*10+30, 200, ff);
            cell.lineView2.frame=CGRectMake(0, 50*10+20, 300, 2);
            
            if ([[self.shopDic objectForKey:@"remark"] isEqual:@" "]||[[self.shopDic objectForKey:@"remark"] isEqual:[NSNull null]]) {
                cell.remark.hidden=YES;
                cell.remarkLabel.hidden=YES;
                cell.lineView.hidden=YES;
                cell.cellBgView.frame = CGRectMake(10, 10, 300, 600);
                _mainScrollView.contentSize=CGSizeMake(0.f, 670);
                
            }else{
                cell.remark.frame = CGRectMake(15, 50*11+ff, 200, ff);
                cell.remarkLabel.frame = CGRectMake(95, 50*11+ff+10, 200, remarkFont);
                if (![[self.shopDic objectForKey:@"remark"] isEqual:[NSNull null]]) {
                    cell.remarkLabel.text=[self.shopDic objectForKey:@"remark"];
                }
                cell.remark.hidden=NO;
                cell.lineView.hidden=NO;
                cell.remarkLabel.hidden=NO;
                cell.lineView.frame=CGRectMake(0, 50*11+ff-5, 300, 2);
                cell.cellBgView.frame = CGRectMake(10, 10, 300, 575+ff+remarkFont);
                _mainScrollView.contentSize=CGSizeMake(0.f, 640+ff+remarkFont);
                
            }

        }else{
            
            cell.coupon.hidden=YES;
            cell.lineView2.hidden = YES;
            cell.receiviAddress.frame = CGRectMake(15, 50*10-10, 200, 20);
            cell.receiviAddLabel.frame = CGRectMake(95, 50*10-10, 200, [self getTheHeight:strAddress]);
            cell.couponLabel.frame = CGRectMake(15, 50*10, 80, 0);
            
            cell.receiviAddLabel.text=strAddress;
            
            if ([[self.shopDic objectForKey:@"remark"] isEqual:@" "]||[[self.shopDic objectForKey:@"remark"] isEqual:[NSNull null]]) {
                cell.remark.hidden=YES;
                cell.lineView.hidden=YES;
                cell.cellBgView.frame = CGRectMake(10, 10, 300, 550+remarkFont);
                _mainScrollView.contentSize=CGSizeMake(0.f, 620+remarkFont);
                
            }else{
                cell.remark.hidden=NO;
                cell.lineView.hidden = NO;
                cell.lineView.frame=CGRectMake(0, 50*10+ff+3, 300, 2);
                cell.remark.frame = CGRectMake(15, 50*10+10+ff, 200, 20);
                cell.remarkLabel.frame = CGRectMake(95, 50*10+10+ff, 200, remarkFont);
                if (![[self.shopDic objectForKey:@"remark"] isEqual:[NSNull null]]) {
                    cell.remarkLabel.text=[self.shopDic objectForKey:@"remark"];
                }
                cell.cellBgView.frame = CGRectMake(10, 10, 300, 550+ff+remarkFont);

                NSLog(@"=====%f",ff+remarkFont);
                _mainScrollView.contentSize=CGSizeMake(0.f, 600+ff+remarkFont);
            }
            
        }
    
        
        // 点击进入详情
        [cell.bgClick addTarget:self action:@selector(clickDetail) forControlEvents:UIControlEventTouchUpInside];
        
        if ([[self.shopDic objectForKey:@"audit"]intValue]==0) {
            cell.statusLabel.text=@"待确认";
            cell.statusBtn.hidden = NO;
            cell.statusBtn.tag=[[self.shopDic objectForKey:@"id"]intValue]+100;
        }else{
            cell.statusBtn.hidden=YES;
            if ([[self.shopDic objectForKey:@"audit"]intValue]==1) {
                cell.statusLabel.text=@"待发货";
            }else if([[self.shopDic objectForKey:@"audit"]intValue]==2) {
                cell.statusLabel.text=@"待收货";
            }
            else if([[self.shopDic objectForKey:@"audit"]intValue]==3) {
                cell.statusLabel.text=@"交易成功";
            }else{
                cell.statusLabel.text=@"已作废";
            }
        }
       
        cell.deliveryTimeLabel.text= [PreferentialObject getTheDate:[[self.shopDic objectForKey:@"delivery_type"]intValue] symbol:1];
        
        cell.invoiceLabel.text= [self.shopDic objectForKey:@"invoice_title"];
       
        [cell.statusBtn addTarget:self action:@selector(cancelOrderClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //图片
        NSString *picUrl = [self.orderlistDic objectForKey:@"image"];
        
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2)
            {
                cell.shopImageView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
                cell.shopImageView.image = defaultPic;
                
                if (tableView.dragging == NO && tableView.decelerating == NO)
                {
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                }
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
            cell.shopImageView.image = defaultPic;
        }
        
    }
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *userName = [self.shopDic objectForKey:@"name"];
    NSString *mobile = [self.shopDic objectForKey:@"mobile"];
    NSString *province = [self.shopDic objectForKey:@"province"];
    NSString *city = [self.shopDic objectForKey:@"city"];
    
    NSString *str = [NSString stringWithFormat:@"%@%@%@",province,city,[self.shopDic objectForKey:@"region"]];
    NSString *region = [self isIncludeString:str];
    NSString *regionAddress = [self addRegion:province andCity:city andAddress:region];
    
    NSLog(@"regionAddress==%@",regionAddress);

    
    NSString *strAddress = [NSString stringWithFormat:@"%@%@  %@  %@",regionAddress,[self.shopDic objectForKey:@"address"],userName,mobile];
    
    //收货地址的自适应高度
    ff = [self getTheHeight:strAddress];

    //备注的自适应高度
    remarkFont = [self getTheHeight:[self.shopDic objectForKey:@"remark"]];
    //有无优惠劵的判断显示，有则显示优惠劵
    if ([[self.shopDic objectForKey:@"discount"]floatValue]!=0.0) {
        
        if ([[self.shopDic objectForKey:@"remark"] isEqual:@" "]||[[self.shopDic objectForKey:@"remark"] isEqual:[NSNull null]]) {
            return 600.0f;
        }else{
            return 585+ff+remarkFont;
        }
    }else{
        if ([[self.shopDic objectForKey:@"remark"] isEqual:@" "]||[[self.shopDic objectForKey:@"remark"] isEqual:[NSNull null]]) {
            return 560.0f;
        }else{
            return 540.0+ff+remarkFont;
        }
    }
    return 550.0f;
    
}

#pragma mark - accessService
- (void)cancelOrderService:(NSString *)productOrderId{
    
    //预订作废数据请求
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                              productOrderId,@"order_id",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_ORDERCANCEL_COMMAND_ID accessAdress:@"book/cancelOrder.do?param=" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        switch (commandid) {
                
            case MEMBER_ORDERCANCEL_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(cancelSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            default:
                break;
        }

    }
}
- (void)cancelSuccess:(NSMutableArray*)resultArray{
    
    if ([[[resultArray objectAtIndex:0]objectForKey:@"ret"]intValue]==1) {
        [_cancelView closeView];
        
        [self progressHud:@"取消预订成功"];
        
        [_tableView reloadData];
        
        NSDictionary *orderCancel = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%d",self.clickIndex],@"clickIndex", nil];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelOrders" object:orderCancel];
        
//        self.cancelOrderCell.statusBtn.hidden = YES;
        
        NSLog(@"shopDic=%@",self.shopDic);
        NSNumber * audit = [NSNumber numberWithInt:4];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.shopDic];
        [dict setObject:audit forKey:@"audit"];
        self.shopDic = nil;
        self.shopDic = dict;
        
        if ([self.delegate respondsToSelector:@selector(orderDelete:)]) {
            [self.delegate performSelector:@selector(orderDelete:) withObject:YES];
        }
        
    }else{
        [_cancelView closeView];
        [self progressHud:@"取消预订失败"];
    }
    
}

#pragma mark - PopCancelOrderDelegate
- (void)OKCancel{
 

    NSString *orderid=[NSString stringWithFormat:@"%d",btnTag-100];
    NSLog(@"确定取消预订");
    [self cancelOrderService:orderid];

}

- (void)isOrderHiddenBtn{
    NSLog(@"取消预订");
}

#pragma mark - IconDownloaderDelegate
//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
            UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(picWidth, picHeight)];
            
            OrderDetailCell *cell = (OrderDetailCell *)[_tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell.shopImageView.image = photo;
            
		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}

- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
@end
