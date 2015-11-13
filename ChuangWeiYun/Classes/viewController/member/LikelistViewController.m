//
//  LikelistViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "LikelistViewController.h"
#import "CustomShopCell.h"
#import "CustomMsgCell.h"
#import "Common.h"
#import "Global.h"
#import "FileManager.h"
#import "NetworkFail.h"
#import "IconPictureProcess.h"
#import "system_config_model.h"
#import "member_info_model.h"
#import "member_shoplikes_model.h"
#import "member_shoplikePic_model.h"
#import "member_msglikes_model.h"
#import "member_msglikePic_model.h"
#import "member_likeshop_model.h"
#import "member_likeinformation_model.h"
#import "InformationDetailViewController.h"
#import "ShopDetailsViewController.h"

#define kcontrolHeight 44
#define kShopTableView 15
#define kMsgTableView 16

@interface LikelistViewController ()<NetworkFailDelegate>
{
    NetworkFail *failView;
}

@end

@implementation LikelistViewController
@synthesize countlikes      = _countlikes;
@synthesize shoplikeArray   = _shoplikeArray;
@synthesize msglikeArray    = _msglikeArray;
@synthesize msglikeDic      = _msglikeDic;
@synthesize progressHUD     = _progressHUD;
@synthesize cloudLoading;

static int shoplikeBtnTag = 0;
static int informationlikeBtnTag = 0;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _shoplikeArray = [[NSMutableArray alloc]init];
        _msglikeArray = [[NSMutableArray alloc]init];

    }
    return self;
}

#pragma mark - lifeCycle

static bool loadMore = YES;
static bool noMore = NO;

- (void)viewWillAppear:(BOOL)animated{
    [_shopTableView reloadData];
    [_messageTableView reloadData];

    noMore = NO;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我赞过的";
    self.view.backgroundColor = KCWViewBgColor;
    
    picHeight = 40.0f;
    picWidth = 70.0f;
    
    _loadingMore = NO;
    _isAllowLoadingMore = NO;
    
 
    [self loadMainView];
    
    [self accessShopLikeService];
    [self accessMsgLikeService];
    
}

- (void)loadMainView{
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, kcontrolHeight)];
    _menuView.backgroundColor=[UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
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
    _shopTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kcontrolHeight, KUIScreenWidth, KUIScreenHeight-kcontrolHeight*2-5) style:UITableViewStylePlain];
    _shopTableView.dataSource = self;
    _shopTableView.delegate = self;
    _shopTableView.tag = kShopTableView;
    _shopTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _shopTableView.backgroundColor = KCWViewBgColor;
    [self.view addSubview:_shopTableView];

}

- (void)createMessageTableView{
    _messageTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kcontrolHeight, KUIScreenWidth, KUIScreenHeight-kcontrolHeight*2-5) style:UITableViewStylePlain];
    _messageTableView.backgroundColor = KCWViewBgColor;
    _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _messageTableView.dataSource = self;
    _messageTableView.delegate = self;
    _messageTableView.tag = kMsgTableView;
    [self.view addSubview:_messageTableView];
    _messageTableView.hidden = YES;
    
}


- (void)click:(UIButton *)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    switch (sender.tag) {
        case 10:
        {
            _lineLabel.frame = CGRectMake(0, kcontrolHeight-6, KUIScreenWidth/2-1, 5);
            [_messageBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
            [_shopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
            _shopTableView.hidden = NO;
            _messageTableView.hidden = YES;
            loadMore = YES;
            noMore = NO;
            
            [self nullViewJudge:self.shoplikeArray andText:@"您还没有赞过的商品哦~"];
            
        }
            break;
        case 11:
        {
             _lineLabel.frame = CGRectMake(KUIScreenWidth/2, kcontrolHeight-6, KUIScreenWidth/2-1, 5);
            [_messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_shopBtn setTitleColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1] forState:UIControlStateNormal];
            
            _shopTableView.hidden = YES;
            _messageTableView.hidden = NO;
            loadMore = NO;
            noMore = NO;
            
            [self nullViewJudge:self.msglikeArray andText:@"您还没有赞过的资讯哦~"];
        }
            
            break;
        default:
            break;
    }
    [UIView commitAnimations];
}

