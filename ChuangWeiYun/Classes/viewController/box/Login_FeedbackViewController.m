//
//  Login_FeedbackViewController.m
//  cw
//
//  Created by LuoHui on 13-9-12.
//
//

#import "Login_FeedbackViewController.h"
#import "UIImageScale.h"
#import "system_config_model.h"
#import "member_info_model.h"
#import "Common.h"
#import "FileManager.h"
#import "Global.h"
#import "IconPictureProcess.h"
#import "shop_near_list_model.h"
#import "feedback_list_model.h"
#import "HttpRequest.h"
#import "NetworkFail.h"

#define KCommentBarHeight 50 
@interface Login_FeedbackViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
    BOOL _isNavHide;
}
@end

@implementation Login_FeedbackViewController
@synthesize myTableView = _myTableView;
@synthesize listArray = __listArray;
@synthesize tempTextContent;
@synthesize cloudLoading;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //注册键盘通知
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        
        __listArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        _isNavHide = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        _isNavHide = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isNavHide) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
    
    shop_near_list_model *snlModel = [[shop_near_list_model alloc] init];
    snlModel.where = [NSString stringWithFormat:@"id = %@",[Global sharedGlobal].shop_id];
    NSMutableArray *dbArr = [snlModel getList];
    [snlModel release];
    
    NSString *titleStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"isFeedbackShop"];
    if (titleStr.length > 0) {
        self.title = titleStr;
    }else {
        if ([dbArr count] > 0) {
            self.title = [[dbArr objectAtIndex:0] objectForKey:@"name"];
        }else {
            self.title = @"留言反馈";
        }
    }
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, KUIScreenHeight - KUpBarHeight - KCommentBarHeight) style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.scrollEnabled = YES;
	[_myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_myTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_myTableView];
    
    [self addCommentView];
    
    //下拉刷新控件
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc]
										   initWithFrame:CGRectMake(0.0f, 0.0f - self.myTableView.bounds.size.height, self.view.frame.size.width, self.myTableView.bounds.size.height)];
		view.delegate = self;
		[self.myTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self accessService];
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
    [tempTextContent release];
    if (failView) {
        [failView release], failView = nil;
    }
    [super dealloc];
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
		return [self.listArray count];
        //return 20;
	}else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section ==0) {
		//return 80.0f;
        if (self.listArray != nil && [self.listArray count] > 0) {
            NSDictionary *commentDic = [self.listArray objectAtIndex:[indexPath row]];
			NSString *text = [commentDic objectForKey:@"content"];
			float length = text.length * 20;
            float width = length > 200 ? 200 : length;
            CGSize titleSize = [text sizeWithFont:[UIFont systemFontOfSize:16]
                                constrainedToSize:CGSizeMake(width,MAXFLOAT)
                                    lineBreakMode:UILineBreakModeWordWrap];
            //20为气泡上下间隔,50为头像高度 30为时间高度
            CGFloat height = (titleSize.height + 20) > 50 ? titleSize.height + 20 : 50;
			return height + 10 + 30;
        }else {
            return 0;
        }
	}else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    //cell = nil;
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] init];
        view.tag = 'v';
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 'i';
        [view addSubview:imageView];
        [imageView release];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectZero;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:16];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 'l';
        label.textAlignment = UITextAlignmentLeft;
        [view addSubview:label];
        [label release];
        
        [cell.contentView addSubview:view];
        [view release];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        timeLabel.text = @"";
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.tag = 1;
        timeLabel.font = [UIFont systemFontOfSize:14.0f];
        timeLabel.textAlignment = UITextAlignmentCenter;
        timeLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:timeLabel];
        [timeLabel release];
        
        TalkStatusView *talkView = [[TalkStatusView alloc] initWithFrame:CGRectMake(400, 0, 20, 20)];
        talkView.tag = 't';
        [cell.contentView addSubview:talkView];
        [talkView release];
        
        UIImageView *headerImageView = [[UIImageView alloc] init];
        headerImageView.tag = 'a';
        [cell.contentView addSubview:headerImageView];
        headerImageView.layer.masksToBounds = YES;
        headerImageView.layer.cornerRadius = 25;
        [headerImageView release];
        
    }
    
    if (self.listArray != nil && [self.listArray count] > 0)
    {
        NSMutableDictionary *dic = [self.listArray objectAtIndex:[indexPath row]];
        
//        if (!(indexPath.row == 0 && [[dic objectForKey:@"shop_talk"] intValue] == 1)) {
//            
//        }
        UILabel *time = (UILabel *)[cell.contentView viewWithTag:1];
        int createTime = [[dic objectForKey:@"created"] intValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:createTime];
        NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
        [outputFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *dateString = [outputFormat stringFromDate:date];
        time.text = dateString;
        [outputFormat release];
        
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:'l'];
        label.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"content"]];
        float length = label.text.length * 20;
        float width = length > 200 ? 200 : length;
        CGSize titleSize = [label.text sizeWithFont:[UIFont systemFontOfSize:16]
                                  constrainedToSize:CGSizeMake(width,MAXFLOAT)
                                      lineBreakMode:UILineBreakModeWordWrap];
        
        UIView *view = (UIView *)[cell.contentView viewWithTag:'v'];
        
        int senderId = [[dic objectForKey:@"shop_talk"] intValue];
        if (senderId == 1)
        {
            view.frame = CGRectMake(70, 30,  titleSize.width+20, titleSize.height+10);
            
//            UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 50, 50)];
//            headerImageView.tag = 'a';
//            [cell.contentView addSubview:headerImageView];
//            headerImageView.layer.masksToBounds = YES;
//            headerImageView.layer.cornerRadius = 25;
            
            UIImageView *headerImageView = (UIImageView *)[cell.contentView viewWithTag:'a'];
            headerImageView.frame = CGRectMake(10, 25, 50, 50);
            
            UIImage *headerImage = [UIImage imageCwNamed:@"portrait_feedback.png"];
            headerImageView.image = headerImage;
            
            NSString *picUrl = [dic objectForKey:@"manager_portrait"];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (picUrl.length > 1)
            {
                UIImage *pic = [[FileManager getPhoto:picName] fillSize:CGSizeMake(50, 50)];
                if (pic.size.width > 2)
                {
                    headerImageView.image = pic;
                }
                else
                {
                    NSLog(@"picUrl === %@",picUrl);
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
                }
            }
            
            label.frame = CGRectMake(15, 10, titleSize.width, titleSize.height);
            //RELEASE_SAFE(headerImageView);
        }
        else
        {
            UIImage *headerImage = [UIImage imageCwNamed:@"portrait_feedback.png"];
            
//            UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320-60, 25, 50, 50)];
//            [cell.contentView addSubview:headerImageView];
//            headerImageView.image = [headerImage fillSize:CGSizeMake(50, 50)];
//            headerImageView.layer.masksToBounds = YES;
//            headerImageView.layer.cornerRadius = 25;
            
            UIImageView *headerImageView = (UIImageView *)[cell.contentView viewWithTag:'a'];
            headerImageView.frame = CGRectMake(320-60, 25, 50, 50);
            headerImageView.image = [headerImage fillSize:CGSizeMake(50, 50)];
            
            view.frame = CGRectMake(320-70-titleSize.width - 20, 30,  titleSize.width+20, titleSize.height+50);
            
            //获取会员信息
            system_config_model *remember = [[system_config_model alloc] init];
            remember.where = [NSString stringWithFormat:@"tag ='%@'",@"RememberName"];
            NSArray *curLocArray = [remember getList];
            RELEASE_SAFE(remember);
            
            member_info_model *info=[[member_info_model alloc]init];
            info.where=[NSString stringWithFormat:@"username ='%@'",[[curLocArray objectAtIndex:0]objectForKey:@"value"]];
            NSMutableArray *userInfoArray=[info getList];
            RELEASE_SAFE(info);
            
            NSString *piclink = [[userInfoArray objectAtIndex:0]objectForKey:@"portrait"];
            NSString *photoname = [Common encodeBase64:(NSMutableData *)[piclink dataUsingEncoding: NSUTF8StringEncoding]];
            UIImage *img = [FileManager getPhoto:photoname];
            if (img != nil) {
                
                headerImageView.image = [img fillSize:CGSizeMake(50, 50)];
            }
            
            label.frame = CGRectMake(10, 10, titleSize.width, titleSize.height);
            //RELEASE_SAFE(headerImageView);
            
            int sta = [[dic objectForKey:@"type"] intValue];
            UIImage *failImg = [UIImage imageCwNamed:@"refresh_fail_feedback.png"];
            
            TalkStatusView *talkView = (TalkStatusView *)[cell.contentView viewWithTag:'t'];
            talkView.delegate = self;
            talkView.currentTime = [[dic objectForKey:@"created"] intValue];
            talkView.frame = CGRectMake(view.frame.origin.x - 25, 30 + (view.frame.size.height - 50)* 0.5, failImg.size.width, failImg.size.height);
            [talkView setCurrectStatus:sta-1];
        }
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:'i'];
        UIImage *balloonImg = nil;
        if (senderId == 1)
        {
            balloonImg = [UIImage imageNamed:@"balloon_l_feedback.png"];
        }
        else
        {
            balloonImg = [UIImage imageNamed:@"balloon_r_feedback.png"];
        }
        
        balloonImg = [balloonImg stretchableImageWithLeftCapWidth:23 topCapHeight:23];
        imgView.frame = CGRectMake(0, 0, titleSize.width+25, titleSize.height+20);
        imgView.image = balloonImg;
        
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
            
            UIImage *photo = [iconDownloader.cardIcon fillSize:CGSizeMake(50, 50)];
            
            UITableViewCell *cell = (UITableViewCell *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            UIImageView *vi = (UIImageView *)[cell viewWithTag:'a'];
            vi.image = photo;
            
            [self.myTableView reloadData];
		}
        
        [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark 键盘通知调用
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
	
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
	
    UIButton *bgBtn = (UIButton *)[self.view viewWithTag:2005];
    if (bgBtn != nil) {
        [bgBtn removeFromSuperview];
    }
	//新增一个遮罩按钮
	UIButton *backGrougBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	backGrougBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (keyboardBounds.size.height + containerFrame.size.height) - 20);
	backGrougBtn.tag = 2005;
	[backGrougBtn addTarget:self action:@selector(hiddenKeyboard) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backGrougBtn];
	
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
    
    self.myTableView.frame = CGRectMake(0, 0, 320, 371);
    
	// commit animations
	[UIView commitAnimations];
    
    //改变tableView的大小以及位置
    [self performSelector:@selector(setTableViewSizeAndOrigin) withObject:nil afterDelay:[duration doubleValue]];
	
	//更改按钮状态
	[self buttonChange:YES];
	
}

