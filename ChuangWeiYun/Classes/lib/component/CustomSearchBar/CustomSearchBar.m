//
//  CustomSearchBar.m
//  search
//
//  Created by yunlai on 13-8-30.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "CustomSearchBar.h"
#import <QuartzCore/QuartzCore.h>

#define CustomSearchBarHeight           44.f
#define CustomSearchBarContentHeight    34.f
#define CustomSearchBarBackViewHeight   5.f

@implementation CustomSearchBar

@synthesize bgView;
@synthesize canelButton;
@synthesize searchTextField;
@synthesize backgdView;
@synthesize placeholder;
@synthesize normalColor;
@synthesize highlightColor;
@synthesize searchNlColor;
@synthesize searchHtColor;
@synthesize delegate;

- (id)initWithColor:(UIColor *)bgNormalColor
     bghighlightColor:(UIColor *)bgHighlightColor
         searchColor:(UIColor *)searchNormalColor
     searchhighlightColor:(UIColor *)searchHighlightColor
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, [UIScreen mainScreen].applicationFrame.size.width, CustomSearchBarHeight)];
    if (self) {
        
        self.normalColor = bgNormalColor;
        self.highlightColor = bgHighlightColor;
        self.searchNlColor = searchNormalColor;
        self.searchHtColor = searchHighlightColor;
        
        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.0f];
        
        bgView = [[UIView alloc]initWithFrame:self.frame];
        bgView.backgroundColor = self.normalColor;
        [self addSubview:bgView];
        
        backgdView = [[UIView alloc]initWithFrame:CGRectMake(10.f, CustomSearchBarBackViewHeight, self.frame.size.width - 20.f, CustomSearchBarContentHeight)];
        backgdView.backgroundColor = self.searchNlColor;
        backgdView.layer.masksToBounds = YES;
        backgdView.layer.cornerRadius = 17.f;
        [bgView addSubview:backgdView];
        
        UIImageView *searchImage = [[UIImageView alloc]initWithFrame:CGRectMake(5.f, 7.f, 20.f, 20.f)];
        searchImage.image = [UIImage imageNamed:@"search_store.png"];
        [backgdView addSubview:searchImage];
        [searchImage release], searchImage = nil;
        
        searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(30.f, 0.f, CGRectGetWidth(backgdView.frame) - 30.f, CustomSearchBarContentHeight)];
        searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        searchTextField.returnKeyType = UIReturnKeySearch;
        searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
        searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
        searchTextField.delegate = self;
        [backgdView addSubview:searchTextField];
        
        canelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        canelButton.frame = CGRectMake(CGRectGetMaxX(backgdView.frame) + 10.f, 5.f, 50.f, CustomSearchBarContentHeight);
        [canelButton setBackgroundColor:[UIColor whiteColor]];
        [canelButton setTitleColor:[UIColor colorWithRed:42.f/255.0f green:144.f/255.f blue:229.f/255.f alpha:1] forState:UIControlStateNormal];
        [canelButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [canelButton setTitle:@"取消" forState:UIControlStateNormal];
        [canelButton addTarget:self action:@selector(canelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        canelButton.layer.cornerRadius = 3.f;
        canelButton.layer.masksToBounds = YES;
        [bgView addSubview:canelButton];
    }
    return self;
}


- (void)dealloc
{
    [bgView release], bgView = nil;
    [searchTextField release], searchTextField = nil;
    [backgdView release], backgdView = nil;
    [normalColor release], normalColor = nil;
    [highlightColor release], highlightColor = nil;
    [searchNlColor release], searchNlColor = nil;
    [searchHtColor release], searchHtColor = nil;
    
    [super dealloc];
}

- (void)setPlaceholder:(NSString *)aplaceholder
{    
    searchTextField.placeholder = aplaceholder;
}

- (void)setTextFieldText:(NSString *)text
{
    searchTextField.text = text;
}

// 设置canelButton是否显示
- (void)setShowCanelButton:(BOOL)isShow blackBG:(BOOL)black animation:(BOOL)animation
{
    CGFloat duration = 0.23f;
    CGFloat xSize = 0.0f;
    
    if (isShow) {
        
        if (black) {
            if (IOS_7) {
                xSize = 20.0f;
            }
            self.frame = CGRectMake(0.f, xSize, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height);
        }
        
        [UIView animateWithDuration:duration animations:^{
            bgView.backgroundColor = self.highlightColor;
            backgdView.backgroundColor = self.searchHtColor;
            self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.8f];
        }];

        if (animation) {
            [UIView animateWithDuration:duration animations:^{
                backgdView.frame = CGRectMake(10.f, CustomSearchBarBackViewHeight, self.frame.size.width - 80.f, CustomSearchBarContentHeight);
                searchTextField.frame = CGRectMake(30.f, 0.f, CGRectGetWidth(backgdView.frame) - 30.f, CustomSearchBarContentHeight);
                canelButton.frame = CGRectMake(CGRectGetMaxX(backgdView.frame) + 10.f,5.f, 50.f, CustomSearchBarContentHeight);
            } completion:^(BOOL finished) {
                
            }];
        } else {
            backgdView.frame = CGRectMake(10.f, CustomSearchBarBackViewHeight, self.frame.size.width - 80.f, CustomSearchBarContentHeight);
            searchTextField.frame = CGRectMake(30.f, 0.f, CGRectGetWidth(backgdView.frame) - 30.f, CustomSearchBarContentHeight);
            canelButton.frame = CGRectMake(CGRectGetMaxX(backgdView.frame) + 10.f, 5.f, 50.f, CustomSearchBarContentHeight);
        }
    } else {
        
        //searchTextField.text = nil;

        [UIView animateWithDuration:duration animations:^{
            bgView.backgroundColor = self.normalColor;
            backgdView.backgroundColor = self.searchNlColor;
            self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.0f];
        }];
        
        if (black) {
            self.frame = CGRectMake(0.f, 0.f, [UIScreen mainScreen].applicationFrame.size.width, CustomSearchBarHeight);
        }

        if (animation) {
            [UIView animateWithDuration:duration animations:^{
                backgdView.frame = CGRectMake(10.f, CustomSearchBarBackViewHeight, self.frame.size.width - 20.f, CustomSearchBarContentHeight);
                searchTextField.frame = CGRectMake(30.f, 0.f, CGRectGetWidth(backgdView.frame) - 30.f, CustomSearchBarContentHeight);
                canelButton.frame = CGRectMake(CGRectGetMaxX(backgdView.frame) + 10.f, 5.f, 50.f, CustomSearchBarContentHeight);
            } completion:^(BOOL finished) {
                
            }];
        } else {
            backgdView.frame = CGRectMake(10.f, CustomSearchBarBackViewHeight, self.frame.size.width - 20.f, CustomSearchBarContentHeight);
            searchTextField.frame = CGRectMake(30.f, 0.f, CGRectGetWidth(backgdView.frame) - 30.f, CustomSearchBarContentHeight);
            canelButton.frame = CGRectMake(CGRectGetMaxX(backgdView.frame) + 10.f, 5.f, 50.f, CustomSearchBarContentHeight);
        }
    }
}


