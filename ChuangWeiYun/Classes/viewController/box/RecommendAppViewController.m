//
//  RecommendAppViewController.m
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import "RecommendAppViewController.h"
#import "FileManager.h"
#import "Common.h"
#import "adView.h"
#import "NetworkFail.h"
#import "RecommendAppCell.h"
#import "IconPictureProcess.h"
#import "recommend_app_model.h"
#import "recommend_app_ads_model.h"
#import "browserViewController.h"
#import "UIImageView+WebCache.h"

@interface RecommendAppViewController ()<NetworkFailDelegate>
{
    NetworkFail *failView;
}


@end

@implementation RecommendAppViewController
@synthesize cloudLoading;
@synthesize bannerScrollView;
@synthesize adsArray=_adsArray;
@synthesize appItemArray=_appItemArray;

#define iconHeight 60.f
#define iconWidth 60.f
#define bannerWidth 320.f
#define bannerHeight 120.f

static bool noMore = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"应用推荐";
    self.view.backgroundColor = KCWViewBgColor;
	
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    
    _adsArray = [[NSMutableArray alloc]init];
    _appItemArray = [[NSMutableArray alloc]init];

    [self accessService];
    [self addAppTabelView];

}
- (void)viewWillAppear:(BOOL)animated{
    noMore = NO;
}

- (void)loading{
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    RELEASE_SAFE(tempLoadingView);
}

//添加banner
- (void)addBannerScrollView:(UIView *)showInView
{
    XLCycleScrollView *tempBannerScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0.0f , 0.0f , KUIScreenWidth , 120)];
    tempBannerScrollView.isAutoPlay = NO;
    tempBannerScrollView.isResponseTap = NO;
    tempBannerScrollView.delegate = self;
    tempBannerScrollView.datasource = self;
    self.bannerScrollView = tempBannerScrollView;
    [tempBannerScrollView release];
    [showInView addSubview:self.bannerScrollView];
    
}

// 创建表格
- (void)addAppTabelView{
    _appTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight-40) style:UITableViewStylePlain];
    _appTableView.delegate=self;
    _appTableView.dataSource=self;
    _appTableView.backgroundColor=[UIColor clearColor];
    _appTableView.showsHorizontalScrollIndicator=NO;
    _appTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_appTableView];

}
// 点击下载按钮
- (void)downloadClick:(UIButton *)btn{

    if ([self.appItemArray count]!=0) {
        NSLog(@"%@===%d",self.appItemArray,btn.tag);
        NSString *downUrl;
        if (self.adsArray.count == 0) {
            downUrl=[[self.appItemArray objectAtIndex:btn.tag + 1]objectForKey:@"iphone_url"];
        }else{
            downUrl=[[self.appItemArray objectAtIndex:btn.tag]objectForKey:@"iphone_url"];
        }
        NSLog(@"downUrl==%@",downUrl);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downUrl]];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)dealloc
{
    self.cloudLoading=nil;
    RELEASE_SAFE(_appTableView);
    RELEASE_SAFE(_appItemArray);
    RELEASE_SAFE(_adsArray);
    RELEASE_SAFE(_nullView);
    if (failView) {
        RELEASE_SAFE(failView);
    }
    [super dealloc];
}
#pragma mark - XLCycleScrollViewDelegate

- (NSInteger)numberOfPages
{
    if ([self.adsArray count]!=0) {
        return [self.adsArray count];
    }else{
        return 1;
    }
    
}

- (UIView *)pageAtIndex:(XLCycleScrollView *)xlcScrollView viewForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    adView *view = [xlcScrollView dequeueReusableViewWithIndex:[indexPath section]];
    
    if (view == nil)
    {
        view = [[[adView alloc]  initWithFrame:CGRectMake(0.0f , 0.0f , bannerWidth , bannerHeight)] autorelease];
    }
    
    if ([self.adsArray count]!=0) {
        NSDictionary *adDic = [self.adsArray objectAtIndex:[indexPath row]];
        
        //图片
        view.picView.mydelegate = self;
        view.picView.imageId = [NSString stringWithFormat:@"%d",[indexPath row]];
        view.picView.contentMode=UIViewContentModeScaleAspectFit;
        view.picView.backgroundColor = [UIColor whiteColor];
        NSString *picUrl = [adDic objectForKey:@"picture"];
        
//        [view.picView setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageCwNamed:@"default_320x120.png"]];
        
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1)
        {
            UIImage *pic = [FileManager getPhoto:picName];
            if (pic.size.width > 2)
            {
                [view.picView stopSpinner];
                view.picView.image = pic;
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x120.png"];
                
                view.picView.image = defaultPic;
                
                [view.picView stopSpinner];
                [view.picView startSpinner];
                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
            }
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x120.png"];
            view.picView.image = defaultPic;
        }
    }else{
        UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x120.png"];
        view.picView.image = defaultPic;
    
    }
    
    
    return view;
}


- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
  
    NSLog(@"--------click:%d------",index);
}


//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    
    if (iconDownloader != nil)
    {
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
        
            [self.bannerScrollView reloadData];
            [_appTableView reloadData];
        }
        
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - 图片滚动委托

- (void)imageViewTouchesEnd:(NSString *)imageId
{
    NSDictionary *adDic = [self.adsArray objectAtIndex:[imageId intValue]];
    NSString *adsUrl=[adDic objectForKey:@"url"];
    browserViewController *browser = [[browserViewController alloc] init];
    browser.url = adsUrl;
    [self.navigationController pushViewController:browser animated:NO];
    [browser release];
    
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.appItemArray count]!=0&&[self.adsArray count]!=0&&section==0) {
        return [self.appItemArray count]+1;
    }else if([self.adsArray count]!=0&&section==0){
        return 1;
    }else if([self.adsArray count]==0&&[self.appItemArray count]!=0&&section==0){
        return [self.appItemArray count];
    }
    else{
        return 0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0 && [self.adsArray count]!=0) {
        static NSString *cellId=@"adCell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell==nil) {
            cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        [self addBannerScrollView:cell.contentView];
    
        return cell;
    } else {
        static NSString *cellID=@"cellId";
        RecommendAppCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell==nil) {
            cell=[[[RecommendAppCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        if ([self.appItemArray count]!=0) {
            NSLog(@"pppppp==%@",self.appItemArray);
            
            NSDictionary *appDic;
            if ([self.adsArray count]!=0) {
                appDic=[self.appItemArray objectAtIndex:indexPath.row-1];

            }else{
                appDic=[self.appItemArray objectAtIndex:indexPath.row];
            }
                       
            cell.appNameLabel.text=[appDic objectForKey:@"name"];
            cell.appBanner.text=[appDic objectForKey:@"intro"];
            cell.downloadBtn.tag= indexPath.row-1;
            [cell.downloadBtn addTarget:self action:@selector(downloadClick:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *picUrl = [appDic objectForKey:@"picture"];
            
//            [cell.iconImageView setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageCwNamed:@"default_recommend.png"]];
            
            NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (picUrl.length > 1)
            {
                UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(iconWidth, iconHeight)];
                if (pic.size.width > 2)
                {
                    
                    cell.iconImageView.image = pic;
                }
                else
                {
                    UIImage *defaultPic = [UIImage imageCwNamed:@"default_recommend.png"];
                    
                    cell.iconImageView.image = defaultPic;
                    
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                }
            }
            else
            {
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_recommend.png"];
                cell.iconImageView.image = [defaultPic fillSize:CGSizeMake(iconWidth, iconHeight)];
            }

        
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0 && [self.adsArray count]!=0) {
        return 120;
    }else
        return 80;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1 && self.appItemArray.count >= 20) {
        return 40;
    }else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 320, 30)];

        moreLabel.tag = 200;
        if (noMore) {
            moreLabel.text=@"没有更多了";
        }else{
            moreLabel.text=@"上拉加载更多";
        }
        
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isAllowLoadingMore && !_loadingMore && [self.appItemArray count] > 0)
    {
        UILabel *label = (UILabel*)[_appTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 5.0f)
        {
            //松开 载入更多
            label.text=@"松开加载更多";
        }
        else
        {
            if (noMore) {
                label.text=@"没有更多了";
            }else{
                label.text=@"上拉加载更多";
            }
        }
    }    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (_isAllowLoadingMore && !_loadingMore)
    {
        UILabel *label = (UILabel*)[_appTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 5.0f)
        {
            //松开 载入更多
            _loadingMore = YES;
            
            label.text=@" 加载中...";
            [indicatorView startAnimating];
     
            [self accessAppMoreService];
        }
        else
        {
            if (noMore) {
                label.text=@"没有更多了";
            }else{
                label.text=@"上拉加载更多";
            }
            
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && bottomEdge > _appTableView.frame.size.height && [self.appItemArray count] >= 20)
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
}


#pragma mark - accessService

- (void)accessService{
    
    [self loading];
    
	NSMutableDictionary *dicData=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                @"1",@"modelphone",
                                                                              nil];
    
	[[NetManager sharedManager]accessService:dicData data:nil command:RECOMMEND_APP_COMMAND_ID accessAdress:@"member/recommend.do?param=" delegate:self withParam:nil];
    
}

