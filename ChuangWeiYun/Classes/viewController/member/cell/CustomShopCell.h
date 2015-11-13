//
//  CustomShopCell.h
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import <UIKit/UIKit.h>

@interface CustomShopCell : UITableViewCell
{
    UILabel     *_typeNum;
    UIImageView *_shopImages;
    UILabel     *_shopName;
    UIButton    *_likeBtn;
}
@property(nonatomic ,retain) UILabel        *typeNum;
@property(nonatomic ,retain) UIImageView    *shopImages;
@property(nonatomic ,retain) UILabel        *shopName;
@property(nonatomic ,retain) UIButton       *likeBtn;

@end
