//
//  PopClearChcheView.m
//  cw
//
//  Created by yunlai on 13-11-6.
//
//

#import "PopClearChcheView.h"
#import "Common.h"

@implementation PopClearChcheView

@synthesize delegate;

#define kcontorlHeight 130.0f
- (id)init:(NSString *)marked andBtnTitle:(NSString *)yesTitle andTitle:(NSString *)noTitle
{
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width - 40.f;
    
    self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, kcontorlHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:221/255.0 alpha:1];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        
        self.center = popupView.center;
        
        CGFloat height = 10.f;
        CGFloat width = CGRectGetWidth(self.frame);
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, width, 70.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:17.0];
        label.text = marked;
        [self addSubview:label];
        RELEASE_SAFE(label);
        
        height += 70.f;
        
        UILabel *levelLine=[[UILabel alloc]initWithFrame:CGRectMake(0.f, height, width, 2)];
        levelLine.backgroundColor=[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1];
        [self addSubview:levelLine];
        RELEASE_SAFE(levelLine);
        
        UIButton *yesBtn=[[UIButton alloc]initWithFrame:CGRectMake(3, height+1, width/2-7, 50.0f)];
        [yesBtn setTitle:yesTitle forState:UIControlStateNormal];
        [yesBtn setTitleColor:[UIColor colorWithRed:62/255.0 green:128/255.0f blue:242/255.0 alpha:0.8] forState:UIControlStateNormal];
        yesBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [yesBtn addTarget:self action:@selector(okCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:yesBtn];
        RELEASE_SAFE(yesBtn);
        
        UILabel *verticalLine=[[UILabel alloc]initWithFrame:CGRectMake(width/2-0.4, height, 1.14, kcontorlHeight-height)];
        verticalLine.backgroundColor=[UIColor colorWithRed:195/255.0 green:195/255.0 blue:196/255.0 alpha:1];
        [self addSubview:verticalLine];
        RELEASE_SAFE(verticalLine);
        
        UIButton *noBtn=[[UIButton alloc]initWithFrame:CGRectMake(width/2+4, height+1, width/2-7, 50.0f)];
        [noBtn setTitle:noTitle forState:UIControlStateNormal];
        [noBtn setTitleColor:[UIColor colorWithRed:62/255.0 green:128/255.0f blue:242/255.0 alpha:0.8] forState:UIControlStateNormal];
        noBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [noBtn addTarget:self action:@selector(noCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:noBtn];
        RELEASE_SAFE(noBtn);
        
    }
    return self;
}


-(void)okCancelClick{
    if ([self.delegate respondsToSelector:@selector(OKClearChche)]) {
        [self.delegate performSelector:@selector(OKClearChche)];
    }
    
}


-(void)noCancelClick{
    [self closeView];
}

- (void)closeView
{
    [UIView animateWithDuration:0.32 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}


- (void)addPopupSubview
{
    [super addPopupSubview:1];
    popupView.alpha = 1;
    [popupView addSubview:self];
    
}


@end