- (void)createHistoryMemory:(NSArray *)arr
{
    if (arr.count == 0) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20.f, CustomSearchBarHeight, 280.f, CustomSearchBarHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14.f];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"您暂时还没有搜索记录";
        [self addSubview:label];
        [label release], label = nil;
    } else {
        int sum = arr.count;
        if ([UIScreen mainScreen].applicationFrame.size.height < 500) {
            if (sum > 3) {
                sum = 3;
            }
        }
        for (int i = 0;i < sum;i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(20.f, (i+1)*CustomSearchBarHeight, 280.f, CustomSearchBarHeight);
            [btn setTag:i];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(btn.frame), CustomSearchBarHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:15.f];
            label.text = [arr objectAtIndex:i];
            [btn addSubview:label];
            [label release], label = nil;
        }
        
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, (sum+1)*CustomSearchBarHeight, [UIScreen mainScreen].applicationFrame.size.width, 1.f)];
        line.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.7f];
        [self addSubview:line];
        [line release], line = nil;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20.f, (sum+1)*CustomSearchBarHeight, 280.f, CustomSearchBarHeight);
        [btn setTag:CustomSearchBarClearTag];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
        img.image = [UIImage imageNamed:@"icon_record_store.png"];
        [btn addSubview:img];
        [img release], img = nil;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30.f, 0.f, CGRectGetWidth(btn.frame), CustomSearchBarHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16.f];
        label.text = @"清空历史记录";
        [btn addSubview:label];
        [label release], label = nil;
    }
}

