//
//  LikelistViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "CommentViewController.h"
#import "CommentShopCell.h"
#import "CommentMsgCell.h"
#import "Common.h"
#import "FileManager.h"
#import "NetworkFail.h"
#import "member_shopcomment_model.h"
#import "member_shopcommentPic_model.h"
#import "member_msgcomment_model.h"
#import "member_msgcommentPic_model.h"
#import "IconPictureProcess.h"
#import "ShopDetailsViewController.h"
#import "InformationDetailViewController.h"
#import "UIImageView+WebCache.h"

#define kcontrolHeight 44

@interface CommentViewController ()<NetworkFailDelegate>
{
    NetworkFail *failView;
}

@end

@implementation CommentViewController
@synthesize shopCommentArray = _shopCommentArray;
@synthesize msgCommentArray = _msgCommentArray;
@synthesize msgCommentDic = _msgCommentDic;

@synthesize cloudLoading;

#pragma mark - lifeCycle

static int clickNum=0;
static bool loadMore = YES;
static bool noMoreMsg = NO;

- (void)viewDidAppear:(BOOL)animated{
    clickNum = 0;
    noMoreMsg = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的评论";
    self.view.backgroundColor = KCWViewBgColor;
	
 
    _shopCommentArray = [[NSMutableArray alloc]init];
    _msgCommentArray = [[NSMutableArray alloc]init];

    
    picHeight=50.0f;
    picWidth =74.0f;
    
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    
    [self loadMainView];

    [self accessShopService];
    [self accessMsgService];
        
}
// 菜单创建
- (void)loadMainView{
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, kcontrolHeight)];
    _menuView.backgroundColor = [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [self.view addSubview:_menuView];
    
    _shopBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth/2-1, kcontrolHeight-6)];
    [_shopBtn setTitle:@"商 品" forState:UIControlStateNormal];
    [_shopBtn setTag:10];
    [_shopBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_shopBtn];
    
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(KUIScreenWidth/2-1, 8, 2, kcontrolHeight-18)];
    line.backgroundColor = [UIColor darkGrayColor];
    line.alpha = 0.3;
    [_menuView addSubview:line];
    RELEASE_SAFE(line);
    
    _messageBtn = [[UIButton alloc]initWithFrame:CGRectMake(KUIScreenWidth/2-1, 0, KUIScreenWidth/2, kcontrolHeight-6)];
    [_messageBtn setTitle:@"资 讯" forState:UIControlStateNormal];
    [_messageBtn setTag:11];
    [_messageBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
    [_messageBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_messageBtn];

    
    _lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kcontrolHeight-6, KUIScreenWidth/2-1, 5)];
    _lineLabel.backgroundColor = [UIColor colorWithRed:51/255.0 green:183/255.0 blue:229/255.0 alpha:1];
    [_menuView addSubview:_lineLabel];
    
}

- (void)createShopTableView{
    _shopTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kcontrolHeight, KUIScreenWidth, KUIScreenHeight-kcontrolHeight*2) style:UITableViewStylePlain];
    _shopTableView.dataSource = self;
    _shopTableView.delegate = self;
    _shopTableView.tag = 15;
    _shopTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _shopTableView.backgroundColor = KCWViewBgColor;
    [self.view addSubview:_shopTableView];
}

- (void)createMessageTableView{
    _messageTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kcontrolHeight, KUIScreenWidth, KUIScreenHeight-kcontrolHeight*2) style:UITableViewStylePlain];
    _messageTableView.backgroundColor = KCWViewBgColor;
    _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _messageTableView.dataSource = self;
    _messageTableView.delegate = self;
    _messageTableView.tag = 16;
    [self.view addSubview:_messageTableView];
    _messageTableView.hidden = YES;
}

//动态获取内容的高度
- (CGFloat)getTheHeight:(NSString *)contentStr
{
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = CGSizeMake(300,2000);
    CGSize labelsize = [contentStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    
    return labelsize.height;
}

//显示评论内容及表情
- (RTLabelComponentsStructure *)getFaceShow:(NSString *)str{
    NSString *str1 = @"<font size = 14>";
    NSString *str2 = @"</font>";
    NSString *str3 = @"<img src='";
    NSString *str4 = @".png'> ";

    str = [NSString stringWithFormat:@"%@%@%@",str1,str,str2];
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:str3];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:str4];
    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:str];
    
    return componentsDS;
}