- (void)nullViewJudge:(NSMutableArray *)arry andText:(NSString *)str{
    if ([arry count]==0) {
        
        [_nullView setNullStatusText:str];
        [self.view addSubview:_nullView];
    }else{
        
        if (_nullView.superview) {
            [_nullView removeNullView];
        }
    }

}

- (void)dealloc
{
    RELEASE_SAFE(_messageTableView);
    RELEASE_SAFE(_shopTableView);
    RELEASE_SAFE(_menuView);
    RELEASE_SAFE(_shopBtn);
    RELEASE_SAFE(_messageBtn);
    RELEASE_SAFE(_lineLabel);
    RELEASE_SAFE(_msglikeArray);
    RELEASE_SAFE(_shoplikeArray);
    RELEASE_SAFE(_nullView);
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
    [self accessShopLikeService];
    [self accessMsgLikeService];
}

#pragma mark - ShopDetailsViewControllerDelegate
// 商品详情页面操作赞 返回来做相应的处理
- (void)isShopDelLikeSelectRow:(NSNumber *)num{

    int selectRow = [num integerValue];
    NSString *likeShopId=@"";
    if ([self.shoplikeArray count]>20) {
        likeShopId = [[self.shoplikeArray objectAtIndex:selectRow]objectForKey:@"id"];
    }else{
        likeShopId = [[self.shoplikeArray objectAtIndex:selectRow]objectForKey:@"product_id"];
    }
    
    [self accessDelShoplikeService:likeShopId];
    
    
    
    if ([self.shoplikeArray count]!=0) {
        shoplikeBtnTag = [[[self.shoplikeArray objectAtIndex:selectRow]objectForKey:@"id"]intValue];
    }
    
    [self sccessCancellike:shoplikeBtnTag];
    
    //取消预订成功后删除表格数据，刷新
    CustomShopCell *cell = (CustomShopCell *)[_shopTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectRow inSection:0]];
    NSIndexPath *indexPath = [_shopTableView indexPathForCell:cell];
    
    [self.shoplikeArray removeObjectAtIndex:selectRow];
    
    [_shopTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - InformationDetailViewDelegate
- (void)isInformationDellikeSelectRow:(NSNumber *)selectNum{
    int selectRow = [selectNum integerValue];
    
    NSString *likeMsgId = [[self.msglikeArray objectAtIndex:selectRow]objectForKey:@"new_id"];
    
    [self accessDelInformationlikeService:likeMsgId];
    
    if ([self.msglikeArray count]!=0) {
        informationlikeBtnTag = [[[self.msglikeArray objectAtIndex:selectRow]objectForKey:@"new_id"]intValue];
    }
  
    
    CustomMsgCell *cell = (CustomMsgCell *)[_messageTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectRow inSection:0]];
    NSIndexPath *indexPath = [_messageTableView indexPathForCell:cell];
    
    [self sccessCancelMsglike:informationlikeBtnTag];
    
    //取消预订成功后删除表格数据，刷新
    [self.msglikeArray removeObjectAtIndex:selectRow];
    
    [_messageTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case kShopTableView:{
                if ([self.shoplikeArray count]!=0 && section == 0) {
                    return [self.shoplikeArray count];
                }else{
                    return 0;
                }
            }
            break;
        case kMsgTableView:{
                if ([self.msglikeArray count]!=0 && section == 0) {
                    return [self.msglikeArray count];
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
        case kShopTableView:{
            static NSString *CellIdentifier = @"shopCell";
            CustomShopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[CustomShopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([self.shoplikeArray count]!=0) {

                NSDictionary *dic = [self.shoplikeArray objectAtIndex:indexPath.row];
                cell.typeNum.text = [dic objectForKey:@"name"];
                cell.shopName.text = [dic objectForKey:@"content"];
                cell.likeBtn.tag = [[dic objectForKey:@"id"]intValue]+110;

                //图片
                NSString *picUrl = [dic objectForKey:@"image"];
                [self setCellImage:picUrl andImgView:cell.shopImages andTable:tableView andIndexPath:indexPath];
                
            }
                
      
            return cell;
        }
            break;
        case kMsgTableView:
        {
            static NSString *CellIdentifier = @"messageCell";
            CustomMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[CustomMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([self.msglikeArray count]!=0) {
                
                NSDictionary *dic = [self.msglikeArray objectAtIndex:indexPath.row];
    
                cell.shopName.text = [dic objectForKey:@"title"];
                cell.shopAbout.text = [dic objectForKey:@"content"];
                cell.likeBtn.tag = [[dic objectForKey:@"new_id"]intValue]+220;

                //图片
                NSString *picUrl = [dic objectForKey:@"picture"];
                [self setCellImage:picUrl andImgView:cell.shopImage andTable:tableView andIndexPath:indexPath];
                            
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
        case kShopTableView:{
            NSDictionary *dic = [self.shoplikeArray objectAtIndex:indexPath.row];
            
            ShopDetailsViewController *shopDetail = [[ShopDetailsViewController alloc]init];
            shopDetail.delegate = self;
            shopDetail.cwStatusType = StatusTypeMemberShop;
            shopDetail.productID = [dic objectForKey:@"product_id"];
             NSLog(@"shoplikeArray=====%@",shopDetail.productID);
            [self.navigationController pushViewController:shopDetail animated:YES];
            RELEASE_SAFE(shopDetail);
            
        }
            break;
        case kMsgTableView:{

            InformationDetailViewController *infoDetail = [[InformationDetailViewController alloc]init];
            NSLog(@"allMsglikeArray=====%@",self.msglikeArray);
            infoDetail.delegate = self;
            infoDetail.dataArr = self.msglikeArray;
            infoDetail.indexValue = indexPath.row;
//            infoDetail.cwStatusType = StatusTypeMemberInformation;
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
		if (noMore) {
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
        case kShopTableView:
        {
            if (section == 1 && self.shoplikeArray.count >= 20) {
                return 40;
            }else {
                return 0;
            }
        }
            break;
        case kMsgTableView:
        {
            if (section == 1 && self.msglikeArray.count >= 20) {
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
        case kShopTableView:
            return 90.0f;
            break;
        case kMsgTableView:
            return 90.0f;
            break;
            
        default:
            break;
    }
    return 0.f;
}

//删除的回调方法
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (tableView.tag==kShopTableView) {
            
            NSString *likeShopId = @"";
            if ([self.shoplikeArray count]>20) {
               likeShopId = [[self.shoplikeArray objectAtIndex:indexPath.row]objectForKey:@"id"];
            }else{
                likeShopId = [[self.shoplikeArray objectAtIndex:indexPath.row]objectForKey:@"product_id"];
            }
            
            [self accessDelShoplikeService:likeShopId];
            
            if ([self.shoplikeArray count]!=0) {
                shoplikeBtnTag = [[[self.shoplikeArray objectAtIndex:indexPath.row]objectForKey:@"id"]intValue];
            }
            
            
            [self.shoplikeArray removeObjectAtIndex:indexPath.row];
            
            NSLog(@"self.shoplikeArray = %@",self.shoplikeArray);
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            
            
        }else if(tableView.tag==kMsgTableView){
            
            NSString *likeMsgId = [[self.msglikeArray objectAtIndex:indexPath.row]objectForKey:@"new_id"];
            
            [self accessDelInformationlikeService:likeMsgId];
            
            if ([self.msglikeArray count]!=0) {
                informationlikeBtnTag = [[[self.msglikeArray objectAtIndex:indexPath.row]objectForKey:@"new_id"]intValue];
            }
            
            
            [self.msglikeArray removeObjectAtIndex:indexPath.row];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        }
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删  除";
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ((_isAllowLoadingMore && !_loadingMore && [self.shoplikeArray count] > 0)|| (_isAllowLoadingMore && !_loadingMore &&[self.msglikeArray count]>0))
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
            if (noMore) {
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
                label.text=@" 加载中...";   
                [self accessShopMoreService];
            }else{
                label2.text=@" 加载中...";
                [self accessMsgMoreService];
            }
            
            [indicatorView startAnimating];
    
        }
        else
        {
            if (noMore) {
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
    if((bottomEdge >= scrollView.contentSize.height && bottomEdge > _shopTableView.frame.size.height && [self.shoplikeArray count] >= 20 )||(bottomEdge >= scrollView.contentSize.height && bottomEdge > _messageTableView.frame.size.height && [self.msglikeArray count] >= 20))
    {
        _isAllowLoadingMore = YES;
    }
    else
    {
        _isAllowLoadingMore = NO;
    }
}


#pragma mark - private methods

- (void)sccessCancellike:(int)tag{
    //更新数据库用户的总赞数
    --self.countlikes;
    NSDictionary *shopDic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.countlikes],@"countlikes", nil];
    member_info_model *infoMod=[[member_info_model alloc]init];
    [infoMod updateDB:shopDic];
    RELEASE_SAFE(infoMod);
    //更新数据库赞过的商品
    member_shoplikes_model *shopMod=[[member_shoplikes_model alloc]init];
    shopMod.where=[NSString stringWithFormat:@"id=%d",tag];
    NSArray *shopLikes=[shopMod getList];
    if ([shopLikes count]!=0) {
        NSString *produtID= [[shopLikes objectAtIndex:0]objectForKey:@"product_id"];
        [shopMod deleteDBdata];
        
        //更新登录的用户删除赞过的商品后，返回分店列表中更新商品的赞状态
        member_likeshop_model *mlMod = [[member_likeshop_model alloc]init];
        mlMod.where = [NSString stringWithFormat:@"produts_id = '%@'",produtID];
        [mlMod deleteDBdata];
        RELEASE_SAFE(mlMod);
    }
    RELEASE_SAFE(shopMod);
}

- (void)sccessCancelMsglike:(int)tag{
    //更新数据库用户的总赞数
    --self.countlikes;
    NSDictionary *shopDic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.countlikes],@"countlikes", nil];
    member_info_model *infoMod=[[member_info_model alloc]init];
    [infoMod updateDB:shopDic];
    RELEASE_SAFE(infoMod);
    
    member_msglikes_model *msgMod=[[member_msglikes_model alloc]init];
    msgMod.where=[NSString stringWithFormat:@"new_id=%d",tag];
    [msgMod deleteDBdata];
    msgMod.where=nil;
    RELEASE_SAFE(msgMod);
    
    member_likeinformation_model *acModel = [[member_likeinformation_model alloc] init];
    acModel.where = [NSString stringWithFormat:@"news_id = %d",tag];
    [acModel deleteDBdata];
    RELEASE_SAFE(acModel);
}

-(void)progressHud:(NSString *)valueText{
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

//滚动loading图片
- (void)loadImagesForOnscreenRows
{
    //每次只下载一屏显示的单元格图片
    if (loadMore) {
        NSArray *visiblePaths = [_shopTableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            int countItems = [self.shoplikeArray count];
            if (countItems >[indexPath row]) {
                NSString *photoURL = [[self.shoplikeArray objectAtIndex:[indexPath row]] objectForKey:@"picture"];
                
                //获取本地图片缓存
                UIImage *cardIcon = [[IconPictureProcess sharedPictureProcess] getPhoto:photoURL];
                
                CustomShopCell *cell = (CustomShopCell *)[_shopTableView cellForRowAtIndexPath:indexPath];
                
                //拖动或滚动table view时，图片不下载
                if (cardIcon == nil) {
                    if (_shopTableView.dragging == NO && _shopTableView.decelerating == NO) {
                        [[IconPictureProcess sharedPictureProcess] startIconDownload:photoURL forIndexPath:indexPath delegate:self];
                    }
                } else {
                    cell.shopImages.image = cardIcon;
                }
            }
        }
    }else{
        NSArray *visiblePaths = [_messageTableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            int countItems = [self.msglikeArray count];
            if (countItems >[indexPath row]) {
                NSString *photoURL = [[self.msglikeArray objectAtIndex:[indexPath row]] objectForKey:@"picture"];
                
                //获取本地图片缓存
                UIImage *cardIcon = [[IconPictureProcess sharedPictureProcess] getPhoto:photoURL];
                
                CustomMsgCell *cell = (CustomMsgCell *)[_messageTableView cellForRowAtIndexPath:indexPath];
                
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


#pragma mark - accessService


- (void)accessShopLikeService{

    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(KUIScreenWidth / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    //我赞过的商品数据请求
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                       @"1",@"like_type",
                                                                                    nil];

	[[NetManager sharedManager]accessService:jsontestDic
                                        data:nil
                                     command:MEMBER_SHOPLIKE_COMMAND_ID
                                accessAdress:@"member/likes.do?param="
                                    delegate:self
                                   withParam:nil];
    
}

- (void)accessMsgLikeService{
    //我赞过的资讯数据请求
    NSMutableDictionary *jsontestDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [Global sharedGlobal].user_id,@"user_id",
                                                                        @"2",@"like_type",
                                                                                     nil];
	
	[[NetManager sharedManager]accessService:jsontestDic2
                                        data:nil
                                     command:MEMBER_NEWSLIKE_COMMAND_ID
                                accessAdress:@"member/likes.do?param="
                                    delegate:self
                                   withParam:nil];
    
}

- (void)accessShopMoreService{
    

    NSString *created1 = [[self.shoplikeArray objectAtIndex:[self.shoplikeArray count] - 1] objectForKey:@"created"];

    
    NSString *reqUrl = @"member/likes.do?param=";
	
    NSLog(@"created1==%@",created1);
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                       @"1",@"like_type",
                                                                     created1,@"created",
                                                                                    nil];
    
    [[NetManager sharedManager] accessService:requestDic
                                         data:nil
                                      command:MEMBER_SHOPLIKE_MORE_COMMAND_ID
                                 accessAdress:reqUrl
                                     delegate:self
                                    withParam:nil];
    
}

- (void)accessMsgMoreService{
    
    NSString *created2 = [[self.msglikeArray objectAtIndex:[self.msglikeArray count] - 1] objectForKey:@"created"];

    NSString *reqUrl2 = @"member/likes.do?param=";
	
    NSLog(@"%d=created2==%@",[self.msglikeArray count],created2);
    
    NSMutableDictionary *requestDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                       @"2",@"like_type",
                                                                     created2,@"created",
                                                                                    nil];
    
    [[NetManager sharedManager] accessService:requestDic2
                                         data:nil
                                      command:MEMBER_NEWSLIKE_MORE_COMMAND_ID
                                 accessAdress:reqUrl2
                                     delegate:self
                                    withParam:nil];
}

- (void)accessDelShoplikeService:(NSString *)likeShopId{
    
    NSString *reqUrl = @"member/dellike.do?param=";
    
    
    NSLog(@"===%@",likeShopId);

    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [Global sharedGlobal].user_id,@"user_id",
                                                                           @"1",@"type",
                                                              likeShopId,@"relation_id",
                                                                                   nil];
    
    [[NetManager sharedManager] accessService:requestDic
                                         data:nil
                                      command:MEMBER_SHOPDELLIKE_COMMAND_ID
                                 accessAdress:reqUrl
                                     delegate:self
                                    withParam:nil];
    
}

- (void)accessDelInformationlikeService:(NSString *)likeInformationId{
    NSString *reqUrl = @"member/dellike.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [Global sharedGlobal].user_id,@"user_id",
                                                                           @"2",@"type",
                                                       likeInformationId,@"relation_id",
                                                                                   nil];
    
    [[NetManager sharedManager] accessService:requestDic
                                         data:nil
                                      command:MEMBER_MSGDELLIKE_COMMAND_ID
                                 accessAdress:reqUrl
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
        
            case MEMBER_SHOPLIKE_COMMAND_ID:
            {
        
                [self performSelectorOnMainThread:@selector(shopSuccess:) withObject:resultArray waitUntilDone:NO];

            }break;
            case MEMBER_NEWSLIKE_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(newsSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            case MEMBER_SHOPLIKE_MORE_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(shopMoreSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
            case MEMBER_NEWSLIKE_MORE_COMMAND_ID:
            {
                
                [self performSelectorOnMainThread:@selector(newsMoreSuccess:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            case MEMBER_SHOPDELLIKE_COMMAND_ID:
            {
                int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
     
                if (resultInt==1) {
                    [self performSelectorOnMainThread:@selector(delShopLikeSuccess:) withObject:resultArray waitUntilDone:NO];
                }else if (resultInt==0){
                    [self performSelectorOnMainThread:@selector(delLikeFail:) withObject:resultArray waitUntilDone:NO];
                }
                
            }break;
                
            case MEMBER_MSGDELLIKE_COMMAND_ID:
            {
                int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
          
                if (resultInt==1) {
                    [self performSelectorOnMainThread:@selector(delMsgLikeSuccess:) withObject:resultArray waitUntilDone:NO];
                }else if (resultInt==0){
                    [self performSelectorOnMainThread:@selector(delLikeFail:) withObject:resultArray waitUntilDone:NO];
                }
                
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

    _nullView=[[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_Like_default.png"] andText:@"您还没有赞过的商品哦~"];

    //loading图标移除
	if (self.cloudLoading) {
        [self.cloudLoading removeFromSuperview];
    }
    
    [_shoplikeArray addObjectsFromArray:resultArray];
    
    NSLog(@"wwwwwwwwwwwww%deeeeee%@",[resultArray count],_shoplikeArray);
    
//    member_shoplikes_model *shoplike=[[member_shoplikes_model alloc]init];
//    shoplike.orderBy = @"created";
//    shoplike.orderType = @"desc";
//    NSArray *shopArry=[shoplike getList];
//    self.shoplikeArray=(NSMutableArray *)[shopArry retain];
//
//    RELEASE_SAFE(shoplike);
//    
//    for (int i = 0; i < [shopArry count]; i ++) {
//        NSMutableDictionary *shoplikeDic = [shopArry objectAtIndex:i];
//        
//        int infoId = [[shoplikeDic objectForKey:@"product_id"] intValue];
//        
//        member_shoplikePic_model *shopPic=[[member_shoplikePic_model alloc]init];
//        
//        shopPic.where = [NSString stringWithFormat:@"product_id = %d",infoId];
//        NSArray *imgArray = [shopPic getList];
//        
//        [shoplikeDic setObject:imgArray forKey:@"pics"];
//        
//        [self.allShoplikeArray addObject:shoplikeDic];
//        
//        shopPic.where = nil;
//        RELEASE_SAFE(shopPic);
//    }
    
    if ([self.shoplikeArray count]!=0) {
     
        [self createShopTableView];
        [_shopTableView reloadData];
        
    }else{
        if (_nullView.superview==nil) {
            _nullView.hidden = NO;

            [self.view addSubview:_nullView];
        }
        _shopTableView.hidden=YES;
        
    }
    
	NSLog(@"db read success!shopArry=%d",[self.shoplikeArray count]);
}
- (void)newsSuccess:(NSMutableArray*)resultArray{
    
    
//    member_msglikes_model *msglike=[[member_msglikes_model alloc]init];
//    msglike.orderBy = @"created";
//    msglike.orderType = @"desc";
//    NSArray *msgArray=[msglike getList];
//    self.msglikeArray=(NSMutableArray *)[msgArray retain];
//    RELEASE_SAFE(msglike);
//    
//    for (int i = 0; i < [msgArray count]; i ++) {
//        _msglikeDic = [msgArray objectAtIndex:i];
//        
//        int infoId = [[_msglikeDic objectForKey:@"new_id"] intValue];
//        
//        member_msglikePic_model *msgPic=[[member_msglikePic_model alloc]init];
//        
//        msgPic.where = [NSString stringWithFormat:@"new_id = %d",infoId];
//        NSArray *imgArray = [msgPic getList];
//        
//        [_msglikeDic setObject:imgArray forKey:@"pics"];
//        
//        [self.allMsglikeArray addObject:_msglikeDic];
//        
//        msgPic.where = nil;
//        RELEASE_SAFE(msgPic);
//    }
    
    [_msglikeArray addObjectsFromArray:resultArray];
    
    NSLog(@"wwwwww_msglikeArraywwwwwww%deeeeee%@",[resultArray count],_msglikeArray);
    
    
    if ([self.msglikeArray count]!=0) {
        
        [self createMessageTableView];
        
    }else{
        _messageTableView.hidden=YES;

    }
    
    [_messageTableView reloadData];
    
}

- (void)shopMoreSuccess:(NSMutableArray*)resultArray{
    UILabel *label = (UILabel*)[_shopTableView viewWithTag:200];
	if ([resultArray count]==0||[resultArray count]<20) {
        noMore = YES;
        label.text = @"没有更多了";
    }else{
        label.text = @"上拉加载更多";
        noMore = NO;
    }
     [indicatorView stopAnimating];
    
    _loadingMore = NO;
	
//	for (int i = 0; i < [resultArray count];i++)
//	{
//		NSMutableDictionary *item = [resultArray objectAtIndex:i];
//		[self.shoplikeArray addObject:item];
//	}
    [_shoplikeArray addObjectsFromArray:resultArray];
    

    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
    for (int ind = 0; ind < [resultArray count]; ind ++)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                [self.shoplikeArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_shopTableView insertRowsAtIndexPaths:insertIndexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
    [_shopTableView reloadData];
}

- (void)newsMoreSuccess:(NSMutableArray*)resultArray{
    UILabel *label = (UILabel*)[_messageTableView viewWithTag:200];
	if ([resultArray count]==0||[resultArray count]<20) {
        noMore = YES;
        label.text = @"没有更多了";
    }else{
        label.text = @"上拉加载更多";
        noMore = NO;
    }
    [indicatorView stopAnimating];
    
    _loadingMore = NO;
	
//	for (int i = 0; i < [resultArray count];i++ )
//	{
//		NSMutableDictionary *item = [resultArray objectAtIndex:i];
//		[self.msglikeArray addObject:item];
//	}
    [_msglikeArray addObjectsFromArray:resultArray];
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[resultArray count]];
    for (int ind = 0; ind < [resultArray count]; ind ++)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:
                                [self.msglikeArray indexOfObject:[resultArray objectAtIndex:ind]] inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    [_messageTableView insertRowsAtIndexPaths:insertIndexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)delShopLikeSuccess:(NSMutableArray*)resultArray{
 
    [self sccessCancellike:shoplikeBtnTag];

    if ([self.shoplikeArray count]==0) {
        [_nullView setNullStatusText:@"您还没有赞过的商品哦~"];
        [self.view addSubview:_nullView];
        
    }else{
        if (_nullView.superview) {
            [_nullView removeNullView];
        }
    }
    
}

- (void)delMsgLikeSuccess:(NSMutableArray*)resultArray{
    
    [self sccessCancelMsglike:informationlikeBtnTag];
    
    NSLog(@"删除商品喜欢");
    
    if ([self.msglikeArray count]==0) {
        [_nullView setNullStatusText:@"您还没有赞过的资讯哦~"];
        [self.view addSubview:_nullView];
        
    }else{
        if (_nullView.superview) {
            [_nullView removeNullView];
        }
    }
    
}

- (void)delLikeFail:(NSMutableArray*)resultArray{

    [self progressHud:@"取消赞失败"];
    
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
            
            CustomShopCell *cell = (CustomShopCell *)[_shopTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell.shopImages.image = photo;
            
            CustomMsgCell *cell2 = (CustomMsgCell *)[_messageTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            cell2.shopImage.image = photo;
            
		}
		
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}

- (void)setCellImage:(NSString *)picUrl andImgView:(UIImageView *)imgView andTable:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    //图片

    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    
    if (picUrl.length > 1)
    {
        UIImage *pic = [FileManager getPhoto:picName];
        if (pic.size.width > 2)
        {
            imgView.image = pic;
        }
        else
        {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
            imgView.image = defaultPic;
            
            if (tableView.dragging == NO && tableView.decelerating == NO)
            {
                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
            }
        }
    }
    else
    {
        UIImage *defaultPic = [UIImage imageCwNamed:@"default_70x53.png"];
        imgView.image = defaultPic;
    }
}

@end