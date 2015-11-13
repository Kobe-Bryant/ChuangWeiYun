//
//  DetailViewDownBar.m
//  cw
//
//  Created by yunlai on 13-8-19.
//
//

#import "DetailViewDownBar.h"
#import "Common.h"

@implementation DetailViewDownBar

@synthesize commentsBtn;
@synthesize orderBtn;
@synthesize likeBtn;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame type:(SDState)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        commentsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        commentsBtn.frame = CGRectMake(10.f, (self.frame.size.height - 30) * 0.5, 30.f, 30.f);
        commentsBtn.tag = SDButtonDBCommets;
        [commentsBtn setBackgroundImage:[UIImage imageNamed:@"icon_chat.png"] forState:UIControlStateNormal];
        [commentsBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:commentsBtn];
        
        if (type == SDButtonStateDetail) {
            orderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            orderBtn.frame = CGRectMake(70.f, (self.frame.size.height - 40) * 0.5, 180.f, 40.f);
            orderBtn.tag = SDButtonDBOrder;
            [orderBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            orderBtn.layer.cornerRadius = 5.f;
            [self addSubview:orderBtn];
        }
        
        likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        likeBtn.frame = CGRectMake(280.f, (self.frame.size.height - 30) * 0.5, 30.f, 30.f);
        likeBtn.tag = SDButtonDBLike;
        [likeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:likeBtn];
        
    }
    return self;
}

- (void)setOrderBtnState:(SDOrderBtnState)state
{
    if (state == SDOrderBtnStateNO) {
//        if ([Common isLoctionAndEqual]) {
            orderBtn.enabled = YES;
            [orderBtn setTitle:@"立即抢购" forState:UIControlStateNormal];
            orderBtn.backgroundColor = [UIColor colorWithRed:234.f/255.f green:50.f/255.f blue:43.f/255.f alpha:1.f];
            [orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        } else {
//            orderBtn.enabled = NO;
//            [orderBtn setTitle:@"" forState:UIControlStateNormal];
//            orderBtn.backgroundColor = [UIColor clearColor];
//            //[orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        }
    } else {
        orderBtn.enabled = NO;
        [orderBtn setTitle:@"当前城市暂无此商品" forState:UIControlStateNormal];
        orderBtn.backgroundColor = [UIColor clearColor];
        [orderBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}

- (void)setLikeBtnImageState:(SDImageState)state
{
    if (state == SDImageStateSure) {
        [likeBtn setBackgroundImage:[UIImage imageNamed:@"icon_like_click.png"] forState:UIControlStateNormal];
    } else {
        [likeBtn setBackgroundImage:[UIImage imageNamed:@"icon_like.png"] forState:UIControlStateNormal];
    }
}

- (void)buttonClick:(UIButton *)btn
{
    if ([delegate respondsToSelector:@selector(detailDownBarEvent:)]) {
        [delegate detailDownBarEvent:btn.tag];
    }
}
@end
