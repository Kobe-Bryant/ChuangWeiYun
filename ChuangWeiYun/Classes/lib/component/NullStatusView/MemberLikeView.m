//
//  MemberLikeView.m
//  cw
//
//  Created by yunlai on 13-9-16.
//
//

#import "MemberLikeView.h"
#import "Common.h"

@implementation MemberLikeView

- (id)initImage:(UIImage *)images andText:(NSString *)reminder
{
    
    self = [super initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)];
    if (self) {
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 155, 80, 80)];
        imgView.image=images;
        [self addSubview:imgView];
        RELEASE_SAFE(imgView);
        
        UILabel *reminderText=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 30)];
        reminderText.center=self.center;
        reminderText.font=[UIFont systemFontOfSize:15];
        reminderText.backgroundColor=[UIColor clearColor];
        reminderText.textColor=[UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
        reminderText.text=reminder;
        reminderText.textAlignment=NSTextAlignmentCenter;
        [self addSubview:reminderText];
        RELEASE_SAFE(reminderText);
    }
    return self;
}

- (void)closeView
{
    [self removeFromSuperview];
}



@end
