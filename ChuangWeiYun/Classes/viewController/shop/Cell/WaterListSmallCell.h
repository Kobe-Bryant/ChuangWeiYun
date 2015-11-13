//
//  WaterListSmallCell.h
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaterCellView;

@interface WaterListSmallCell : UITableViewCell
{
    WaterCellView *waterView1;
    WaterCellView *waterView2;
}

+ (CGFloat)getCellHeight;

- (void)setCellView1Image:(UIImage *)image;
- (void)setCellView2Image:(UIImage *)image;

- (void)setCellContentAndFrame:(NSArray *)arr delegate:(id)delegate fromCenter:(BOOL)_isHide;

@end
