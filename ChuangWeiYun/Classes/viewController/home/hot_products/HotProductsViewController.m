//
//  HotProductsViewController.m
//  cw
//
//  Created by LuoHui on 13-8-26.
//
//

#import "HotProductsViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "hot_products_model.h"
#import "IconPictureProcess.h"
#import "ShopDetailsViewController.h"
#import "PopGuideView.h"
#import "NetworkFail.h"

@interface HotProductsViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
}
@end

@implementation HotProductsViewController
@synthesize myTableView = _myTableView;
@synthesize listArray = __listArray;
@synthesize cloudLoading;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __listArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"热销商品";
    self.view.backgroundColor = [UIColor colorWithRed:0.9333 green:0.9333 blue:0.9333 alpha:1.0];
    
    viewHeight = KUIScreenHeight - KUpBarHeight;
    
    picWidth = 320.0f;
    picHeight = 240.0f;
    
	_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, viewHeight - 50) style:UITableViewStylePlain];
    self.myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.pagingEnabled = YES;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myTableView];
    
    [self accessItemService];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_myTableView release];
    [__listArray release];
    [cloudLoading release];
    if (failView) {
        [failView release], failView = nil;
    }
    [super dealloc];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.listArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return viewHeight - 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	//NSInteger row = [indexPath row];
	
	HotProductsCell *cell = (HotProductsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[HotProductsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier with:viewHeight] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellDelegate = self;
        
        cell.pNameLabel.text = @"";
        cell.pLoveLabel.text = @"";
		cell.pOrderLabel.text = @"";
        cell.indexLabel.text = @"";
    }
    if ([self.listArray count] > 0) {
        NSDictionary *productDic = [self.listArray objectAtIndex:[indexPath row]];
        
        cell.goButton.tag = indexPath.row + 10000;
        
        //标题
        cell.pNameLabel.text = [productDic objectForKey:@"name"];
        CGSize size = CGSizeMake(1000,20);
        CGSize labelsize = [[productDic objectForKey:@"name"] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
        cell.pNameLabel.frame = CGRectMake(0, 5, labelsize.width + 10, 20);
        
        cell.pLoveLabel.text = [productDic objectForKey:@"like_sum"];
		cell.pOrderLabel.text = [productDic objectForKey:@"sale_sum"];
        
        // 11.15 chenfeng
        NSString *webviewText = @"<style>body{margin:0;background-color:transparent;font:16px/32px Custom-Font-Name}</style>";
        NSString *htmlString = [webviewText stringByAppendingFormat:@"%@", [productDic objectForKey:@"content"]];
        [cell.pContent loadHTMLString:htmlString baseURL:nil];
        
        cell.indexLabel.text = [NSString stringWithFormat:@"%d/%d",indexPath.row + 1,[self.listArray count]];
        
        //图片
        NSString *picUrl = [productDic objectForKey:@"image"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
            if (pic.size.width > 2)
            {
                cell.pImageView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
                cell.pImageView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
                
				if (tableView.dragging == NO && tableView.decelerating == NO)
				{
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
				}
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
            cell.pImageView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
        }
    }
    
	return cell;
}


//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width > 2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
            UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(picWidth, picHeight)];
            
            HotProductsCell *cell = (HotProductsCell *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell.pImageView.image = photo;
		}
        
        [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
    
	for (NSIndexPath *indexPath in visiblePaths)
	{
		int countItems = [self.listArray count];
		if (countItems >[indexPath row])
		{
            NSString *photoURL = [[self.listArray objectAtIndex:[indexPath row]] objectForKey:@"image"];
            
			//获取本地图片缓存
			UIImage *cardIcon = [[[IconPictureProcess sharedPictureProcess] getPhoto:photoURL]fillSize:CGSizeMake(picWidth, picHeight)];
			
			HotProductsCell *cell = (HotProductsCell *)[self.myTableView cellForRowAtIndexPath:indexPath];
            
			if (cardIcon == nil)
			{
				if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO)
				{
					[[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
				}
			}
			else
			{
				cell.pImageView.image = cardIcon;
			}
		}
	}
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate)
	{
		[self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark ---- HotProductsCellDelegate 
- (void)goToSee:(UIButton *)button
{
    NSLog(@"hui === %d",button.tag);
    NSDictionary *dic = [self.listArray objectAtIndex:button.tag - 10000];
    ShopDetailsViewController *shopDetail = [[ShopDetailsViewController alloc] init];
    shopDetail.productID = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"id"] intValue]];
    shopDetail.cwStatusType = StatusTypeHotShop;
    [self.navigationController pushViewController:shopDetail animated:YES];
    [shopDetail release];
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService];
}

