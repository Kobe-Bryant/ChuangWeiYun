//
//  boxView.m
//  cw
//
//  Created by yunlai on 13-12-3.
//
//

#import "boxView.h"

@implementation boxView
@synthesize delegate;

/**
 *@param frame 百宝箱图标视图的frame
 *@param imageStr 图标的名称
 *@param textStr  图标下的名称
 *@param tag 图标的Tag
 *@param delegates 是否设置代理
 */

- (id)initWithFrame:(CGRect)frame andIcon:(NSString *)imageStr andText:(NSString *)textStr andTag:(int)tag delegate:(id<boxBtnDelegate>)delegates
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
 
        UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aboutButton.frame = self.bounds;
        [aboutButton setBackgroundImage:[UIImage imageNamed:@"icon_bg_click_box"] forState:UIControlStateHighlighted];
        UIImage *aboutImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageStr ofType:@"png"]];
        [aboutButton setImage:aboutImage forState:UIControlStateNormal];
        [aboutButton setTag:tag];
        [aboutImage release];
        [aboutButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:aboutButton];

        UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(aboutButton.frame.origin.x, CGRectGetMaxY(aboutButton.frame) , aboutButton.frame.size.width, 20)];
        aboutLabel.text = textStr;
        aboutLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        aboutLabel.font = [UIFont systemFontOfSize:12.0f];
        aboutLabel.textAlignment = UITextAlignmentCenter;
        aboutLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:aboutLabel];
        [aboutLabel release];
        
        if (delegates !=nil) {
            self.delegate = delegates;
        }
        
    }
    return self;
}

- (void)click:(UIButton *)btn{
  
    if ([self.delegate respondsToSelector:@selector(clickBtn:)]) {
        [self.delegate performSelector:@selector(clickBtn:)withObject:btn.tag];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
