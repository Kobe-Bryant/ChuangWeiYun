//
//  WaterListCell.m
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "WaterListBigCell.h"
#import "WaterCellView.h"

@implementation WaterListBigCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        waterView = [[WaterCellView alloc]initWithFrame:CGRectMake(WLCSpaceLW, WLCSpaceDH/2, WLCBigImageW, WLCBigImageH + WLCSpaceDH) isbig:YES];
        waterView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:waterView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCellContentAndFrame:(NSArray *)arr delegate:(id)delegate fromCenter:(BOOL)_isHide
{    
    waterView.tag = [[arr objectAtIndex:1] intValue];
    waterView.delegate = delegate;
    [waterView setViewContentAndFrame:[arr objectAtIndex:2] fromCenter:_isHide];
}

- (void)setCellViewImage:(UIImage *)image
{
    [waterView setViewImage:image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (CGFloat)getCellHeight
{
    CGFloat height = [WaterCellView getViewBigHeight];
    
    height += 2*WLCSpaceDH;
    
    return height;
}

- (void)dealloc
{
    [waterView release], waterView = nil;
    
    [super dealloc];
}
@end
