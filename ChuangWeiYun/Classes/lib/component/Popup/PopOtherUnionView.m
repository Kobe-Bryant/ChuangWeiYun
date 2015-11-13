//
//  PopOtherUnionView.m
//  cw
//
//  Created by yunlai on 13-9-13.
//
//

#import "PopOtherUnionView.h"
#import "Common.h"

#define KPOUVHeight     200.f

@implementation PopOtherUnionView

@synthesize delegate;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth-20.f, KPOUVHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:234.f/255.f green:234.f/255.f blue:234.f/255.f alpha:1.f];
        self.layer.cornerRadius = 3.f;
        self.layer.masksToBounds = YES;
        
        self.center = CGPointMake(popupView.center.x, popupView.center.y-20.f);
        
        CGFloat space = 10.f;
        CGFloat height = 10.f;
        CGFloat width = CGRectGetWidth(self.frame) - 20.f;
        
        // 完成购买后，请向店长索取验证码
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(space, height, width, 20.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = KCWSystemFont(16.f);
        label.text = @"完成购买后，请向店长索取验证码";
        [self addSubview:label];
        [label release], label = nil;
        
        // 关闭按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(CGRectGetWidth(self.frame)-35.f, 5.f, 25.f, 25.f);
        [btn setBackgroundImage:[UIImage imageCwNamed:@"icon_close_black.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageCwNamed:@"icon_close.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 0;
        [self addSubview:btn];
        
        height += 30.f;
        
        // 输入框背景
        UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(space, height, width, 100.f)];
        bgview.backgroundColor = [UIColor whiteColor];
        bgview.layer.cornerRadius = 2.f;
        bgview.layer.masksToBounds = YES;
        [self addSubview:bgview];
        
        // 输入验证码
        _codeText = [[UITextField alloc]initWithFrame:CGRectMake(space, 0.f, width-20.f, 50.f)];
        _codeText.placeholder = @"输入验证码";
        _codeText.returnKeyType = UIReturnKeyDefault;
        _codeText.keyboardType = UIKeyboardTypeNumberPad; // 键盘显示类型
        _codeText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
        _codeText.delegate = self;
        [bgview addSubview:_codeText];
        
        // 线
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 50.f, width, 1.f)];
        line.backgroundColor = [UIColor colorWithRed:234.f/255.f green:234.f/255.f blue:234.f/255.f alpha:1.f];
        [bgview addSubview:line];
        [line release], line = nil;
        
        // 输入验证码
        _phoneText = [[UITextField alloc]initWithFrame:CGRectMake(space, 50.f, width-20.f, 50.f)];
        _phoneText.placeholder = @"输入手机号码";
        _phoneText.returnKeyType = UIReturnKeyDefault;
        _phoneText.keyboardType = UIKeyboardTypeNumberPad; // 键盘显示类型
        _phoneText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
        _phoneText.delegate = self;
        [bgview addSubview:_phoneText];
        
        [bgview release], bgview = nil;
        
        height += 110.f;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(space, height, width, 40.f);
        [btn setBackgroundColor:[UIColor colorWithRed:14.f/255.f green:83.f/255.f blue:180.f/255.f alpha:1.f]];
        [btn setTitle:@"获取优惠券" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1;
        [self addSubview:btn];
        
    }
    return self;
}

- (void)dealloc
{
    [_codeText release], _codeText = nil;
    [_phoneText release], _phoneText = nil;
    [super dealloc];
}

- (void)addPopupSubview
{
    [super addPopupSubview];
    
    UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.frame = popupView.bounds;
    [bgBtn addTarget:self action:@selector(btnClickKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    bgBtn.tag = 2;
    [popupView addSubview:bgBtn];
    
    [popupView addSubview:self];
}

// 隐藏键盘
- (void)hideKeyboard
{
    if ([_codeText isFirstResponder]) {
        [_codeText resignFirstResponder];
    } else if ([_phoneText isFirstResponder]) {
        [_phoneText resignFirstResponder];
    }
}

// 点击其他地方隐藏键盘
- (void)btnClickKeyboard:(UIButton *)btn
{
    [self hideKeyboard];
}

// 判断输入是否正确
- (BOOL)isTextisRight
{
    BOOL right = NO;
    
    if (_codeText.text.length == 0) {
        [Common MsgBox:@"提示" messege:@"请输入验证码" cancel:@"确定" other:nil delegate:nil];
        right = NO;
    } else if (_phoneText.text.length == 0) {
        [Common MsgBox:@"提示" messege:@"请输入手机号码" cancel:@"确定" other:nil delegate:nil];
        right = NO;
    } else if (![Common phoneNumberChecking:_phoneText.text]) {
        [Common MsgBox:@"提示" messege:@"请输入正确的手机号码" cancel:@"确定" other:nil delegate:nil];
        right = NO;
    } else {
        right = YES;
    }
    
    return right;
}

// 关闭和获取优惠券
- (void)btnClick:(UIButton *)btn
{
    [self hideKeyboard];
    
    if (btn.tag == 1) {
        if ([self isTextisRight]) {
            if ([delegate respondsToSelector:@selector(getOtherUnionCoupons:phone:)]) {
                [delegate getOtherUnionCoupons:_codeText.text phone:_phoneText.text];
            }
        } else {
            return;
        }
    }

    [UIView animateWithDuration:0.23 animations:^{
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    }];
    
    [self removeFromSuperview];
}

@end