-(void) keyboardWillHide:(NSNotification *)note{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    self.myTableView.frame = CGRectMake(0, 0 - keyboardBounds.size.height, 320, 124);
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
    
    self.myTableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - KCommentBarHeight);
    
	// commit animations
	[UIView commitAnimations];
    
	//移出遮罩按钮
	UIButton *backGrougBtn = (UIButton *)[self.view viewWithTag:2005];
	[backGrougBtn removeFromSuperview];
	
	//更改按钮状态
	[self buttonChange:NO];
}

//关闭键盘
-(void)hiddenKeyboard
{
    //输入内容 存起来
	self.tempTextContent = textView.text;
	textView.text = @"说两句吧...";
	textView.textColor = [UIColor grayColor];
	[textView resignFirstResponder];
}
#pragma mark 改变键盘按钮
-(void)buttonChange:(BOOL)isKeyboardShow
{
	//判断软键盘显示
	if (isKeyboardShow)
	{
        UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
        
        //缩小输入框
        if (sendBtn.hidden)
        {
            UIView *entryImageView = (UIView *)[containerView viewWithTag:2000];
            CGRect entryFrame = entryImageView.frame;
            entryFrame.size.width -= 65.0f;
            
            CGRect textFrame = textView.frame;
            textFrame.size.width -= 65.0f;
            
            entryImageView.frame = entryFrame;
            textView.frame = textFrame;
        }
		
		//显示字数统计
		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
		remainCountLabel.hidden = NO;
		
		//显示发送按钮
		sendBtn.hidden = NO;
        
	}
	else
	{
		//拉长输入框
        //隐藏字数统计
		UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
		remainCountLabel.hidden = YES;
		
		//隐藏发送按钮
		UIButton *sendBtn = (UIButton *)[containerView viewWithTag:2003];
		sendBtn.hidden = YES;
        
		UIView *entryImageView = (UIView *)[containerView viewWithTag:2000];
		CGRect entryFrame = entryImageView.frame;
		entryFrame.size.width += 65.0f;
		
		CGRect textFrame = textView.frame;
		textFrame.size.width += 65.0f;
		
		entryImageView.frame = entryFrame;
		textView.frame = textFrame;
		
	}
    
}

