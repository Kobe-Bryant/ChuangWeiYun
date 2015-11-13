//
//  CrossLabel.h
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CrossLabel : UILabel
{
    UIColor *textColor;
    UIColor *lineColor;
}

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)atextColor lineColor:(UIColor *)alineColor;

@end
