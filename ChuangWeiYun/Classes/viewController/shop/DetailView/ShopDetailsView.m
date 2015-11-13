//
//  ShopDetailsView.m
//  scrollview
//
//  Created by yunlai on 13-8-16.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "ShopDetailsView.h"
#import "TableViewCell.h"
#import "AdCwViewCell.h"
#import "AboutViewCell.h"
#import "CommentsCell.h"
#import "ProductPamraCell.h"
#import "Common.h"
#import "FileManager.h"
#import "IconPictureProcess.h"
#import "shop_near_list_model.h"
#import "callSystemApp.h"
#import "BaiduMapViewController.h"
#import "PfDetailViewController.h"
#import "DetailImageViewController.h"
#import "MBProgressHUD.h"

#define loadingTag      100
#define ShopHeaderViewH 50.f

@implementation ShopDetailsView

@synthesize tableViewC;
@synthesize dataDict;
@synthesize cwStatusType;
@synthesize navViewController;
@synthesize proID;
@synthesize delegate;
@synthesize paramStr;
@synthesize shopList;
@synthesize commentBtn;
@synthesize isEnd;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)createView
{
    [super createView];
    
    guesslikeArr = [[NSMutableArray alloc]initWithCapacity:0];
    commentlistArr = [[NSMutableArray alloc]initWithCapacity:0];
    
    tableViewC = [[UITableView alloc]initWithFrame:self.bounds];
    tableViewC.backgroundColor = KCWViewBgColor;
    tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableViewC.delegate = self;
    tableViewC.dataSource = self;
    [self addSubview:tableViewC];
}

- (void)dealloc
{
    NSLog(@"shopdetails view dealloc.......");
    [tableViewC release], tableViewC = nil;
    [dataDict release], dataDict = nil;
    
    [guesslikeArr release], guesslikeArr = nil;
    [commentlistArr release], commentlistArr = nil;
    
    [indicatorView release], indicatorView = nil;
    
    self.proID = nil;
    self.paramStr = nil;
    self.shopList = nil;
    self.commentBtn = nil;
    self.navViewController = nil;
    
    [super dealloc];
}

// tableView 刷新
- (void)tableViewReloadData:(NSDictionary *)adict shopList:(NSMutableArray *)shoplist type:(ShopDetailsEnum)type
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    self.dataDict = adict;
    self.shopList = shoplist;
    NSLog(@"self.shopList = %@",self.shopList);
    commentSum = [[self.dataDict objectForKey:@"comment_sum"] intValue];
    
    if (type == ShopDetailsEnumNormal) {
        
        commentFlag = NO;
        parameterFlag = NO;
        
        tableViewC.contentOffset = CGPointMake(0.f, 0.f);
        if (!self.isEnd) {
            if ([[self.dataDict objectForKey:@"is_guess_like"] intValue] == 0) {
                is_guess_like = NO;
            } else {
                if ([Global sharedGlobal].shop_id.length != 0) {
                    is_guess_like = YES;
                    [self accessItemGuessLikeService];
                }
            }
        } else {
            is_guess_like = NO;
        }
        
        [tableViewC reloadData];
    } else if (type == ShopDetailsEnumDelike || type == ShopDetailsEnumLike || type == ShopDetailsEnumOrder) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        // hui 11.19
        AdCwViewCell *cell = (AdCwViewCell *)[tableViewC cellForRowAtIndexPath:indexPath];
        UILabel *label1 = (UILabel *)[cell viewWithTag:'l'];
        label1.text = [NSString stringWithFormat:@"%d",[[self.dataDict objectForKey:@"like_sum"] intValue]];
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:'o'];
        label2.text = [NSString stringWithFormat:@"%d",[[self.dataDict objectForKey:@"sale_sum"] intValue]];
        
    } else if (type == ShopDetailsEnumComment) {
        if (commentFlag) {
            if (loading == NO) {
                loading = YES;
                [self accessItemCommentListService];
            }
        } else {
            [self clickBtnInsertCell:self.commentBtn];
        }
        NSRange range = NSMakeRange(3, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == ShopDetailsEnumReturn) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        AdCwViewCell *cell = (AdCwViewCell *)[tableViewC cellForRowAtIndexPath:indexPath];
        [cell scrollinvalidate];
    }
    
    [pool release];
}

