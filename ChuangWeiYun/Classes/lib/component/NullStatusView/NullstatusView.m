//
//  NullstatusView.m
//  cw
//
//  Created by yunlai on 13-9-16.
//
//

#import "NullstatusView.h"

@implementation NullstatusView
@synthesize textValue;
@synthesize delegate;

- (id)initNullStatusImage:(UIImage *)images andText:(NSString *)reminder{
    
    self = [super initWithFrame:CGRectMake(0, 50, KUIScreenWidth, KUIScreenHeight-50)];
    if (self) {
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(120, 105, 80, 80)];
        imgView.image=images;
        [self addSubview:imgView];
        RELEASE_SAFE(imgView);
        
        reminderText = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, KUIScreenWidth-60.f, 40)];
        reminderText.center = self.center;
        reminderText.numberOfLines = 2;
        reminderText.lineBreakMode = NSLineBreakByWordWrapping;
        reminderText.frame = CGRectMake(30.f, self.center.y-100, KUIScreenWidth-60.f, 40.f);
        reminderText.font = [UIFont systemFontOfSize:15];
        reminderText.backgroundColor = [UIColor clearColor];
        reminderText.textColor = [UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
        if (reminder==nil) {
            if ([delegate respondsToSelector:@selector(setStatusText)]) {
               reminderText.text =[delegate performSelector:@selector(setStatusText)];
            }
        }else{
            reminderText.text= reminder;
        }
        reminderText.textAlignment=NSTextAlignmentCenter;
        
        if (self.frame.size.height <= 410.0f)
        {
            reminderText.frame=CGRectMake(30, self.center.y-60, KUIScreenWidth-60.f, 40);
        }
        
        [self addSubview:reminderText];
        
    }
    return self;
    
}

- (void)setNullStatusText:(NSString *)reminder{

    reminderText.text= reminder;
}

- (void)removeNullView{
    [self removeFromSuperview];
}

- (void)dealloc
{
    RELEASE_SAFE(reminderText);
    [super dealloc];
}
@end
