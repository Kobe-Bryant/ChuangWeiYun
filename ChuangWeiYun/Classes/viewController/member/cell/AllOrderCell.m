//
//  AllOrderCell.m
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import "AllOrderCell.h"
#import "UICustomOrderView.h"
#import "Common.h"
@implementation AllOrderCell
@synthesize shopImage=_shopImage;
@synthesize shopPrice=_shopPrice;
@synthesize shopName=_shopName;
@synthesize cancelBtn=_cancelBtn;
@synthesize orderStatus=_orderStatus;

#define kleftpan 10
#define kabovepan 10

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
 
        _cellView=[[UICustomOrderView alloc]initWithFrame:CGRectMake(kleftpan, kabovepan, 300, 125)];
        _cellView.layer.borderColor=[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.4].CGColor;
        _cellView.layer.borderWidth=1;
        _cellView.layer.cornerRadius=3;
        _cellView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:_cellView];
        
        self.backgroundColor = [UIColor clearColor];
        
        _orderStatus=[[UILabel alloc]initWithFrame:CGRectMake(90, kabovepan, 120, 15)];
        _orderStatus.textAlignment=NSTextAlignmentCenter;
        _orderStatus.font=[UIFont systemFontOfSize:12];
        _orderStatus.layer.cornerRadius=8;
        _orderStatus.backgroundColor=[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1];
        _orderStatus.textColor=[UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
        [_cellView addSubview:_orderStatus];
        
        _cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(260, 5, 35, 30)];
        _cancelBtn.backgroundColor=[UIColor clearColor];
        [_cancelBtn setImage:[UIImage imageCwNamed:@"icon_invalid_member.png"] forState:UIControlStateNormal];
        [_cellView addSubview:_cancelBtn];
        
        _shopImage=[[UIImageView alloc]initWithFrame:CGRectMake(kleftpan, kabovepan+40, 74, 53)];
        _shopImage.backgroundColor=[UIColor clearColor];
        _shopImage.contentMode = UIViewContentModeScaleAspectFit;
        [_cellView addSubview:_shopImage];
        
        
        _shopName=[[UILabel alloc]initWithFrame:CGRectMake(90, kabovepan+35, 200, 40)];
        _shopName.font=[UIFont systemFontOfSize:13];
        _shopName.numberOfLines=0;
        _shopName.lineBreakMode=NSLineBreakByWordWrapping;
        _shopName.backgroundColor=[UIColor clearColor];
        _shopName.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellView addSubview:_shopName];
        
        
        _shopPrice=[[UILabel alloc]initWithFrame:CGRectMake(90, kabovepan+80, 100, 20)];
        _shopPrice.font=[UIFont systemFontOfSize:13];
        _shopPrice.textColor=[UIColor colorWithRed:204/255.0 green:11/255.0 blue:4/255.0 alpha:1];
        [_cellView addSubview:_shopPrice];
        
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_shopName);
    RELEASE_SAFE(_shopPrice);
    RELEASE_SAFE(_shopImage);
    RELEASE_SAFE(_cancelBtn);
    RELEASE_SAFE(_orderStatus);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