#pragma mark 点击监听
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//输入内容 存起来
	self.tempTextContent = textView.text;
	textView.text = @"说两句吧...";
	textView.textColor = [UIColor grayColor];
    
	[textView resignFirstResponder];
}

#pragma mark -----HPGrowingTextViewDelegate methods
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
	
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
    
    UIView *entryImageView = (UIView *)[containerView viewWithTag:2000];
    CGRect entryFrame = entryImageView.frame;
    entryFrame.size.height -= diff;
    entryImageView.frame = entryFrame;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    return YES;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
	if([growingTextView.text isEqualToString:@"说两句吧..."])
	{
		//内容设置回来
		growingTextView.text = self.tempTextContent;
	}
	growingTextView.textColor = [UIColor blackColor];
	
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	[self performSelectorOnMainThread:@selector(doEditing) withObject:nil waitUntilDone:NO];
	return YES;
}

#pragma mark Data Source Loading / Reloading Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)reloadTableViewDataSource{
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.myTableView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self accessMoreService];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark --- methods
- (void)addCommentView
{
    NSLog(@"=== %f",KUIScreenHeight);
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, KUIScreenHeight - KUpBarHeight - KCommentBarHeight, 320, KCommentBarHeight)];
    containerView.backgroundColor = [UIColor colorWithRed:0.9569 green:0.9569 blue:0.9569 alpha:1];
    [self.view addSubview:containerView];
    
    UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(5,5, 310, KCommentBarHeight - 10)];
    textBgView.layer.cornerRadius = 3;
    textBgView.layer.masksToBounds = YES;
    textBgView.backgroundColor = [UIColor whiteColor];
    textBgView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor;
    textBgView.layer.borderWidth = 1;
    textBgView.tag = 2000;
    [containerView addSubview:textBgView];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, 310, textBgView.frame.size.height)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 3;
	//textView.returnKeyType = UIReturnKeyNext; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
    textView.textColor = [UIColor grayColor];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    textView.text = @"说两句吧...";
	[textBgView addSubview:textView];
    [textBgView release];
    
    //字数统计
	UILabel *remainCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(265.0f, 5.0f, 50.0f, 20.0f)];
	[remainCountLabel setFont:[UIFont systemFontOfSize:12.0f]];
	remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	remainCountLabel.tag = 2004;
	remainCountLabel.text = @"140/140";
	remainCountLabel.hidden = YES;
	remainCountLabel.backgroundColor = [UIColor clearColor];
	remainCountLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
	remainCountLabel.textAlignment = UITextAlignmentCenter;
	[containerView addSubview:remainCountLabel];
	[remainCountLabel release];
	
	//添加发送按钮
	UIImage *sendBtnBackground = [[UIImage imageNamed:@"green_button.png"] stretchableImageWithLeftCapWidth:30 topCapHeight:16];
	UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"green_button.png"] stretchableImageWithLeftCapWidth:30 topCapHeight:16];
	
	UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	sendBtn.frame = CGRectMake(containerView.frame.size.width - 65, 5, 60, KCommentBarHeight - 10);
	sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[sendBtn setTitle:@"发送" forState:UIControlStateNormal];
	[sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
	sendBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
	sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
	sendBtn.tag = 2003;
	sendBtn.hidden = YES;
	[sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sendBtn addTarget:self action:@selector(publishComment:) forControlEvents:UIControlEventTouchUpInside];
	[sendBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
	[sendBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:sendBtn];
}

-(void)doEditing
{
	UILabel *remainCountLabel = (UILabel *)[containerView viewWithTag:2004];
	int textCount = [textView.text length];
	if (textCount > 140)
	{
		remainCountLabel.textColor = [UIColor colorWithRed:1.0 green: 0.0 blue: 0.0 alpha:1.0];
	}
	else
	{
		remainCountLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
	}
	
	remainCountLabel.text = [NSString stringWithFormat:@"%d/140",140 - [textView.text length]];
}

- (void)setTableViewSizeAndOrigin
{
    self.myTableView.frame = CGRectMake(0, 0, 320, 124);
    
    //滚动到最后一行
    if ([self.listArray count] > 0)
    {
        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:NO];
    }
}

