//
//  WaterListCell.h
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaterCellView;

@interface WaterListBigCell : UITableViewCell
{
    WaterCellView *waterView;
}

+ (CGFloat)getCellHeight;

- (void)setCellViewImage:(UIImage *)image;

- (void)setCellContentAndFrame:(NSArray *)arr delegate:(id)delegate fromCenter:(BOOL)_isHide;

@end
