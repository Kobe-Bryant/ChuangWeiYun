//
//  CancelOrderCell.m
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import "CancelOrderCell.h"

@implementation CancelOrderCell

@synthesize shopImage=_shopImage;
@synthesize shopName=_shopName;
@synthesize shopPrice=_shopPrice;

#define kleftpan 10
#define kabovepan 10

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _cellView=[[UIView alloc]initWithFrame:CGRectMake(kleftpan, kabovepan, 300, 90)];
        _cellView.layer.borderColor=[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.4].CGColor;
        _cellView.layer.borderWidth=1;
        _cellView.layer.cornerRadius=3;
        _cellView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:_cellView];
        
        self.backgroundColor = [UIColor clearColor];
    
        _shopImage=[[UIImageView alloc]initWithFrame:CGRectMake(kleftpan+10, kabovepan+20, 70, 50)];
        _shopImage.backgroundColor=[UIColor clearColor];
        _shopImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_shopImage];
        
        
        _shopName=[[UILabel alloc]initWithFrame:CGRectMake(100, kabovepan+15, 200, 40)];
        _shopName.font=[UIFont systemFontOfSize:13];
        _shopName.numberOfLines=0;
        _shopName.lineBreakMode=NSLineBreakByWordWrapping;
        _shopName.backgroundColor=[UIColor clearColor];
        _shopName.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.contentView addSubview:_shopName];
        
        
        _shopPrice=[[UILabel alloc]initWithFrame:CGRectMake(100, kabovepan+55, 100, 20)];
        _shopPrice.font=[UIFont systemFontOfSize:13];
        _shopPrice.textColor=[UIColor colorWithRed:204/255.0 green:11/255.0 blue:4/255.0 alpha:1];
        [self.contentView addSubview:_shopPrice];
        
        
        
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_shopImage);
    RELEASE_SAFE(_shopName);
    RELEASE_SAFE(_shopPrice);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