- (NSMutableDictionary *)appendTableWith:(NSString *)text
{
    //把回车 转化成 空格
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    self.myTableView.scrollEnabled = YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:11];
    if (label != nil) {
        [label removeFromSuperview];
    }
    
    //填充数据
    int oldCount = [self.listArray count];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:[[Global sharedGlobal].user_id intValue]],@"userId",
                                text,@"content",
                                [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]],@"created",
                                @"",@"manager_portrait",
                                @"",@"portrait",
                                [NSNumber numberWithInt:0],@"shop_talk",
                                [NSNumber numberWithInt:4],@"type",
                                [NSNumber numberWithInt:[[Global sharedGlobal].shop_id intValue]],@"shopId",nil];
    
    
    [self.listArray addObject:dic];
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:1];
    
    NSIndexPath *insertNewPath = [NSIndexPath indexPathForRow:oldCount inSection:0];
    [insertIndexPaths addObject:insertNewPath];
    
    if ([self.listArray count] != 0 )
    {
        
        [self.myTableView insertRowsAtIndexPaths:insertIndexPaths
                                withRowAnimation:UITableViewRowAnimationFade];
        
        //滚动到最后一行
        if ([self.listArray count] > 0)
        {
            [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                                    atScrollPosition:UITableViewScrollPositionBottom
                                            animated:NO];
        }
        
        [self.myTableView reloadRowsAtIndexPaths:insertIndexPaths
                                withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        [self.myTableView insertRowsAtIndexPaths:insertIndexPaths
                                withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:[[Global sharedGlobal].user_id intValue]],@"userId",
                                 text,@"content",
                                 [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]],@"created",
                                 @"",@"manager_portrait",
                                 @"",@"portrait",
                                 [NSNumber numberWithInt:0],@"shop_talk",
                                 [NSNumber numberWithInt:2],@"type",
                                 [NSNumber numberWithInt:[[Global sharedGlobal].shop_id intValue]],@"shopId",nil];
    //插入数据库
    feedback_list_model *fbPMod = [[feedback_list_model alloc] init];
    [fbPMod insertDB:dic1];
    [fbPMod release];
    
    [_myTableView reloadData];
    return dic;
}

