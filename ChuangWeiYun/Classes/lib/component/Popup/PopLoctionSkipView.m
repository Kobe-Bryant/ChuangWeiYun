//
//  PopLoctionSkipView.m
//  cw
//
//  Created by yunlai on 13-10-25.
//
//

#import "PopLoctionSkipView.h"
#import "Common.h"

#define PPLSVHeight   195

@implementation PopLoctionSkipView

@synthesize delegate;

- (id)init
{
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width - 20.f;
    
    self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, PPLSVHeight)];
    if (self) {
        UIColor *clore = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];;
        
        self.backgroundColor = KCWViewBgColor;
        self.layer.cornerRadius = 3.f;
        self.layer.masksToBounds = YES;
        
        self.center = popupView.center;
        
        CGFloat height = 20.f;
        CGFloat width = CGRectGetWidth(self.frame);
        
        // 关闭按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(width-40.f, 10.f, 30.f, 30.f);
        [btn setImage:[UIImage imageCwNamed:@"icon_Shut_black.png"] forState:UIControlStateNormal];
        [btn setTag:0];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        height += 20.f;
        
        _textlabel = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, width, 30.f)];
        _textlabel.backgroundColor = [UIColor clearColor];
        _textlabel.textColor = clore;
        _textlabel.font = KCWSystemFont(17.f);
        _textlabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textlabel];
        
        height += 50.f;
        
        // 切换
        _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipBtn.frame = CGRectMake(10.f, height, width-20.f, 40.f);
        [_skipBtn setBackgroundColor:[UIColor colorWithRed:0.f green:106.f/255.f blue:193.f/255.f alpha:1.f]];
        [_skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_skipBtn.titleLabel setFont:KCWSystemFont(15.f)];
        [_skipBtn setTag:1];
        [_skipBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_skipBtn];
        
        height += 50.f;
        
        // 继续
        _goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBtn.frame = CGRectMake(10.f, height, width-20.f, 40.f);
        [_goBtn setBackgroundColor:[UIColor whiteColor]];
        [_goBtn setTitleColor:clore forState:UIControlStateNormal];
        [_goBtn.titleLabel setFont:KCWSystemFont(15.f)];
        [_goBtn setTag:2];
        _goBtn.layer.borderColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f].CGColor;
        _goBtn.layer.borderWidth = 1.f;
        [_goBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_goBtn];
    }
    return self;
}

- (void)dealloc
{
    [_textlabel release], _textlabel = nil;
    [super dealloc];
}

- (void)addPopupSubview:(NSString *)locCity city:(NSString *)currCity
{
    [super addPopupSubview];
    
    [popupView addSubview:self];
    
    _textlabel.text = [NSString stringWithFormat:@"定位显示您在%@，您可以...",locCity];
    
    [_skipBtn setTitle:[NSString stringWithFormat:@"切换到%@",locCity] forState:UIControlStateNormal];
    
    [_goBtn setTitle:[NSString stringWithFormat:@"继续浏览%@",currCity] forState:UIControlStateNormal];
}

- (void)btnClick:(UIButton *)btn
{
    [UIView animateWithDuration:0.23 animations:^{
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    }];
    
    [self removeFromSuperview];
    
    if (btn.tag == 1) {
        if ([delegate respondsToSelector:@selector(popLoctionSkipViewClick:)]) {
            [delegate popLoctionSkipViewClick:self];
        }
    } else {
        if ([delegate respondsToSelector:@selector(popLoctionSkipViewClose:)]) {
            [delegate popLoctionSkipViewClose:self];
        }
    }
}
@end
