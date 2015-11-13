//
//  UITableScrollView.h
//  scrollview
//
//  Created by yunlai on 13-8-16.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableScrollViewCell.h"

@protocol UITableScrollViewDelagate;

@interface UITableScrollView : UIScrollView <UIScrollViewDelegate>
{
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    
    NSInteger clickIndex;
    NSInteger sumPages;
    NSInteger currIndex;
    NSInteger pages;                // 此处可以修改，如果为1  说明是3个内存在循环，如果为2  说明是5个内存在循环
    
    id <UITableScrollViewDelagate> dataSource;
}

@property (assign, nonatomic) NSInteger clickIndex;
@property (assign, nonatomic) id <UITableScrollViewDelagate> dataSource;

// 移除试图
- (void)removeFromSuperviewSelf;

// 重用函数
- (id)dequeueRecycledPage;

// 重载视图
- (void)reloadView;

// 要传如点击的是哪个row
- (id)initWithFrame:(CGRect)frame clickIndex:(NSInteger)aclickIndex pages:(NSInteger)cpages;

@end


@protocol UITableScrollViewDelagate <NSObject>

@required
- (NSInteger)tableScrollViewNumberOfRow:(UITableScrollView *)tableScrollView;
- (UITableScrollViewCell *)tableScrollView:(UITableScrollView *)tableScrollView viewForRowAtIndex:(NSInteger)index;

@optional
- (void)tableScrollView:(UITableScrollView *)tableScrollView didSelectRowAtIndex:(NSInteger)index beforeIndex:(NSInteger)aindex;
- (void)tablescrollViewDidScroll:(UIScrollView *)scrollView;

@end