//发表评论
-(void)publishComment:(id)sender
{
    NSString *content = textView.text;
    //NSLog(@"content===%@",content);
    //把回车 转化成 空格
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    if ([content length] > 0)
    {
        if ([content length] > 140)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"回复内容不能超过140个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            NSMutableDictionary *dic =  [self appendTableWith:textView.text];
            
            int created = [[[self.listArray objectAtIndex:[self.listArray count] - 1] objectForKey:@"created"] intValue];
            
            NSString *reqUrl = @"member/feedback.do?param=";
            
            NSString *userId = [Global sharedGlobal].user_id;
            NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               [Global sharedGlobal].shop_id,@"shop_id",
                                               [NSNumber numberWithInt: [userId intValue]],@"user_id",
                                               content,@"content",
                                               [NSNumber numberWithInt:created],@"create",nil];
            
            [[NetManager sharedManager] accessService:requestDic data:nil command:SEND_FEEDBACK_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
            
            feedback_list_model *fbPMod = [[feedback_list_model alloc] init];
            fbPMod.where = [NSString stringWithFormat:@"created = %d and userId = %d and shopId = %d",[[dic objectForKey:@"create"] intValue],[userId intValue],[[Global sharedGlobal].shop_id intValue]];
            NSMutableArray *dbArray = [fbPMod getList];
            if ([dbArray count] > 0)
            {
                NSMutableDictionary *infoDic = [dbArray objectAtIndex:0];
                [infoDic setObject:[NSNumber numberWithInt:3] forKey:@"type"];
                [fbPMod updateDB:infoDic];
            }
            fbPMod.where = nil;
            [fbPMod release];
            
            //初始化
            tempTextContent = @"";
            textView.text = @"";
            
            [_myTableView reloadData];
        }
    }
    else
    {
        [self hiddenKeyboard];
    }
}

