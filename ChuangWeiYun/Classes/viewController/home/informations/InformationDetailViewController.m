//
//  InformationDetailViewController.m
//  cw
//
//  Created by LuoHui on 13-8-29.
//
//

#import "InformationDetailViewController.h"
#import "PopShareView.h"
#import "WeiboView.h"
#import "Common.h"
#import "Global.h"
#import "member_likeinformation_model.h"
#import "PopGuideView.h"
#import "PopLikeView.h"
#import "member_info_model.h"
#import "apns_model.h"
#import "FileManager.h"
#import "PfShare.h"
#import "NetworkFail.h"
#import "news_log_model.h"
#import "VideoWebViewController.h"

@interface InformationDetailViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
    MediaPopView *mediaPopView;
    BOOL shareFlag;
    BOOL islikes;
    BOOL _isNavHide;
}
@property (retain, nonatomic) WeiboView *commentView;
@end

@implementation InformationDetailViewController
@synthesize scrollViewC = _scrollViewC;
@synthesize downBarView = _downBarView;
@synthesize dataArr;
@synthesize commentView;
@synthesize indexValue;
@synthesize inforId;
@synthesize cloudLoading;
@synthesize cwStatusType;
@synthesize delegate;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        dataArr = [[NSMutableArray alloc] init];
//    }
//    return self;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        _isNavHide = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        _isNavHide = NO;
    }
    
    if (loginBack == LoginBackCommentBack) {
        loginBack = LoginBackNomal;
        
        WeiboView *weiboShare = [[WeiboView alloc]initWithString:@""];
        weiboShare.navController = self.navigationController;
        weiboShare.delegate = self;
        self.commentView = weiboShare;
        [weiboShare release];
        [self.commentView showWeiboView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_isNavHide) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    // 12.4chenfeng
    if (islikes) {
        NSNumber *selectRow = [NSNumber numberWithInt:indexValue];
        if ([delegate respondsToSelector:@selector(isInformationDellikeSelectRow:)] && delegate) {
            [delegate performSelector:@selector(isInformationDellikeSelectRow:)withObject:selectRow];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"资讯详情";
    self.view.backgroundColor = [UIColor colorWithRed:0.9333 green:0.9333 blue:0.9333 alpha:1.0];
    
    [self dataLoad];
}

- (void)dataLoad
{
    if ([self.dataArr count] == 0 && inforId != nil) {
        [self accessItemService:[inforId intValue]];
    }else {
        [self addView];

        [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
    }
}

- (void)addView
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    int height;
     if (self.cwStatusType != StatusTypeMemberInformation) {
         height = KUIScreenHeight - KUpBarHeight - KDownBarHeight;
     }else {
         height = KUIScreenHeight - KUpBarHeight;
     }
    
    _scrollViewC = [[UITableScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, height) clickIndex:indexValue pages:1];
    _scrollViewC.bounces = YES;
    _scrollViewC.pagingEnabled = YES;
    _scrollViewC.dataSource = self;
    _scrollViewC.userInteractionEnabled = YES;
    _scrollViewC.showsHorizontalScrollIndicator = NO;
    _scrollViewC.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollViewC];
    
    if (self.cwStatusType != StatusTypeMemberInformation) {
        _downBarView = [[DetailViewDownBar alloc]initWithFrame:CGRectMake(0.f, KUIScreenHeight-KDownBarHeight-KUpBarHeight, KUIScreenWidth, KDownBarHeight) type:SDButtonStateInfo];
        _downBarView.delegate = self;
        [self.view addSubview:_downBarView];
        
        member_likeinformation_model *acModel = [[member_likeinformation_model alloc] init];
        acModel.where = [NSString stringWithFormat:@"news_id = %@",[[self.dataArr objectAtIndex:indexValue] objectForKey:@"new_id"]];
        NSArray *dbArr = [acModel getList];
        
        if ([Global sharedGlobal].isLogin == YES && [dbArr count] > 0) {
            _isLike = YES;
            
            [_downBarView setLikeBtnImageState:SDImageStateSure];
        }else {
            _isLike = NO;
            
            [_downBarView setLikeBtnImageState:SDImageStateCanel];
        }
        acModel.where = nil;
        [acModel release];
    }

    UIImage *shareImg = [UIImage imageCwNamed:@"share.png"];
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(0.0f, 0.0f, shareImg.size.width, shareImg.size.height);
    [shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setBackgroundImage:shareImg forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage imageCwNamed:@"share_click.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];
    
    UIImage *image = [[UIImage alloc ]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return" ofType:@"png"]];
    UIButton *barbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    barbutton.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    if (IOS_7) {//chenfeng2014.2.9 add
        barbutton.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
    }
    
    [barbutton addTarget:self action:@selector(popNavigation) forControlEvents:UIControlEventTouchUpInside];
    [barbutton setImage:image forState:UIControlStateNormal];
    UIImage *img = [[UIImage alloc ]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return_click" ofType:@"png"]];
    [barbutton setImage:img forState:UIControlStateHighlighted];
    [image release], image = nil;
    [img release], img = nil;
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:barbutton];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    [barBtnItem release], barBtnItem = nil;
    
    if (![PopGuideView isInsertTable:Guide_Enum_Info]) {
        UIImage *img = nil;
        if (KUIScreenHeight > 500) {
            img = [UIImage imageCwNamed:@"infordetail_guide2.png"];
        } else {
            img = [UIImage imageCwNamed:@"infordetail_guide.png"];
        }
        PopGuideView *popGuideView = [[PopGuideView alloc]initWithImage:img index:Guide_Enum_Info];
        [popGuideView addPopupSubview];
        [popGuideView release], popGuideView = nil;
    }
    
    [pool release];
}

- (void)dealloc
{
    NSLog(@"informationdetailView dealloc.....");
    [_scrollViewC release],_scrollViewC = nil;
    [_downBarView release],_downBarView = nil;
    [dataArr release],dataArr = nil;
    [inforId release],inforId = nil;
    [cloudLoading release],cloudLoading = nil;
    if (failView) {
        [failView release], failView = nil;
    }
    if (mediaPopView) {
        [mediaPopView release], mediaPopView = nil;
    }
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableScrollViewDelagate
- (NSInteger)tableScrollViewNumberOfRow:(UITableScrollView *)tableScrollView
{
    return [self.dataArr count];
}

- (UITableScrollViewCell *)tableScrollView:(UITableScrollView *)tableScrollView viewForRowAtIndex:(NSInteger)index
{
    InformationDetailView *cell = [tableScrollView dequeueRecycledPage];
    if (cell == nil) {
        
        cell = [[[InformationDetailView alloc] initWithFrame:self.view.bounds] autorelease];
        
        if (self.cwStatusType != StatusTypeMemberInformation) {
            [cell createView:From_Enum_List];
        }else {
            [cell createView:From_Enum_Member];
        }
    }
    
    cell.delegate = self;
    
    NSMutableDictionary *dict = [self.dataArr objectAtIndex:index];
    [cell tableViewReloadData:dict type:0];
    
    
    return cell;
}

- (void)tableScrollView:(UITableScrollView *)tableScrollView didSelectRowAtIndex:(NSInteger)index beforeIndex:(NSInteger)aindex
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    for (id cell in _scrollViewC.subviews) {
        if ([cell isKindOfClass:[InformationDetailView class]]) {
            if (((InformationDetailView *)cell).index == aindex) {
                [cell tableViewReloadData:nil type:1];
            }
        }
    }
    
    indexValue = index;
    
    member_likeinformation_model *acModel = [[member_likeinformation_model alloc] init];
    NSDictionary *allDict = [self.dataArr objectAtIndex:indexValue];
    acModel.where = [NSString stringWithFormat:@"news_id = %d",[[allDict objectForKey:@"new_id"] intValue]];
    NSArray *dbArr = [acModel getList];
    
    if ([Global sharedGlobal].isLogin == YES && [dbArr count] > 0) {
        _isLike = YES;
        
        [_downBarView setLikeBtnImageState:SDImageStateSure];
    }else {
        _isLike = NO;
        
        [_downBarView setLikeBtnImageState:SDImageStateCanel];
    }
    acModel.where = nil;
    [acModel release];
    
    [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
}

#pragma mark - InformationViewDelegate
- (void)InformationView:(InformationDetailView *)infoView
{
    for (id cell in _scrollViewC.subviews) {
        if ([cell isKindOfClass:[InformationDetailView class]]) {
            if (((InformationDetailView *)cell).index == indexValue) {
                [cell tableViewReloadData:nil type:2];
            }
        }
    }
    if (mediaPopView == nil) {
        mediaPopView = [[MediaPopView alloc]init];
        mediaPopView.delegate = self;
    }
    
    NSArray *arr = [[self.dataArr objectAtIndex:indexValue] objectForKey:@"media"];
//    mediaPopView.mediaPopViewBlock = ^ {
//        [mediaPopView release], mediaPopView = nil;
//    };
    //[mediaPopView addPopupSubviews:self.navigationController.view media:arr];
    [mediaPopView addPopupSubviews:arr];
}

#pragma mark - MediaPopViewDelegate
- (void)mediaPopView:(MediaPopView *)view Index:(int)tag
{
    NSArray *arr = [[self.dataArr objectAtIndex:indexValue] objectForKey:@"media"];
     NSLog(@"%@",arr);
    VideoWebViewController *videoView = [[VideoWebViewController alloc]init];
    NSDictionary *mediaDict = [arr objectAtIndex:tag];
    NSString *url = nil;
    if ([[mediaDict objectForKey:@"is_web"]intValue] == 0) {
        videoView.webType = WebViewLocVideo;
//        url = [mediaDict objectForKey:@"video"];
    } else {
        videoView.webType = WebViewNetVideo;
        
        NSString *urlStr = [mediaDict objectForKey:@"video"];
       
        NSArray *arrstr = [urlStr componentsSeparatedByString:@" "];
        if (arrstr.count > 0) {
            NSString *heights = [arrstr objectAtIndex:1];
            NSString *widths = [arrstr objectAtIndex:2];
            CGFloat height = [[heights substringFromIndex:7] floatValue];
            CGFloat width = [[widths substringFromIndex:6] floatValue];
            videoView.webSize = CGSizeMake(width, height);
        }
    }
    url = [mediaDict objectForKey:@"url"];
    NSLog(@"%@",url);
    videoView.urlStr = url;
    videoView.title = [[self.dataArr objectAtIndex:indexValue] objectForKey:@"title"];
    [self.navigationController pushViewController:videoView animated:YES];
    [videoView release], videoView = nil;
}

#pragma mark --- LoginViewDelegate
#pragma makr - loginSuccessBackCtl
- (void)loginSuccessBackCtl:(LoginBack)cwBackType
{
    loginBack = cwBackType;
}

- (void)loginWithResult:(BOOL)isLoginSuccess
{
}

#pragma mark - DetailViewDownBarDelegate
- (void)detailDownBarEvent:(SDButtonDB)sdButton
{
    switch (sdButton) {
        case SDButtonDBCommets:
        {
            if ([Global sharedGlobal].isLogin == YES) {
                WeiboView *weiboShare = [[WeiboView alloc]initWithString:@""];
                weiboShare.navController = self.navigationController;
                weiboShare.delegate = self;
                self.commentView = weiboShare;
                [weiboShare release];
                [self.commentView showWeiboView];
            }else {
                LoginViewController *login = [[LoginViewController alloc] init];
                login.delegate = self;
                login.cwStatusType = StatusTypeMemberLogin;
                login.cwBackType = LoginBackCommentBack;
                [self.navigationController pushViewController:login animated:YES];
                [login release];
            }
        }
            break;
        case SDButtonDBOrder:
        {
        }
            break;
        case SDButtonDBLike:
            // 喜欢
            [self accessItemLikeService];
            break;
        default:
            break;
    }
}

#pragma mark - WeiboViewDelegate
- (void)weiboViewSendComment:(NSString *)text
{
    // 评论
    [self accessCommentService:text];
}

#pragma mark - ShareAPIActionDelegate
- (NSDictionary *)shareApiActionReturnValue
{
    NSDictionary *allDict = [self.dataArr objectAtIndex:indexValue];
    
    [Global sharedGlobal].countObj_id = [NSString stringWithFormat:@"%d",[[allDict objectForKey:@"new_id"] intValue]];
    [Global sharedGlobal]._countType = CountTypeNew;
    
    NSString *shareUrl;
    apns_model *aMod = [[apns_model alloc] init];
    NSMutableArray *dbArray = [aMod getList];
    [aMod release];
    
    if ([dbArray count] > 0) {
        NSDictionary *dic = [dbArray objectAtIndex:0];
        shareUrl = [dic objectForKey:@"client_downurl"];
    }else{
        shareUrl = @"";
    }
    
    NSString *title = [allDict objectForKey:@"title"];
    NSString *content = [NSString stringWithFormat:@"【%@】，%@ （分享自@创维云GO）",title,shareUrl];
    
    NSString *picUrl = [allDict objectForKey:@"picture"];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    UIImage *pic = [FileManager getPhoto:picName];
    
    UIImage *shareImg;
    if (pic.size.width > 2)
    {
        shareImg = pic;
    }else{
        shareImg = [UIImage imageCwNamed:@"default_60x60.png"];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          content, ShareContent,
                          shareUrl, ShareUrl,
                          title, ShareTitle,
                          shareImg, ShareImage, nil];
    
    return dict;
}

#pragma mark --- private
- (void)shareAction
{
    if (!shareFlag) {
        [PfShare defaultSingle].getPf = Share_Get_Pf_Info;
        [PfShare defaultSingle].share_gift = 0;
        [[PopShareView defaultExample] showPopupView:self.navigationController delegate:self];
    }
}

- (void)popNavigation
{
    for (id cell in _scrollViewC.subviews) {
        if ([cell isKindOfClass:[InformationDetailView class]]) {
            if (((InformationDetailView *)cell).index == indexValue) {
                [cell tableViewReloadData:nil type:1];
                [cell tableViewReloadData:nil type:3];
            } else {
                [cell tableViewReloadData:nil type:3];
            }
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

//网络获取数据
-(void)accessItemService:(int)infoId
{
    shareFlag = YES;
    
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    NSString *reqUrl = @"newdetail.do?param=";
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:infoId],@"info_id",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:INFOR_DETAIL_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

// 网络请求喜欢
- (void)accessItemLikeService
{
    NSString *userid = [Global sharedGlobal].user_id;
    NSDictionary *allDict = [self.dataArr objectAtIndex:indexValue];
    
    if (_isLike == NO) {
        NSString *reqUrl = @"member/like.do?param=";
        
        NSString *shopId = nil;
        if ([Global sharedGlobal].shop_id == nil) {
            shopId = @"0";
        }else {
            shopId = [Global sharedGlobal].shop_id;
        }
        
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           shopId,@"shop_id",
                                           [NSNumber numberWithInt:[userid intValue]],@"user_id",
                                           @"2",@"like_type",
                                           [allDict objectForKey:@"new_id"],@"relation_id",nil];
        //NSLog(@"requestDic === %@",requestDic);
        [[NetManager sharedManager]accessService:requestDic
                                            data:nil
                                         command:LIKE_COMMAND_ID
                                    accessAdress:reqUrl
                                        delegate:self
                                       withParam:nil];
        islikes = 0;
    }else{
        NSString *reqUrl = @"member/dellike.do?param=";
        
        int _id = [[allDict objectForKey:@"new_id"] intValue];
        
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:_id],@"relation_id",
                                          [NSNumber numberWithInt:[userid intValue]],@"user_id",
                                           @"2",@"type",nil];
        
        [[NetManager sharedManager]accessService:requestDic
                                            data:nil
                                         command:CANCEL_LIKE_COMMAND_ID
                                    accessAdress:reqUrl
                                        delegate:self
                                       withParam:nil];
        islikes = 1;
    }
}

// 网络请求评论
- (void)accessCommentService:(NSString *)str
{
    NSString *userid = [Global sharedGlobal].user_id;
    
    NSString *shopId = nil;
    if ([Global sharedGlobal].shop_id == nil || [Global sharedGlobal].shop_id.length == 0) {
        shopId = @"0";
    }else {
        shopId = [Global sharedGlobal].shop_id;
    }
    
    NSString *reqUrl = @"member/comment.do?param=";
	
    NSDictionary *dict = [self.dataArr objectAtIndex:indexValue];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shopId   ,@"shop_id",
                                       @"2"     ,@"type",
                                       [NSNumber numberWithInt:[userid intValue]],@"user_id",
                                       [NSString stringWithFormat:@"%d",[[dict objectForKey:@"new_id"] intValue]],@"info_id",
                                       str,@"content",nil];
    
    //NSLog(@"== %@",requestDic);
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:COMMENT_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch (commandid) {
        case INFOR_DETAIL_COMMAND_ID:
        {
            [self update:resultArray];
        }
            break;
        case LIKE_COMMAND_ID:
        {
            [self likeResult:resultArray];
        }
            break;
        case CANCEL_LIKE_COMMAND_ID:
        {
            [self cancelLikeResult:resultArray];
        }
            break;
        case COMMENT_COMMAND_ID:
        {
            [self commentResult:resultArray];
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
    
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]){
            _downBarView.hidden = YES;
            _scrollViewC.hidden = YES;
            
            shareFlag = YES;
            // 服务器繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoService];
        }else {
            shareFlag = NO;
            
            [self.dataArr removeAllObjects];
            self.dataArr = resultArray;
            
            indexValue = 0;
            
            [self addView];
            
            [_scrollViewC reloadView];
            
            [Common countObject:[Global sharedGlobal].shop_id withType:CountTypeShop];
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
}

- (void)likeResult:(NSMutableArray*)resultArray
{
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
            [self progressHUD:CwRequestTip withImgName:@"icon_tip_normal.png"];
        }else {
            int ret = [[resultArray objectAtIndex:0] intValue];
            if (ret == 1) {
                _isLike = YES;
                [_downBarView setLikeBtnImageState:SDImageStateSure];
                
                PopLikeView *poplike = [[PopLikeView alloc]init];
                [poplike addPopupSubviewType:PopLikeEnumAdd];
                [poplike release];
                
                if ([Global sharedGlobal].isLogin == YES) {
                    //更新会员赞的资讯id表
                    NSDictionary *allDict = [self.dataArr objectAtIndex:indexValue];
                    
                    member_likeinformation_model *acModel = [[member_likeinformation_model alloc] init];
                    acModel.where = [NSString stringWithFormat:@"news_id = %@",[allDict objectForKey:@"new_id"]];
                    NSArray *dbArr = [acModel getList];
                    
                    NSString *userid = [Global sharedGlobal].user_id;
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          userid,@"userId",
                                          [NSNumber numberWithInt:[[allDict objectForKey:@"new_id"] intValue]],@"news_id",nil];
                    if ([dbArr count] > 0) {
                        [acModel updateDB:dict];
                    } else {
                        [acModel insertDB:dict];
                    }
                    acModel.where = nil;
                    [acModel release];
                    
                    //更新会员信息表赞的总数
                    member_info_model *miModel = [[member_info_model alloc] init];
                    miModel.where = [NSString stringWithFormat:@"id = %@",[Global sharedGlobal].user_id];
                    NSArray *dbArray = [miModel getList];
                    int likeCount = [[[dbArray objectAtIndex:0] objectForKey:@"countlikes"] intValue];
                    
                    NSDictionary *auditDic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",likeCount + 1],@"countlikes", nil];
                    
                    [miModel updateDB:auditDic];
                    [miModel release];
                    
                }
            }else {
                _isLike = NO;
                [_downBarView setLikeBtnImageState:SDImageStateCanel];
            }
        }
    }else {
        [self progressHUD:@"网络不好,请求失败" withImgName:@"icon_tip_normal.png"];
    }
}

- (void)cancelLikeResult:(NSMutableArray*)resultArray
{
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
            [self progressHUD:CwRequestTip withImgName:@"icon_tip_normal.png"];
        }else {
            int ret = [[resultArray objectAtIndex:0] intValue];
            if (ret == 1) {
                _isLike = NO;
                [_downBarView setLikeBtnImageState:SDImageStateCanel];
                
                PopLikeView *poplike = [[PopLikeView alloc]init];
                [poplike addPopupSubviewType:PopLikeEnumMinusAdd];
                [poplike release];
                
                if ([Global sharedGlobal].isLogin == YES) {
                    //更新会员赞的资讯id表
                    member_likeinformation_model *acModel = [[member_likeinformation_model alloc] init];
                    acModel.where = [NSString stringWithFormat:@"news_id = %@",[[self.dataArr objectAtIndex:indexValue] objectForKey:@"new_id"]];
                    NSArray *dbArr = [acModel getList];
                    
                    if ([dbArr count] > 0) {
                        [acModel deleteDBdata];
                    }
                    acModel.where = nil;
                    [acModel release];
                    
                    //更新会员信息表赞的总数
                    member_info_model *miModel = [[member_info_model alloc] init];
                    miModel.where = [NSString stringWithFormat:@"id = %@",[Global sharedGlobal].user_id];
                    NSArray *dbArray = [miModel getList];
                    int likeCount = [[[dbArray objectAtIndex:0] objectForKey:@"countlikes"] intValue];
                    
                    NSDictionary *auditDic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",likeCount - 1],@"countlikes", nil];
                    
                    [miModel updateDB:auditDic];
                    [miModel release];
                }
            }else {
                _isLike = YES;
                [_downBarView setLikeBtnImageState:SDImageStateSure];
            }
        }
    }else {
        [self progressHUD:@"网络不好,请求失败" withImgName:@"icon_tip_normal.png"];
    }
}

