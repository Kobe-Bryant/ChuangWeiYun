//
//  CrossLabel.m
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "CrossLabel.h"

@implementation CrossLabel

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)atextColor lineColor:(UIColor *)alineColor
{
    self = [super initWithFrame:frame];
    if (self) {
        textColor = [atextColor retain];
        lineColor = [alineColor retain];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetFillColorWithColor(ctx, textColor.CGColor);
    CGSize size = [self.text sizeWithFont:self.font];
    CGRect srect = rect;
    srect.origin.y = srect.size.height/2 - size.height/2;
    [self.text drawInRect:srect withFont:self.font];

    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextSetLineWidth(ctx, 1.f);
    CGContextMoveToPoint(ctx, 1.f, rect.size.height/2);
    CGContextAddLineToPoint(ctx, rect.size.width,rect.size.height/2);
    CGContextStrokePath(ctx);
}

- (void)dealloc
{
    [textColor release], textColor = nil;
    [lineColor release], lineColor = nil;
    
    [super dealloc];
}
@end
