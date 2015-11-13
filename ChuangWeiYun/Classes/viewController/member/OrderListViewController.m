//
//  OrderListViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "OrderListViewController.h"
#import "CancelOrderCell.h"
#import "AllOrderCell.h"
#import "Common.h"
#import "Global.h"
#import "memberViewController.h"
#import "OrderDetailViewController.h"
#import "member_allorder_list_model.h"
#import "member_allorder_listPic_model.h"
#import "member_orderdetail_list_model.h"
#import "FileManager.h"
#import "IconPictureProcess.h"
#import "cloudLoadingView.h"
#import "NetworkFail.h"
#import "LoginViewController.h"
#import "ShopDetailsViewController.h"

#define kcontrolHeight 44

@interface OrderListViewController ()<NetworkFailDelegate>
{
    NetworkFail *failView;
    
}
@end

@implementation OrderListViewController

@synthesize orderShopArray = _orderShopArray;
@synthesize shopImageArray = _shopImageArray;
@synthesize cancelShopArray = _cancelShopArray;
@synthesize progressHUD = _progressHUD;
@synthesize cloudLoading;
@synthesize orderCell;
@synthesize StatusType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _orderShopArray=[[NSMutableArray alloc]init];
        _shopImageArray=[[NSArray alloc]init];
        _cancelShopArray=[[NSMutableArray alloc]init];
        _cancelOrderBtn=[[UIButton alloc]init];

    }
    return self;
}


#pragma mark - lifeCycle

static bool loadMore = YES;
static bool noMoreOrder = NO;


- (void)viewWillAppear:(BOOL)animated{
    [_shopTableView reloadData];
    [_messageTableView reloadData];
    
    noMoreOrder = NO;
    
    if (_nullView!=nil && self.orderShopArray.count != 0) {
        _nullView.hidden = YES;
    }


}

// dufu add 2013.11.14
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.StatusType == StatusTypeOrderToMember) {
        self.StatusType = StatusTypeNormal;
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return" ofType:@"png"]];
        UIButton *barbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        barbutton.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        if (IOS_7) {//chenfeng2014.2.9 add
            barbutton.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
        }
        [barbutton addTarget:self action:@selector(popself) forControlEvents:UIControlEventTouchUpInside];
        [barbutton setImage:image forState:UIControlStateNormal];
        [barbutton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return_click" ofType:@"png"]] forState:UIControlStateHighlighted];
        UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:barbutton];
        self.navigationItem.leftBarButtonItem = barBtnItem;
        [barBtnItem release];
    }
}

// dufu add 2013.11.14
-(void)popself
{
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[ShopDetailsViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if (_nullView.superview) {
        [_nullView removeNullView];
    }
    
    if (self.StatusType == StatusTypeOrderToMember) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"我的预订";
    self.view.backgroundColor = KCWViewBgColor;
    
    picHeight=40.0f;
    picWidth =70.0f;
    
    
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    
    
    [self loadMainView];
    
    
    [self accessAllService];
    [self accessCancelService];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCancelOrder:) name:@"cancelOrders" object:nil];
    
}

- (void)loadMainView{
    _menuView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, kcontrolHeight)];
    _menuView.backgroundColor=[UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [self.view addSubview:_menuView];
    
    _allOrderBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth/2-1, kcontrolHeight-6)];
    [_allOrderBtn setTitle:@"全部预订" forState:UIControlStateNormal];
    [_allOrderBtn setTag:10];
    [_allOrderBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_allOrderBtn];
    
    UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(KUIScreenWidth/2-1, 8, 2, kcontrolHeight-18)];
    line.backgroundColor=[UIColor darkGrayColor];
    line.alpha=0.3;
    [_menuView addSubview:line];
    [line release];
    
    _cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(KUIScreenWidth/2-1, 0, KUIScreenWidth/2, kcontrolHeight-6)];
    [_cancelBtn setTitle:@"取消的预订" forState:UIControlStateNormal];
    [_cancelBtn setTag:11];
    [_cancelBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_cancelBtn];

    
    _lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, kcontrolHeight-6, KUIScreenWidth/2-1, 5)];
    _lineLabel.backgroundColor=[UIColor colorWithRed:51/255.0 green:183/255.0 blue:229/255.0 alpha:1];
    [_menuView addSubview:_lineLabel];
    
    
    _cancelView=[[PopCancelOrderView alloc]init];
    _cancelView.delegate=self;
    
}

