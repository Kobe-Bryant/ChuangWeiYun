//
//  InformationDetailView.m
//  cw
//
//  Created by LuoHui on 13-8-29.
//
//

#import "InformationDetailView.h"
#import "TableViewCell.h"
#import "AdCwViewCell.h"
#import "AboutViewCell.h"
#import "NearestStoreCell.h"
#import "GuessLikeCell.h"
#import "CommentsCell.h"
#import "Common.h"
#import "FileManager.h"
#import "UIImageScale.h"
#import "IconPictureProcess.h"
#import "HttpRequest.h"
#import "MBProgressHUD.h"
#import "CWLabel.h"
#import "YLLabelView.h"

#define loadingTag  100

@implementation InformationDetailView
@synthesize tableViewC;
@synthesize itemDic;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        commentArr = [[NSMutableArray alloc] init];
        picsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)createView:(From_Enum)_type
{
    [super createView];
    picWidth = 320;
    picHeight = 240;
    
    int height;
    if (_type == From_Enum_List) {
        height = KUIScreenHeight - KUpBarHeight - KDownBarHeight;
    }else {
        height = KUIScreenHeight - KUpBarHeight;
    }
    
    tableViewC = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, height)];
    tableViewC.backgroundColor = KCWViewBgColor;
    tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableViewC.delegate = self;
    tableViewC.dataSource = self;
    [self addSubview:tableViewC];
}

- (void)dealloc
{
    NSLog(@"informationDetailView dealloc.....");
    [tableViewC release], tableViewC = nil;
    [itemDic release], itemDic = nil;
    [picsScrollView release],picsScrollView = nil;
    [picsArray release],picsArray = nil;
    [commentArr release],commentArr = nil;
    [indicatorView release],indicatorView = nil;
    if (CWPview) {
        [CWPview release], CWPview = nil;
    }
    [super dealloc];
}

//网络获取数据
-(void)accessItemService:(int)infoId
{
    NSString *reqUrl = @"infocommentlist.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:2],@"type",
                                       [NSNumber numberWithInt:infoId],@"info_id",
                                       nil];
    
    [[NetManager sharedManager] accessService:requestDic
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
                                       @"2",@"type",
                                       [self.itemDic objectForKey:@"new_id"],@"info_id",
                                       [[commentArr lastObject] objectForKey:@"created"],@"created",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:COMMENT_LIST_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    
    switch (commandid) {
        case COMMENT_LIST_COMMAND_ID:
        {
            [self update:resultArray];
        }
            break;
        case COMMENT_LIST_MORE_COMMAND_ID:
        {
            [self updateCommentMore:resultArray];
        }
            break;
        default:
            break;
    }
}

//更新数据
-(void)update:(NSMutableArray*)resultArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[resultArray lastObject] isEqual:CwRequestFail])
        {
            if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MBProgressHUD *mprogressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
                    mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
                    mprogressHUD.labelText = CwRequestTip;
                    mprogressHUD.mode = MBProgressHUDModeCustomView;
                    [self addSubview:mprogressHUD];
                    [self bringSubviewToFront:mprogressHUD];
                    [mprogressHUD show:YES];
                    [mprogressHUD hide:YES afterDelay:1.5];
                    [mprogressHUD release],mprogressHUD = nil;
                });
            }else {
                [commentArr removeAllObjects];
                
                int sum = [[[resultArray lastObject] objectForKey:@"comment_sum"] intValue];
                if (sum != 0) {
                    commentSum = sum;
                }
                NSArray *arr = [[resultArray lastObject] objectForKey:@"comments"];
                if (arr != nil && [arr count] > 0) {
                    [commentArr addObjectsFromArray:arr];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableViewC reloadData];
        });
    });
}

-(void)updateCommentMore:(NSMutableArray*)resultArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[resultArray lastObject] isEqual:CwRequestFail])
        {
            if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
                dispatch_async(dispatch_get_main_queue(),^{
                    MBProgressHUD *mprogressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
                    mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
                    mprogressHUD.labelText = CwRequestTip;
                    mprogressHUD.mode = MBProgressHUDModeCustomView;
                    [self addSubview:mprogressHUD];
                    [self bringSubviewToFront:mprogressHUD];
                    [mprogressHUD show:YES];
                    [mprogressHUD hide:YES afterDelay:1.5];
                    [mprogressHUD release];
                });
            }else{
                if (resultArray.count > 0) {
                    NSArray *arr = [[resultArray lastObject] objectForKey:@"comments"];
                    if (arr != nil && [arr count] > 0) {
                        [commentArr addObjectsFromArray:arr];
                    }
                }
                loading = NO;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicatorView stopAnimating];
            [tableViewC reloadData];
        });
    });
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

