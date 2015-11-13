//
//  OrderDetailCell.h
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import <UIKit/UIKit.h>
#import "UICutLineView.h"

@interface OrderDetailCell : UITableViewCell
{
    UIView      *_cellBgView;
    UIImageView *_shopIcon;
    UILabel     *_shopName;
    UILabel     *_orderStatus;
    UILabel     *_statusLabel;
    UIButton    *_statusBtn;
    UILabel     *_shopInfo;
    UIImageView *_shopImageView;
    UILabel     *_shopTypeLabel;
    UILabel     *_shopAboutLabel;
    UILabel     *_shopPriceLabel;
    UILabel     *_orderNumber;
    UILabel     *_orderNumLabel;
    UILabel     *_orderTime;
    UILabel     *_orderTimeLabel;
    UILabel     *_deliveryTime;
    UILabel     *_deliveryTimeLabel;
    UILabel     *_invoice;
    UILabel     *_invoiceLabel;
    UILabel     *_pay;
    UILabel     *_payLabel;
    UILabel     *_distribution;
    UILabel     *_distriLabel;
    UILabel     *_coupon;
    UILabel     *_couponLabel;
    UILabel     *_receiviAddress;
    UILabel     *_receiviAddLabel;
    UILabel     *_remark;
    UILabel     *_remarkLabel;
    UILabel     *_amount;
    UILabel     *_amountLabel;
    UIButton    *_bgClick;
    UICutLineView *_lineView;
    UICutLineView *_lineView2;
}
@property(nonatomic ,retain) UILabel        *shopName;
@property(nonatomic ,retain) UIImageView    *shopImageView;
@property(nonatomic ,retain) UIButton       *statusBtn;
@property(nonatomic ,retain) UILabel        *shopTypeLabel;
@property(nonatomic ,retain) UILabel        *shopAboutLabel;
@property(nonatomic ,retain) UILabel        *shopPriceLabel;
@property(nonatomic ,retain) UILabel        *orderNumLabel;
@property(nonatomic ,retain) UILabel        *orderTimeLabel;
@property(nonatomic ,retain) UILabel        *deliveryTimeLabel;
@property(nonatomic ,retain) UILabel        *invoiceLabel;
@property(nonatomic ,retain) UILabel        *payLabel;
@property(nonatomic ,retain) UILabel        *distriLabel;
@property(nonatomic ,retain) UILabel        *couponLabel;
@property(nonatomic ,retain) UILabel        *amountLabel;
@property(nonatomic ,retain) UILabel        *coupon;
@property(nonatomic ,retain) UILabel        *receiviAddress;
@property(nonatomic ,retain) UILabel        *remark;
@property(nonatomic ,retain) UILabel        *receiviAddLabel;
@property(nonatomic ,retain) UILabel        *statusLabel;
@property(nonatomic ,retain) UILabel        *remarkLabel;
@property(nonatomic ,retain) UIButton       *bgClick;
@property(nonatomic ,retain) UIView         *cellBgView;
@property(nonatomic ,retain) UICutLineView  *lineView;
@property(nonatomic ,retain) UICutLineView  *lineView2;
@end
