//
//  PopLoctionHelpView.m
//  cw
//
//  Created by yunlai on 13-10-18.
//
//

#import "PopLoctionHelpView.h"
#import "Common.h"

@implementation PopLoctionHelpView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight+20.f)];
    if (self) {
        _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, KUIScreenHeight+20.f, KUIScreenWidth, KUIScreenHeight+20.f)];
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 7.0) {
            _imgView.image = [UIImage imageCwNamed:@"ios7LoctionHelp.jpg"];
        } else {
            _imgView.image = [UIImage imageCwNamed:@"ios6LoctionHelp.jpg"];
        }
        
        [self addSubview:_imgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
        [tap release], tap = nil;
    }
    return self;
}

- (void)dealloc
{
    [_imgView release], _imgView = nil;
    [super dealloc];
}

- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.23 animations:^{
        _imgView.frame = CGRectMake(0.f, KUIScreenHeight+20.f, KUIScreenWidth, KUIScreenHeight+20.f);
    } completion:^(BOOL finished) {
        [self removeFromSuperviewSelf];
    }];
}

- (void)addPopupSubview
{
    [super addPopupSubview];
    
    popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    
    [popupView addSubview:self];
    
    [UIView animateWithDuration:0.23 animations:^{
        _imgView.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight+20.f);
    }];
}

- (void)removeFromSuperviewSelf
{
    [self removeFromSuperview];
}
@end