#pragma mark ---- private methods
//网络获取数据
-(void)accessItemService
{
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    NSString *reqUrl = @"hotlist.do?param=";
	
    //NSString *ver = [NSString stringWithFormat:@"%d",[[Common getVersion:HOT_PRODUCTS_COMMAND_ID] intValue]];
    NSString *ver = @"0";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       ver,@"ver",
                                       nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:HOT_PRODUCTS_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

//更新数据
-(void)update:(NSMutableArray*)resultArray
{
    //loading图标移除
    [self.cloudLoading removeFromSuperview];
    
    hot_products_model *hotPMod = [[hot_products_model alloc] init];
    hotPMod.orderBy = @"position";
    hotPMod.orderType = @"desc";
    self.listArray = [hotPMod getList];
    [hotPMod release];
    
    if ([self.listArray count] == 0) {
        if (![[resultArray lastObject] isEqual:CwRequestFail]){
            if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                // 服务器繁忙，请重新再试
                [self failViewCreate:CwTypeViewNoService];
            }else {
                UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 40)];
                strLabel.backgroundColor = [UIColor clearColor];
                strLabel.textColor = [UIColor darkTextColor];
                strLabel.text = @"暂无热销商品";
                strLabel.font = [UIFont systemFontOfSize:16.0f];
                strLabel.textAlignment = UITextAlignmentCenter;
                [self.myTableView addSubview:strLabel];
                [strLabel release];
            }
        }else {
            if ([Common connectedToNetwork]) {
                // 网络繁忙，请重新再试
                [self failViewCreate:CwTypeViewNoRequest];
            } else {
                // 当前网络不可用，请重新再试
                [self failViewCreate:CwTypeViewNoNetWork];
            }
        }
    }else {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight - 50, 320, 50)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        [bgView release];
        
        UIImage *btnImage = [UIImage imageCwNamed:@"blue-button.png"];
        UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
        goButton.frame = CGRectMake(60, viewHeight - 45, 200, 40);
        [goButton setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:30 topCapHeight:15] forState:UIControlStateNormal];
        [goButton addTarget:self action:@selector(goAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:goButton];
        
        UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, goButton.frame.size.width, goButton.frame.size.height)];
        strLabel.backgroundColor = [UIColor clearColor];
        strLabel.textColor = [UIColor whiteColor];
        strLabel.text = @"去最近的店看看";
        strLabel.font = [UIFont systemFontOfSize:16.0f];
        strLabel.textAlignment = UITextAlignmentCenter;
        [goButton addSubview:strLabel];
        [strLabel release];
        
        if (![PopGuideView isInsertTable:Guide_Enum_HotShop]) {
            UIImage *img = nil;
            if (KUIScreenHeight > 500) {
                img = [UIImage imageCwNamed:@"hotpro_guide2.png"];
            } else {
                img = [UIImage imageCwNamed:@"hotpro_guide.png"];
            }
            PopGuideView *popGuideView = [[PopGuideView alloc]initWithImage:img index:Guide_Enum_HotShop];
            [popGuideView addPopupSubview];
            [popGuideView release], popGuideView = nil;
        }
    }
    
   [self.myTableView reloadData];
}

- (void)goAction
{
    NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths)
	{
        NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
        //NSLog(@"dic = %@",dic);
        ShopDetailsViewController *shopDetail = [[ShopDetailsViewController alloc] init];
        shopDetail.productID = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"id"] intValue]];
        shopDetail.cwStatusType = StatusTypeHotShop;
        [self.navigationController pushViewController:shopDetail animated:YES];
        [shopDetail release];
    }
}
@end
