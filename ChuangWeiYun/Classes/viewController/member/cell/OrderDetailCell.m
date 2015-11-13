//
//  OrderDetailCell.m
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import "OrderDetailCell.h"
#import "UIOrderDetailView.h"
#import "Common.h"

@implementation OrderDetailCell

@synthesize shopName        = _shopName;
@synthesize shopImageView   = _shopImageView;
@synthesize shopTypeLabel   = _shopTypeLabel;
@synthesize shopAboutLabel  = _shopAboutLabel;
@synthesize shopPriceLabel  = _shopPriceLabel;
@synthesize orderNumLabel   = _orderNumLabel;
@synthesize orderTimeLabel  = _orderTimeLabel;
@synthesize deliveryTimeLabel= _deliveryTimeLabel;
@synthesize invoiceLabel    = _invoiceLabel;
@synthesize payLabel        = _payLabel;
@synthesize distriLabel     = _distriLabel;
@synthesize couponLabel     = _couponLabel;
@synthesize receiviAddLabel = _receiviAddLabel;
@synthesize statusLabel     = _statusLabel;
@synthesize statusBtn       = _statusBtn;
@synthesize bgClick         = _bgClick;
@synthesize remarkLabel     = _remarkLabel;
@synthesize amountLabel     = _amountLabel;
@synthesize coupon          = _coupon;
@synthesize remark          = _remark;
@synthesize receiviAddress  = _receiviAddress;
@synthesize cellBgView      = _cellBgView;
@synthesize lineView        = _lineView;
@synthesize lineView2       = _lineView2;
#define kleftpan 15
#define kabovepan 10
#define krowspan 50


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _cellBgView=[[UIOrderDetailView alloc]initWithFrame:CGRectMake(kleftpan-5, kabovepan, 300, 620)];
        _cellBgView.layer.borderColor=[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.3].CGColor;
        _cellBgView.layer.borderWidth=1;
        _cellBgView.layer.cornerRadius=3;
        _cellBgView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:_cellBgView];
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *aboveView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 45)];
        aboveView.backgroundColor=[UIColor colorWithRed:248/255.0 green:251/255.0 blue:250/255.0 alpha:1];
        [_cellBgView addSubview:aboveView];
        RELEASE_SAFE(aboveView);
        
        _shopIcon=[[UIImageView alloc]initWithFrame:CGRectMake(kleftpan, kabovepan, 30, 30)];
        [_shopIcon setImage:[UIImage imageCwNamed:@"icon_branch_member.png"]];
        _shopIcon.backgroundColor=[UIColor clearColor];
        [_cellBgView addSubview:_shopIcon];
        
        _shopName=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+40, kabovepan, 200, 30)];
        _shopName.backgroundColor=[UIColor clearColor];
        _shopName.font=[UIFont systemFontOfSize:15];
        _shopName.backgroundColor=[UIColor clearColor];
        _shopName.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_shopName];
        
        
        _orderStatus=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, kabovepan+krowspan, 80, 20)];
        _orderStatus.backgroundColor=[UIColor clearColor];
        _orderStatus.text=@"预订状态";
        _orderStatus.font=[UIFont systemFontOfSize:15];
        _orderStatus.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_orderStatus];
        
        _statusLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, kabovepan+krowspan, 150, 20)];
        _statusLabel.backgroundColor=[UIColor clearColor];
        _statusLabel.font=[UIFont systemFontOfSize:15];
        _statusLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_statusLabel];
        
        
        _statusBtn=[[UIButton alloc]initWithFrame:CGRectMake(kleftpan+250, kabovepan+krowspan-5, 20, 20)];
        _statusBtn.backgroundColor=[UIColor clearColor];
        [_statusBtn setImage:[UIImage imageCwNamed:@"icon_invalid_member.png"] forState:UIControlStateNormal];
        _statusBtn.hidden=YES;
        [_cellBgView addSubview:_statusBtn];
        
        _bgClick=[[UIButton alloc]initWithFrame:CGRectMake(0, krowspan*2-10, KUIScreenWidth-20, 95)];
        _bgClick.backgroundColor=[UIColor clearColor];
        [_cellBgView addSubview:_bgClick];
        
        _shopInfo=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*2-5, 80, 20)];
        _shopInfo.backgroundColor=[UIColor clearColor];
        _shopInfo.text=@"商品信息";
        _shopInfo.font=[UIFont systemFontOfSize:15];
        _shopInfo.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_shopInfo];
        
        _shopImageView=[[UIImageView alloc]initWithFrame:CGRectMake(kleftpan, 25+krowspan*2, 70, 50)];
        _shopImageView.backgroundColor=[UIColor clearColor];
        _shopImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_cellBgView addSubview:_shopImageView];
        
        
        _shopTypeLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+90, 15+krowspan*2, 180, 40)];
        _shopTypeLabel.numberOfLines=0;
        _shopTypeLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        _shopTypeLabel.backgroundColor=[UIColor clearColor];
        _shopTypeLabel.font=[UIFont systemFontOfSize:13];
        [_cellBgView addSubview:_shopTypeLabel];
        
        _shopPriceLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+90, krowspan*2+55, 180, 20)];
        _shopPriceLabel.backgroundColor=[UIColor clearColor];
        _shopPriceLabel.font=[UIFont systemFontOfSize:13];
        _shopPriceLabel.textColor=[UIColor colorWithRed:204/255.0 green:11/255.0 blue:4/255.0 alpha:1];
        [_cellBgView addSubview:_shopPriceLabel];
        
        _orderNumber=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*4+10, 80, 20)];
        _orderNumber.backgroundColor=[UIColor clearColor];
        _orderNumber.text=@"订  单 号";
        _orderNumber.font=[UIFont systemFontOfSize:15];
        _orderNumber.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_orderNumber];
        
        _orderNumLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*4+10, 180, 20)];
        _orderNumLabel.backgroundColor=[UIColor clearColor];
        _orderNumLabel.font=[UIFont systemFontOfSize:15];
        _orderNumLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_orderNumLabel];
        
        _amount=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*5, 80, 20)];
        _amount.backgroundColor=[UIColor clearColor];
        _amount.text=@"预订数量";
        _amount.font=[UIFont systemFontOfSize:15];
        _amount.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_amount];
        
        _amountLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*5, 180, 20)];
        _amountLabel.backgroundColor=[UIColor clearColor];
        _amountLabel.font=[UIFont systemFontOfSize:15];
        _amountLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_amountLabel];
        
        
        _orderTime=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*6-10, 80, 20)];
        _orderTime.backgroundColor=[UIColor clearColor];
        _orderTime.text=@"预订时间";
        _orderTime.font=[UIFont systemFontOfSize:15];
        _orderTime.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_orderTime];
        
        _orderTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*6-10, 180, 20)];
        _orderTimeLabel.backgroundColor=[UIColor clearColor];
        _orderTimeLabel.font=[UIFont systemFontOfSize:15];
        _orderTimeLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_orderTimeLabel];
        
        _deliveryTime=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*7-20, 80, 20)];
        _deliveryTime.backgroundColor=[UIColor clearColor];
        _deliveryTime.text=@"送货时间";
        _deliveryTime.font=[UIFont systemFontOfSize:15];
        _deliveryTime.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_deliveryTime];
        
        _deliveryTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*7-20, 180, 20)];
        _deliveryTimeLabel.backgroundColor=[UIColor clearColor];
        _deliveryTimeLabel.font=[UIFont systemFontOfSize:15];
        _deliveryTimeLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_deliveryTimeLabel];
        
        _invoice=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*8-30, 80, 20)];
        _invoice.backgroundColor=[UIColor clearColor];
        _invoice.text=@"发      票";
        _invoice.font=[UIFont systemFontOfSize:15];
        _invoice.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_invoice];
        
        _invoiceLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*8-30, 180, 20)];
        _invoiceLabel.backgroundColor=[UIColor clearColor];
        _invoiceLabel.font=[UIFont systemFontOfSize:15];
        _invoiceLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_invoiceLabel];
        
        _pay=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*8+10, 80, 20)];
        _pay.backgroundColor=[UIColor clearColor];
        _pay.text=@"支      付";
        _pay.font=[UIFont systemFontOfSize:15];
        _pay.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_pay];
        
        _payLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*8+10, 180, 20)];
        _payLabel.backgroundColor=[UIColor clearColor];
        _payLabel.font=[UIFont systemFontOfSize:15];
        _payLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_payLabel];
        
        _distribution=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*9, 80, 20)];
        _distribution.backgroundColor=[UIColor clearColor];
        _distribution.text=@"配      送";
        _distribution.font=[UIFont systemFontOfSize:15];
        _distribution.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_distribution];
        
        _distriLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*9, 180, 20)];
        _distriLabel.backgroundColor=[UIColor clearColor];
        _distriLabel.font=[UIFont systemFontOfSize:15];
        _distriLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_distriLabel];
        
        _coupon=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*10-10, 80, 20)];
        _coupon.backgroundColor=[UIColor clearColor];
        _coupon.text=@"优  惠 券";
        _coupon.font=[UIFont systemFontOfSize:15];
        _coupon.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_coupon];
        
        _couponLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*10-10, 180, 20)];
        _couponLabel.backgroundColor=[UIColor clearColor];
        _couponLabel.font=[UIFont systemFontOfSize:15];
        _couponLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_couponLabel];
        
        _lineView2 = [[UICutLineView alloc]initWithFrame:CGRectMake(0, krowspan*10+2, 300, 2)];
        _lineView2.backgroundColor = [UIColor clearColor];
        [_cellBgView addSubview:_lineView2];
        
        CGFloat kheightc = _coupon.frame.size.height+10;
        
        _receiviAddress=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*10+kheightc, 80, 20)];
        _receiviAddress.backgroundColor=[UIColor clearColor];
        _receiviAddress.text=@"收货地址";
        _receiviAddress.font=[UIFont systemFontOfSize:15];
        _receiviAddress.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_receiviAddress];
        
        _receiviAddLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*10+kheightc, 200, 260)];
        _receiviAddLabel.backgroundColor=[UIColor clearColor];
        _receiviAddLabel.font=[UIFont systemFontOfSize:15];
        _receiviAddLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _receiviAddLabel.numberOfLines=0;
        [_cellBgView addSubview:_receiviAddLabel];
        
        _lineView = [[UICutLineView alloc]initWithFrame:CGRectMake(0, krowspan*10+kheightc+2, 300, 2)];
        _lineView.backgroundColor = [UIColor clearColor];
        [_cellBgView addSubview:_lineView];
        
        _remark=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, krowspan*11+20+kheightc, 80, 20)];
        _remark.backgroundColor=[UIColor clearColor];
        _remark.text=@"备      注";
        _remark.font=[UIFont systemFontOfSize:15];
        _remark.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellBgView addSubview:_remark];
        
        _remarkLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+80, krowspan*11+20+kheightc, 200, 140)];
        _remarkLabel.backgroundColor=[UIColor clearColor];
        _remarkLabel.font=[UIFont systemFontOfSize:15];
        _remarkLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _remarkLabel.numberOfLines=0;
        _remarkLabel.lineBreakMode=NSLineBreakByCharWrapping;
        [_cellBgView addSubview:_remarkLabel];
        
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_cellBgView);
    RELEASE_SAFE(_shopIcon);
    RELEASE_SAFE(_shopName);
    RELEASE_SAFE(_orderStatus);
    RELEASE_SAFE(_statusLabel);
    RELEASE_SAFE(_statusBtn);
    RELEASE_SAFE(_shopInfo);
    RELEASE_SAFE(_shopImageView);
    RELEASE_SAFE(_shopTypeLabel);
    RELEASE_SAFE(_shopPriceLabel);
    RELEASE_SAFE(_orderNumber);
    RELEASE_SAFE(_orderNumLabel);
    RELEASE_SAFE(_orderTime);
    RELEASE_SAFE(_orderTimeLabel);
    RELEASE_SAFE(_deliveryTime);
    RELEASE_SAFE(_deliveryTimeLabel);
    RELEASE_SAFE(_invoice);
    RELEASE_SAFE(_invoiceLabel);
    RELEASE_SAFE(_pay);
    RELEASE_SAFE(_payLabel);
    RELEASE_SAFE(_distribution);
    RELEASE_SAFE(_distriLabel);
    RELEASE_SAFE(_coupon);
    RELEASE_SAFE(_couponLabel);
    RELEASE_SAFE(_receiviAddress);
    RELEASE_SAFE(_receiviAddLabel);

    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
