//
//  PopPfShareFail.m
//  cw
//
//  Created by yunlai on 13-9-26.
//
//

#import "PopPfShareFail.h"
#import "Common.h"

#define PPSF1Height  150.f
#define PPSF2Height  135.f

@implementation PopPfShareFail

@synthesize pfShareClosingBlock;

- (id)initType:(int)type
{
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width - 20.f;
    CGFloat heght = 0.f;
    if (type == 1) {
        heght = PPSF2Height;
    } else {
        heght = PPSF1Height;
    }
    self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, heght)];
    if (self) {
        UIColor *clore = [UIColor colorWithRed:246.f/255.f green:97.f/255.f blue:48.f/255.f alpha:1.f];
        
        self.backgroundColor = clore;
        self.layer.cornerRadius = 3.f;
        self.layer.masksToBounds = YES;
        
        self.center = popupView.center;
        
        CGFloat height = 20.f;
        CGFloat width = CGRectGetWidth(self.frame);
        
        // 关闭按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(width-40.f, 10.f, 30.f, 30.f);
        [btn setImage:[UIImage imageCwNamed:@"icon_close.png"] forState:UIControlStateNormal];
        [btn setTag:0];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        // 笑脸
        UIImage *smile = [UIImage imageCwNamed:@"icon_sorry_activity.png"];
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(width/2 - smile.size.width/2, height, smile.size.width, smile.size.height)];
        img.image = smile;
        [self addSubview:img];
        [img release], img = nil;
        
        height += smile.size.height;
        
        // 恭喜您
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(45.f, height, width-90.f, 50.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 2;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16.f];
        if (type == 1) {
            label.text = @"您已经领取过此优惠券";
        } else {
            label.text = @"抱歉，暂时无法领取优惠券，请稍后再试";
        }
        
        [self addSubview:label];
        [label release], label = nil;
    }
    return self;
}

- (void)dealloc
{
    self.pfShareClosingBlock = nil;
    [super dealloc];
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
    } completion:^(BOOL finished) {
        self.pfShareClosingBlock();
    }];
    
    [self removeFromSuperview];
}
@end
