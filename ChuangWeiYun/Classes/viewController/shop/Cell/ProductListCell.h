//
//  ProductListCell.h
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@class CrossLabel;

@interface ProductListCell : UITableViewCell
{
    UIImageView *pImageView;
    UILabel *pTitleLabel;
    UILabel *pMoneyLabel;
    CrossLabel *pLoseMoneyLabel;
    UIImageView *pLoveImage;
    UILabel *pLoveLabel;
    UILabel *pContentLabel;
    UILabel *line;
}

@property (assign, nonatomic) CwStatusType statusType;

- (void)setCellContentAndFrame:(NSDictionary *)dict;

- (void)setCellViewImage:(UIImage *)image;

+ (CGFloat)getCellHeight;

@end