// 时间显示格式化
- (NSString *)formatTime:(int)commentTimes{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:commentTimes];
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    [outputFormat setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSString *dateString = [outputFormat stringFromDate:date];
    RELEASE_SAFE(outputFormat);
    return dateString;
}

- (void)nullViewArray:(NSMutableArray *)arry{
    if ([arry count]==0) {
        if (_nullView.superview==nil) {
            [self.view addSubview:_nullView];
        }
    }else{
        if (_nullView.superview) {
            [_nullView removeNullView];
            
        }
    }
}

//菜单按钮切换
- (void)click:(UIButton *)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    switch (sender.tag) {
        case 10:
        {   _lineLabel.frame = CGRectMake(0, kcontrolHeight-6, KUIScreenWidth/2-1, 5);
            [_messageBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
            [_shopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            loadMore = YES;
            noMoreMsg = NO;
            _shopTableView.hidden = NO;
            _messageTableView.hidden = YES;
            
            [self nullViewArray:self.shopCommentArray];
            
        }
            break;
        case 11:
        {
            _lineLabel.frame = CGRectMake(KUIScreenWidth/2, kcontrolHeight-6, KUIScreenWidth/2-1, 5);
            [_messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_shopBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
            
    
            if (clickNum==0) {
//                [self accessMsgService];
            }
            clickNum++;
    
            loadMore = NO;
            noMoreMsg = NO;
            _shopTableView.hidden = YES;
            _messageTableView.hidden = NO;
            
            [self nullViewArray:self.msgCommentArray];

        }
            break;
        default:
            break;
    }
    [UIView commitAnimations];
}
- (void)dealloc
{
    RELEASE_SAFE(_messageTableView);
    RELEASE_SAFE(_shopTableView);
    RELEASE_SAFE(_menuView);
    RELEASE_SAFE(_shopBtn);
    RELEASE_SAFE(_messageBtn);
    RELEASE_SAFE(_lineLabel);
    RELEASE_SAFE(_shopCommentArray);
    RELEASE_SAFE(_msgCommentArray);
    RELEASE_SAFE(_nullView);
    if (failView) {
        RELEASE_SAFE(failView);
    }
    [super dealloc];
}

-(void)viewDidUnload
{
    // Release any retained subviews of the main view.不包含self.view
    //ios3.0-ios5.0版本调用 处理一些内存和资源问题。
    [super viewDidUnload];
    self.msgCommentArray=nil;
    self.shopCommentArray=nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"内存不足了");
    
 
    // ios6.0调用屏蔽了viewDidUnload
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
        if (self.isViewLoaded && self.view.window == nil)// 是否是正在使用的视图
        {
            // Add code to preserve data stored in the views that might be
            // needed later.
            
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        }
     
        self.shopCommentArray=nil;
        self.msgCommentArray=nil;
        
    }
    
}
// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessShopService];
    [self accessMsgService];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case 15:{
            if ([self.shopCommentArray count]!=0 && section == 0) {
                return [self.shopCommentArray count];
            }else{
                return 0;
            }
        }
            break;
        case 16:
        {
            if ([self.msgCommentArray count]!=0 && section == 0) {
                return [self.msgCommentArray count];
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
            static NSString *CellIdentifier = @"shopCell";
            CommentShopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[CommentShopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            if ([self.shopCommentArray count]!=0) {
                NSDictionary *dic = [self.shopCommentArray objectAtIndex:indexPath.row];
                
                int commentTimes = [[dic objectForKey:@"comment_created"] intValue];
                                
                cell.commentTime.text = [self formatTime:commentTimes];
            
                CGFloat contentFloat = [self getTheHeight:[dic objectForKey:@"comment_content"]];
                //显示评论内容及表情
                cell.rtLabel.componentsAndPlainText = [self getFaceShow:[dic objectForKey:@"comment_content"]];
               
                cell.rtLabel.frame = CGRectMake(5, 25, 280, contentFloat+5);

                cell.cellView.frame = CGRectMake(10, 10, 300, 110+contentFloat);
                cell.lineView.frame = CGRectMake(0, 30+contentFloat, 300, 2);
                cell.typeNum.frame = CGRectMake(0, 35+contentFloat, 83, 16);
                cell.shopImage.frame = CGRectMake(10, 55+contentFloat, 74, picHeight);
                cell.shopAbout.frame = CGRectMake(90, 50+contentFloat, 205, 40);
                
                cell.typeNum.text = [dic objectForKey:@"name"];
                
                if ([dic objectForKey:@"content"] == [NSNull null]) {
                
                    cell.shopAbout.text=nil;
                }else{
                    cell.shopAbout.text=[dic objectForKey:@"content"];
                }
                //图片
                NSString *picUrl = [dic objectForKey:@"image"];
                
                [cell.shopImage setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageCwNamed:@"default_70x53.png"]];
                
            }
            
            return cell;
        }
            break;
        case 16:
        {
            static NSString *CellIdentifier = @"messageCell";
            CommentMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[CommentMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            if ([self.msgCommentArray count]!=0) {
                NSDictionary *dic=[self.msgCommentArray objectAtIndex:indexPath.row];
                int commentTimes = [[dic objectForKey:@"comment_created"] intValue];

                cell.commentTime.text= [self formatTime:commentTimes];
                
                cell.content.text=[dic objectForKey:@"comment"];
                cell.shopAbout.text=[dic objectForKey:@"content"];
                cell.shopName.text=[dic objectForKey:@"title"];
                
                CGFloat contentMsgFloat = [self getTheHeight:[dic objectForKey:@"comment"]];
                
                //显示评论内容及表情
                cell.rtLabel.componentsAndPlainText = [self getFaceShow:[dic objectForKey:@"comment"]];
               
                
                cell.rtLabel.frame =  CGRectMake(5, 25, 280, contentMsgFloat+5);
                cell.cellView.frame = CGRectMake(10, 10, 300, 100+contentMsgFloat);
                cell.lineView.frame = CGRectMake(0, 28+contentMsgFloat, 300, 2);
                cell.shopImage.frame = CGRectMake(10, 38+contentMsgFloat, 74, 53);
                cell.shopName.frame = CGRectMake(90, 35+contentMsgFloat, 180, 20);
                cell.shopAbout.frame = CGRectMake(90, 50+contentMsgFloat, 205, 40);

                //图片
                NSString *picUrl = [dic objectForKey:@"image"];
                
                [cell.shopImage setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageCwNamed:@"default_70x53.png"]];
            
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (tableView.tag) {
        case 15:{
            NSDictionary *dic = [self.shopCommentArray objectAtIndex:indexPath.row];
            
            ShopDetailsViewController *shopDetail = [[ShopDetailsViewController alloc]init];
            shopDetail.cwStatusType = StatusTypeMemberShop;
            shopDetail.productID = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"product_id"] intValue]];
            [self.navigationController pushViewController:shopDetail animated:YES];
            RELEASE_SAFE(shopDetail);
            
        }
            break;
        case 16:{
            
            InformationDetailViewController *infoDetail = [[InformationDetailViewController alloc]init];
            NSLog(@"msgCommentArray=========%@",self.msgCommentArray);
            infoDetail.dataArr = self.msgCommentArray;
            infoDetail.indexValue = indexPath.row;
            [self.navigationController pushViewController:infoDetail animated:YES];
            RELEASE_SAFE(infoDetail);
        }
            break;
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    if (section == 1) {
        UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 320, 30)];
        if (noMoreMsg) {
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
    switch (tableView.tag) {
        case 15:
        {
            if (section == 1 && self.shopCommentArray.count >= 20) {
                return 40;
            }else {
                return 0;
            }
        }
            break;
        case 16:
        {
            if (section == 1 && self.msgCommentArray.count >= 20) {
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
        {
            CommentShopCell *cell = (CommentShopCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            return cell.rtLabel.frame.size.height+120.0f;

        }   break;
        case 16:
        {
            CommentMsgCell *cell = (CommentMsgCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            return cell.rtLabel.frame.size.height+110.0f;

        }
            break;
            
        default:
            break;
    }
    return 0.f;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ((_isAllowLoadingMore && !_loadingMore && [self.shopCommentArray count] > 0)||(_isAllowLoadingMore && !_loadingMore && [self.msgCommentArray count] > 0))
    {
        UILabel *label = (UILabel*)[_shopTableView viewWithTag:200];
        UILabel *label2 = (UILabel*)[_messageTableView viewWithTag:200];
        
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height + 5.0f)
        {
            //松开 载入更多
            label.text=@"松开加载更多";
            label2.text=@"松开加载更多";
        }
        else
        {
            if (noMoreMsg) {
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
        if (bottomEdge > scrollView.contentSize.height + 5.0f)
        {
            //松开 载入更多
            _loadingMore = YES;
            if (loadMore) {
                label.text = @" 加载中...";
                [self accessShopMoreService];
            }else{
                label2.text = @" 加载中...";
                [self accessMsgMoreService];
            }
            
            [indicatorView startAnimating];
            
        }
        else
        {
            if (noMoreMsg) {
                label.text = @"没有更多了";
                label2.text = @"没有更多了";
            }else{
                label.text = @"上拉加载更多";
                label2.text = @"上拉加载更多";
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if ((bottomEdge >= scrollView.contentSize.height && bottomEdge > _shopTableView.frame.size.height && [self.shopCommentArray count] >= 20)||(bottomEdge >= scrollView.contentSize.height && bottomEdge > _messageTableView.frame.size.height && [self.msgCommentArray count] >= 20))
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
}


#pragma mark - accessService

- (void)accessShopService{

    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(KUIScreenWidth / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    //我的商品评论数据请求
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                    @"1",@"comment_type",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic
                                        data:nil
                                     command:MEMBER_SHOPCOMMEND_COMMAND_ID
                                accessAdress:@"member/memberscomment.do?param="
                                    delegate:self
                                   withParam:nil];
    
    
}

- (void)accessMsgService{
    //我的资讯评论数据请求
    NSMutableDictionary *jsontestDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [Global sharedGlobal].user_id,@"user_id",
                                                                     @"2",@"comment_type",
                                                                                     nil];
	
	[[NetManager sharedManager]accessService:jsontestDic2
                                        data:nil
                                     command:MEMBER_MSGCOMMEND_COMMAND_ID
                                accessAdress:@"member/memberscomment.do?param="
                                    delegate:self
                                   withParam:nil];

    
}
- (void)accessShopMoreService{
    
    NSString *created1 = [[self.shopCommentArray objectAtIndex:[self.shopCommentArray count] - 1] objectForKey:@"comment_created"];
    
    //我的商品评论数据加载更多请求
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                    @"1",@"comment_type",
                                                                     created1,@"created",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic
                                        data:nil command:MEMBER_SHOPCOMMEND_MORE_COMMAND_ID
                                accessAdress:@"member/memberscomment.do?param="
                                    delegate:self
                                   withParam:nil];
    
     
}

- (void)accessMsgMoreService{
    
    NSString *created2 = [[self.msgCommentArray objectAtIndex:[self.msgCommentArray count] - 1] objectForKey:@"comment_created"];
    //我的资讯评论数据加载更多请求
    NSMutableDictionary *jsontestDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [Global sharedGlobal].user_id,@"user_id",
                                                                     @"2",@"comment_type",
                                                                      created2,@"created",
                                                                                     nil];
	
	[[NetManager sharedManager]accessService:jsontestDic2
                                        data:nil
                                     command:MEMBER_MSGCOMMEND_MORE_COMMAND_ID
                                accessAdress:@"member/memberscomment.do?param="
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
	NSLog(@"information finish");
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        switch (commandid) {
                
            case MEMBER_SHOPCOMMEND_COMMAND_ID:
            {
                
                [self performSelector:@selector(shopSuccess:) withObject:resultArray];
                
            }break;
                
            case MEMBER_MSGCOMMEND_COMMAND_ID:
            {
                [self performSelector:@selector(msgSuccess:) withObject:resultArray];
                
            }break;
                
            case MEMBER_SHOPCOMMEND_MORE_COMMAND_ID:
            {
                [self performSelector:@selector(shopMoreSuccess:) withObject:resultArray];
                
            }break;
            case MEMBER_MSGCOMMEND_MORE_COMMAND_ID:
            {
                [self performSelector:@selector(msgMoreSuccess:) withObject:resultArray];
                
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
        
    }

}

- (void)shopSuccess:(NSMutableArray*)resultArray{
    
    _nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_comment_default.png"] andText:@"您还没有评论哦~"];
    
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    _nullView.hidden = NO;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
            [_shopCommentArray addObjectsFromArray:resultArray];
            NSLog(@"shopshop=%@",self.shopCommentArray);
        
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.shopCommentArray count]!=0) {
                    [self createShopTableView];
                }else{
                    if (_nullView.superview==nil) {
                        [self.view addSubview:_nullView];
                    }
                    _shopTableView.hidden = YES;
                    
                }
                
               [_shopTableView reloadData];
                
            });
            
//    });

	NSLog(@"db read success!shopCommentArray=%d",[self.shopCommentArray count]);
}

- (void)msgSuccess:(NSMutableArray*)resultArray{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [_msgCommentArray addObjectsFromArray:resultArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([resultArray count]!=0) {
                for (int i = 0; i < [resultArray count]; i ++) {
                    NSMutableDictionary *dic = [resultArray objectAtIndex:i];
                    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [dic objectForKey:@"comment_id"],@"comment_id",
                                           [dic objectForKey:@"comment_created"],@"comment_created",
                                           [dic objectForKey:@"comment"],@"comment",
                                           [dic objectForKey:@" user_name"],@"user_name",
                                           [dic objectForKey:@"new_id"],@"new_id",
                                           [dic objectForKey:@"image"],@"image",
                                           [dic objectForKey:@"title"],@"title",
                                           [dic objectForKey:@"content"],@"content",
                                           [dic objectForKey:@"comment_sum"],@"comment_sum",
                                           [dic objectForKey:@"recommend"],@"recommend",
                                           [dic objectForKey:@"pics"],@"pics",
                                           [dic objectForKey:@"news_created"],@"created",
                                           nil];
                    [self.msgCommentArray addObject:dict2];
                }
                
                NSLog(@"_msgCommentArray=%@",self.msgCommentArray);
                [self createMessageTableView];
                
            }else{
                
                _messageTableView.hidden=YES;
            }

             [_messageTableView reloadData];
            
        });
    });
    

   
    
}

