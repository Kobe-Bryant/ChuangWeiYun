//
//  WeiboView.m
//  ShareDemo
//
//  Created by yunlai on 13-7-12.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "WeiboView.h"
#import "Common.h"


#define WeiboBGViewHeight           208.f   // 白色背景的高度
#define WeiboBGViewUpBarHeight      44.f    // 白色上bar的高度
#define WeiboBGViewImageHeight      60.f    // 内容图标的高度
#define WeiboBGViewDownHeight       16.f    // 内容图标与底部的高度
#define WeiboBGViewNumlabelHeight   44.f    // 渐变图标的高度，为了显示剩余多少字

#define TextNum                     140     // 可以输入字的个数

#define  keyboardHeight 216
#define  facialViewWidth 300
#define facialViewHeight 170

@implementation WeiboView

@synthesize bgView = _bgView;
@synthesize textView = _textView;
@synthesize numfontLabel = _numfontLabel;
@synthesize sendBtn = _sendBtn;
@synthesize contentStr;
@synthesize flagHeight;
@synthesize navController;
@synthesize progressHUD;
@synthesize strP;

@synthesize delegate;

// 初始化一些数据及视图
- (id)initWithString:(NSString *)content
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight + 20.f)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];

        self.contentStr = content;
        
        [self createBgView];
    }
    return self;
}

- (void)dealloc
{
    [_bgView release], _bgView = nil;
    [_textView release], _textView = nil;
    [_numfontLabel release], _numfontLabel = nil;
    [contentStr release], contentStr = nil;
    
    self.navController = nil;
    self.progressHUD = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [faceView release];
    [faceScrollView release];
    [pageControl release];
    [super dealloc];
}

// 创建上bar
- (void)createUpBar
{
    UIImage *pngImage = [UIImage imageNamed:@"icon_close_comments.png"];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(15.f, WeiboBGViewUpBarHeight/2 - pngImage.size.height/2, pngImage.size.width, pngImage.size.height);
    [closeBtn setBackgroundImage:pngImage forState:UIControlStateNormal];
    [closeBtn setTag:0];
    [closeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:closeBtn];
    
    pngImage = [UIImage imageNamed:@"icon_submit_comments.png"];
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendBtn.frame = CGRectMake(self.frame.size.width - 15.f - pngImage.size.width, WeiboBGViewUpBarHeight/2 - pngImage.size.height/2, pngImage.size.width, pngImage.size.height);
    [_sendBtn setBackgroundImage:pngImage forState:UIControlStateNormal];
    [_sendBtn setTag:1];
    [_sendBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.enabled = NO;
    [_bgView addSubview:_sendBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100.f, 0.f, 140.f, WeiboBGViewUpBarHeight)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
    titleLabel.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, WeiboBGViewUpBarHeight);
    titleLabel.text = @"评论";
    [_bgView addSubview:titleLabel];
    [titleLabel release], titleLabel = nil;
    
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, WeiboBGViewUpBarHeight, self.frame.size.width, 1.f)];
    line.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
    [_bgView addSubview:line];
    [line release], line = nil;
}

// 创建scrollView
- (void)createScrollView
{
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(0.f, WeiboBGViewUpBarHeight + 1.f, KUIScreenWidth, WeiboBGViewHeight - WeiboBGViewNumlabelHeight - WeiboBGViewUpBarHeight)];
    _textView.text = self.contentStr;
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyDefault;//返回键的类型
    _textView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _textView.font = [UIFont systemFontOfSize:20.f];
    [_bgView addSubview:_textView];
}

