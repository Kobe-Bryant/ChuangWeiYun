//
//  WaterCellView.h
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WLCBigImageW        300.f   // 图片的宽度
#define WLCBigImageH        225.f   // 图片的高度
#define WLCSmallImageW      145.f   // 图片的宽度
#define WLCSmallImageH      145.f   // 图片的高度
#define WLCSpaceLW          10.f    // 左边距
#define WLCSpaceUH          10.f    // 上边距
#define WLCSpaceRW          10.f    // 右边距
#define WLCSpaceDH          10.f    // 下边距
#define WLCMaskVH           20.f    // 蒙版高度

@protocol WaterCellViewDelegate;

@interface WaterCellView : UIView
{
    UIImageView *wImageView;
    UILabel *wNameLabel;
    UILabel *wMoneyLabel;
    UIButton *wImageBtn;
    
    BOOL _isbig;
    
    id <WaterCellViewDelegate> delegate;
}

@property (assign, nonatomic) id <WaterCellViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame isbig:(BOOL)isbig;

- (void)setViewContentAndFrame:(NSDictionary *)dict fromCenter:(BOOL)_isHide;

- (void)setViewImage:(UIImage *)image;

+ (CGFloat)getViewBigHeight;

+ (CGFloat)getViewSmallHeight;

@end

@protocol WaterCellViewDelegate <NSObject>

@optional
- (void)tapClickWaterCellView:(WaterCellView *)water;

@end