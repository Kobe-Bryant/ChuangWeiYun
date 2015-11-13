//
//  PfContentCell.h
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import <UIKit/UIKit.h>

@interface PfContentCell : UITableViewCell
{
    UIView *_bgView;
    UILabel *_bgLabel;
    UIImageView *_titleImageView;
    UILabel *_titlelabel;
    UILabel *_contentLabel;
}

+ (CGFloat)getCellHeight:(NSString *)content;

- (void)setCellContentAndFrame:(UIImage *)titleImage title:(NSString *)title content:(NSString *)content;

@end