// 创建bgView
- (void)createBgView
{
    _bgView = [[UIView alloc]initWithFrame:CGRectMake(0.f, self.frame.size.height - WeiboBGViewHeight, KUIScreenWidth, WeiboBGViewHeight)];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bgView];
    
    //创建表情键盘view ---------------------
    int pageValue = 4;
    faceView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - keyboardHeight, self.frame.size.width, keyboardHeight)];
    [faceView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"facesBack"]]];
    
    faceScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, faceView.frame.size.height)];
    for (int i= 0; i < pageValue; i++) {
        FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(12+320*i, 15, facialViewWidth, facialViewHeight)];
        [fview setBackgroundColor:[UIColor clearColor]];
        [fview loadFacialView:i size:CGSizeMake(28, 28)];
        fview.delegate=self;
        [faceScrollView addSubview:fview];
        [fview release];
    }
    [faceScrollView setShowsVerticalScrollIndicator:NO];
    [faceScrollView setShowsHorizontalScrollIndicator:NO];
    faceScrollView.contentSize=CGSizeMake(320*pageValue, keyboardHeight);
    faceScrollView.pagingEnabled=YES;
    faceScrollView.delegate=self;
    [faceView addSubview:faceScrollView];
 
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(98, faceView.frame.size.height-30, 150, 30)];
    [pageControl setCurrentPage:0];
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:195/255.0 green:179/255.0 blue:163/255.0 alpha:1];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:132/255.0 green:104/255.0 blue:77/255.0 alpha:1];
    pageControl.numberOfPages = pageValue;//指定页面个数
    [pageControl setBackgroundColor:[UIColor clearColor]];
    [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    [faceView addSubview:pageControl];
    
    //--------------------------
    [self createUpBar];
    
    [self createScrollView];

    // 创建渐变背景
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, WeiboBGViewHeight - WeiboBGViewNumlabelHeight, self.frame.size.width, WeiboBGViewNumlabelHeight)];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.image = [UIImage imageNamed:@"bg_light_white.png"];
    
    //切换文字键盘或表情
    _keyboardType = KeyboardTypeNormal;
    
    UIImage *imgFace = [UIImage imageCwNamed:@"icon_expression_comments.png"];
    changeTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeTypeBtn.frame = CGRectMake(10, (bgImageView.frame.size.height - imgFace.size.height) * 0.5, imgFace.size.width, imgFace.size.height);
    [changeTypeBtn addTarget:self action:@selector(changeType) forControlEvents:UIControlEventTouchUpInside];
    [changeTypeBtn setImage:imgFace forState:UIControlStateNormal];
    [bgImageView addSubview:changeTypeBtn];
    
    // 显示多少字
    _numfontLabel = [[UILabel alloc]initWithFrame:CGRectMake(bgImageView.frame.size.width - 80.f, 0.f, 80.f, WeiboBGViewNumlabelHeight)];
    _numfontLabel.text = [NSString stringWithFormat:@"%d",TextNum - _textView.text.length];
    _numfontLabel.textAlignment = NSTextAlignmentCenter;
    if (_textView.text.length <= TextNum) {
        _numfontLabel.textColor = [UIColor blackColor];
    } else {
        _numfontLabel.textColor = [UIColor redColor];
    }
    _numfontLabel.backgroundColor = [UIColor clearColor];
    [bgImageView addSubview:_numfontLabel];
    
    [_bgView addSubview:bgImageView];
    [bgImageView release], bgImageView = nil;
}

- (void)changeType
{
    UIImage *imgFace = [UIImage imageCwNamed:@"icon_expression_comments.png"];
    UIImage *imgNormal = [UIImage imageCwNamed:@"icon_keyboard_comments.png"];
    
    [_textView resignFirstResponder];
    if (_keyboardType == KeyboardTypeNormal) {
        
        _keyboardType = KeyboardTypeFace;

        [changeTypeBtn setImage:imgNormal forState:UIControlStateNormal];

        [UIView animateWithDuration:0.25 animations:^{
            [_textView resignFirstResponder];
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].delegate.window addSubview:faceView];
        }];
    } else {
        _keyboardType = KeyboardTypeNormal;

        [changeTypeBtn setImage:imgFace forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25 animations:^{
            [faceView removeFromSuperview];
        } completion:^(BOOL finished) {
            [_textView becomeFirstResponder];
        }];
    }
}

// 显示weibo发送页面
- (void)showWeiboView
{
    flag = NO;
    
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    // 键盘将要显示的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘将要隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 激活键盘
    [_textView becomeFirstResponder];
}

// 隐藏face键盘
- (void)hidefaceView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
        faceView.frame = CGRectMake(0.f,self.frame.size.height, KUIScreenWidth, WeiboBGViewHeight);
        _bgView.frame = CGRectMake(0.f,self.frame.size.height, KUIScreenWidth, WeiboBGViewHeight);
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [faceView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

// button事件，处理关闭和发送
- (void)buttonClick:(UIButton *)button
{
    if (button.tag == 1) {
        if (_textView.text.length != 0) {
            if ([delegate respondsToSelector:@selector(weiboViewSendComment:)]) {
                                
                NSString *submitStr = [self changeSomeString:_textView.text];
                NSLog(@"submitStr == %@",submitStr);
                
                [delegate weiboViewSendComment:submitStr];
            }
        } else {
            return;
        }
    }
    
    if (_keyboardType == KeyboardTypeFace) {
        [self hidefaceView];
    } else {
        flag = YES;
        [_textView resignFirstResponder];
    }
}

// 微博分享中
- (void)progress
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.navController.view.frame];
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = @"分享中...";
    [self.navController.view addSubview:self.progressHUD];
    [self.navController.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.navController.view];
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ok_normal.png"]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [self.navController.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (self.progressHUD) {
        [progressHUD removeFromSuperview];
    }
    [self progressHUD:self.strP];
}

