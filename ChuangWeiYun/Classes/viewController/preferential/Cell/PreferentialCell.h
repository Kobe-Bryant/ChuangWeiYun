//
//  PreferentialCell.h
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import <UIKit/UIKit.h>

@interface PreferentialCell : UITableViewCell
{
    UIView *_bgView;
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    UIImageView *_smallImageView;
    UIImageView *_bigImageView;
}

+ (CGFloat)getCellHeight;

- (void)setBigImageView:(UIImage *)img;

- (void)setCellContentAndFrame:(NSDictionary *)dict;

@end
