//
//  PopShareView.m
//  ShareDemo
//
//  Created by yunlai on 13-7-11.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "PopShareView.h"
#import "ShareAPIAction.h"
#import "cwAppDelegate.h"
#import "Common.h"

#define ButHegiht       60.f    // 图标按钮的高度
#define LabelHeight     25.f    // 图标字体的高度

#define UpHeight        20.f    // 图标与上边距的高度
#define DownHeight      20.f    // 图标与下边距的高度
#define LeftWidth       30.f    // 图标与左边距的宽度

#define SpaceWidth      40.f    // 图标与图标的宽度
#define DownBtnHeight   40.f    // 取消按钮的高度

static PopShareView *popup = nil;

@implementation PopShareView

@synthesize bgView;
@synthesize butArrayText;
@synthesize butArrayImage;
@synthesize share;
@synthesize delegatePop;
@synthesize navController;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight + 20.f)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];

        bgView = [[UIView alloc]initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        butArrayText = [NSArray arrayWithObjects:@"新浪微博",@"微信朋友",@"朋友圈",@"腾讯微博",@"QQ好友",@"短信", nil];
        butArrayImage = [NSArray arrayWithObjects:
                         @"icon_sinaweibo_114.png",
                         @"icon_weixin_114.png",
                         @"icon_pyq_114.png",
                         @"icon_txweibo_114.png",
                         @"txqq_share_store.png",
                         @"sms_share_store.png", nil];
    }
    return self;
}

// 单例模式搞起
+ (PopShareView *)defaultExample
{
    @synchronized(self) {
        if (popup == nil) {
            popup = [[PopShareView alloc]init];
        }
    }
    return popup;
}

// 创建弹出框
- (void)createPopupView
{
    if (bgView.subviews.count == 0) {
        int row = butArrayText.count%3 == 0 ? butArrayText.count/3 : butArrayText.count/3 + 1;
        int count = 0;
        int rowCount = 0;
        
        UILabel *leftline = [[UILabel alloc]initWithFrame:CGRectMake(10.f, 30.f, 110.f, 1.f)];
        leftline.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
        [bgView addSubview:leftline];
        [leftline release], leftline = nil;
        
        UILabel *sharelabel = [[UILabel alloc]initWithFrame:CGRectMake(120.f, 20.f, 60.f, 20.f)];
        sharelabel.backgroundColor = [UIColor clearColor];
        sharelabel.textColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
        sharelabel.text = @"分享到";
        sharelabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:sharelabel];
        [sharelabel release], sharelabel = nil;
        
        UILabel *rightline = [[UILabel alloc]initWithFrame:CGRectMake(180.f, 30.f, 130.f, 1.f)];
        rightline.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
        [bgView addSubview:rightline];
        [rightline release], rightline = nil;
        
        for (int i = 0; i < butArrayText.count; i++) {
            if (i%3 == 0) {
                count = 0;
                rowCount++;
            } else {
                count++;
            }
            
            // 图标按钮开始创建
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(count*(ButHegiht+SpaceWidth) + LeftWidth,
                                      rowCount*UpHeight + (rowCount-1)*(ButHegiht + LabelHeight) + 40.f,
                                      ButHegiht, ButHegiht);
            [button setBackgroundImage:[UIImage imageNamed:[butArrayImage objectAtIndex:i]] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [bgView addSubview:button];
            
            // 图标字体开始创建
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(button.frame.origin.x,
                                                                      button.frame.origin.y + button.frame.size.height,
                                                                      button.frame.size.width, LabelHeight)];
            label.font = [UIFont systemFontOfSize:12.f];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [butArrayText objectAtIndex:i];
            label.tag = i + 100;
            [bgView addSubview:label];
            [label release], label = nil;
        }
        
        CGFloat height = row * (ButHegiht + LabelHeight + UpHeight) + UpHeight + 40.f;
        
        // 取消按钮开始创建
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(LeftWidth - 5.f, height,
                               [UIScreen mainScreen].applicationFrame.size.width - 2*(LeftWidth-5.f), DownBtnHeight);
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:17.f]];
        [btn setBackgroundColor:[UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = ShareMax;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        
        height += DownBtnHeight + DownHeight;
                
        bgViewHeight = height;
    } 
}

// 显示弹窗
- (void)showPopupView:(UINavigationController *)viewController delegate:(id)adelegate
{
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    self.delegatePop = adelegate;
    self.navController = viewController;

    [self createPopupView];
    
    bgView.frame = CGRectMake(0.f, self.frame.size.height, self.frame.size.width, bgViewHeight);
    
    // 动画弹窗向上弹出，且背景色由透明变半透明
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        bgView.frame = CGRectMake(0.f, self.frame.size.height - bgViewHeight, self.frame.size.width, bgViewHeight);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToClose)];
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];
    
}

//关闭
-(void)tapToClose
{
    // 动画弹窗向下消失，且背景色由半透明变透明
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.0f];
        bgView.frame = CGRectMake(0.f, self.frame.size.height, self.frame.size.width, bgViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

// 按钮事件
- (void)buttonClick:(UIButton *)btn
{
    // 动画弹窗向下消失，且背景色由半透明变透明
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.0f];
        bgView.frame = CGRectMake(0.f, self.frame.size.height, self.frame.size.width, bgViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    if (btn.tag != ShareMax) {
        ShareAPIAction *shareA = [[ShareAPIAction alloc]init];
        self.share = shareA;
        [shareA release];
        [share startShare:self.delegatePop shareEnum:btn.tag];
    }
}

- (void)dealloc
{
    [bgView release], bgView = nil;
    [butArrayText release], butArrayText = nil;
    [butArrayImage release], butArrayImage = nil;
    self.delegatePop = nil;
    self.share = nil;
    self.navController = nil;
    
    [super dealloc];
}

@end
