//
//  PopUpdatePwdSucceedView.m
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import "PopUpdatePwdSucceedView.h"
#import "Common.h"


@implementation PopUpdatePwdSucceedView

#define kcontorlHeight 130.0f
- (id)init
{
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width - 40.f;
    
    self = [super initWithFrame:CGRectMake(0.f, 0.f, bgwidth, kcontorlHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:221/255.0 alpha:1];
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
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.f];
        label.text = @"恭喜您 密码修改成功 !";
        [self addSubview:label];
        [label release], label = nil;
        
    }
    return self;
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
    
    [popupView addSubview:self];
    
    [self performSelector:@selector(closeView) withObject:nil afterDelay:1];
}


@end
