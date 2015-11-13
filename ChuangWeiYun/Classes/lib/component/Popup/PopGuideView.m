//
//  PopGuideView.m
//  cw
//
//  Created by yunlai on 13-9-23.
//
//

#import "PopGuideView.h"
#import "guide_model.h"

@implementation PopGuideView

- (id)initWithImage:(UIImage *)img index:(Guide_Enum)guide
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 568.f)];
    if (self) {
        UIImageView *imgeView = [[UIImageView alloc]initWithFrame:self.bounds];
        imgeView.image = img;
        [self addSubview:imgeView];
        [imgeView release], imgeView = nil;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = self.bounds;
        [btn addTarget:self action:@selector(tapGesture:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        guideEnum = guide;
    }
    return self;
}

- (void)tapGesture:(UIButton *)tap
{
    guide_model *gMod = [[guide_model alloc]init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:guideEnum],@"id", nil];
    [gMod insertDB:dict];
    [gMod release], gMod = nil;
    
    [UIView animateWithDuration:0.23 animations:^{
        self.opaque = YES;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)addPopupSubview
{
    [super addPopupSubview];
    
    popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    
    [popupView addSubview:self];
}

+ (BOOL)isInsertTable:(Guide_Enum)guide
{
    guide_model *gMod = [[guide_model alloc]init];
    gMod.where = [NSString stringWithFormat:@"id = '%d'",guide];
    NSArray *arr = [gMod getList];
    [gMod release], gMod = nil;
    
    if (arr.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end
