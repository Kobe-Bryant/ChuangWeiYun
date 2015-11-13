//
//  CancelOrderCell.h
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import <UIKit/UIKit.h>

@interface CancelOrderCell : UITableViewCell
{
    UIImageView *_shopImage;
    UILabel     *_shopName;
    UILabel     *_shopPrice;
    UIView      *_cellView;
}
@property(nonatomic, retain) UIImageView *shopImage;
@property(nonatomic, retain) UILabel     *shopName;
@property(nonatomic, retain) UILabel     *shopPrice;
@end