- (void)removeFromSuperviewSelf
{
    [UIView animateWithDuration:0.23 animations:^{
        for (id view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view removeFromSuperview];
            } else if ([view isKindOfClass:[UILabel class]]) {
                [view removeFromSuperview];
            }
        }
    }];
}

// 历史记录
- (void)btnClick:(UIButton *)btn
{
    if (btn.tag != CustomSearchBarClearTag) {

        [searchTextField resignFirstResponder];
        
        searchTextField.text = ((UILabel *)[btn.subviews lastObject]).text;
        
        if ([delegate respondsToSelector:@selector(textFieldSearchBarShouldSearch:)]) {
            [delegate textFieldSearchBarShouldSearch:searchTextField];
        }
    } else {
        
        [self removeFromSuperviewSelf];
        
        if ([delegate respondsToSelector:@selector(clearSearchBarHistory)]) {
            [delegate clearSearchBarHistory];
        }
        if ([delegate respondsToSelector:@selector(clickSearchBar)]) {
            NSArray *arr = [delegate clickSearchBar];
            [self createHistoryMemory:arr];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([delegate respondsToSelector:@selector(clickSearchBar)]) {
        NSArray *arr = [delegate clickSearchBar];
        [self createHistoryMemory:arr];
    }
    
    if ([delegate respondsToSelector:@selector(textFieldSearchBarDidBeginEditing:)]) {
        [delegate textFieldSearchBarDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self removeFromSuperviewSelf];
    
    if ([delegate respondsToSelector:@selector(textFieldSearchBarDidEndEditing:)]) {
        [delegate textFieldSearchBarDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    BOOL hide = NO;
    
    if ([delegate respondsToSelector:@selector(textFieldSearchBarShouldClear:)]) {
        hide = [delegate textFieldSearchBarShouldClear:textField];
    } else {
        hide = YES;
    }
    return hide;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL hide = NO;

    if ([delegate respondsToSelector:@selector(textFieldSearchBarShouldSearch:)]) {
        hide = [delegate textFieldSearchBarShouldSearch:textField];
        NSLog(@"hide = %d",hide);
        if (hide) {
            [searchTextField resignFirstResponder];
        }
    } else {
        hide = YES;
    }
    return hide;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL hide = NO;
    
    if ([delegate respondsToSelector:@selector(textFieldSearchBar:shouldChangeCharactersInRange:replacementString:)]) {
        hide = [delegate textFieldSearchBar:textField shouldChangeCharactersInRange:range replacementString:string];
    } else {
        hide = YES;
    }
    return hide;
}

// 取消按钮触发事件
- (void)canelButtonClick:(UIButton *)btn
{
    [searchTextField resignFirstResponder];
    
    searchTextField.text = nil;
    
    if ([delegate respondsToSelector:@selector(textFieldSearchBarClickCanelButton)]) {
        [delegate textFieldSearchBarClickCanelButton];
    }
}

@end
