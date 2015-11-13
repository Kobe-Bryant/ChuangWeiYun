//
//  FeedbackViewController.m
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import "FeedbackViewController.h"
#import "UIImageScale.h"
#import "alertView.h"
#import "Global.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController
@synthesize myTextView;
@synthesize telTextField;
@synthesize progressHUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KCWViewBgColor;
	self.title = @"留言反馈";
    
    UIImage *telImgNormal = [UIImage imageCwNamed:@"complete.png"];
    UIImage *telImgClick = [UIImage imageCwNamed:@"complete_click.png"];
    UIButton *telButton = [UIButton buttonWithType:UIButtonTypeCustom];
    telButton.frame = CGRectMake(0.0f, 0.0f, telImgNormal.size.width, telImgNormal.size.height);
    [telButton addTarget:self action:@selector(publishFeedback) forControlEvents:UIControlEventTouchUpInside];
    [telButton setImage:telImgNormal forState:UIControlStateNormal];
    [telButton setImage:telImgClick forState:UIControlStateHighlighted];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:telButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    RELEASE_SAFE(rightBarButton);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = self.view.frame;
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    int bgViewHeight;
    if (KUIScreenHeight == 460) {
        bgViewHeight = 120;
    }else{
        bgViewHeight = 210;
    }
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, bgViewHeight)];
    bgView.layer.cornerRadius = 3;
    bgView.layer.masksToBounds = YES;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor;
    bgView.layer.borderWidth = 1;
    [self.view addSubview:bgView];
    
    UITextView *tempTextView = [[UITextView alloc]initWithFrame:CGRectMake(5.0f, 5.0f, bgView.frame.size.width, bgView.frame.size.height - 15)];
	tempTextView.returnKeyType = UIReturnKeyDefault; //just as an example
	tempTextView.font = [UIFont systemFontOfSize:16.0f];
	tempTextView.textColor = [UIColor darkTextColor];
	tempTextView.delegate = self;
    tempTextView.backgroundColor = [UIColor clearColor];
	tempTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	tempTextView.text = @"";
	self.myTextView = tempTextView;
	[self.view addSubview:self.myTextView];
	[tempTextView release];
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 3.0f, 290.0f, 40.0f)];
	tipLabel.tag = 100;
	tipLabel.font = [UIFont systemFontOfSize:14.0f];
	tipLabel.textColor = [UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
	tipLabel.text = @"建议留下联系方式以便我们更快的为您解决问题，有价值的反馈会获得优惠卷哦...";
	tipLabel.textAlignment = UITextAlignmentLeft;
    tipLabel.numberOfLines = 0;
    tipLabel.lineBreakMode = UILineBreakModeWordWrap;
	tipLabel.backgroundColor = [UIColor clearColor];
	[self.myTextView addSubview:tipLabel];
	[tipLabel release];
    
    UILabel *remainCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(260.0f, self.myTextView.frame.size.height + 5.0f, 50.0f, 15.0f)];
	remainCountLabel.tag = 200;
	remainCountLabel.font = [UIFont systemFontOfSize:12.0f];
	remainCountLabel.textColor = [UIColor grayColor];
	remainCountLabel.text = @"140/140";
	remainCountLabel.textAlignment = UITextAlignmentCenter;
	remainCountLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:remainCountLabel];
    remainCountLabel.hidden = YES;
	[remainCountLabel release];
    
    [bgView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(bgView.frame) + 5,80, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    label.text = @"联系方式：";
    label.textAlignment = UITextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15.0f];
    [self.view addSubview:label];
    [label release];
    
    UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),CGRectGetMaxY(bgView.frame) + 5, 225, 30)];
    textBgView.layer.cornerRadius = 3;
    textBgView.layer.masksToBounds = YES;
    textBgView.backgroundColor = [UIColor whiteColor];
    textBgView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor;
    textBgView.layer.borderWidth = 1;
    [self.view addSubview:textBgView];
    
    telTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 220, 30)];
    telTextField.font = [UIFont systemFontOfSize:16.0f];
    telTextField.textAlignment = UITextAlignmentLeft;
    telTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    telTextField.returnKeyType = UIReturnKeyDone;
    telTextField.keyboardType = UIKeyboardTypeNumberPad;
    telTextField.borderStyle = UITextBorderStyleNone;
    telTextField.backgroundColor = [UIColor clearColor];
    [telTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    //telTextField.placeholder = @"13800138000";
    [textBgView addSubview:telTextField];
    
    [textBgView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [myTextView release];
    [progressHUD release];
    [super dealloc];
}

#pragma mark -
#pragma mark TextView
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)tex
{
	
	[self performSelectorOnMainThread:@selector(doEditing) withObject:nil waitUntilDone:NO];
	
	return YES;
}

