//
//  WeiboViewController.m
//  cw
//
//  Created by yunlai on 13-9-29.
//
//

#import "WeiboViewController.h"
#import "Common.h"
#import "weibo_userinfo_model.h"
#import "PfShare.h"

#define WeiboViewSpaceWH                10.f
#define WeiboViewTextViewH              155.f   // 文本框的高度
#define WeiboViewImageViewH             60.f    // 图片的高
#define WeiboViewImageViewW             80.f    // 图片的宽
#define WeiboViewButtonViewW            80.f    // 按钮的宽
#define WeiboViewButtonViewH            40.f    // 按钮的高

@interface WeiboViewController () <UITextViewDelegate>
{
    UITextView *_textView;
    UIImageView *_imgView;
    UILabel *_fontLabel;
    UIScrollView *_scrollViewC;
}

@end

@implementation WeiboViewController

@synthesize weiboImage;
@synthesize weiboText;
@synthesize weiboShare;
@synthesize strP;
@synthesize progressHUD;

@synthesize type;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (self.type == WeiboEnumSina) {
        self.title = @"新浪微博分享";
    } else {
        self.title = @"腾讯微博分享";
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_textView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KCWViewBgColor;
    
    [self viewLoad];
    
    // 键盘将要显示的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘将要隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// 创建试图
- (void)viewLoad
{
    CGFloat height = WeiboViewSpaceWH;
    CGFloat width = WeiboViewSpaceWH;
    
    _scrollViewC = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scrollViewC.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollViewC];

    _textView = [[UITextView alloc]initWithFrame:CGRectZero];
    _textView.frame = CGRectMake(width, height, KUIScreenWidth - 2*WeiboViewSpaceWH, WeiboViewTextViewH);
    _textView.text = self.weiboText;
    _textView.delegate = self;
    _textView.font = KCWSystemFont(15.f);
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.layer.borderColor = [[UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0] CGColor];
    _textView.layer.borderWidth = 1.0;
    _textView.layer.cornerRadius = 5.f;
    [_scrollViewC addSubview:_textView];
    
    _fontLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.f, WeiboViewTextViewH - 20.f, CGRectGetWidth(_textView.frame) - 10.f, 25.f)];
    _fontLabel.backgroundColor = [UIColor clearColor];
    _fontLabel.textColor = [UIColor grayColor];
    _fontLabel.textAlignment = NSTextAlignmentRight;
    [self setFontLabelText];
    [_scrollViewC addSubview:_fontLabel];
    
    height += WeiboViewTextViewH + WeiboViewSpaceWH;
    
    _imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    if (self.weiboImage.size.width < WeiboViewImageViewW) {
        _imgView.frame = CGRectMake(width, height + (WeiboViewImageViewH - self.weiboImage.size.height), self.weiboImage.size.width, self.weiboImage.size.height);
    } else {
        _imgView.frame = CGRectMake(width, height, WeiboViewImageViewW, WeiboViewImageViewH);
    }
    _imgView.image = self.weiboImage;
    [_scrollViewC addSubview:_imgView];
    
    width = KUIScreenWidth - WeiboViewSpaceWH - WeiboViewButtonViewW;
    height += 20.f;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(width, height, WeiboViewButtonViewW, WeiboViewButtonViewH);
    btn.backgroundColor = [UIColor colorWithRed:48.f/255.f green:114.f/255.f blue:191.f/255.f alpha:1.f];
    [btn setTitle:@"分享" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnShareClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5.f;
    [_scrollViewC addSubview:btn];
    
    height += WeiboViewButtonViewH + 10.f;
    
    _scrollViewC.contentSize = CGSizeMake(0.f, height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [weiboShare release], weiboShare = nil;
    
    [_textView release], _textView = nil;
    [_imgView release], _imgView = nil;
    [_fontLabel release], _fontLabel = nil;
    [_scrollViewC release], _scrollViewC = nil;
    self.weiboImage = nil;
    self.weiboText = nil;
    self.strP = nil;
    self.progressHUD = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark - custom modth
- (void)btnShareClick:(UIButton *)btn
{
    if (_textView.text.length > 140) {
        [Common MsgBox:@"提示" messege:@"您输入的文字超过了140个字" cancel:@"确定" other:nil delegate:nil];
    } else {
        if (self.type == WeiboEnumSina) {
            [self sinaWeibo];
        } else if (self.type == WeiboEnumTencent) {
            [self tencentWeibo];
        }
        
        [Common countObject:[Global sharedGlobal].countObj_id withType:[Global sharedGlobal]._countType];
    }
}

// 新浪微博判断
- (void)sinaWeibo
{
    weibo_userinfo_model *weiboMod = [[weibo_userinfo_model alloc] init];
    
    weiboMod.where = [NSString stringWithFormat:@"weiboType = '%@'",SINA];
    
    NSArray *weiboArray = [weiboMod getList];
    
    [weiboMod release], weiboMod = nil;
    
    if (weiboArray != nil && [weiboArray count] > 0) {
        weiboShare = [[WeiboShare alloc]init];
        weiboShare.delegate = self;
        [self progress];
        [weiboShare sinaWeiboShareImage:self.weiboImage text:_textView.text];
        
    }else {
        SinaWeiboViewController *sinaView = [[SinaWeiboViewController alloc]init];
        sinaView.delegate = self;
        [self.navigationController pushViewController:sinaView animated:YES];

        [sinaView release];
    }
}

// 腾讯微博判断
- (void)tencentWeibo
{
    weibo_userinfo_model *weiboMod = [[weibo_userinfo_model alloc] init];
    
    weiboMod.where = [NSString stringWithFormat:@"weiboType = '%@'",TENCENT];
    
    NSArray *weiboArray = [weiboMod getList];
    
    [weiboMod release], weiboMod = nil;
    
    if (weiboArray != nil && [weiboArray count] > 0) {
        weiboShare = [[WeiboShare alloc]init];
        weiboShare.delegate = self;
        [self progress];

        [weiboShare tencentWeiboShareImage:self.weiboImage text:_textView.text];
    }else {
        TencentWeiboViewController *tencentView = [[TencentWeiboViewController alloc]init];
        tencentView.delegate = self;
        [self.navigationController pushViewController:tencentView animated:YES];
        [tencentView release];

    }
}

// 设置_textView的显示
- (void)setFontLabelText
{
    _fontLabel.text = [NSString stringWithFormat:@"%d",140 - _textView.text.length];
}

// 微博分享中
- (void)progress
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = @"分享中...";
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ok_normal.png"]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];
    [progressHUDTmp release],progressHUDTmp=nil;
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (self.progressHUD) {
        [progressHUD removeFromSuperview];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (_textView.text.length > 140) {
        _fontLabel.textColor = [UIColor redColor];
        [self setFontLabelText];
    } else {
        _fontLabel.textColor = [UIColor grayColor];
        [self setFontLabelText];
    }
    return YES;
}

// 新浪微博是否授权成功
#pragma mark - OauthSinaWeiSuccessDelegate
- (void)oauthSinaSuccessIsFail:(BOOL)isSuccess
{
    if (isSuccess) {
        [self progress];
        weiboShare = [[WeiboShare alloc]init];
        weiboShare.delegate = self;
        [weiboShare sinaWeiboShareImage:self.weiboImage text:_textView.text];
    } else {
        [self progressHUD:@"授权失败"];
    }
}

// 腾讯微博是否授权成功
#pragma mark - OauthTencentWeiSuccessDelegate
- (void)oauthTencentSuccessIsFail:(BOOL)isSuccess
{
    if (isSuccess) {
        [self progress];
        weiboShare = [[WeiboShare alloc]init];
        weiboShare.delegate = self;
        [weiboShare tencentWeiboShareImage:self.weiboImage text:_textView.text];
    } else {
        [self progressHUD:@"授权失败"];
    }
}

// 分享成功与失败
#pragma mark - WeiboShareDelegate
- (void)WeiboShareResult:(WEIBORESULT)result
{
    [self.progressHUD hide:YES afterDelay:0.f];
    
    CGFloat time = 0.f;
    
    if (result == WeiboResultSuccess) {
        self.strP = @"分享成功！";
        
    } else {
        self.strP = @"分享失败！";
        time = 2.1f;
    }
   
    [self progressHUD:self.strP];
    [self performSelector:@selector(closeSelf:) withObject:[NSNumber numberWithInt:result] afterDelay:time];
}

- (void)closeSelf:(NSNumber *)result
{
    [self.navigationController popViewControllerAnimated:NO];
    
    if ([result intValue] == WeiboResultSuccess) {
        [[PfShare defaultSingle] pfShareRequest];
    }
}

#pragma mark -
#pragma mark Responding to keyboard events
// 键盘将要显示
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // 键盘显示需要的frame
    CGRect keyboardRect = [aValue CGRectValue];
    
    // 键盘显示需要的时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 需要用的键盘显示的时间，这个时间段来做_bgView的frame的改变，实现动画
    [UIView animateWithDuration:animationDuration animations:^{
        _scrollViewC.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, self.view.bounds.size.height - keyboardRect.size.height);
    }];
}

// 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    // 键盘显示需要的时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 需要用的键盘隐藏的时间，这个时间段来做_bgView的frame的改变，实现动画
    [UIView animateWithDuration:1.5*animationDuration animations:^{
        _scrollViewC.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }];
}

@end
