//
//  ProductPamraCell.h
//  cw
//
//  Created by yunlai on 13-11-12.
//
//

#import <UIKit/UIKit.h>

@interface ProductPamraCell : UITableViewCell
{
    UIView *_bgView;
    UILabel *_contentLabel;
}

- (void)setCellContentAndFrame:(NSString *)str;

+ (CGFloat)getCellHeight:(NSString *)str;

@end
