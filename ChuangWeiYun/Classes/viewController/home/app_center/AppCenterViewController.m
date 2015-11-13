//
//  AppCenterViewController.m
//  cw
//
//  Created by LuoHui on 13-9-3.
//
//

#import "AppCenterViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "IconPictureProcess.h"
#import "service_cats_model.h"
#import "AppCatListViewController.h"
#import "browserViewController.h"
#import "add_content_model.h"
#import "NetworkFail.h"
#import "HttpRequest.h"
#import "Global.h"
#import "NullstatusView.h"

@interface AppCenterViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
}
@property (retain, nonatomic) NSDictionary *dataDict;
@end

@implementation AppCenterViewController
@synthesize myTableView = _myTableView;
@synthesize listArray = __listArray;
@synthesize cloudLoading;
@synthesize delegate;
@synthesize dataDict;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"便民服务";
    self.view.backgroundColor = KCWViewBgColor;
    
    __listArray = [[NSMutableArray alloc] init];
    
    CGFloat viewHeight = KUIScreenHeight - KUpBarHeight;
    
    picWidth = 60.0f;
    picHeight = 60.0f;
    
	_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, viewHeight) style:UITableViewStylePlain];
    self.myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myTableView];
    
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    _noMore = NO;
    
    [self accessItemService];
}

