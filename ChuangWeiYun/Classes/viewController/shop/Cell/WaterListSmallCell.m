//
//  WaterListSmallCell.m
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "WaterListSmallCell.h"
#import "WaterCellView.h"

@implementation WaterListSmallCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        waterView1 = [[WaterCellView alloc]initWithFrame:CGRectMake(WLCSpaceLW, WLCSpaceDH/2, WLCSmallImageW, WLCSmallImageH+WLCSpaceDH) isbig:NO];
        [self.contentView addSubview:waterView1];
        
        waterView2 = [[WaterCellView alloc]initWithFrame:CGRectMake(WLCSmallImageW + 2*WLCSpaceLW, WLCSpaceDH/2, WLCSmallImageW, WLCSmallImageH+WLCSpaceDH) isbig:NO];
        [self.contentView addSubview:waterView2];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCellContentAndFrame:(NSArray *)arr delegate:(id)delegate fromCenter:(BOOL)_isHide
{
    waterView1.backgroundColor = [UIColor clearColor];
    waterView1.tag = [[arr objectAtIndex:1] intValue];
    waterView1.delegate = delegate;
    [waterView1 setViewContentAndFrame:[arr objectAtIndex:2] fromCenter:_isHide];

    if (arr.count > 3) {
        waterView2.backgroundColor = [UIColor clearColor];
        waterView2.tag = [[arr objectAtIndex:3] intValue];
        waterView2.delegate = delegate;
        [waterView2 setViewContentAndFrame:[arr objectAtIndex:4] fromCenter:_isHide];
        waterView2.hidden = NO;
    } else {
        waterView2.hidden = YES;
    }
}

- (void)setCellView1Image:(UIImage *)image
{
    [waterView1 setViewImage:image];
}

- (void)setCellView2Image:(UIImage *)image
{
    [waterView2 setViewImage:image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (CGFloat)getCellHeight
{
    CGFloat height = [WaterCellView getViewSmallHeight];
    
    height += 2*WLCSpaceDH;
    
    return height;
}

- (void)dealloc
{
    [waterView1 release], waterView1 = nil;
    [waterView2 release], waterView2 = nil;
    
    [super dealloc];
}

@end
