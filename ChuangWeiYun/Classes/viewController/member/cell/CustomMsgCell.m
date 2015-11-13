//
//  CustomMsgCell.m
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import "CustomMsgCell.h"

@implementation CustomMsgCell
@synthesize shopName=_shopName;
@synthesize shopAbout=_shopAbout;
@synthesize shopImage=_shopImage;
@synthesize likeBtn=_likeBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView *mainView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, KUIScreenWidth, 90.0)];
        mainView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:mainView];
        
        self.backgroundColor = [UIColor clearColor];
        
        
        UILabel *headLine=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 1)];
        headLine.backgroundColor=KCWViewBgColor;
        [mainView addSubview:headLine];
        RELEASE_SAFE(headLine);
        
        _shopImage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 20, 74, 53)];
        _shopImage.contentMode = UIViewContentModeScaleAspectFit;
        [mainView addSubview:_shopImage];
        
        _shopName=[[UILabel alloc]initWithFrame:CGRectMake(90, 20, 200, 20)];
        _shopName.font=[UIFont boldSystemFontOfSize:15];
        _shopName.backgroundColor=[UIColor clearColor];
        
        [mainView addSubview:_shopName];
        
        _shopAbout=[[UILabel alloc]initWithFrame:CGRectMake(90,40, 200, 40)];
        _shopAbout.font=[UIFont systemFontOfSize:12];
        _shopAbout.numberOfLines=0;
        _shopAbout.backgroundColor=[UIColor clearColor];
        _shopAbout.lineBreakMode=NSLineBreakByTruncatingTail;
        [mainView addSubview:_shopAbout];
        
        _likeBtn=[[UIButton alloc]initWithFrame:CGRectMake(270, 30, 40, 40)];
        [mainView addSubview:_likeBtn];
        
        RELEASE_SAFE(mainView);
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_shopImage);
    RELEASE_SAFE(_shopName);
    RELEASE_SAFE(_shopAbout);
    RELEASE_SAFE(_likeBtn);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
