//
//  WeiboView.h
//  ShareDemo
//
//  Created by yunlai on 13-7-12.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "FacialView.h"

typedef enum
{
    KeyboardTypeNormal,
    KeyboardTypeFace,
}KeyboardType;

@protocol WeiboViewDelegate;

@interface WeiboView : UIView <UITextViewDelegate,MBProgressHUDDelegate,facialViewDelegate>
{
    UIView *_bgView;
    UITextView *_textView;
    UILabel *_numfontLabel;
    UIButton *_sendBtn;
    NSString *contentStr;
    
    CGFloat flagHeight; 
    
    UINavigationController *navController;
    MBProgressHUD *progressHUD;
    
    id <WeiboViewDelegate> delegate;
    
    UIButton *changeTypeBtn;
    KeyboardType _keyboardType;
    
    UIView *faceView;
    UIScrollView *faceScrollView;//表情滚动视图
    UIPageControl *pageControl;
    
    float value;
    BOOL flag;
}

// 背景view
@property (retain, nonatomic) UIView *bgView;
// 文本框
@property (retain, nonatomic) UITextView *textView;
// 文本框字数
@property (retain, nonatomic) UILabel *numfontLabel;
// 发评论按钮
@property (retain, nonatomic) UIButton *sendBtn;
// 显示的内容
@property (retain, nonatomic) NSString *contentStr;
// _textView高度改变标识符
@property (assign, nonatomic) CGFloat flagHeight;

@property (retain, nonatomic) UINavigationController *navController;

@property (retain, nonatomic) MBProgressHUD *progressHUD;

@property (retain, nonatomic) NSString *strP;

@property (assign, nonatomic) id <WeiboViewDelegate> delegate;

// 初始化数据
- (id)initWithString:(NSString *)content;

// 显示微博发送页面
- (void)showWeiboView;

@end


@protocol WeiboViewDelegate <NSObject>

@optional
- (void)weiboViewSendComment:(NSString *)text;

@end
