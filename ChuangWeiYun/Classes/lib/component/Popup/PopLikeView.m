//
//  PopLikeView.m
//  cw
//
//  Created by yunlai on 13-9-22.
//
//

#import "PopLikeView.h"
#import "Common.h"

@implementation PopLikeView

- (id)init
{
    UIImage *img = [UIImage imageCwNamed:@"icon_like_add.png"];
    
    self = [super initWithFrame:CGRectMake(KUIScreenWidth/2 - img.size.width/2, KUIScreenHeight/2 - img.size.height/2, img.size.width, img.size.height)];
    if (self) {
        self.center = popupView.center;
        
        imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, 0.f, img.size.width, img.size.height)];
        [self addSubview:imgView];
    }
    return self;
}

- (void)dealloc
{
    [imgView release], imgView = nil;
    [super dealloc];
}

- (void)closeView
{
    [UIView animateWithDuration:0.23 animations:^{
        self.opaque = 0.f;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)addPopupSubviewType:(PopLikeEnum)type
{
    [super addPopupSubview:1];
    
    popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    
    if (type == PopLikeEnumAdd) {
        UIImage *img = [UIImage imageCwNamed:@"icon_like_add.png"];
        imgView.image = img;
    } else {
        UIImage *img = [UIImage imageCwNamed:@"icon_minus_add.png"];
        imgView.image = img;
    }

    [popupView addSubview:self];
    
    [self performSelector:@selector(closeView) withObject:nil afterDelay:1.f];
}

@end
