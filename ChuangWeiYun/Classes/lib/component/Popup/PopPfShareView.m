//
//  PopPfShareView.m
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import "PopPfShareView.h"
#import "PfImageView.h"
#import "Common.h"
#import "PreferentialObject.h"

#define PPS1Height       270.f

#define PPS2Height       190.f

@implementation PopPfShareView

@synthesize delegate;

@synthesize pfShareBlock;

@synthesize shareType;

- (id)initType:(int)type
{
    shareType = type;
    
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width - 20.f;
    
    if (shareType == 0) {
        self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, PPS1Height)];
    } else {
        self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, PPS2Height)];
    }
    
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
        UIImage *smile = [UIImage imageCwNamed:@"icon_smiling_activity.png"];
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(width/2 - smile.size.width/2, height, smile.size.width, smile.size.height)];
        img.image = smile;
        [self addSubview:img];
        [img release], img = nil;
        
        height += smile.size.height;
        
        // 恭喜您
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, width, 50.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16.f];
        if (shareType == 0) {
            label.text = @"成功领取优惠券！";
        } else {
            label.text = @"分享成功！";
        }
        [self addSubview:label];
        [label release], label = nil;
        
        height += 50.f;
        
        if (shareType == 0) {
            pfimage = [[PfImageView alloc]initWithFrame:CGRectMake(0.f, height, width, 80.f)];
            pfimage.image = [UIImage imageCwNamed:@"coupons_store.png"];
            pfimage.titellabel.textColor = clore;
            pfimage.moneylabel.textColor = clore;
            pfimage.startlabel.textColor = clore;
            pfimage.endlabel.textColor = clore;
            pfimage.pfLabel.textColor = clore;
            pfimage.usefullabel.textColor = clore;
            [self addSubview:pfimage];
            
            height += 80.f; 
        }

        // 前往“我的优惠券”
        label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, width, 60.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:20.f];
        if (shareType == 0) {
            label.text = @"前往“我的优惠券”";
        } else {
            label.text = @"登录领取优惠券";
            label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageCwNamed:@"receive_button.png"]];
        }
        [self addSubview:label];
        [label release], label = nil;
        
        UIImage *imForg = [UIImage imageCwNamed:@"forward_store.png"];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0.f, height, width, 60.f);
        [btn setImage:imForg forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0.f, 230.f, 0.f, 0.f);
        [btn setTag:1];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
    }
    return self;
}

- (void)dealloc
{
    [pfimage release], pfimage = nil;
    self.pfShareBlock = nil;
    [super dealloc];
}

- (void)addPopupSubview:(NSDictionary *)dict
{
    [super addPopupSubview];
    
    if (shareType == 0) {
        pfimage.titellabel.text = [dict objectForKey:@"title"];
        pfimage.moneylabel.text = [NSString stringWithFormat:@"¥%d",[[dict objectForKey:@"discount"] intValue]];
        pfimage.startlabel.text = [PreferentialObject getTheDate:[[dict objectForKey:@"start_date"] intValue] symbol:1];
        pfimage.endlabel.text = [PreferentialObject getTheDate:[[dict objectForKey:@"end_date"] intValue] symbol:1];
    }
    
    [popupView addSubview:self];
}

- (void)btnClick:(UIButton *)btn
{
    [UIView animateWithDuration:0.23 animations:^{
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    } completion:^(BOOL finished) {
        self.pfShareBlock();
    }];
    
    [self removeFromSuperview];
    
    if (btn.tag == 1) {
        if ([delegate respondsToSelector:@selector(popPfShareViewClick:)]) {
            [delegate popPfShareViewClick:shareType];
        }
    } 
}

@end
