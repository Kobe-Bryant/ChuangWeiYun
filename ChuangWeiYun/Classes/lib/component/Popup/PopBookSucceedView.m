//
//  PopBookSucceedView.m
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import "PopBookSucceedView.h"
#import "Common.h"

#define PBSHeight       200.f

@implementation PopBookSucceedView

@synthesize delegate;

- (id)init
{
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width - 20.f;
    
    self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, PBSHeight)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.f;
        self.layer.masksToBounds = YES;
        
        self.center = popupView.center;
        
        CGFloat height = 20.f;
        CGFloat width = CGRectGetWidth(self.frame);
        
        // 笑脸
        UIImage *smile = [UIImage imageCwNamed:@"icon_smiling.png"];
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(width/2 - smile.size.width/2, height, smile.size.width, smile.size.height)];
        img.image = smile;
        [self addSubview:img];
        [img release], img = nil;
        
        height += smile.size.height;
        
        // 恭喜您
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, width, 70.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14.f];
        label.text = @"抢购成功 稍后会有店长与您联系";
        [self addSubview:label];
        [label release], label = nil;
        
        height += 70.f;
        
        // 关闭按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(70.f, height, width - 140.f, 40.f);
        btn.backgroundColor = [UIColor colorWithRed:0.f green:105.f/255.f blue:182.f/255.f alpha:1.f];
        [btn setTitle:@"我知道了" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 3.f;
        btn.layer.masksToBounds = YES;
        [self addSubview:btn];
    }
    return self;
}

- (void)addPopupSubview
{
    [super addPopupSubview];
    
    [popupView addSubview:self];
}

- (void)btnClick:(UIButton *)btn
{
    [UIView animateWithDuration:0.23 animations:^{
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    }];
    [self removeFromSuperview];
    
    if ([delegate respondsToSelector:@selector(PopBookSucceedViewClick:)]) {
        [delegate PopBookSucceedViewClick:self];
    }
}

@end
