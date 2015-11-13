//
//  UICustomOrderView.m
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import "UICustomOrderView.h"

@implementation UICustomOrderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//绘制虚线
-(void)drawRect:(CGRect)rect{
    CGContextRef context =UIGraphicsGetCurrentContext();  //获取绘图上下文----画板
    CGContextBeginPath(context);  //创建一条路径
    CGContextSetLineWidth(context, 0.5);  //设置线宽
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor);  //设置线的颜色
    float lengths[] = {4,4};
    CGContextSetLineDash(context, 0, lengths,1);  //设置虚线的样式
    CGContextMoveToPoint(context, 0.0, 35.0);  //将路径绘制的起点移动到一个位置，即设置线条的起点
    CGContextAddLineToPoint(context, 320.0,35.0);  //在图形上下文移动你的笔画来指定线条的重点
    CGContextStrokePath(context);  //创建你已经设定好的路径。此过程将使用图形上下文已经设置好的颜色来绘制路径。
    CGContextClosePath(context);
}

@end
