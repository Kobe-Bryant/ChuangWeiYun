//
//  SubbranchCell.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "SubbranchCell.h"
#import "Common.h"
#import "Global.h"

#define SubbranchLeftW      10.f
#define SubbranchUpH        10.f
#define SubbranchImageWH    60.f
#define SubbranchSmallWH    25.f
#define SubbranchLabelW     200.f
#define SubbranchH          85.f

#define SubbranchFontSize15 15.f
#define SubbranchFontSize12 12.f

@implementation SubbranchCell

@synthesize deleagte;
@synthesize enterShopBtn=_enterShopBtn;
@synthesize statusType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _timageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _timageView.layer.cornerRadius = 3.f;
        _timageView.layer.masksToBounds = YES;
        _timageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_timageView];

        _titelLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titelLabel.backgroundColor = [UIColor clearColor];
        _titelLabel.textColor = [UIColor blackColor];
        _titelLabel.numberOfLines = 0;
        _titelLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titelLabel.font = KCWSystemFont(SubbranchFontSize15);
        [self.contentView addSubview:_titelLabel];

        _addressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _addressLabel.backgroundColor = [UIColor clearColor];
        _addressLabel.textColor = [UIColor blackColor];
        _addressLabel.numberOfLines = 0;
        _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _addressLabel.font = KCWSystemFont(SubbranchFontSize12);
        [self.contentView addSubview:_addressLabel];

        _spaceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _spaceLabel.backgroundColor = [UIColor clearColor];
        _spaceLabel.textColor = [UIColor blackColor];
        _spaceLabel.font = KCWSystemFont(SubbranchFontSize12);
        [self.contentView addSubview:_spaceLabel];

        _phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _phoneBtn.tag = 1;
        [_phoneBtn setImage:[UIImage imageCwNamed:@"icon_call32.png"] forState:UIControlStateNormal];
        [_phoneBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_phoneBtn];

        _mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _mapBtn.tag = 2;
        [_mapBtn setImage:[UIImage imageCwNamed:@"icon_map32.png"] forState:UIControlStateNormal];
        [_mapBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_mapBtn];
    }
    return self;
}

- (void)dealloc
{
    [_timageView release], _timageView = nil;
    [_titelLabel release], _titelLabel = nil;
    [_addressLabel release], _addressLabel = nil;
    [_spaceLabel release], _spaceLabel = nil;
    RELEASE_SAFE(_enterShopBtn);
    [super dealloc];
}

- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    if ([deleagte respondsToSelector:@selector(subbranchCellClickHeadImg:)]) {
        [deleagte subbranchCellClickHeadImg:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
//11.11 chenfeng
- (void)resetView:(CwStatusType)status{
    if (status == StatusTypeNearShop) {
        _timageView.layer.cornerRadius = 29.0f;
        _timageView.layer.masksToBounds = YES;
        
        // dufu add 2013.12.19 点击头像进店铺详情，加多一个单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [_timageView addGestureRecognizer:tap];
        [tap release], tap = nil;
        
        _enterShopBtn = [[UIButton alloc]initWithFrame:CGRectZero];//CGRectMake(145, 58, 60, 20.f)
        _enterShopBtn.layer.cornerRadius = 3;
        _enterShopBtn.titleLabel.font = KCWSystemFont(SubbranchFontSize12);
        _enterShopBtn.backgroundColor = [UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1];
        [_enterShopBtn setTitle:@"进店看看" forState:UIControlStateNormal];
        [_enterShopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_enterShopBtn];
        
    }else{
        _timageView.layer.cornerRadius = 3.f;
    }
}

- (void)btnClick:(UIButton *)btn
{
    if (btn.tag == 1) {
        if ([deleagte respondsToSelector:@selector(subbranchCellClickBtnPhone:)]) {
            [deleagte subbranchCellClickBtnPhone:self];
        }
    } else {
        if ([deleagte respondsToSelector:@selector(subbranchCellClickBtnMap:)]) {
            [deleagte subbranchCellClickBtnMap:self];
        }
    }
}

//动态获取内容的宽度 11.24 chenfeng
- (CGFloat)getTheWidth:(NSString *)contentStr
{
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize size = CGSizeMake(150,15);
    CGSize labelsize = [contentStr sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    
    return labelsize.width;
}

- (void)setCellContentAndFrame:(NSDictionary *)dict
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    CGFloat height = SubbranchUpH;
    CGFloat frontW = SubbranchLeftW;

    _timageView.frame = CGRectMake(frontW, height, SubbranchImageWH, SubbranchImageWH);

    frontW += SubbranchImageWH + SubbranchLeftW;
    
    CGSize conSize = CGSizeMake(SubbranchLabelW, 1000.f);
    
    NSString *labelstr = [dict objectForKey:@"name"];
    _titelLabel.text = labelstr;
    CGSize size = [labelstr sizeWithFont:KCWSystemFont(SubbranchFontSize15)
                  constrainedToSize:conSize
                      lineBreakMode:NSLineBreakByWordWrapping];
    _titelLabel.frame = CGRectMake(frontW, height, SubbranchLabelW, size.height);
    
    height += size.height + 10.f;
    
    labelstr = [dict objectForKey:@"address"];
    size = [labelstr sizeWithFont:KCWSystemFont(SubbranchFontSize12)
                  constrainedToSize:conSize
                      lineBreakMode:NSLineBreakByWordWrapping];
    _addressLabel.text = labelstr;
    _addressLabel.frame = CGRectMake(frontW, height, SubbranchLabelW, size.height);
    
    height += size.height + 5.f;

    double longitude = [[dict objectForKey:@"longitude"] doubleValue];
    double latitude = [[dict objectForKey:@"latitude"] doubleValue];
    
    if (longitude == 0.000000 && latitude == 0.000000) {
        _spaceLabel.text = @"未知";
    } else {
        double space = [Common lantitudeLongitudeToDist:[Global sharedGlobal].myLocation.longitude
                                              Latitude1:[Global sharedGlobal].myLocation.latitude
                                                  long2:longitude
                                              Latitude2:latitude];
        NSString *str = [NSString stringWithFormat:@"%d",(int)space];
        
        if (str.length > 3) {
            _spaceLabel.text = [NSString stringWithFormat:@"%0.1f km",space/1000];
        } else {
            _spaceLabel.text = [NSString stringWithFormat:@"%d m",(int)space];
        }
    }

    //chenfeng 11.24
    float spaceFloat = [self getTheWidth:_spaceLabel.text];
    _spaceLabel.frame = CGRectMake(frontW, height, spaceFloat, 15.f);
    
    if (_enterShopBtn.superview) {
        _enterShopBtn.frame = CGRectMake(_spaceLabel.frame.origin.x+spaceFloat+5, height-2, 60, 20.f);
    }
    
    height += 25.f;
    frontW += SubbranchLabelW;
    
    _phoneBtn.frame = CGRectMake(frontW, SubbranchUpH, SubbranchSmallWH, SubbranchSmallWH);
    
    _mapBtn.frame = CGRectMake(frontW, height - SubbranchUpH - SubbranchSmallWH, SubbranchSmallWH, SubbranchSmallWH);
    
    [pool release];
}

+ (CGFloat)getCellHeight:(NSDictionary *)dict
{
    CGFloat height = SubbranchUpH;
    
    CGSize conSize = CGSizeMake(SubbranchLabelW, 1000.f);
    
    NSString *labelstr = [dict objectForKey:@"name"];

    CGSize size = [labelstr sizeWithFont:KCWSystemFont(SubbranchFontSize15)
                       constrainedToSize:conSize
                           lineBreakMode:NSLineBreakByWordWrapping];
    
    height += size.height + 10.f;
    
    labelstr = [dict objectForKey:@"address"];
    size = [labelstr sizeWithFont:KCWSystemFont(SubbranchFontSize12)
                constrainedToSize:conSize
                    lineBreakMode:NSLineBreakByWordWrapping];

    height += size.height + 5.f;
    
    height += 15.f;
    
    height += 10.f;
    
    return height;
}

- (void)setTimageView:(UIImage *)img // 
{
    _timageView.image = img;
}
@end