- (void)messageSendResult:(NSMutableArray *)resultArray
{
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        NSDictionary *dic = [resultArray objectAtIndex:0];
        
        feedback_list_model *fbPMod = [[feedback_list_model alloc] init];
        
        NSString *ret = [dic objectForKey:@"ret"];
        if ([ret intValue] == 1) {
            fbPMod.where = [NSString stringWithFormat:@"created = %d and userId = %d and shopId = %d",[[dic objectForKey:@"create"] intValue],[[Global sharedGlobal].user_id intValue],[[Global sharedGlobal].shop_id intValue]];
            NSMutableArray *dbArray = [fbPMod getList];
            if ([dbArray count] > 0)
            {
                NSMutableDictionary *infoDic = [dbArray objectAtIndex:0];
                [infoDic setObject:[NSNumber numberWithInt:[[dic objectForKey:@"server_create"] intValue]] forKey:@"created"];
                [infoDic setObject:[NSNumber numberWithInt:1] forKey:@"type"];
                [fbPMod updateDB:infoDic];
            }
            fbPMod.where = nil;
        }else {
            fbPMod.where = [NSString stringWithFormat:@"created = %d and userId = %d and shopId = %d",[[dic objectForKey:@"create"] intValue],[[Global sharedGlobal].user_id intValue],[[Global sharedGlobal].shop_id intValue]];
            NSMutableArray *dbArray = [fbPMod getList];
            if ([dbArray count] > 0)
            {
                NSMutableDictionary *infoDic = [dbArray objectAtIndex:0];
                [infoDic setObject:[NSNumber numberWithInt:2] forKey:@"type"];
                [fbPMod updateDB:infoDic];
            }
            fbPMod.where = nil;
        }
        
        fbPMod.orderBy = @"created";
        fbPMod.orderType = @"asc";
        fbPMod.where = [NSString stringWithFormat:@"userId = %d and shopId = %d",[[Global sharedGlobal].user_id intValue],[[Global sharedGlobal].shop_id intValue]];
        self.listArray = [fbPMod getList];
        fbPMod.where = nil;
        [fbPMod release];
        
        [_myTableView reloadData];
    }
}

- (void)accessService
{
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    NSString *reqUrl = @"member/lookfeedback.do?param=";
    
    NSString *user_Id = [Global sharedGlobal].user_id;
    
    NSString *shopId = nil;
    NSString *_shopIdStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"isFeedbackMsg"];
    if (_shopIdStr != nil && [_shopIdStr intValue] > 0) {
        shopId = _shopIdStr;
    }else {
        shopId = [Global sharedGlobal].shop_id;
    }
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt: [user_Id intValue]],@"user_id",
                                       shopId,@"shop_id",nil];
    //NSLog(@"=== %@",requestDic);
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:LOGIN_FEEDBACK_LIST_COMMAND_ID accessAdress:reqUrl delegate:self withParam:requestDic];
}

- (void)accessMoreService{
    if ([self.listArray count] == 0) {
        //下拉缩回
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
    }else {
        int last = [[[self.listArray objectAtIndex:0] objectForKey:@"created"] intValue];
        NSLog(@"last === %d",last);
        NSString *reqUrl = @"member/lookfeedback.do?param=";
        
        NSString *user_Id = [Global sharedGlobal].user_id;
        
        NSString *shopId = nil;
        NSString *_shopIdStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"isFeedbackMsg"];
        if (_shopIdStr != nil && [_shopIdStr intValue] > 0) {
            shopId = _shopIdStr;
        }else {
            shopId = [Global sharedGlobal].shop_id;
        }
        
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt: [user_Id intValue]],@"user_id",
                                           [NSNumber numberWithInt: last],@"created",
                                           shopId,@"shop_id",nil];
        
        [[NetManager sharedManager] accessService:requestDic data:nil command:FEEDBACK_LIST_MORE_COMMAND_ID accessAdress:reqUrl delegate:self withParam:requestDic];
        
    }
}