- (void)shopMoreSuccess:(NSMutableArray*)resultArray{
    UILabel *label = (UILabel*)[_shopTableView viewWithTag:200];
    if ([resultArray count]==0||[resultArray count]<20) {
        noMoreMsg = YES;
        label.text = @"没有更多了";
    }else{
        label.text = @"上拉加载更多";
        noMoreMsg = NO;
    }
	[indicatorView stopAnimating];
    
    
    NSLog(@"=%d=resultArray=%@",[resultArray count],resultArray);
    _loadingMore = NO;
	
    [_shopCommentArray addObjectsFromArray:resultArray];
    
	NSLog(@"shopCommentArray========%@==-%d",self.shopCommentArray,[self.shopCommentArray count]);
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
    for (int ind = 0; ind < [resultArray count]; ind ++)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                [self.shopCommentArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_shopTableView insertRowsAtIndexPaths:insertIndexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)msgMoreSuccess:(NSMutableArray*)resultArray{
    UILabel *label = (UILabel*)[_messageTableView viewWithTag:200];
    if ([resultArray count]==0||[resultArray count]<20) {
        noMoreMsg = YES;
        label.text = @"没有更多了";
    }else{
        label.text = @"上拉加载更多";
        noMoreMsg = NO;
    }
	[indicatorView stopAnimating];
    
    
    [_msgCommentArray addObjectsFromArray:resultArray];
    
    _loadingMore = NO;
	
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
    for (int ind = 0; ind < [resultArray count]; ind ++)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                [self.msgCommentArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_messageTableView insertRowsAtIndexPaths:insertIndexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
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
            
            UIImage *photo = iconDownloader.cardIcon;
            
            CommentMsgCell *cell = (CommentMsgCell *)[_messageTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell.shopImage.image = photo;

		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - private motheds
//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    if (loadMore) {
        //每次只下载一屏显示的单元格图片
        NSArray *visiblePaths = [_shopTableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            int countItems = [self.shopCommentArray count];
            if (countItems >[indexPath row]) {
                NSString *photoURL = [[self.shopCommentArray objectAtIndex:[indexPath row]] objectForKey:@"image"];
                
                //获取本地图片缓存
                UIImage *cardIcon = [[IconPictureProcess sharedPictureProcess] getPhoto:photoURL];
                
                CommentShopCell *cell = (CommentShopCell *)[_shopTableView cellForRowAtIndexPath:indexPath];
                
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
    }else{
        //每次只下载一屏显示的单元格图片
        NSArray *visiblePaths = [_messageTableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            int countItems = [self.msgCommentArray count];
            if (countItems >[indexPath row]) {
                NSString *photoURL = [[self.msgCommentArray objectAtIndex:[indexPath row]] objectForKey:@"image"];
                
                //获取本地图片缓存
                UIImage *cardIcon = [[IconPictureProcess sharedPictureProcess] getPhoto:photoURL];
                
                CommentMsgCell *cell = (CommentMsgCell *)[_messageTableView cellForRowAtIndexPath:indexPath];
                
                //拖动或滚动table view时，图片不下载
                if (cardIcon == nil) {
                    if (_messageTableView.dragging == NO && _messageTableView.decelerating == NO) {
                        [[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
                    }
                } else {
                    cell.shopImage.image = cardIcon;
                }
            }
        }
    }
}

@end