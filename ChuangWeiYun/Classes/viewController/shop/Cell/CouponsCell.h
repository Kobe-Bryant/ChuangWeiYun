//
//  CouponsCell.h
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import <UIKit/UIKit.h>

@interface CouponsCell : UITableViewCell
{
    UIImageView *_bgImageView;
    UILabel *_titleLabel;
    UILabel *_moneyLabel;
    UILabel *_startTimeLabel;
    UILabel *_endTimeLabel;
}

+ (CGFloat)getCellHeight;

- (void)setCellContentAndFrame:(NSDictionary *)dict;

@end