#pragma mark progressHUD委托
//在该函数 [progressHUD hide:YES afterDelay:1.0f] 执行后回调
- (void)hudWasHidden:(MBProgressHUD *)hud{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- mehtods
- (void)btnAction
{
    [self hideKeyBoard];
}

- (void)hideKeyBoard
{
    [myTextView resignFirstResponder];
    [telTextField resignFirstResponder];
}

//编辑中
-(void) doEditing
{
	UILabel *tipLabel = (UILabel *)[self.myTextView viewWithTag:100];
	[tipLabel removeFromSuperview];
	
	UILabel *remainCountLabel = (UILabel *)[self.view viewWithTag:200];
    remainCountLabel.hidden = NO;
    
	int textCount = [self.myTextView.text length];
	if (textCount > 140)
	{
		remainCountLabel.textColor = [UIColor colorWithRed:1.0 green: 0.0 blue: 0.0 alpha:1.0];
	}
	else
	{
		remainCountLabel.textColor = [UIColor grayColor];
	}
	
	remainCountLabel.text = [NSString stringWithFormat:@"%d/140",140 - [self.myTextView.text length]];
}

//发表反馈
-(void)publishFeedback
{
	NSString *content = self.myTextView.text;
	
	//把回车 转化成 空格
	content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
	content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
    
    if ([content length] == 0) {
        [alertView showAlert:@"请输入反馈内容"];
    }
//    else if ([self.telTextField.text length] > 11 ) {
//        [alertView showAlert:@"请输入正确的联系方式"];
//    }
    else {
        if ([content length] > 140)
		{
			[alertView showAlert:@"反馈内容不能超过140个字符"];
		}
		else
		{
			[self accessServiceSubmit];
		}
    }
}

- (void)accessServiceSubmit
{
    [self hideKeyBoard];
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.labelText = @"发送中... ";
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
    
    NSString *reqUrl = @"member/feedback.do?param=";
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].shop_id,@"shop_id",
                                       self.myTextView.text,@"content",
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]],@"create",
                                       self.telTextField.text,@"phone",nil];
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:SEND_FEEDBACK_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch (commandid) {
        case SEND_FEEDBACK_COMMAND_ID:
        {
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
        }
            break;
        default:
            break;
    }
}

//更新数据
-(void)update:(NSMutableArray*)resultArray
{
    if (self.progressHUD) {
		[self.progressHUD removeFromSuperview];
		self.progressHUD = nil;
	}
    
    MBProgressHUD *mprogressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    if ([resultArray count] > 0) {
        NSDictionary *dic = [resultArray objectAtIndex:0];
        int isSuccess = [[dic objectForKey:@"ret"] intValue];
        
        if (isSuccess == 1 ) {
            mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ok_normal.png"]] autorelease];
            mprogressHUD.delegate = self;
            mprogressHUD.labelText = [NSString stringWithFormat:@"反馈成功"];
            
        }else if(isSuccess == 0 ){
            mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
            mprogressHUD.labelText = [NSString stringWithFormat:@"反馈失败"];
        }
    }else{
        mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
        mprogressHUD.labelText = [NSString stringWithFormat:@"反馈失败"];
    }
    
    [self.view addSubview:mprogressHUD];
    [self.view bringSubviewToFront:mprogressHUD];
    mprogressHUD.mode = MBProgressHUDModeCustomView;
    [mprogressHUD show:YES];
    [mprogressHUD hide:YES afterDelay:1.5];
    [mprogressHUD release];
}
@end
