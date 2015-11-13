//
//  PopCheckUpdateView.m
//  cw
//
//  Created by yunlai on 13-9-26.
//
//

#import "PopCheckUpdateView.h"
#import "Common.h"

@implementation PopCheckUpdateView

@synthesize delegate;

#define kcontorlHeight 430.0f
- (id)initWithTitle:(NSString *)titleStr andContent:(NSString *)marked andBtnTitle:(NSString *)yesTitle andTitle:(NSString *)noTitle
{
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width - 40.f;
    
    self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, kcontorlHeight)];
    
    CGFloat height = 15.f;
    CGFloat width = CGRectGetWidth(self.frame);
    
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:207/255.0 green:214/255.0 blue:214/255.0 alpha:1];
        self.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:221/255.0 alpha:1];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        
        self.center = popupView.center;
        
        if (titleStr.length > 0) {
            UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(10.f, height, width-20, 30.f)];
            labelTitle.backgroundColor = [UIColor clearColor];
            labelTitle.text = titleStr;
            labelTitle.font = [UIFont boldSystemFontOfSize:17.0];
            labelTitle.textColor = [UIColor blackColor];
            labelTitle.textAlignment = NSTextAlignmentCenter;
            [self addSubview:labelTitle];
            RELEASE_SAFE(labelTitle);
            
            height +=30;
        }
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10.f, height, width-20, 70.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
//        label.textColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.0];
        label.text = marked;//@"发现新版本，现在去更新";
        label.numberOfLines=0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        CGSize labelSize = CGSizeZero;
        CGSize aMaxSize = CGSizeMake(width-20, 2000);
        UIFont *font = [UIFont systemFontOfSize:15.0];
        labelSize = [label.text sizeWithFont:font constrainedToSize:aMaxSize lineBreakMode:NSLineBreakByWordWrapping];
        
        label.frame = CGRectMake(10.f, height, width-20, labelSize.height);
        
        [self addSubview:label];
        RELEASE_SAFE(label);
        
        height += labelSize.height+5;
        
        UILabel *levelLine=[[UILabel alloc]initWithFrame:CGRectMake(0.f, height+5, width, 2)];
        levelLine.backgroundColor=[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1];
        [self addSubview:levelLine];
        RELEASE_SAFE(levelLine);
        
        UIButton *yesBtn=[[UIButton alloc]initWithFrame:CGRectMake(3, height+5, width/2-7, 50.0f)];
        [yesBtn setTitle:yesTitle forState:UIControlStateNormal];
        [yesBtn setTitleColor:[UIColor colorWithRed:62/255.0 green:128/255.0f blue:242/255.0 alpha:0.8] forState:UIControlStateNormal];
        yesBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [yesBtn addTarget:self action:@selector(noCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:yesBtn];
        RELEASE_SAFE(yesBtn);
        
        UILabel *verticalLine=[[UILabel alloc]initWithFrame:CGRectMake(width/2-0.4, height+5, 1.15, 50)];
        verticalLine.backgroundColor=[UIColor colorWithRed:195/255.0 green:195/255.0 blue:196/255.0 alpha:1];
        [self addSubview:verticalLine];
        RELEASE_SAFE(verticalLine);
        
        UIButton *noBtn=[[UIButton alloc]initWithFrame:CGRectMake(width/2+4, height+5, width/2-7, 50.0f)];
        [noBtn setTitle:noTitle forState:UIControlStateNormal];
        [noBtn setTitleColor:[UIColor colorWithRed:62/255.0 green:128/255.0f blue:242/255.0 alpha:0.8] forState:UIControlStateNormal];
        noBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [noBtn addTarget:self action:@selector(okCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:noBtn];
        RELEASE_SAFE(noBtn);
        
        self.frame = CGRectMake(0.f, 0.f, bgwidth, height+55);
        self.center = popupView.center;
        
    }
  
    return self;
}

//确定检查更新
-(void)okCancelClick{
    if ([self.delegate respondsToSelector:@selector(OKCheckUpdates)]) {
        [self.delegate performSelector:@selector(OKCheckUpdates)];
    }
    
}

//不更新
-(void)noCancelClick{
    
    [self closeView];
}

- (void)closeView
{
    [UIView animateWithDuration:0.32 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
//         popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
         [self removeFromSuperview];
    }];
    
}

- (CAKeyframeAnimation *)getKeyframeAni{
    CAKeyframeAnimation* popAni=[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAni.duration=0.4;
    popAni.values=@[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)],[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAni.keyTimes=@[@0.0,@0.5,@0.75,@1.0];
    popAni.timingFunctions=@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    return popAni;
}

- (void)addPopupSubview
{

    [super addPopupSubview:1];
    
    [popupView addSubview:self];
    
}
@end