- (void)accessAppMoreService{
    
    NSString *position = [[self.appItemArray objectAtIndex:[self.appItemArray count] - 1] objectForKey:@"position"];
    
//    NSLog(@"adsVer==%@appVer==%@,created==%@",adsVer,appVer,position);
    
    NSMutableDictionary *dicData=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                position,@"created",
                                                                @"1",@"modelphone",
//                                                                @"222",@"ad_ver",
//                                                                @"118",@"app_ver",
                                                                              nil];
    
	[[NetManager sharedManager]accessService:dicData data:nil command:RECOMMEND_APP_MORE_COMMAND_ID accessAdress:@"member/recommend.do?param=" delegate:self withParam:nil];
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        switch (commandid) {
            case RECOMMEND_APP_COMMAND_ID:
            {
                [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
            }
                break;
            case RECOMMEND_APP_MORE_COMMAND_ID:
            {
                [self performSelectorOnMainThread:@selector(moreSuccess:) withObject:resultArray waitUntilDone:NO];
            }
                break;
            default:
                break;
        }

        self.cloudLoading.hidden = NO;
        
    }else{
        
        _appTableView.hidden = YES;
        
        self.cloudLoading.hidden = YES;
        _nullView.hidden = YES;

        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoRequest];
        } else {
            // 当前网络不可用，请重新再试
            [self failViewCreate:CwTypeViewNoNetWork];
        }
        
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

// 数据请求成功
- (void)success:(NSMutableArray*)resultArray{
    
    NSLog(@"resultArray====%@",[resultArray objectAtIndex:0]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if ([[resultArray objectAtIndex:0] isEqual:@"cwRequestTimeout"]) {

            //服务器繁忙
            [self failViewCreate:CwTypeViewNoService];
            
            //loading图标移除
            [self.cloudLoading removeFromSuperview];
            _appTableView.hidden = YES;
        }else{
            [self.appItemArray addObjectsFromArray:[[resultArray objectAtIndex:0]objectForKey:@"recommends"]];
            [self.adsArray addObjectsFromArray:[[resultArray objectAtIndex:0]objectForKey:@"ads"]];
            appVer =[[resultArray objectAtIndex:0]objectForKey:@"app_ver"];
            adsVer =[[resultArray objectAtIndex:0]objectForKey:@"ad_ver"];
            
            
            NSLog(@"==%@resultArray==%@==%@==%@",appVer,resultArray,self.appItemArray,self.adsArray);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                //loading图标移除
                [self.cloudLoading removeFromSuperview];
                
                _appTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                
                [_appTableView reloadData];
                
                _nullView.hidden = NO;
                if ([self.appItemArray count]!=0 || [self.adsArray count]!=0) {
                    if (_nullView.superview!=NULL) {
                        [_nullView removeNullView];
                    }
                    _appTableView.hidden = NO;
                }else{
                    
                    _nullView=[[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_trophy_default.png"] andText:@"当前暂无应用推荐信息~"];
                    [self.view addSubview:_nullView];
                    _appTableView.hidden = YES;
                }
                
            });

            
        }
               
    });
    
}
// 更多请求成功
- (void)moreSuccess:(NSMutableArray*)resultArray{
    UILabel *label = (UILabel*)[_appTableView viewWithTag:200];
    if ([resultArray count]==0||[resultArray count]<20) {
        noMore = YES;
        label.text = @"没有更多了";
    }else{
        label.text = @"上拉加载更多";
        noMore = NO;
    }
    [indicatorView stopAnimating];
    
    _loadingMore = NO;
	
   
    NSLog(@"appItemArray=%@resultArray=%@",self.appItemArray,resultArray);
    
	for (int i = 0; i < [resultArray count];i++ )
	{
		NSDictionary *item = [resultArray objectAtIndex:i];
        NSLog(@"itemitem%@",item);
		[self.appItemArray addObject:item];
        
	}
    
    
    NSLog(@"resultArray=%@==%d=item==%d",resultArray,[resultArray count],[self.appItemArray count]);
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
    
    for (int ind = 0; ind < [resultArray count]; ind ++)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                [self.appItemArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_appTableView insertRowsAtIndexPaths:insertIndexPaths
                             withRowAnimation:UITableViewRowAnimationFade];

}
// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessService];
    
}

#pragma mark - private motheds
//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    //每次只下载一屏显示的单元格图片
	NSArray *visiblePaths = [_appTableView indexPathsForVisibleRows];
    
	for (NSIndexPath *indexPath in visiblePaths) {
		int countItems = [self.appItemArray count];
        NSLog(@"row==%d",[indexPath row]);
        
		if (countItems >[indexPath row]) {
            NSString *photoURL = [[self.appItemArray objectAtIndex:[indexPath row]] objectForKey:@"picture"];
            
			//获取本地图片缓存
			UIImage *cardIcon = [[[IconPictureProcess sharedPictureProcess] getPhoto:photoURL]fillSize:CGSizeMake(60, 60)];
			
			RecommendAppCell *cellApp = (RecommendAppCell *)[_appTableView cellForRowAtIndexPath:indexPath];
            
            //拖动或滚动table view时，图片不下载
			if (cardIcon == nil) {
				if (_appTableView.dragging == NO && _appTableView.decelerating == NO) {
					[[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
				}
			} else {
				cellApp.iconImageView.image = cardIcon;
			}
		}
	}
}



@end
