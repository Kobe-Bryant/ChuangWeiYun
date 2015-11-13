//
//  CustomSearchBar.h
//  search
//
//  Created by yunlai on 13-8-30.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CustomSearchBarClearTag 6

@protocol CustomSearchBarDelegate;

@interface CustomSearchBar : UIView <UITextFieldDelegate>
{
    UIView      *bgView;
    UIButton    *canelButton;
    UITextField *searchTextField;
    UIView      *backgdView;
    NSString    *placeholder;
    
    UIColor     *normalColor;
    UIColor     *highlightColor;
    UIColor     *searchNlColor;
    UIColor     *searchHtColor;
    
    id <CustomSearchBarDelegate> delegate;
}

@property (retain, nonatomic) UIView        *bgView;
@property (retain, nonatomic) UIButton      *canelButton;
@property (retain, nonatomic) UITextField   *searchTextField;
@property (retain, nonatomic) UIView        *backgdView;
@property (retain, nonatomic) NSString      *placeholder;
@property (retain, nonatomic) UIColor       *normalColor;
@property (retain, nonatomic) UIColor       *highlightColor;
@property (retain, nonatomic) UIColor       *searchNlColor;
@property (retain, nonatomic) UIColor       *searchHtColor;

@property (assign, nonatomic) id <CustomSearchBarDelegate> delegate;

/*   设置背景色及搜索框颜色
 *   bgNormalColor          视图普通背景色
 *   bgHighlightColor       视图高亮背景色
 *   searchNormalColor      搜索框普通背景色
 *   searchHighlightColor   搜索框高亮背景色
 */
- (id)initWithColor:(UIColor *)bgNormalColor
   bghighlightColor:(UIColor *)bgHighlightColor
        searchColor:(UIColor *)searchNormalColor
searchhighlightColor:(UIColor *)searchHighlightColor;

// 设置canelButton是否显示
/*
 *  isShow      是否显示取消按钮
 *  black       是否显示黑色背景
 *  animation   是否显示动画
 */
- (void)setShowCanelButton:(BOOL)isShow blackBG:(BOOL)black animation:(BOOL)animation;

- (void)setTextFieldText:(NSString *)text;

@end


@protocol CustomSearchBarDelegate <NSObject>

@optional
// 搜索框刚开始执行，弹出键盘
- (void)textFieldSearchBarDidBeginEditing:(UITextField *)textField;
// 搜索框搜索
- (BOOL)textFieldSearchBarShouldSearch:(UITextField *)textField;
// 搜索框清楚
- (BOOL)textFieldSearchBarShouldClear:(UITextField *)textField;
// 搜索框退出键盘
- (void)textFieldSearchBarDidEndEditing:(UITextField *)textField;
// 搜索框输入时执行
- (BOOL)textFieldSearchBar:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
// 搜索框取消按钮
- (void)textFieldSearchBarClickCanelButton;
// 搜索框弹出键盘显示历史记录
- (NSArray *)clickSearchBar;
// 搜索框清楚历史记录
- (void)clearSearchBarHistory;

@end