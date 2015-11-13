//
//  WaterCellView.m
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "WaterCellView.h"
#import "Global.h"
#import "Common.h"

@implementation WaterCellView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame isbig:(BOOL)isbig
{
    self = [super initWithFrame:frame];
    if (self) {
        _isbig = isbig;
        
        self.backgroundColor = [UIColor whiteColor];
        
        wImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [wImageBtn addTarget:self action:@selector(tapImageBtn:) forControlEvents:UIControlEventTouchUpInside];
        [wImageBtn setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:wImageBtn];
        
        wImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:wImageView];

        if (_isbig) {
            wImageView.frame = CGRectMake(0.f, (CGRectGetHeight(self.frame) - WLCBigImageH)/2, WLCBigImageW, WLCBigImageH);
            wImageBtn.frame = self.bounds;
        } else {
            wImageView.frame = CGRectMake(0.f, (CGRectGetHeight(self.frame) - WLCSmallImageH)/2, WLCSmallImageW, WLCSmallImageH);
            wImageBtn.frame = self.bounds;
        }
        
        wNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        wNameLabel.frame = CGRectMake(0.f, 5.f, 100.f, 20.f);
        wNameLabel.backgroundColor = [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:0.8f];
        wNameLabel.textColor = [UIColor whiteColor];
        wNameLabel.textAlignment = NSTextAlignmentCenter;
        wNameLabel.font = KCWSystemFont(14.f);
        [self addSubview:wNameLabel];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0.f, CGRectGetHeight(self.frame) - WLCMaskVH, CGRectGetWidth(self.frame), WLCMaskVH)];
        view.tag = 'b';
        view.backgroundColor = [UIColor colorWithRed:224.f/255.f green:224.f/255.f blue:224.f/255.f alpha:0.1f];
        [self addSubview:view];
        [view release], view = nil;

        wMoneyLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        wMoneyLabel.backgroundColor = [UIColor clearColor];
        wMoneyLabel.textColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];
        wMoneyLabel.textAlignment = NSTextAlignmentRight;
        wMoneyLabel.font = KCWSystemFont(12.f);
        wMoneyLabel.frame = CGRectMake(0.f, CGRectGetHeight(self.frame) - WLCMaskVH, CGRectGetWidth(self.frame)-10.f, WLCMaskVH);
        [self addSubview:wMoneyLabel];
    }
    return self;
}

- (void)setViewContentAndFrame:(NSDictionary *)dict fromCenter:(BOOL)_isHide
{
    wNameLabel.text = [dict objectForKey:@"name"];
    
    if ([Common isLoctionAndEqual]) {
        wMoneyLabel.text = [NSString stringWithFormat:@"￥%0.2f",[[dict objectForKey:@"price"] doubleValue]];
    } else {
        wMoneyLabel.text = nil;
    }
    
    if (_isHide == YES) {
        UIView *vi = [self viewWithTag:'b'];
        vi.hidden = YES;
        
        wMoneyLabel.hidden = YES;
    }
}

- (void)setViewImage:(UIImage *)image
{
    if (!_isbig) {
        CGSize imgSie = CGSizeMake(WLCSmallImageH, WLCSmallImageH);
        
        CGSize size = [UIImage fitsize:image.size size:imgSie];
        
        wImageView.frame = CGRectMake(WLCSmallImageH/2 - size.width/2, (CGRectGetHeight(self.frame) - WLCSmallImageH)/2 + WLCSmallImageH/2 - size.height/2, size.width, size.height);
    }

    wImageView.image = image;

}

+ (CGFloat)getViewSmallHeight
{
    return WLCSmallImageH;
}

+ (CGFloat)getViewBigHeight
{
    return WLCBigImageH;
}

- (void)tapImageBtn:(UIButton *)btn
{
    if ([delegate respondsToSelector:@selector(tapClickWaterCellView:)]) {
        [delegate tapClickWaterCellView:self];
    }
}

- (void)dealloc
{
    [wImageView release], wImageView = nil;
    [wNameLabel release], wNameLabel = nil;
    [wMoneyLabel release], wMoneyLabel = nil;
    
    [super dealloc];
}

@end
