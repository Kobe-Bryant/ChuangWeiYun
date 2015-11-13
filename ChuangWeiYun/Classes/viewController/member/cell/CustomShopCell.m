//
//  CustomShopCell.m
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import "CustomShopCell.h"

@implementation CustomShopCell
@synthesize typeNum=_typeNum;
@synthesize shopImages=_shopImages;
@synthesize shopName=_shopName;
@synthesize likeBtn=_likeBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        UIView *mainView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, KUIScreenWidth, 90.0)];
        mainView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:mainView];
        
        UILabel *headLine=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 1)];
        headLine.backgroundColor=KCWViewBgColor;
        [mainView addSubview:headLine];
        RELEASE_SAFE(headLine);
        
        self.backgroundColor = [UIColor clearColor];
        
        _typeNum=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 63, 16)];
        _typeNum.backgroundColor=[UIColor colorWithRed:130/255.0 green:130/255.0 blue:131/255.0 alpha:1];
        _typeNum.textColor=[UIColor whiteColor];
        _typeNum.textAlignment=NSTextAlignmentCenter;
        _typeNum.font=[UIFont systemFontOfSize:10];
        [mainView addSubview:_typeNum];
        
        _shopImages=[[UIImageView alloc]initWithFrame:CGRectMake(10, 33, 74, 53)];
        _shopImages.backgroundColor=[UIColor clearColor];
        _shopImages.contentMode = UIViewContentModeScaleAspectFit;
        [mainView addSubview:_shopImages];
        
        _shopName=[[UILabel alloc]initWithFrame:CGRectMake(95, 35, 200, 40)];
        _shopName.font=[UIFont systemFontOfSize:12];
        _shopName.numberOfLines=0;
        _shopName.lineBreakMode=NSLineBreakByTruncatingTail;
        _shopName.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
         [mainView addSubview:_shopName];
        
        _likeBtn=[[UIButton alloc]initWithFrame:CGRectMake(270, 30, 40, 40)];
        [mainView addSubview:_likeBtn];
        
        RELEASE_SAFE(mainView);
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_typeNum);
    RELEASE_SAFE(_shopImages);
    RELEASE_SAFE(_shopName);
    RELEASE_SAFE(_likeBtn);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
