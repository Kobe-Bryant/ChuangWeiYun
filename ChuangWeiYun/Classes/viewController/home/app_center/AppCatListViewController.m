//
//  AppCatListViewController.m
//  cw
//
//  Created by LuoHui on 13-9-5.
//
//

#import "AppCatListViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "IconPictureProcess.h"
#import "AppCatDetailViewController.h"
#import "service_cat_list_model.h"
#import "callSystemApp.h"
#import "BaiduMapViewController.h"
#import "NetworkFail.h"
#import "MBProgressHUD.h"

@interface AppCatListViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
}
@end

@implementation AppCatListViewController
@synthesize navTitle;
@synthesize catId;
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
	self.title = navTitle;
    self.view.backgroundColor = KCWViewBgColor;
    
    CGFloat viewHeight = KUIScreenHeight - KUpBarHeight;
    
    picWidth = 60.0f;
    picHeight = 60.0f;
    
	_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, 320, viewHeight - 5) style:UITableViewStylePlain];
    self.myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myTableView];
    
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    
    [self accessItemService];
}

- (void)dealloc
{
    [_myTableView release];
    [__listArray release];
    [cloudLoading release];
    [indicatorView release];
    [navTitle release];
    [catId release];
    if (failView) {
        [failView release], failView = nil;
    }
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [self.listArray count];
	}else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
		return 160;
	}else {
		return 0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 1) {
		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 320, 30)];
		moreLabel.text = @"上拉加载更多";
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
		
		return [vv autorelease];
	}else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 1 && self.listArray.count >= 20) {
		return 40;
	}else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	//NSInteger row = [indexPath row];
	
	AppCatListCell *cell = (AppCatListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[AppCatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellDelegate = self;
        
        cell.cTitleLabel.text = @"";
        cell.cNameLabel.text = @"";
		cell.cAddressLabel.text = @"";
    }
    if ([self.listArray count] > 0) {
//        [cell.detailButton setTitle:[NSString stringWithFormat:@"%d",indexPath.row] forState:UIControlStateNormal];
//        [cell.addrButton setTitle:[NSString stringWithFormat:@"%d",indexPath.row] forState:UIControlStateNormal];
        cell.detailButton.tag = indexPath.row + 10;
        cell.addrButton.tag = indexPath.row + 10000;
        
        NSDictionary *itemDic = [self.listArray objectAtIndex:[indexPath row]];
        
        cell.cTitleLabel.text = [itemDic objectForKey:@"name"];
        
        cell.cNameLabel.text = [NSString stringWithFormat:@"联系人：%@",[itemDic objectForKey:@"linkman"]];
        
		cell.cAddressLabel.text = [itemDic objectForKey:@"address"];
        
        //图片
        NSString *picUrl = [itemDic objectForKey:@"picture"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
            if (pic.size.width > 2)
            {
                cell.cImageView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_60x60.png"];
                cell.cImageView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
                
				if (tableView.dragging == NO && tableView.decelerating == NO)
				{
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
				}
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_60x60.png"];
            cell.cImageView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
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
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
            UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(picWidth, picHeight)];
            
            AppCatListCell *cell = (AppCatListCell *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell.cImageView.image = photo;
		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
//滚动loading图片
- (void)loadImagesForOnscreenRows
{
	NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		int countItems = [self.listArray count];
		if (countItems >[indexPath row]) {
            NSString *photoURL = [[self.listArray objectAtIndex:[indexPath row]] objectForKey:@"picture"];
            
			//获取本地图片缓存
			UIImage *cardIcon = [[[IconPictureProcess sharedPictureProcess] getPhoto:photoURL]fillSize:CGSizeMake(picWidth, picHeight)];
			
			AppCatListCell *cell = (AppCatListCell *)[self.myTableView cellForRowAtIndexPath:indexPath];
            
			if (cardIcon == nil) {
				if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO) {
					[[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
				}
			} else {
				cell.cImageView.image = cardIcon;
			}
		}
	}
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isAllowLoadingMore && !_loadingMore && [self.listArray count] > 0)
    {
        UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            label.text=@"松开加载更多";
        }
        else
        {
            label.text=@"上拉加载更多";
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
        UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            _loadingMore = YES;
            
            label.text=@" 加载中 ...";
            [indicatorView startAnimating];
            
            [self accessMoreService];
        }
        else
        {
            label.text=@"上拉加载更多";
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > self.myTableView.frame.size.height && [self.listArray count] >= 20)
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
}

#pragma mark ---- AppCatListCellDelegate
- (void)toDetail:(UIButton *)button
{
    AppCatDetailViewController *detail = [[AppCatDetailViewController alloc] init];
    detail.dataDic = [self.listArray objectAtIndex:button.tag - 10];
    detail.titleStr = self.navTitle;
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
}

- (void)toAddress:(UIButton *)button
{
    NSDictionary *dict = [self.listArray objectAtIndex:button.tag - 10000];
    //NSLog(@"dict === %@",dict);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [dict objectForKey:@"latitude"],@"longitude",
                          [dict objectForKey:@"longitude"],@"latitude",
                          [dict objectForKey:@"name"],@"name",
                          [dict objectForKey:@"picture"],@"manager_portrait",
                          @"",@"shop_image",
                          [dict objectForKey:@"linkman"],@"manager_name",
                          [dict objectForKey:@"tel"],@"manager_tel",
                          [dict objectForKey:@"address"],@"address",
                           nil];
    
    BaiduMapViewController *baiduMap = [[BaiduMapViewController alloc]init];
    baiduMap.otherStatusTypeMap = StatusTypeServiceToMap;
    baiduMap.dataDic = dic;
    [self.navigationController pushViewController:baiduMap animated:YES];
    [baiduMap release];
}

- (void)callPhone:(AppCatListCell *)appCatListCell
{
    NSIndexPath *indexPath = [_myTableView indexPathForCell:appCatListCell];
    NSString *phoneNum = [[self.listArray objectAtIndex:indexPath.row] objectForKey:@"tel"];
    [callSystemApp makeCall:phoneNum];
}

#pragma mark --- private methods
//网络获取数据
-(void)accessItemService
{
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    
    NSString *reqUrl = @"servicelist.do?param=";
	
    //NSString *verStr = [NSString stringWithFormat:@"%d",[[Common getCatVersion:SERVICE_CAT_LIST_COMMAND_ID withId:[catId intValue]] intValue]];
    NSString *verStr = @"0";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       verStr,@"ver",
                                       [NSNumber numberWithInt:[catId intValue]],@"cat_id",
                                       [Global sharedGlobal].shop_id,@"shop",nil];
    //NSLog(@"== %@",requestDic);
    [[NetManager sharedManager] accessService:requestDic data:nil command:SERVICE_CAT_LIST_COMMAND_ID accessAdress:reqUrl delegate:self withParam:requestDic];
}

- (void)accessMoreService
{
    int created = [[[self.listArray objectAtIndex:[self.listArray count] - 1] objectForKey:@"position"] intValue];
    NSString *reqUrl = @"servicelist.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:-1],@"ver",
                                       [NSNumber numberWithInt:[catId intValue]],@"cat_id",
                                       [NSNumber numberWithInt:created],@"position",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:SERVICE_CAT_LIST_MORE_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch (commandid) {
        case SERVICE_CAT_LIST_COMMAND_ID:
        {
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
        }
            break;
        case SERVICE_CAT_LIST_MORE_COMMAND_ID:
        {
            [self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
        }
            break;
        default:
            break;
    }
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
    
    service_cat_list_model *catMod = [[service_cat_list_model alloc] init];
    catMod.where = [NSString stringWithFormat:@"service_catalog_id = %d and shop_id = %d",[catId intValue],[[Global sharedGlobal].shop_id intValue]];
    catMod.orderBy = @"position";
    catMod.orderType = @"desc";
    self.listArray = [catMod getList];
    [catMod release];
    
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
            self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            // 服务器繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoService];
        }else {
            if ([self.listArray count] == 0) {
                self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                
                UIView *vi = [[UIView alloc] initWithFrame:self.view.frame];
                vi.backgroundColor = [UIColor clearColor];
                [self.view addSubview:vi];
                
                int yValue = 0;
                if (KUIScreenHeight > 480) {
                    yValue = 170;
                }else {
                    yValue = 130;
                }
                UIImage *img = [UIImage imageCwNamed:@"icon_prompt_default.png"];
                UIImageView *tipView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - img.size.width) * 0.5, yValue, img.size.width, img.size.height)];
                tipView.image = img;
                [vi addSubview:tipView];
                [tipView release];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tipView.frame) + 5, 320, 40)];
                label.text = @"还未添加商家信息";
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor colorWithRed:0.7529 green:0.7529 blue:0.7529 alpha:1.0f];
                label.textAlignment = UITextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:16.0f];
                [vi addSubview:label];
                [label release];
                
                [vi release];
                
            }
            [self.myTableView reloadData];
        }
        //NSLog(@"self.listArray === %@",self.listArray);
    }else {
        if ([self.listArray count] == 0) {
            if ([Common connectedToNetwork]) {
                // 网络繁忙，请重新再试
                [self failViewCreate:CwTypeViewNoRequest];
            } else {
                // 当前网络不可用，请重新再试
                [self failViewCreate:CwTypeViewNoNetWork];
            }
        }else {
            [self.myTableView reloadData];
        }
    }
}

- (void)getMoreResult:(NSMutableArray *)resultArray
{
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
        label.text = @"上拉加载更多";
        [indicatorView stopAnimating];
        
        _loadingMore = NO;
        
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]){
            MBProgressHUD *mprogressHUD = [[MBProgressHUD alloc] initWithView:self.view];
            mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
            mprogressHUD.labelText = CwRequestTip;
            mprogressHUD.mode = MBProgressHUDModeCustomView;
            [self.view addSubview:mprogressHUD];
            [self.view bringSubviewToFront:mprogressHUD];
            [mprogressHUD show:YES];
            [mprogressHUD hide:YES afterDelay:1.5];
            [mprogressHUD release];
        }else {
            for (int i = 0; i < [resultArray count];i++ )
            {
                NSMutableDictionary *item = [resultArray objectAtIndex:i];
                [self.listArray addObject:item];
            }

            NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
            for (int ind = 0; ind < [resultArray count]; ind ++)
            {
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                        [self.listArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
                [insertIndexPaths addObject:newPath];
            }
            [self.myTableView insertRowsAtIndexPaths:insertIndexPaths
                                    withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService];
}
@end