// type 为0表示全部的刷新，为1表示音频需要释放，type为2 为其他表示音频不需要释放 type为3表示时间
- (void)tableViewReloadData:(NSMutableDictionary *)dic type:(int)type
{
    if (type == 0) {
        tableViewC.contentOffset = CGPointMake(0.f, 0.f);
        
        self.itemDic = dic;
        
        NSArray *arr = [self.itemDic objectForKey:@"pics"];
        
        [picsArray removeAllObjects];
        if (arr.count > 0) {
            [picsArray addObjectsFromArray:arr];
        }
        
        //请求评论列表数据
        [self accessItemService:[[self.itemDic objectForKey:@"new_id"] intValue]];
        
        [tableViewC reloadData];
    } else if (type == 1 || type == 2) {
        UITableViewCell *cell = [tableViewC cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        RollImageView *imageView = (RollImageView *)[cell viewWithTag:100];
        if (!imageView.hidden) {
            if (type == 1) {
                [imageView setPlayer:0];
            } else {
                [imageView setPlayer:1];
            }
        }
    } else {
        [picsScrollView invalidateSingle];
    }
}

// 视频弹窗按钮
- (void)mediaClickBtn:(UIButton *)btn
{
    if ([delegate respondsToSelector:@selector(InformationView:)]) {
        [delegate InformationView:self];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1){
        return [commentArr count];
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            static NSString *str = @"TableViewCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];

            if (cell == nil) {
                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                picsScrollView = [[SingleScrollView alloc] initWithFrame:CGRectMake(0.f,0.f, picWidth, picHeight)];
                picsScrollView.delegate = self;
                [cell addSubview:picsScrollView];
                
                UIImage *img = [UIImage imageCwNamed:@"icon_video_play.png"];
                UIButton *mediaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                mediaBtn.frame = CGRectMake(20.f, 180.f, img.size.width, img.size.height);
                mediaBtn.tag = 11;
                [mediaBtn setBackgroundImage:[UIImage imageCwNamed:@"icon_video_play.png"] forState:UIControlStateNormal];
                [mediaBtn addTarget:self action:@selector(mediaClickBtn:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:mediaBtn];
            }
            
            UIButton *mediaBtn = (UIButton *)[cell viewWithTag:11];
            NSArray *arr = [self.itemDic objectForKey:@"media"];
            if (arr.count > 0) {
                mediaBtn.hidden = NO;
            } else {
                mediaBtn.hidden = YES;
            }

            return cell;
        } else if (indexPath.row == 1 || indexPath.row == 2) {
            static NSString *str = @"TableViewContentCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel *iTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 320 - 20, 45)];
                iTitleLabel.backgroundColor = [UIColor clearColor];
                iTitleLabel.tag = 1;
                iTitleLabel.textColor = [UIColor blackColor];
                iTitleLabel.numberOfLines = 2;
                iTitleLabel.font = [UIFont systemFontOfSize:15.0f];
                [cell addSubview:iTitleLabel];
                [iTitleLabel release];
                
                UILabel *iTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(iTitleLabel.frame), 320 - 20, 20)];
                iTimeLabel.tag = 2;
                iTimeLabel.backgroundColor = [UIColor clearColor];
                iTimeLabel.textColor = [UIColor grayColor];
                iTimeLabel.font = [UIFont systemFontOfSize:12.0f];
                [cell addSubview:iTimeLabel];
                [iTimeLabel release];
                
                RollImageView *imageView = [[RollImageView alloc]initWithFrame:CGRectMake(15.f, CGRectGetMaxY(iTimeLabel.frame)+10.f, 290.f, 40.f)];
                imageView.image = [UIImage imageCwNamed:@"pic_music_bg.png"];
                imageView.tag = 100;
                [cell addSubview:imageView];
                [imageView release];
                
                //12.10 chenfeng add 
                CWLabel *iContentLabel = [[CWLabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(imageView.frame) + 10.f, 280, 10)];
                iContentLabel.tag = 3;
                iContentLabel.backgroundColor = [UIColor clearColor];
                iContentLabel.textColor = [UIColor darkGrayColor];
                iContentLabel.font = [UIFont fontWithName:@"Arial" size:14];
                [cell addSubview:iContentLabel];
                [iContentLabel release];
                
                cell.backgroundColor = [UIColor clearColor];
            }
            
            UILabel *iTitleLabel = (UILabel *)[cell viewWithTag:1];
            iTitleLabel.text = [self.itemDic objectForKey:@"title"];
            
            int createTime = [[self.itemDic objectForKey:@"created"] intValue];
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
            NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
            [outputFormat setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            NSString *dateString = [outputFormat stringFromDate:date];
            [outputFormat release];
            
            UILabel *iTimeLabel = (UILabel *)[cell viewWithTag:2];
            iTimeLabel.text = dateString;
            
            RollImageView *imageView = (RollImageView *)[cell viewWithTag:100];
            NSString *music = [self.itemDic objectForKey:@"music"];
            if ([music length] > 0) {
                imageView.frame = CGRectMake(15.f, CGRectGetMaxY(iTimeLabel.frame) + 10.f, 290.f, 40.f);
                imageView.url = [NSURL URLWithString:music];
                imageView.hidden = NO;
            } else {
                imageView.frame = CGRectMake(15.f, CGRectGetMaxY(iTimeLabel.frame), 290.f, 0.f);
                imageView.hidden = YES;
            }
            
            // 12.10 chenfeng add
            CWLabel *iContentLabel = (CWLabel *)[cell viewWithTag:3];
            
            NSString *labelString = [self.itemDic objectForKey:@"content"];
            NSString *myString = [labelString stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
            NSString *contentStr = [myString stringByReplacingOccurrencesOfString:@"\n \n" withString:@"\n"];
            NSString *contentStr2 = [contentStr stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n"];
            
            [iContentLabel setText:contentStr2];
            // 计算内容高度
            //CGSize titleSize = [YLLabelView height:labelString Font:14 Character:0 Line:6 Pragraph:5];
            
            int strHeight;
            if (cwHeight < 20) {
                strHeight = 20;
            }else {
                strHeight = cwHeight;
            }
            
            iContentLabel.frame = CGRectMake(20, CGRectGetMaxY(imageView.frame) + 10.f, 280, strHeight +10);

            return cell;
        }
    } else if (indexPath.section == 1)  {
        static NSString *str = @"CommentsCell";
        
        CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[[CommentsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *dic = nil;
        if (commentArr.count > 0) {
            dic = [commentArr objectAtIndex:indexPath.row];
        }
        
        if (commentSum == indexPath.row + 1) {
            [cell setCellContentAndFrame:dic imgFlag:NO];
        } else {
            [cell setCellContentAndFrame:dic imgFlag:YES];
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            
            //图片
            NSString *picUrl = [dic objectForKey:@"portrait"];
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
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
   
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *groudView = [[UIImageView alloc]initWithFrame:CGRectZero];
    groudView.frame = CGRectMake(10.f, 0.f, KUIScreenWidth-20.f, 40.f);
    groudView.userInteractionEnabled = YES;
    [view addSubview:groudView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = KCWSystemFont(15.f);
    [groudView addSubview:label];
    
    if (section == 1) {             // 评论头
        view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, 40.f);
        
        groudView.image = [UIImage imageCwNamed:@"on_form_comments.png"];
        
        label.frame = CGRectMake(35.f, 0.f, 200.f, 40.f);
        label.text = [NSString stringWithFormat:@"%d条评论",commentSum];
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(10.f, 10.f, 20.f, 20.f)];
        img.image = [UIImage imageCwNamed:@"icon_comment_store.png"];
        [groudView addSubview:img];
        [img release], img = nil;
        
    } else if (section == 2) {      // 评论尾
        view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, 40.f);
        
        groudView.image = [UIImage imageCwNamed:@"next_form_comments.png"];
        
        label.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(view.frame), 40.f);
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = loadingTag;
        
        int count = commentArr.count;
        if (count % 20 == 0 && count > 0) {
            label.text = @"查看更多";
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(view.frame), 40.f);
            [btn addTarget:self action:@selector(btnCheakMoreClick:) forControlEvents:UIControlEventTouchUpInside];
            [groudView addSubview:btn];
        } else if (count % 20 != 0 && count > 0) {
            //label.text = @"没有更多评论";
        } else {
            label.text = @"目前没有评论，快来抢沙发吧！";
        }
        
        //添加loading图标
		indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
		[indicatorView setCenter:CGPointMake(320 / 3, 40 / 2.0)];
		indicatorView.hidesWhenStopped = YES;
		[groudView addSubview:indicatorView];
    }
    
    [label release], label = nil;
    [groudView release], groudView = nil;

    return [view autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.f;
    
    if (section == 1) {
        height = 40.f;
    } else if (section == 2) {
        int count = commentArr.count;
        if (count % 20 != 0 && count > 0) {
            height = 0.f;
        } else {
            height = 40.f;
        }
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = 240;
        } else if (indexPath.row == 1 || indexPath.row == 2) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            
            // 12.10 chenfeng add 
            NSString *str = [self.itemDic objectForKey:@"content"];
            NSString *myString = [str stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
            NSString *contentStr = [myString stringByReplacingOccurrencesOfString:@"\n \n" withString:@"\n"];
            NSString *contentStr2 = [contentStr stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n"];
            
            // 计算内容高度
            CGSize titleSize = [YLLabelView height:contentStr2 Font:14 Character:0 Line:6 Pragraph:5];
            
            cwHeight = titleSize.height;
            
            int strHeight;
            if (cwHeight < 20) {
                strHeight = 20;
            }else {
                strHeight = cwHeight +20;
            }
            
            if ([[self.itemDic objectForKey:@"music"] length] > 0) {
                height = 70 + strHeight + 5 + 60;
            } else {
                height = 70 + strHeight + 5 + 10;
            }
            
            [pool release];
        }
    } else if (indexPath.section == 1) {
        NSDictionary *dic = nil;
        if (commentArr.count > 0) {
            dic = [commentArr objectAtIndex:indexPath.row];
        }
        height = [CommentsCell getCellHeight:dic];
    }

    return height;
}

#pragma mark - SingleScrollViewDelegate
- (NSInteger)numberOfPagesSingle:(SingleScrollView *)singleScrollView
{
    return [picsArray count];
}

- (CWImageView *)pageSingleReturnEachView:(SingleScrollView *)singleScrollView pageIndex:(NSInteger)aindex
{
    CWImageView *view = [[[CWImageView alloc]initWithFrame:CGRectMake(aindex*KUIScreenWidth , 0.f , KUIScreenWidth , picHeight)] autorelease];

    NSDictionary *adDic = [picsArray objectAtIndex:aindex];
    
    //图片
    view.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        NSString *picUrl = [adDic objectForKey:@"img_path"];
        NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
        
        if (picUrl.length > 1) {
            UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(picWidth, picHeight)];
            if (pic.size.width > 2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    view.image = pic;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
                    view.image = defaultPic;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:aindex inSection:20000];
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
                view.image = defaultPic;
            });
        }
        
        [pool release];
    });

    return view;
}