- (void)dealloc
{
    [_myTableView release];
    [__listArray release];
    [cloudLoading release];
    [indicatorView release];
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
		return 80;
	}else {
		return 0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 1) {
		UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 320, 30)];
		if (_noMore) {
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
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, picWidth, picHeight)];
        picView.backgroundColor = [UIColor clearColor];
        picView.tag = 100;
        [cell.contentView addSubview:picView];
        [picView release];
        
        UILabel *appTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(picView.frame) + 15, 20, 150, 40)];
        appTitle.backgroundColor = [UIColor clearColor];
        appTitle.tag = 101;
        appTitle.font = [UIFont systemFontOfSize:16];
        appTitle.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1];
        [cell.contentView addSubview:appTitle];
        [appTitle release];
        
        UIImage *img = [UIImage imageNamed:@"icon_add_community.png"];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(cell.frame.size.width - 15 - img.size.width, (80 - img.size.height) * 0.5, img.size.width, img.size.height);
        rightBtn.tag = 10000;
        [rightBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:rightBtn];
    }
    if ([self.listArray count] > 0) {
        
        NSDictionary *itemDic = [self.listArray objectAtIndex:[indexPath row]];
        
        UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
		UILabel *title = (UILabel *)[cell.contentView viewWithTag:101];
        
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:10000];
        [btn setTitle:[NSString stringWithFormat:@"%d",indexPath.row] forState:UIControlStateNormal];
        
        add_content_model *acModel = [[add_content_model alloc] init];
        acModel.where = [NSString stringWithFormat:@"id = %@",[itemDic objectForKey:@"id"]];
        NSArray *dbArr = [acModel getList];
        acModel.where = nil;
        [acModel release];
        
        if ([dbArr count] > 0) {
            [btn setImage:[UIImage imageNamed:@"icon_repair_community.png"] forState:UIControlStateNormal];
        }else {
            [btn setImage:[UIImage imageNamed:@"icon_add_community.png"] forState:UIControlStateNormal];
        }
        
        title.text = [itemDic objectForKey:@"name"];
        
        //图片
        NSString *picUrl = [itemDic objectForKey:@"logo"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
            if (pic.size.width > 2)
            {
                picView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_60x60.png"];
                picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
                
				if (tableView.dragging == NO && tableView.decelerating == NO)
				{
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
				}
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_60x60.png"];
            picView.image = [defaultPic fillSize:CGSizeMake(picWidth, picHeight)];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int type = [[[self.listArray objectAtIndex:indexPath.row] objectForKey:@"service_type"] intValue];
    if (type == 2) {
        NSString *url = [[self.listArray objectAtIndex:indexPath.row] objectForKey:@"url"];
        if (url.length > 0) {
            browserViewController *browser = [[browserViewController alloc] init];
            browser.url = url;
            [self.navigationController pushViewController:browser animated:YES];
            [browser release];
        }
    }else {
        NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
        
        [self catList:dic];
    }
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
            
            UITableViewCell *cell = (UITableViewCell *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
            picView.image = photo;
            
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
            NSString *photoURL = [[self.listArray objectAtIndex:[indexPath row]] objectForKey:@"logo"];
            
			//获取本地图片缓存
			UIImage *cardIcon = [[[IconPictureProcess sharedPictureProcess] getPhoto:photoURL]fillSize:CGSizeMake(picWidth, picHeight)];
			
			UITableViewCell *cell = (UITableViewCell *)[self.myTableView cellForRowAtIndexPath:indexPath];
            
            UIImageView *picView = (UIImageView *)[cell.contentView viewWithTag:100];
            
			if (cardIcon == nil) {
				if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO) {
					[[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
				}
			} else {
				picView.image = cardIcon;
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
            if (_noMore) {
                label.text = @"没有更多了";
            }else{
                label.text = @"上拉加载更多";
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
            if (_noMore) {
                label.text = @"没有更多了";
            }else{
                label.text = @"上拉加载更多";
            }
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
    
    NSString *reqUrl = @"servicecatalog.do?param=";
	
    //NSString *verStr = [NSString stringWithFormat:@"%d",[[Common getCatVersion:SERVICE_CATS_COMMAND_ID withId:[[Global sharedGlobal].shop_id intValue]] intValue]];
    NSString *verStr = @"0";
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       verStr,@"ver",
                                       [Global sharedGlobal].shop_id,@"shop",nil];
    
    //NSLog(@"== %@",requestDic);
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:SERVICE_CATS_COMMAND_ID accessAdress:reqUrl delegate:self withParam:requestDic];
}

- (void)accessMoreService
{
    int created = [[[self.listArray objectAtIndex:[self.listArray count] - 1] objectForKey:@"position"] intValue];
    NSString *reqUrl = @"servicecatalog.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:-1],@"ver",
                                       [NSNumber numberWithInt:created],@"position",
                                       [Global sharedGlobal].shop_id,@"shop",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:SERVICE_CATS_MORE_COMMAND_ID accessAdress:reqUrl delegate:self withParam:requestDic];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch (commandid) {
        case SERVICE_CATS_COMMAND_ID:
        {
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
        }
            break;
        case SERVICE_CATS_MORE_COMMAND_ID:
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
    
    service_cats_model *catMod = [[service_cats_model alloc] init];
    catMod.orderBy = @"position";
    catMod.orderType = @"desc";
    catMod.where = [NSString stringWithFormat:@"shop_id = %@",[Global sharedGlobal].shop_id];
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
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 40)];
//                label.text = @"当前分店暂无添加便民服务信息";
//                label.backgroundColor = [UIColor clearColor];
//                label.textColor = [UIColor darkTextColor];
//                label.textAlignment = UITextAlignmentCenter;
//                label.font = [UIFont systemFontOfSize:16.0f];
//                [self.view addSubview:label];
//                [label release];
                NullstatusView *_nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_app_default.png"] andText:@"还没有便民服务信息哦~"];
                [self.view addSubview:_nullView];
                [_nullView release];
            }else {
                _myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            }
            
            [self.myTableView reloadData];
        }
        
    }else{
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
	[indicatorView stopAnimating];
    
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        _loadingMore = NO;
        
        UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
        
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]){
            _noMore = NO;
            label.text = @"上拉加载更多";
            
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
            if ([resultArray count] == 0 || [resultArray count] < 20) {
                _noMore = YES;
                label.text = @"没有更多了";
            }else{
                _noMore = NO;
                label.text = @"上拉加载更多";
            }
            
            for (int i = 0; i < [resultArray count];i++ )
            {
                NSMutableDictionary *item = [resultArray objectAtIndex:i];
                [self.listArray addObject:item];
            }
            //NSLog(@"self.listArray========%@",self.listArray);
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

- (void)btnAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    NSMutableDictionary *item = [self.listArray objectAtIndex:[btn.titleLabel.text intValue]];
    
    add_content_model *acModel = [[add_content_model alloc] init];
    acModel.where = [NSString stringWithFormat:@"id = %@",[item objectForKey:@"id"]];
    NSArray *dbArr = [acModel getList];
    
    if ([dbArr count] > 0) {
        [acModel deleteDBdata];
        [btn setImage:[UIImage imageNamed:@"icon_add_community.png"] forState:UIControlStateNormal];
        
        if (delegate != nil && [delegate respondsToSelector:@selector(addToContent:)]) {
            [delegate addToContent:NO];
        }
    }else {
        NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];   //转化为时间戳
        long long int currentTime = (long long int)cTime;
        NSNumber *time = [NSNumber numberWithLongLong:currentTime];
        
        [item setObject:[NSString stringWithFormat:@"%d",[time intValue]] forKey:@"created"];
        
        [item removeObjectForKey:@"shop_id"];
        
        [acModel insertDB:item];
        
        [btn setImage:[UIImage imageNamed:@"icon_repair_community.png"] forState:UIControlStateNormal];
        
        if (delegate != nil && [delegate respondsToSelector:@selector(addToContent:)]) {
            [delegate addToContent:YES];
        }
    }
    
    acModel.where = nil;
    [acModel release];
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

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService];
}
@end
