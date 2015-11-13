//
//  InformationsViewController.m
//  cw
//
//  Created by LuoHui on 13-8-28.
//
//

#import "InformationsViewController.h"
#import "InformationCell.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "IconPictureProcess.h"
#import "informations_model.h"
#import "information_images_model.h"
#import "informations_media_model.h"
#import "InformationDetailViewController.h"
#import "dqxx_model.h"
#import "NetworkFail.h"
#import "PreferentialObject.h"
#import "NullstatusView.h"

@interface InformationsViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
}
@end

@implementation InformationsViewController
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
	self.title = @"创维资讯";
    self.view.backgroundColor = [UIColor colorWithRed:0.9333 green:0.9333 blue:0.9333 alpha:1.0];
    
    CGFloat viewHeight = KUIScreenHeight - KUpBarHeight - KDownBarHeight;
    
    picWidth = 280.0f;
    picHeight = 210.0f;
    
	_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, viewHeight) style:UITableViewStylePlain];
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myTableView];
    
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    _noMore = NO;
    
    [self accessItemService];
    
    if (IOS_7) {
        [Common iosCompatibility:self];
    }
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
		return 340;
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

	InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[InformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.iTitleLabel.text = @"";
        cell.iTimeLabel.text = @"";
		cell.iContentLabel.text = @"";
    }

    if ([self.listArray count] > 0) {
        
        NSDictionary *itemDic = [self.listArray objectAtIndex:[indexPath row]];

        cell.iTitleLabel.text = [itemDic objectForKey:@"title"];
        
        int createTime = [[itemDic objectForKey:@"created"] intValue];

        NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
        NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
        [outputFormat setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        NSString *dateString = [outputFormat stringFromDate:date];
        [outputFormat release];
        cell.iTimeLabel.text = dateString;
        //cell.iTimeLabel.text = [PreferentialObject getTheDate:createTime symbol:3];
        
        [cell.iContentLabel setText:[itemDic objectForKey:@"content"]];
        
        int value = [[itemDic objectForKey:@"recommend"] intValue];
        if (value == 1) {
            cell.recommendView.hidden = NO;
        }else{
            cell.recommendView.hidden = YES;
        }

        //图片
        NSString *picUrl = [itemDic objectForKey:@"picture"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2)
            {
                cell.iImageView.image = [pic fillSize:CGSizeMake(picWidth, picHeight)];
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"newsList_default_280x210.png"];
                cell.iImageView.image = defaultPic;
                
//				if (tableView.dragging == NO && tableView.decelerating == NO)
//				{
//                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
//				}
                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"newsList_default_280x210.png"];
            cell.iImageView.image = defaultPic;
        }
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InformationDetailViewController *detail = [[InformationDetailViewController alloc] init];
    detail.indexValue = indexPath.row;
    detail.dataArr = self.listArray;
    [self.navigationController pushViewController:detail animated:YES];
    [detail release], detail = nil;
}

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    
    if (iconDownloader != nil)
    {
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
            UIImage *photo = iconDownloader.cardIcon;
            
            InformationCell *cell = (InformationCell *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell.iImageView.image = [photo fillSize:CGSizeMake(picWidth, picHeight)];
		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
	NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		int countItems = [self.listArray count];
		if (countItems >[indexPath row]) {
            NSString *photoURL = [[self.listArray objectAtIndex:[indexPath row]] objectForKey:@"picture"];
            
			//获取本地图片缓存
			UIImage *cardIcon = [[IconPictureProcess sharedPictureProcess] getPhoto:photoURL];
			
			InformationCell *cell = (InformationCell *)[self.myTableView cellForRowAtIndexPath:indexPath];
            
			if (cardIcon == nil) {
				if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO) {
					[[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
				}
			} else {
				cell.iImageView.image = [cardIcon fillSize:CGSizeMake(picWidth, picHeight)];
			}
		}
	}
    
    [pool release];
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
            label.text = @"松开加载更多";
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
//    if (!decelerate)
//	{
//		[self loadImagesForOnscreenRows];
//    }
    
    if (_isAllowLoadingMore && !_loadingMore)
    {
        UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 10.0f)
        {
            //松开 载入更多
            _loadingMore = YES;
            
            label.text = @" 加载中 ...";
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

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService];
}

#pragma mark --- private methods
//网络获取数据
-(void)accessItemService
{
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    
    NSString *reqUrl = @"newlist.do?param=";
    
    NSString *cityId = nil;
    dqxx_model *dqxxModel = [[dqxx_model alloc] init];
    dqxxModel.where = [NSString stringWithFormat:@"DQXX02 = '%@'",[Global sharedGlobal].currCity];
    NSArray *arr = [dqxxModel getList];
    if ([arr count] > 0) {
        cityId = [[arr objectAtIndex:0] objectForKey:@"DQXX01"];
    }else {
        cityId = @"0";
    }
    dqxxModel.where = nil;
    [dqxxModel release];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Common getVersion:INFORMATIONS_COMMAND_ID],@"ver",
                                       cityId,@"city",nil];
    //NSLog(@"requestDic === %@",requestDic);
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:INFORMATIONS_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