// 查看更多
- (void)btnCheakMoreClick:(UIButton *)btn
{
    if (loading == NO) {
        loading = YES;
        UIImageView *bgImg = (UIImageView *)btn.superview;
        UILabel *bgLabel = (UILabel *)[bgImg viewWithTag:loadingTag];
        bgLabel.text = @"加载中...";
        
        [indicatorView startAnimating];
        
        [self accessItemCommentListMoreService];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (guesslikeArr.count > 0) {
        return 6;
    }else{
        return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger sum = 0;
    if (section == 0) {
//        if (cwStatusType == StatusTypeMemberShop) {
//            sum = 2;
//        } else {
            sum = 3;
//        }
    } else if (section == 1) {
        if (self.paramStr.length == 0) {
            sum = 0;
        } else {
            sum = 1;
        }
    } else if (section == 3) {
        sum = commentlistArr.count;
    } else if (section == 4) {
        sum = 1;
    } else if (section == 5){
        if (cwStatusType == StatusTypePfDetail) {
            if (guesslikeArr.count > 0) {
                sum = 1;
            } else {
                sum = 0;
            }
        } else {
            if (is_guess_like) {
                sum = 1;
            } else {
                sum = 0;
            }
        }
    }
    
    return sum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            AdCwViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdCwViewCell"];
            if (cell == nil) {
                cell = [[[AdCwViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AdCwViewCell"] autorelease];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (cwStatusType == StatusTypeHotAD
                || cwStatusType == StatusTypeHotShop
                || cwStatusType == StatusTypeMemberShop
                || cwStatusType == StatusTypeMemberShopOrder
                || cwStatusType == StatusTypePfDetail
                || cwStatusType == StatusTypeProductPush
                || cwStatusType == StatusTypeFromCenter) {
                [cell setCellContentAndFrame:self.dataDict index:self.index state:NO from:NO];
//            }else if () {
//                [cell setCellContentAndFrame:self.dataDict index:self.index state:YES from:YES]; //hui add
            }else {
                [cell setCellContentAndFrame:self.dataDict index:self.index state:YES from:NO];
            }
            
            return cell;
        } else if (indexPath.row == 1) {
            AboutViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutViewCell"];
            if (cell == nil) {
                cell = [[[AboutViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AboutViewCell"] autorelease];
                cell.cwStatusType = self.cwStatusType;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [cell setCellContentAndFrame:self.dataDict];
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
        } else if (indexPath.row == 2) {
            NearestStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearestStoreCell"];
            if (cell == nil) {
                cell = [[[NearestStoreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NearestStoreCell"] autorelease];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cwStatusType = self.cwStatusType;
            }
            
            cell.delegate = self;
            
            [cell setCellContentAndFrame:self.shopList];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    } else if (indexPath.section == 1) {
        static NSString *str = @"ProductPamraCell";
        ProductPamraCell *cell = (ProductPamraCell *)[tableViewC dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            cell = [[[ProductPamraCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSString *parameter = [self.dataDict objectForKey:@"parameter"];
        if (parameter.length == 0) {
            [cell setCellContentAndFrame:self.paramStr];
        } else {
            [cell setCellContentAndFrame:parameter];
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else if (indexPath.section == 3) {
        static NSString *str = @"CommentsCell";
        CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[[CommentsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *dict = nil;
        
        if (commentlistArr.count > 0) {
            dict = [commentlistArr objectAtIndex:indexPath.row];
        }
        
        if (commentlistArr.count == indexPath.row + 1) {
            [cell setCellContentAndFrame:dict imgFlag:NO];
        } else {
            [cell setCellContentAndFrame:dict imgFlag:YES];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            
            //图片
            NSString *picUrl = [dict objectForKey:@"portrait"];
            NSString *picName = nil;
            if (picUrl.length > 0) {
                picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
            }
            
            if (picUrl.length > 1) {
                UIImage *pic = [FileManager getPhoto:picName];
                if (pic.size.width > 2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setImageView:pic];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setImageView:[UIImage imageCwNamed:@"portrait_member.png"]];
                        [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setImageView:[UIImage imageCwNamed:@"portrait_member.png"]];
                });
            }
            
            [pool release];
        });
        
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else if (indexPath.section == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else if (indexPath.section == 5) {
       
        GuessLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuessLikeCell"];
        if (cell == nil) {
            cell = [[[GuessLikeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuessLikeCell"] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (guesslikeArr.count > 0) {
            cell.delegate = self;
            [cell setCellContentAndFrame:guesslikeArr];
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
      
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
// 返回header视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 5 || (section == 4 && !commentFlag)) {
        return nil;
    }

    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (IOS_7) {
        view.backgroundColor = [UIColor clearColor];
    }else{
        view.backgroundColor = KCWViewBgColor;
    }
    
    if (section == 1) {
        view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, ShopHeaderViewH);
    } else {
        view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, ShopHeaderViewH - 10.f);
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];

    UIButton *groudBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (section == 1) {
        groudBtn.frame = CGRectMake(10.f, 10.f, KUIScreenWidth-20.f, ShopHeaderViewH-10.f);
    } else {
        groudBtn.frame = CGRectMake(10.f, 0.f, KUIScreenWidth-20.f, ShopHeaderViewH-10.f);
    }
    
    groudBtn.tag = section;
    [groudBtn addTarget:self action:@selector(clickBtnInsertCell:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:groudBtn];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.frame = CGRectMake(32.f, 0.f, 200.f, ShopHeaderViewH-10.f);
    label.backgroundColor = [UIColor clearColor];
    label.font = KCWSystemFont(15.f);
    [groudBtn addSubview:label];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectZero];
    img.frame = CGRectMake(10.f, 14.f, 13.f, 12.f);
    [groudBtn addSubview:img];
    
    // image
    int xValue = 275.f;
    UIImageView *_imageV = [[UIImageView alloc]initWithFrame:CGRectMake(xValue, (ShopHeaderViewH-10.f)/2-7.f, 15.f, 15.f)];
    [groudBtn addSubview:_imageV];
    
    if (section == 1) {
        UIImage *setImg = [UIImage imageCwNamed:@"on_form_comments.png"];
        [groudBtn setBackgroundImage:setImg forState:UIControlStateNormal];
        [groudBtn setBackgroundImage:setImg forState:UIControlStateHighlighted];
        label.text = @"产品参数";
        img.image = [UIImage imageCwNamed:@"tmall_detail_icon_list.png"];
        _imageV.image = [UIImage imageCwNamed:@"icon_front_store.png"];
    } else if (section == 2) {
        UIImage *setImg = [[UIImage imageCwNamed:@"central_form_comments.png"] stretchableImageWithLeftCapWidth:10.f
                                                                                                   topCapHeight:10.f];
        [groudBtn setBackgroundImage:setImg forState:UIControlStateNormal];
        [groudBtn setBackgroundImage:setImg forState:UIControlStateHighlighted];
        label.text = @"图文详情";
        img.image = [UIImage imageCwNamed:@"tmall_detail_icon_pic.png"];
        _imageV.image = [UIImage imageCwNamed:@"icon_front_store.png"];
    } else if (section == 3) {
        UIImage *setImg = nil;
        if (commentFlag) {
            setImg = [[UIImage imageCwNamed:@"central_form_comments.png"] stretchableImageWithLeftCapWidth:10.f
                                                                                              topCapHeight:10.f];
            _imageV.image = [UIImage imageCwNamed:@"icon_down_store.png"];
        } else {
            setImg = [UIImage imageCwNamed:@"next_form_comments.png"];
            _imageV.image = [UIImage imageCwNamed:@"icon_front_store.png"];
        }
        [groudBtn setBackgroundImage:setImg forState:UIControlStateNormal];
        [groudBtn setBackgroundImage:setImg forState:UIControlStateHighlighted];
        label.text = [NSString stringWithFormat:@"用户评论(%d条)",commentSum];
        img.image = [UIImage imageCwNamed:@"tmall_detail_icon_comment.png"];
        self.commentBtn = groudBtn;
    } else if (section == 4) {      // 评论尾
        UIImage *setImg = [UIImage imageCwNamed:@"next_form_comments.png"];
        [groudBtn setBackgroundImage:setImg forState:UIControlStateNormal];
        [groudBtn setBackgroundImage:setImg forState:UIControlStateHighlighted];
        
        label.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(view.frame), ShopHeaderViewH-10.f);
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = loadingTag;
        
        img.frame = CGRectZero;
        //添加loading图标
        if (indicatorView == nil) {
            indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
            [indicatorView setCenter:CGPointMake(320 / 3, 40 / 2.0)];
            indicatorView.hidesWhenStopped = YES;
        }
		[groudBtn addSubview:indicatorView];
        
        int count = commentlistArr.count;
        if (commentFlag) {
            if (count % 20 == 0 && count > 0) {
                label.text = @"查看更多";
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(view.frame), ShopHeaderViewH-10.f);
                [btn addTarget:self action:@selector(btnCheakMoreClick:) forControlEvents:UIControlEventTouchUpInside];
                [groudBtn addSubview:btn];
            } else if (count == 0 && commentLoadFlag){
                label.text = @"加载中...";
                [indicatorView startAnimating];
                
                if (loading == NO) {
                    loading = YES;
                    [self accessItemCommentListService];
                }
            } else if (count == 0){
                label.text = @"目前没有评论，快来抢沙发吧！";
            }
        }
    }
    
    [img release], img = nil;
    [label release], label = nil;
    [_imageV release],_imageV = nil;
    
    [pool release];
    
    return [view autorelease];
}

// 返回header视图高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.f;
    if (section == 1 || section == 2 || section == 3) {
        if (section == 1) {
            height = ShopHeaderViewH;
        } else {
            height = ShopHeaderViewH-10.f;
        }
    } else if (section == 4 && commentFlag) {
        int count = commentlistArr.count;
        if (commentFlag) {
            if (count % 20 == 0 && count > 0) {
                height = ShopHeaderViewH-10.f;
            } else if (count % 20 == 0 && count == 0){
                height = ShopHeaderViewH-10.f;
            }
        }
    }
    
    return height;
}


// 返回cell视图高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = [AdCwViewCell getCellHeight];
        } else if (indexPath.row == 1) {
            height = [AboutViewCell getCellHeight:self.dataDict state:self.cwStatusType];
        } else if (indexPath.row == 2) {
            height = [NearestStoreCell getCellHeight:self.shopList state:self.cwStatusType];
        }
    } else if (indexPath.section == 1) {
        NSString *parameter = [self.dataDict objectForKey:@"parameter"];
        if (parameter.length == 0) {
            height = [ProductPamraCell getCellHeight:self.paramStr];
        } else {
            height = [ProductPamraCell getCellHeight:parameter];
        }
    } else if (indexPath.section == 3) {
        NSDictionary *dict = nil;
        if (commentlistArr.count > 0) {
            dict = [commentlistArr objectAtIndex:indexPath.row];
        }
        height = [CommentsCell getCellHeight:dict];
    } else if (indexPath.section == 4) {
        height = 10.f;
    } else if (indexPath.section == 5) {
         if (guesslikeArr.count > 0) {
             height = [GuessLikeCell getCellHeight];
             
         }else{
             height = 0.0f;
         }
    }
    
    [pool release];
    
    return height;
}

// 改变cell
- (void)changCell:(NSInteger)tag flag:(BOOL)flag ImageView:(UIImageView *)imgView sectionFlag:(BOOL)secFlag
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    [tableViewC beginUpdates];
    
    NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:tag];
    [rowArray addObject:indexPath];
    
    if (!flag) {
        [UIView animateWithDuration:0.18 animations:^{
            imgView.image = [UIImage imageCwNamed:@"icon_front_store.png"];
        }];
        [tableViewC deleteRowsAtIndexPaths:rowArray withRowAnimation:UITableViewRowAnimationMiddle];
    } else {
        [UIView animateWithDuration:0.18 animations:^{
            imgView.image = [UIImage imageCwNamed:@"icon_down_store.png"];
        }];
        [tableViewC insertRowsAtIndexPaths:rowArray withRowAnimation:UITableViewRowAnimationNone];
    }
    if (secFlag) {
        NSRange range = NSMakeRange(tag, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [tableViewC endUpdates];
    
    if (flag) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [tableViewC scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [pool release];
}

// 点击headerView的btn触发事件
- (void)clickBtnInsertCell:(UIButton *)btn
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    UIImageView *imgView = [btn.subviews lastObject];
    
    if (btn.tag == 1) {
        if (parameterFlag) {
            parameterFlag = NO;
            self.paramStr = nil;
        } else {
            parameterFlag = YES;
            self.paramStr = @"暂无产品参数";
        }
        [self changCell:btn.tag flag:parameterFlag ImageView:imgView sectionFlag:NO];
        
    } else if (btn.tag == 2) {
        DetailImageViewController *detailImgView = [[DetailImageViewController alloc]init];
        NSString *imgstr = [self.dataDict objectForKey:@"detail_image"];
        NSMutableArray *imgArr = [NSMutableArray arrayWithArray:[imgstr componentsSeparatedByString:@","]];
        detailImgView.imgArr = imgArr;
        //detailImgView.loadSums = imgArr;
        [self.navViewController pushViewController:detailImgView animated:YES];
        [detailImgView release], detailImgView = nil;
    } else if (btn.tag == 3) {
        if (commentFlag) {
            commentLoadFlag = NO;
            commentFlag = NO;
            [commentlistArr removeAllObjects];
            [UIView animateWithDuration:0.18 animations:^{
                imgView.image = [UIImage imageCwNamed:@"icon_front_store.png"];
            }];
        } else {
            commentFlag = YES;
            commentLoadFlag = YES;
            [UIView animateWithDuration:0.18 animations:^{
                imgView.image = [UIImage imageCwNamed:@"icon_down_store.png"];
            }];
        }
        NSRange range = NSMakeRange(btn.tag, 2);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [pool release];
}

// 得到店的数据
- (NSArray *)getshop_near_list
{
    shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
    snlMod.where = [NSString stringWithFormat:@"id = '%@'",[Global sharedGlobal].shop_id];
    NSArray *arr = [snlMod getList];
    [snlMod release], snlMod = nil;
    
    return arr;
}
#pragma mark - NearestStoreCellDelegate
// 附近的店  电话
- (void)nearestStorePhoneCall:(NearestStoreCell *)cell tag:(int)aindex
{
    //    NSArray *arr = [self getshop_near_list];
    NSArray *arr = self.shopList;
    
    NSDictionary *dict = nil;
    if (arr.count > 0) {
        int i = aindex / 2;
        dict = [arr objectAtIndex:i];
    }
    
    NSString *phone = [dict objectForKey:@"manager_tel"];
    NSLog(@"phone = %@",phone);
    if (phone.length == 0) {
        NSLog(@"暂时没有电话");
    } else {
        [callSystemApp makeCall:phone];
    }
}

// 附近的店  地图
- (void)nearestStoreMapClick:(NearestStoreCell *)cell tag:(int)aindex
{
    if ([delegate respondsToSelector:@selector(shopDetailsViewFlag:)]) {
        [delegate shopDetailsViewFlag:YES];
    }

    NSArray *arr = self.shopList;
    
    NSDictionary *dict = nil;
    if (arr.count > 0) {
        int i = aindex / 2;
        dict = [arr objectAtIndex:i];
    }
    BaiduMapViewController *mapView = [[BaiduMapViewController alloc]init];
    mapView.otherStatusTypeMap = StatusTypeMap;
    mapView.dataDic = dict;
    [self.navViewController pushViewController:mapView animated:YES];
    [mapView release],mapView = nil;
}

#pragma mark - 网络请求自定义
// 网络请求猜你喜欢
- (void)accessItemGuessLikeService
{
    if (cwStatusType != StatusTypeFromCenter)
    {
        NSString *reqUrl = @"guesslike.do?param=";
        
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [Global sharedGlobal].shop_id,@"shop_id",
                                           [self.dataDict objectForKey:@"product_id"],@"product_id",nil];
        
        [[NetManager sharedManager]accessService:requestDic
                                            data:nil
                                         command:GUESSLIKE_COMMAND_ID
                                    accessAdress:reqUrl
                                        delegate:self
                                       withParam:nil];
    }
}

// 网络请求评论列表
- (void)accessItemCommentListService
{
    NSString *reqUrl = @"infocommentlist.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"1",@"type",
                                       [self.dataDict objectForKey:@"product_id"],@"info_id",
                                       [Global sharedGlobal].shop_id,@"shop_id",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:COMMENT_LIST_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 网络请求评论列表更多
- (void)accessItemCommentListMoreService
{
    NSString *reqUrl = @"infocommentlist.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].shop_id,@"shop_id",
                                       @"1",@"type",
                                       [self.dataDict objectForKey:@"product_id"],@"info_id",
                                       [[commentlistArr lastObject] objectForKey:@"created"],@"created",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:COMMENT_LIST_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result type:(int)atype
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self];
    progressHUDTmp.center = CGPointMake(self.center.x, self.center.y + 120);
    
    UIImage *img = nil;
    if (atype == 1) {
        img = [UIImage imageCwNamed:@"icon_ok_normal.png"];
    } else if (atype == 0) {
        img = [UIImage imageCwNamed:@"icon_tip_normal.png"];
    }
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [self addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (commandid == GUESSLIKE_COMMAND_ID) {                        // 商品猜你喜欢
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    [guesslikeArr removeAllObjects];
                    if (resultArray.count > 0) {
                        [guesslikeArr addObjectsFromArray:resultArray];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableViewC reloadData];
            });
        });
    } else if (commandid == COMMENT_LIST_COMMAND_ID) {              // 评论列表
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    [commentlistArr removeAllObjects];
                    int sum = [[[resultArray lastObject] objectForKey:@"comment_sum"] intValue];
                    if (sum != 0) {
                        commentSum = sum;
                    }
                    NSArray *arr = [[resultArray lastObject] objectForKey:@"comments"];
                    if (arr != nil && arr.count > 0) {
                        [commentlistArr addObjectsFromArray:arr];
                        commentLoadFlag = YES;
                    } else {
                        commentLoadFlag = NO;
                    }
                } else {
                    commentLoadFlag = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self progressHUD:KCWServerBusyPrompt type:0];
                    });
                }
            } else {
                commentLoadFlag = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([Common connectedToNetwork]) {
                        [self progressHUD:KCWNetBusyPrompt type:0];
                    } else {
                        [self progressHUD:KCWNetNOPrompt type:3];
                    }
                });
            }
            
            loading = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [indicatorView stopAnimating];
                NSRange range = NSMakeRange(3, 2);
                NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
                [tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
                
                if (commentlistArr.count > 0) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
                    [tableViewC scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                } else {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
                    [tableViewC scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            });
        });
    } else if (commandid == COMMENT_LIST_MORE_COMMAND_ID) {         // 评论更多列表
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![[resultArray lastObject] isEqual:CwRequestFail]) {
                if (![[resultArray lastObject] isEqual:CwRequestTimeout]) {
                    NSArray *arr = [[resultArray lastObject] objectForKey:@"comments"];
                    if (arr != nil && arr.count > 0) {
                        [commentlistArr addObjectsFromArray:arr];
                        commentLoadFlag = YES;
                    } else {
                        commentLoadFlag = NO;
                    }
                } else {
                    commentLoadFlag = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self progressHUD:KCWServerBusyPrompt type:0];
                    });
                }
            } else {
                commentLoadFlag = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([Common connectedToNetwork]) {
                        [self progressHUD:KCWNetBusyPrompt type:0];
                    } else {
                        [self progressHUD:KCWNetNOPrompt type:3];
                    }
                });
            }
            loading = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                [indicatorView stopAnimating];
                NSRange range = NSMakeRange(3, 2);
                NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
                [tableViewC reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
            });
        });
    }
    
    [pool release];
}

// 图片加载
#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        if (iconDownloader != nil)
        {
            if(iconDownloader.cardIcon.size.width > 2.0)
            {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
                
                UIImage *photo = iconDownloader.cardIcon;
                
                CommentsCell *cell = (CommentsCell *)[tableViewC cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setImageView:photo];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - GuessLikeCellDelegate
- (void)guessLikeCellClickImg:(GuessLikeCell *)cell proID:(NSString *)pid
{
    PfDetailViewController *pfView = [[PfDetailViewController alloc]init];
    pfView.promotionId = pid;
    //pfView.navigationItem.title = @"优惠券详情";
    [self.navViewController pushViewController:pfView animated:YES];
    [pfView release], pfView = nil;
}

@end
