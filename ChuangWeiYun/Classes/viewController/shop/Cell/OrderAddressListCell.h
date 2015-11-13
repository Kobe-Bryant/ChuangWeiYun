//
//  OrderAddressListCell.h
//  cw
//
//  Created by yunlai on 13-8-24.
//
//

#import <UIKit/UIKit.h>

@protocol OrderAddressCellDelegate;

@interface OrderAddressListCell : UITableViewCell
{
    UIView *_bgView;
    UILabel *_nameLabel;
    UILabel *_phoneLabel;
    UILabel *_addresslabel;
    UIButton *_modBtn;
    
    id <OrderAddressCellDelegate> delegate;
}

@property (assign, nonatomic) id <OrderAddressCellDelegate> delegate;
@property (retain, nonatomic) NSString *area;

+ (CGFloat)getCellHeight:(NSDictionary *)dict;

- (void)setCellContentAndFrame:(NSDictionary *)dict;

- (void)set_bgViewborderColorState:(BOOL)_bool;

@end

@protocol OrderAddressCellDelegate <NSObject>

@optional
- (void)modOrderAddressListCellBtn:(OrderAddressListCell *)acell;

@end