- (void)accessMoreService
{
    int created = [[[self.listArray objectAtIndex:[self.listArray count] - 1] objectForKey:@"created"] intValue];
    int state = [[[self.listArray objectAtIndex:[self.listArray count] - 1] objectForKey:@"recommend_sate"] intValue];
    
    NSString *cityId = nil;
    dqxx_model *dqxxModel = [[dqxx_model alloc] init];
    dqxxModel.where = [NSString stringWithFormat:@"DQXX02 = '%@'",[Global sharedGlobal].currCity];
    NSArray *arr = [dqxxModel getList];
    if ([arr count] > 0) {
        cityId = [[arr objectAtIndex:0] objectForKey:@"DQXX01"];
    }else {
        cityId = @"0";
    }
    dqxxModel.where = nil;
    [dqxxModel release];
    
    NSString *reqUrl = @"newlist.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:-1],@"ver",
                                       [NSNumber numberWithInt:created],@"created",
                                       cityId,@"city",
                                       [NSNumber numberWithInt:state],@"recommend_sate",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:INFORMATIONS_MORE_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    
    switch (commandid) {
        case INFORMATIONS_COMMAND_ID:
        {
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
        }
            break;
        case INFORMATIONS_MORE_COMMAND_ID:
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
- (void)update:(NSMutableArray*)resultArray
{
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    
    informations_model *infoMod = [[informations_model alloc] init];
    
    NSString *sql = @"select * from t_informations order by recommend desc,created desc";
    NSMutableArray *dbArr = [infoMod querSelectSql:sql];
    
    [infoMod release];
    
    for (int i = 0; i < [dbArr count]; i ++) {
        NSMutableDictionary *dic = [dbArr objectAtIndex:i];
        
        int infoId = [[dic objectForKey:@"new_id"] intValue];
        information_images_model *imgMod = [[information_images_model alloc] init];
        imgMod.where = [NSString stringWithFormat:@"new_id = %d",infoId];
        NSMutableArray *imgArray = [imgMod getList];
        [dic setObject:imgArray forKey:@"pics"];
        
        informations_media_model *imMod = [[informations_media_model alloc] init];
        imMod.where = [NSString stringWithFormat:@"new_id = %d",infoId];
        NSMutableArray *imArray = [imMod getList];
        [imMod release], imMod = nil;
        [dic setObject:imArray forKey:@"media"];
        
        [self.listArray addObject:dic];
        
        [imgMod release];
    }
    
    //NSLog(@"self.listArray === %@",self.listArray);
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
            // 服务器繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoService];
        }else {
            if ([self.listArray count] == 0) {
                self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                
                NullstatusView *_nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_activity_default.png"] andText:@"暂无资讯信息哦~"];
                [self.view addSubview:_nullView];
                [_nullView release];
            }
            
            [self.myTableView reloadData];
        }
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
    [indicatorView stopAnimating];
    _loadingMore = NO;
    
    UILabel *label = (UILabel*)[self.myTableView viewWithTag:200];
    
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {// 服务器繁忙，请重新再试
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
    }else {
        _noMore = NO;
        label.text = @"上拉加载更多";
    }
}
@end