- (void)createOrderTableView{
    _shopTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, kcontrolHeight, KUIScreenWidth, KUIScreenHeight-kcontrolHeight*2) style:UITableViewStylePlain];
    _shopTableView.dataSource=self;
    _shopTableView.delegate=self;
    _shopTableView.tag=15;
    _shopTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _shopTableView.backgroundColor = KCWViewBgColor;
    [self.view addSubview:_shopTableView];
}

- (void)createCancelOrderTableView{
    _messageTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, kcontrolHeight, KUIScreenWidth, KUIScreenHeight-kcontrolHeight*2+10) style:UITableViewStylePlain];
    _messageTableView.backgroundColor = KCWViewBgColor;
    _messageTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _messageTableView.dataSource=self;
    _messageTableView.delegate=self;
    _messageTableView.tag=16;
    [self.view addSubview:_messageTableView];
    _messageTableView.hidden=YES;
}


- (void)click:(UIButton *)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    switch (sender.tag) {
        case 10:
        {
            _lineLabel.frame=CGRectMake(0, kcontrolHeight-6, KUIScreenWidth/2-1, 5);
            [_cancelBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
            [_allOrderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            _shopTableView.hidden=NO;
            _messageTableView.hidden=YES;
            noMoreOrder = NO;
            loadMore=YES;
            
            if ([self.orderShopArray count]==0) {
                    [_nullView setNullStatusText:@"您还没有预订哦~"];
                    [self.view addSubview:_nullView];
                    _nullView.hidden = NO;
            }else{
                if (_nullView.superview) {
                    [_nullView removeNullView];
                    
                }
            }
        }
            break;
        case 11:
        {
            _lineLabel.frame=CGRectMake(KUIScreenWidth/2, kcontrolHeight-6, KUIScreenWidth/2-1, 5);
            [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_allOrderBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
            
            _shopTableView.hidden=YES;
            _messageTableView.hidden=NO;
            noMoreOrder = NO;
            loadMore=NO;
            
            if ([self.cancelShopArray count]==0) {
                    [_nullView setNullStatusText:@"您还没有取消的预订哦~"];
                    [self.view addSubview:_nullView];
                    _nullView.hidden = NO;
            }else{
                if (_nullView.superview) {
                    [_nullView removeNullView];
                    
                }
            }
        }
            break;
        default:
            break;
    }
    [UIView commitAnimations];
}


- (void)cancelOrderClick:(UIButton *)btn{
    //获取点击的Btn的cell
    //IOS7获取点击cell，cell上面还多了一个UITableViewWrapperView，所以需UITableViewCell.superview.superview获取UITableView
    if (IOS_7) {
         self.orderCell= (AllOrderCell *)btn.superview.superview.superview.superview;
    }else{
         self.orderCell= (AllOrderCell *)btn.superview.superview.superview;
    }
   
    _cancelOrderBtn.tag=btn.tag;
    [_cancelView addPopupSubview];
}

- (void)orderDelete:(BOOL)isHidden{
    
    if (isHidden) {
        NSLog(@"隐藏%@",self.orderCell);

        
    }else{
        NSLog(@"ddddd");
    }
    
}

- (void)progressHud:(NSString *)valueText{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center=CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.delegate = self;
    progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = valueText;
    [self.view addSubview:progressHUDTmp];
    [self.view bringSubviewToFront:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];
}

- (void)backToMemberCenter{
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , 44.0f , 44.0f )];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = leftView.frame;
    [btn setImage:[UIImage imageCwNamed:@"return.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:btn];
    leftView.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftBtn;
    RELEASE_SAFE(leftBtn);
    RELEASE_SAFE(leftView);
}

- (void)backBtn{
    LoginViewController *member = [[LoginViewController alloc]init];
    member.navigationController.navigationBar.backItem.hidesBackButton = YES;
    [self.navigationController pushViewController:member animated:YES];
    RELEASE_SAFE(member);
}

- (void)dealloc
{
    RELEASE_SAFE(_cancelOrderBtn);
    RELEASE_SAFE(_messageTableView);
    RELEASE_SAFE(_shopTableView);
    RELEASE_SAFE(_menuView);
    RELEASE_SAFE(_cancelBtn);
    RELEASE_SAFE(_allOrderBtn);
    RELEASE_SAFE(_lineLabel);
    RELEASE_SAFE(_orderShopArray);
    RELEASE_SAFE(_shopImageArray);
    RELEASE_SAFE(_cancelShopArray);
    RELEASE_SAFE(_progressHUD);
    RELEASE_SAFE(_nullView);
    if (failView) {
        RELEASE_SAFE(failView);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelOrders" object:nil];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - NSNotification
- (void)deleteCancelOrder:(NSNotification *)notification
{
    NSDictionary *dic = [notification object];
    NSLog(@"dic====%@",dic);
    
  
    int row = [[dic objectForKey:@"clickIndex"]intValue];
    
    NSLog(@"devinrow = %d",row);
    AllOrderCell *cell = (AllOrderCell *)[_shopTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    NSIndexPath *indexPath = [_shopTableView indexPathForCell:cell];
    
    NSLog(@"devinindexPath==%@===%d==%d",indexPath,row,[self.orderShopArray count]);
    //取消预订成功后删除表格数据，刷新
    [self.orderShopArray removeObjectAtIndex:row];

    [_shopTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    if ([self.orderShopArray count]==0) {
        NSLog(@"_nullView=%@",_nullView);
//        [_nullView setNullStatusText:@"你还没有预订哦~"];
//        [self.view bringSubviewToFront:_nullView];
        _nullView.hidden = NO;
        _shopTableView.hidden = YES;
    }

    [self accessCancelService];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case 15:
        {
            if ([self.orderShopArray count]!=0&&section==0) {
                return [self.orderShopArray count];
            }else{
                return 0;
            }
        }
            break;
        case 16:
        {
            if ([self.cancelShopArray count]!=0&&section==0) {
                return [self.cancelShopArray count];
            }else{
                return 0;
            }
        }
            break;
            
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (tableView.tag) {
        case 15:{
            static NSString *CellIdentifier = @"shopOrderCell";
            AllOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[AllOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
            
            if ([self.orderShopArray count]!=0) {
                NSLog(@"indexPath==%d====%d",[self.orderShopArray count],indexPath.row);
                
                NSDictionary *orderDic =[[[self.orderShopArray objectAtIndex:indexPath.row]objectForKey:@"products"]objectAtIndex:0];
                NSDictionary *shopOrderDic=[self.orderShopArray objectAtIndex:indexPath.row];
            
                NSLog(@"audit==%@",[shopOrderDic objectForKey:@"audit"]);
                if ([[shopOrderDic objectForKey:@"audit"]integerValue]==0) {
                    cell.orderStatus.text=@"待确认";
                    if (![[orderDic objectForKey:@"content"] isEqual:[NSNull null]]) {
                        cell.shopName.text=[orderDic objectForKey:@"content"];
                    }
                    
                    cell.shopPrice.text=[NSString stringWithFormat:@"￥%0.2f",[[shopOrderDic objectForKey:@"money"] doubleValue]];
               
                    cell.cancelBtn.tag=[[shopOrderDic objectForKey:@"id"]intValue]+100;
                    
                    [cell.cancelBtn addTarget:self action:@selector(cancelOrderClick:) forControlEvents:UIControlEventTouchUpInside];
                }else{
                    cell.cancelBtn.hidden=YES;
                    if ([[shopOrderDic objectForKey:@"audit"]integerValue]==1) {
                        cell.orderStatus.text=@"待发货";
                    }else if([[shopOrderDic objectForKey:@"audit"]integerValue]==2) {
                        cell.orderStatus.text=@"待收货";
                    }
                    else if([[shopOrderDic objectForKey:@"audit"]integerValue]==3) {
                        cell.orderStatus.text=@"交易成功";
                    }else{
                         cell.orderStatus.text=@"已作废";
                    }
                    if (![[orderDic objectForKey:@"content"] isEqual:[NSNull null]]) {
                        cell.shopName.text=[orderDic objectForKey:@"content"];
                    }
                    cell.shopPrice.text=[NSString stringWithFormat:@"￥%@",[shopOrderDic objectForKey:@"money"]];
                    
                }
                
                //图片
                NSString *picUrl = [orderDic objectForKey:@"image"];
                
                NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
                
                if (picUrl.length > 1)
                {
                    UIImage *pic = [FileManager getPhoto:picName];
                    if (pic.size.width > 2)
                    {
                        cell.shopImage.image = pic;
                    }
                    else
                    {
                        UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
                        cell.shopImage.image = defaultPic;
                        
                        if (tableView.dragging == NO && tableView.decelerating == NO)
                        {
                            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                        }
                    }
                }
                else
                {
                    UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
                    cell.shopImage.image = defaultPic;
                }

                
            }
            
            return cell;
        }
            break;
        case 16:
        {
            static NSString *CellIdentifier = @"cancelOrderCell";
            CancelOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[CancelOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            if ([self.cancelShopArray count]!=0) {
           
                NSDictionary *orderDic =[[[self.cancelShopArray objectAtIndex:indexPath.row]objectForKey:@"products"]objectAtIndex:0];
                
                NSDictionary *shopOrderDic=[self.cancelShopArray objectAtIndex:indexPath.row];
                
                NSLog(@"audit==%@",[shopOrderDic objectForKey:@"audit"]);
                if (![[orderDic objectForKey:@"content"] isEqual:[NSNull null]]) {
                    cell.shopName.text=[orderDic objectForKey:@"content"];
                }
                cell.shopPrice.text=[NSString stringWithFormat:@"￥%@",[shopOrderDic objectForKey:@"money"]];
                
                //图片
                NSString *picUrl = [orderDic objectForKey:@"image"];
                
                NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
                
                if (picUrl.length > 1)
                {
                    UIImage *pic = [FileManager getPhoto:picName];
                    if (pic.size.width > 2)
                    {
                        cell.shopImage.image = pic;
                    }
                    else
                    {
                        UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
                        cell.shopImage.image = defaultPic;
                        
                        if (tableView.dragging == NO && tableView.decelerating == NO)
                        {
                            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                        }
                    }
                }
                else
                {
                    UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
                    cell.shopImage.image = defaultPic;
                }
                
                
            }

            return cell;
        }
            break;
            
        default:
            break;
    }
    
    
	return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (tableView.tag) {
        case 15:{
            
           
            OrderDetailViewController *detailCtl=[[OrderDetailViewController alloc]init];
            
            detailCtl.shopDic = [self.orderShopArray objectAtIndex:indexPath.row];
            detailCtl.orderlistDic = [[[self.orderShopArray objectAtIndex:indexPath.row]objectForKey:@"products"]objectAtIndex:0];
            detailCtl.clickIndex = indexPath.row;
            detailCtl.delegate = self;
            NSLog(@"orderId=%d,productId=%d",detailCtl.orderId,detailCtl.productId);
            [self.navigationController pushViewController:detailCtl animated:YES];
            RELEASE_SAFE(detailCtl);
        }
            break;
        case 16:{
            OrderDetailViewController *detailCtl=[[OrderDetailViewController alloc]init];

            detailCtl.shopDic = [self.cancelShopArray objectAtIndex:indexPath.row];
            detailCtl.orderlistDic = [[[self.cancelShopArray objectAtIndex:indexPath.row]objectForKey:@"products"]objectAtIndex:0];
            [self.navigationController pushViewController:detailCtl animated:YES];
            RELEASE_SAFE(detailCtl);
        } break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 1) {
		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 320, 30)];
        if (noMoreOrder) {
            moreLabel.text=@"没有更多了";
        }else{
            moreLabel.text=@"上拉加载更多";
        }
		moreLabel.tag = 200;
        moreLabel.font = [UIFont systemFontOfSize:14.0f];
		moreLabel.textColor = [UIColor colorWithRed:0.3 green: 0.3 blue: 0.3 alpha:1.0];
		moreLabel.textAlignment = UITextAlignmentCenter;
		moreLabel.backgroundColor = [UIColor clearColor];
		[vv addSubview:moreLabel];
		[moreLabel release];
		
		//添加loading图标
		indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
		[indicatorView setCenter:CGPointMake(320 / 3, 40 / 2.0)];
		indicatorView.hidesWhenStopped = YES;
		[vv addSubview:indicatorView];
		
		return [vv autorelease] ;
	}else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (tableView.tag) {
        case 15:
        {
            if (section == 1 && self.orderShopArray.count >= 20) {
                return 40;
            }else {
                return 0;
            }
        }
            break;
        case 16:
        {
            if (section == 1 && self.cancelShopArray.count >= 20) {
                return 40;
            }else {
                return 0;
            }
        }
            break;
            
        default:
            break;
    }
    return 0.f;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (tableView.tag) {
        case 15:
            return 135.0f;
            break;
        case 16:
            return 100.0f;
            break;
            
        default:
            break;
    }
    return 0.f;
}

#pragma mark - accessService

- (void)accessAllService{

    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(KUIScreenWidth / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    //全部预订数据请求
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                            @"1",@"type",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_ORDERLIST_COMMAND_ID accessAdress:@"member/orderlist.do?param=" delegate:self withParam:nil];
    
   
    
}
- (void)accessCancelService{
    
    //取消的预订数据请求
    NSMutableDictionary *jsontestDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [Global sharedGlobal].user_id,@"user_id",
                                                                             @"2",@"type",
                                                                                     nil];
	
	[[NetManager sharedManager]accessService:jsontestDic2 data:nil command:MEMBER_CANCELORDER_COMMAND_ID accessAdress:@"member/orderlist.do?param=" delegate:self withParam:nil];
}

- (void)accessMoreService{
    
    NSString *created = [[self.orderShopArray objectAtIndex:[self.orderShopArray count] - 1] objectForKey:@"created"];

    
    //全部预订数据请求
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                            @"1",@"type",
                                                                      created,@"created",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_ORDERLIST_MORE_COMMAND_ID                                accessAdress:@"member/orderlist.do?param=" delegate:self withParam:nil];
    
}

- (void)accessCancelMoreService{
    NSString *created2 = [[self.cancelShopArray objectAtIndex:[self.cancelShopArray count] - 1] objectForKey:@"created"];
    
    
    //取消的预订数据请求
    NSMutableDictionary *jsontestDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [Global sharedGlobal].user_id,@"user_id",
                                         @"2",@"type",
                                         created2,@"created",
                                         nil];
	
	[[NetManager sharedManager]accessService:jsontestDic2 data:nil command:MEMBER_CANCELORDER_MORE_COMMAND_ID
                                accessAdress:@"member/orderlist.do?param=" delegate:self withParam:nil];

}

- (void)cancelOrderService:(NSString *)orderId{
    
    //预订作废数据请求
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                     orderId,@"order_id",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_ORDERCANCEL_COMMAND_ID accessAdress:@"book/cancelOrder.do?param=" delegate:self withParam:nil];
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
	NSLog(@"information finish");
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        switch (commandid) {
                
            case MEMBER_ORDERLIST_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(allOrderSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            case MEMBER_CANCELORDER_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(cancelOrderSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            case MEMBER_ORDERLIST_MORE_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(allOrderMoreSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            case MEMBER_CANCELORDER_MORE_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(cancelOrderMoreSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            case MEMBER_ORDERCANCEL_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(cancelSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            default:
                break;
        }
        self.cloudLoading.hidden = NO;
        
    }else{
        
        _shopTableView.hidden = YES;
        _messageTableView.hidden = YES;
        self.cloudLoading.hidden = YES;
        _nullView.hidden = YES;
        if (_nullView.superview) {
            [_nullView removeNullView];
        }
        
        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoRequest];
        } else {
            // 当前网络不可用，请重新再试
            [self failViewCreate:CwTypeViewNoNetWork];
        }
//        
    }

}
- (void)allOrderSuccess:(NSMutableArray*)resultArray{
    
    if (_nullView == nil) {
        _nullView=[[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_orders_default.png"] andText:@"您还没有预订哦~"];
    }
    
    //loading图标移除
	[self.cloudLoading removeFromSuperview];

    [_orderShopArray addObjectsFromArray:resultArray];
    
    NSLog(@"wwwwwwwwwwwww%d%@",[resultArray count],_orderShopArray);

    
    if ([self.orderShopArray count]!=0) {
        
        [self createOrderTableView];
    }else{
        _nullView.hidden = NO;
        if (_nullView.superview==NULL) {
            [self.view addSubview:_nullView];
        }
        
    }
    
    [_shopTableView reloadData];
    

	NSLog(@"db read success---orderShopArray=%d",[self.orderShopArray count]);
}

- (void)cancelOrderSuccess:(NSMutableArray*)resultArray{
    
    if ([_cancelShopArray count]!=0) {
        [_cancelShopArray removeAllObjects];
    }
    [_cancelShopArray addObjectsFromArray:resultArray];
    
    NSLog(@"-----------%@",self.cancelShopArray);
    
    if ([self.cancelShopArray count]!=0) {
        
        [self createCancelOrderTableView];
    }else{
        if (_nullView.superview==nil) {
            [self.view addSubview:_nullView];
        }
        
    }
    
    [_messageTableView reloadData];
    
}

- (void)allOrderMoreSuccess:(NSMutableArray*)resultArray{
    UILabel *label = (UILabel*)[_shopTableView viewWithTag:200];
    if ([resultArray count]==0||[resultArray count]<20) {
        noMoreOrder = YES;
        label.text = @"没有更多了";
    }else{
        label.text = @"上拉加载更多";
        noMoreOrder = NO;
    }
	[indicatorView stopAnimating];
    
    _loadingMore = NO;
	
    [_orderShopArray addObjectsFromArray:resultArray];

    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
    for (int ind = 0; ind < [resultArray count]; ind ++)
    {
        
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                [self.orderShopArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_shopTableView insertRowsAtIndexPaths:insertIndexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)cancelOrderMoreSuccess:(NSMutableArray*)resultArray{
    UILabel *label = (UILabel*)[_messageTableView viewWithTag:200];
    if ([resultArray count]==0||[resultArray count]<20) {
        noMoreOrder = YES;
        label.text = @"没有更多了";
    }else{
        label.text = @"上拉加载更多";
        noMoreOrder = NO;
    }
	[indicatorView stopAnimating];
    
    _loadingMore = NO;
	
    [_cancelShopArray addObjectsFromArray:resultArray];
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
    for (int ind = 0; ind < [resultArray count]; ind ++)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                [self.cancelShopArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_messageTableView insertRowsAtIndexPaths:insertIndexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
}


- (void)cancelSuccess:(NSMutableArray*)resultArray{

    if ([[[resultArray objectAtIndex:0]objectForKey:@"ret"]intValue]==1) {
        [_cancelView closeView];
        
        [self progressHud:@"取消预订成功"];
        

        NSIndexPath *indexPath = [_shopTableView indexPathForCell:self.orderCell];
        
        NSLog(@"indexPath2==%@===%@",indexPath,self.orderCell);
        //取消预订成功后删除表格数据，刷新
        [self.orderShopArray removeObjectAtIndex:indexPath.row];
                
//        [_shopTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_shopTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

        
        if ([self.orderShopArray count]==0) {

            [_nullView setNullStatusText:@"您还没有预订哦~"];
            [self.view addSubview:_nullView];
            _nullView.hidden = NO;
        }
        
        
        [self accessCancelService];
    
    }else{
        [_cancelView closeView];
        [self progressHud:@"取消预订失败"];
  
    }
    
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessAllService];
    [self accessCancelService];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ((_isAllowLoadingMore && !_loadingMore && [self.orderShopArray count] > 0)||(_isAllowLoadingMore && !_loadingMore && [self.cancelShopArray count] > 0))
    {
        UILabel *label = (UILabel*)[_shopTableView viewWithTag:200];
        UILabel *label2 = (UILabel*)[_messageTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            label.text=@"松开加载更多";
            label2.text=@"松开加载更多";
        }
        else
        {
            if (noMoreOrder) {
                label.text=@"没有更多了";
                label2.text=@"没有更多了";
            }else{
                label.text=@"上拉加载更多";
                label2.text=@"上拉加载更多";
            }
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate)
	{
		[self loadImagesForOnscreenRows];
    }
    
    if (_isAllowLoadingMore && !_loadingMore)
    {
        UILabel *label = (UILabel*)[_shopTableView viewWithTag:200];
        UILabel *label2 = (UILabel*)[_messageTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            _loadingMore = YES;
            
            if (loadMore) {
                label.text=@" 加载中...";
                [self accessMoreService];
            }else{
                label2.text=@" 加载中...";
                [self accessCancelMoreService];
            }
            
            [indicatorView startAnimating];
            
        }
        else
        {
            if (noMoreOrder) {
                label.text=@"没有更多了";
                label2.text=@"没有更多了";
            }else{
                label.text=@"上拉加载更多";
                label2.text=@"上拉加载更多";
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if ((bottomEdge >= scrollView.contentSize.height && bottomEdge > _shopTableView.frame.size.height && [self.orderShopArray count] >= 20)||(bottomEdge >= scrollView.contentSize.height && bottomEdge > _messageTableView.frame.size.height && [self.cancelShopArray count] >= 20))
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
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
            
            AllOrderCell *cell = (AllOrderCell *)[_shopTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell.shopImage.image = photo;
            
		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - PopCancelOrderDelegate
- (void)OKCancel{

    NSString *orderId=[NSString stringWithFormat:@"%d",_cancelOrderBtn.tag-100];
    NSLog(@"确定取消预订=%@",orderId);
    [self cancelOrderService:orderId];

}

#pragma mark - Private Motheds
//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    //每次只下载一屏显示的单元格图片
	NSArray *visiblePaths = [_shopTableView indexPathsForVisibleRows];
    
	for (NSIndexPath *indexPath in visiblePaths) {
		int countItems = [self.orderShopArray count];
		if (countItems >[indexPath row]) {
            NSString *photoURL = [[[[self.orderShopArray objectAtIndex:[indexPath row]]objectForKey:@"products"]objectAtIndex:0] objectForKey:@"image"];
            
			//获取本地图片缓存
			UIImage *cardIcon = [[IconPictureProcess sharedPictureProcess] getPhoto:photoURL];
			
			AllOrderCell *cell = (AllOrderCell *)[_shopTableView cellForRowAtIndexPath:indexPath];
            
            //拖动或滚动table view时，图片不下载
			if (cardIcon == nil) {
				if (_shopTableView.dragging == NO && _shopTableView.decelerating == NO) {
					[[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
				}
			} else {
				cell.shopImage.image = cardIcon;
			}
		}
	}
}


@end