- (void)commentResult:(NSMutableArray*)resultArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[resultArray lastObject] isEqual:CwRequestFail])
        {
            if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self progressHUD:CwRequestTip withImgName:@"icon_tip_normal.png"];
                });
            }else {
                int ret = [[resultArray objectAtIndex:0] intValue];
                if (ret == 1) {
                    NSMutableDictionary *modDict = [NSMutableDictionary dictionaryWithDictionary:[self.dataArr objectAtIndex:indexValue]];
                    int commentNum = [[modDict objectForKey:@"comment_sum"] intValue] + 1;
                    [modDict setObject:[NSString stringWithFormat:@"%d",commentNum] forKey:@"comment_sum"];

                    if ([Global sharedGlobal].isLogin == YES) {
                        //更新会员信息表评论的总数
                        member_info_model *miModel = [[member_info_model alloc] init];
                        miModel.where = [NSString stringWithFormat:@"id = %@",[Global sharedGlobal].user_id];
                        NSArray *dbArray = [miModel getList];
                        int commentCount = [[[dbArray objectAtIndex:0] objectForKey:@"countcomment"] intValue];
                        
                        NSDictionary *auditDic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",commentCount + 1],@"countcomment", nil];
                        
                        [miModel updateDB:auditDic];
                        [miModel release];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (id cell in _scrollViewC.subviews) {
                            if ([cell isKindOfClass:[InformationDetailView class]]) {
                                if (((InformationDetailView *)cell).index == indexValue) {
                                    [cell tableViewReloadData:modDict type:0];
                                }
                            }
                        }
                        
                        [self progressHUD:@"评论成功" withImgName:@"icon_ok_normal.png"];
                    });
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self progressHUD:@"评论失败" withImgName:@"icon_tip_normal.png"];
                    });
                }
            }
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self progressHUD:@"网络不好,发送失败" withImgName:@"icon_tip_normal.png"];
            });
        }
    });
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result withImgName:(NSString *)_imgName
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:_imgName]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [self.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessItemService:[inforId intValue]];
}

@end