#pragma mark -- mehtod
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = faceScrollView.contentOffset.x / 320;//通过滚动的偏移量来判断目前页面所对应的小白点
    pageControl.currentPage = page;//pagecontroll响应值的变化
}

- (void)changePage:(id)sender {
    int page = pageControl.currentPage;//获取当前pagecontroll的值
    [faceScrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
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

    //NSLog(@"==== %f",keyboardRect.size.height);
    // 需要用的键盘显示的时间，这个时间段来做_bgView的frame的改变，实现动画
    [UIView animateWithDuration:animationDuration animations:^{
        _bgView.frame = CGRectMake(0.f, self.frame.size.height - WeiboBGViewHeight - keyboardRect.size.height, KUIScreenWidth, WeiboBGViewHeight);
    }];
    
    value = keyboardRect.size.height;
    
}

// 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];

    // 键盘显示需要的时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [faceView removeFromSuperview];
    
    // 需要用的键盘隐藏的时间，这个时间段来做_bgView的frame的改变，实现动画
    if (flag) {
        [UIView animateWithDuration:1.5*animationDuration animations:^{
            self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
            _bgView.frame = CGRectMake(0.f,self.frame.size.height, KUIScreenWidth, WeiboBGViewHeight);
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
            [self removeFromSuperview];
        }];
    } else {
        [UIView animateWithDuration:animationDuration animations:^{
            _bgView.frame = CGRectMake(0.f,self.frame.size.height - WeiboBGViewHeight - 216.f, KUIScreenWidth, WeiboBGViewHeight); //
        }];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 根据_textView.text.length，来判断还有多少个字有效
    
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\t"]) {
        NSLog(@"text = %@",text);
    }
    
    if (_textView.text.length <= TextNum) {
        _numfontLabel.textColor = [UIColor blackColor];
        _numfontLabel.text = [NSString stringWithFormat:@"%d",TextNum - _textView.text.length];
    } else {
        _numfontLabel.textColor = [UIColor redColor];
        _numfontLabel.text = [NSString stringWithFormat:@"%d",TextNum - _textView.text.length];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (_textView.text.length == 0) {
        _sendBtn.enabled = NO;
        return;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimedString = [_textView.text stringByTrimmingCharactersInSet:set];
    if ([trimedString length] == 0) {
        _sendBtn.enabled = NO;
    } else {
        _sendBtn.enabled = YES;
    }
}

#pragma mark facialView delegate 点击表情键盘上的文字
-(void)selectedFacialView:(NSString*)str
{
    NSString *newStr = nil;
    if ([str isEqualToString:@"删除"]) {
        if (_textView.text.length>0) {
//            if ([[Emoji allEmoji] containsObject:[_textView.text substringFromIndex:_textView.text.length-2]])
//            {
//                newStr=[_textView.text substringToIndex:_textView.text.length-2];
//            }else{
//                newStr=[_textView.text substringToIndex:_textView.text.length-1];
//            }
            NSString *inputString = _textView.text;
          
            NSInteger stringLength = inputString.length;
            if (stringLength > 0) {
                if ([@"]" isEqualToString:[inputString substringFromIndex:stringLength-1]]) {
                    if ([inputString rangeOfString:@"["].location == NSNotFound){
                        newStr = [inputString substringToIndex:stringLength - 1];
                    } else {
                        newStr = [inputString substringToIndex:[inputString rangeOfString:@"[" options:NSBackwardsSearch].location];
                    }
                } else {
                    newStr = [inputString substringToIndex:stringLength - 1];
                }
            }
            
            _textView.text = newStr;
        }
    }else{
        int location  = _textView.selectedRange.location;
        NSString * textStr = _textView.text;
        
        newStr = [NSString stringWithFormat:@"%@%@%@",[textStr substringToIndex:location],str,[textStr substringFromIndex:location]];
        [_textView setText:newStr];
    }
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimedString = [_textView.text stringByTrimmingCharactersInSet:set];
    if ([trimedString length] == 0) {
        _sendBtn.enabled = NO;
    } else {
        _sendBtn.enabled = YES;
    }
}

- (NSString *)changeSomeString:(NSString *)str
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *array = [data allKeys];
    
    for (int i = 0; i< array.count; i++) {
        str = [str stringByReplacingOccurrencesOfString:[array objectAtIndex:i] withString:[data objectForKey:[array objectAtIndex:i]]];
    }
    
    [data release], data= nil;
    
    return str;
}
@end