//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        
        if (iconDownloader != nil)
        {
            // Display the newly loaded image
            if(iconDownloader.cardIcon.size.width > 2.0)
            {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url ];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [picsScrollView reloadScrollViewImage:iconDownloader.cardIcon index:iconDownloader.indexPathInTableView.row];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
        
        [pool release];
    });
    
    
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - CWImageViewDelegate
- (NSMutableArray *)getScrollViewCWImageView
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (id view in picsScrollView.scrollView.subviews) {
        if ([view isKindOfClass:[CWImageView class]]) {
            [arr addObject:view];
        }
    }
    return arr;
}

- (void)touchCWImageView:(CWImageView *)imageView
{
    if (CWPview == nil) {
        CWPview = [[CWPictureView alloc]initWithclickIndex:imageView.tag];
    } else {
        CWPview.selectIndex = imageView.tag;
    }
    
    CWPview.delegate = self;
    
    NSMutableArray *arr = [self getScrollViewCWImageView];
    
    CWPview.CwPictureViewClose = ^ {
//        [CWPview release], CWPview = nil;
    };
    
    [CWPview setPictureView:arr];
}

#pragma mark - CWPictureViewDelegate
- (void)cwPictureViewSetPage:(int)page
{
    [picsScrollView setCurrentPage:page];
}
@end