- (void)getMoreResult:(NSMutableArray *)resultArray
{
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([resultArray count] > 0 && [resultArray count] <= 20)
        {
            //int oldCount = [self.listArray count];
            
            //填充数组
            for (int i = [resultArray count]-1; i >= 0; i--)
            {
                NSMutableDictionary *item = [resultArray objectAtIndex:i];
                [self.listArray insertObject:item atIndex:0];
            }
            
            [self.myTableView reloadData];
        }
        
        //下拉缩回
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:NO];
    }
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	switch (commandid) {
		case LOGIN_FEEDBACK_LIST_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
            
		}break;
        case SEND_FEEDBACK_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(messageSendResult:) withObject:resultArray waitUntilDone:NO];
		}break;
        case FEEDBACK_LIST_MORE_COMMAND_ID:
		{
            [self performSelectorOnMainThread:@selector(getMoreResult:) withObject:resultArray waitUntilDone:NO];
		}break;
            
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

- (void)update:(NSMutableArray *)resultArray
{
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    
    NSString *shopId = nil;
    NSString *_shopIdStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"isFeedbackMsg"];
    if (_shopIdStr != nil && [_shopIdStr intValue] > 0) {
        shopId = _shopIdStr;
    }else {
        shopId = [Global sharedGlobal].shop_id;
    }
    
    feedback_list_model *fbPMod = [[feedback_list_model alloc] init];
    fbPMod.orderBy = @"created";
    fbPMod.orderType = @"asc";
    fbPMod.where = [NSString stringWithFormat:@"userId = %@ and shopId = %d",[Global sharedGlobal].user_id,[shopId intValue]];
    self.listArray = [fbPMod getList];
    [fbPMod release];
    
    //NSLog(@"self.listArray === %@",self.listArray);
    
	self.myTableView.scrollEnabled = YES;
    UILabel *label = (UILabel *)[self.view viewWithTag:11];
    if (label != nil) {
        [label removeFromSuperview];
    }
    
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([self.listArray count] == 0) {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 320, 40)];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"给我留言反馈哦！";
//            label.textAlignment = UITextAlignmentCenter;
//            label.textColor = [UIColor darkTextColor];
//            label.tag = 11;
//            [self.myTableView addSubview:label];
//            [label release];
        }
        
        [self.myTableView reloadData];
        
        //滚动到最后一行
        if ([self.listArray count] > 0)
        {
            [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listArray count]-1 inSection:0]
                                    atScrollPosition:UITableViewScrollPositionBottom
                                            animated:NO];
        }
        
        if (delegate != nil && [delegate respondsToSelector:@selector(accessServiceItemsSuccess)]) {
            [delegate accessServiceItemsSuccess];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isFeedbackMsg"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"isFeedbackShop"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark -- TalkStatusViewDelegate 
- (void)reSendaTalk:(int)talkTime
{
    NSString *content = nil;
    int created = 0;
    
    feedback_list_model *fbPMod = [[feedback_list_model alloc] init];
    fbPMod.where = [NSString stringWithFormat:@"created = %d and userId = %d and shopId = %d",talkTime,[[Global sharedGlobal].user_id intValue],[[Global sharedGlobal].shop_id intValue]];
    NSMutableArray *dbArray = [fbPMod getList];
    if ([dbArray count] > 0)
    {
        NSMutableDictionary *infoDic = [dbArray objectAtIndex:0];
        content = [infoDic objectForKey:@"content"];
        created = [[infoDic objectForKey:@"created"] intValue];
    }
    fbPMod.where = nil;
    [fbPMod release];
    
    NSString *reqUrl = @"member/feedback.do?param=";
    
    NSString *userId = [Global sharedGlobal].user_id;
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].shop_id,@"shop_id",
                                       [NSNumber numberWithInt: [userId intValue]],@"user_id",
                                       content,@"content",
                                       [NSNumber numberWithInt:created],@"create",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:SEND_FEEDBACK_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessService];
}
@end
