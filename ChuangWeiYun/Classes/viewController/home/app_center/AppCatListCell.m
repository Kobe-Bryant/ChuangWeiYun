//
//  AppCatListCell.m
//  cw
//
//  Created by LuoHui on 13-9-5.
//
//

#import "AppCatListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageScale.h"

#define kXSpace 10
#define kYSpace 5

@implementation AppCatListCell
@synthesize cImageView = _cImageView;
@synthesize cTitleLabel = _cTitleLabel;
@synthesize cNameLabel = _cNameLabel;
@synthesize cAddressLabel = _cAddressLabel;
@synthesize detailButton;
@synthesize addrButton;
@synthesize cellDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kXSpace, kYSpace, 300, 150)];
        bgView.layer.cornerRadius = 3;
        bgView.layer.masksToBounds = YES;
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0].CGColor;
        bgView.layer.borderWidth = 1;
        [self.contentView addSubview:bgView];
        
        _cImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kXSpace + 5, kXSpace + 5, 60, 60)];
        _cImageView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:_cImageView];
        
        _cTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, _cImageView.frame.origin.y + 5, 140, 30)];
        _cTitleLabel.backgroundColor = [UIColor clearColor];
        _cTitleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _cTitleLabel.text = @"";
        _cTitleLabel.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:_cTitleLabel];
        
        _cNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cImageView.frame) + 10, CGRectGetMaxY(_cTitleLabel.frame), 140, 20)];
        _cNameLabel.backgroundColor = [UIColor clearColor];
        _cNameLabel.textColor = [UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        _cNameLabel.text = @"";
        _cNameLabel.font = [UIFont systemFontOfSize:12.0f];
        [bgView addSubview:_cNameLabel];
        
        UILabel *seperator = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cNameLabel.frame) + 10, _cImageView.frame.origin.y, 0.5, 60)];
        seperator.backgroundColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0];
        [bgView addSubview:seperator];
        [seperator release];
        
        UIImage *telImgNormal = [UIImage imageCwNamed:@"icon_phone.png"];
        UIImage *telImgClick = [UIImage imageCwNamed:@"icon_phone_click.png"];
        UIButton *phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        phoneButton.frame = CGRectMake(260, (60 - telImgNormal.size.height) * 0.5 + 20, telImgNormal.size.width, telImgNormal.size.height);
        [phoneButton setImage:telImgNormal forState:UIControlStateNormal];
        [phoneButton setImage:telImgClick forState:UIControlStateHighlighted];
        [phoneButton addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:phoneButton];
        
        UILabel *seperator1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 89, 300, 0.5)];
        seperator1.backgroundColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0];
        [bgView addSubview:seperator1];
        [seperator1 release];
        
        _cAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(kXSpace, 95, bgView.frame.size.width - 80, 50)];
        _cAddressLabel.backgroundColor = [UIColor clearColor];
        _cAddressLabel.textColor = [UIColor darkTextColor];
        _cAddressLabel.text = @"";
        _cAddressLabel.numberOfLines = 2;
        _cAddressLabel.font = [UIFont systemFontOfSize:13.0f];
        [bgView addSubview:_cAddressLabel];
        
        UIImage *addrImgNormal = [UIImage imageCwNamed:@"locate.png"];
        UIImageView *addrImgVi = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cAddressLabel.frame) + addrImgNormal.size.width *0.5, (_cAddressLabel.frame.size.height - addrImgNormal.size.height) * 0.5 + _cAddressLabel.frame.origin.y, addrImgNormal.size.width, addrImgNormal.size.height)];
        addrImgVi.image = addrImgNormal;
        [bgView addSubview:addrImgVi];
        [addrImgVi release];
        
        [bgView release];
        
        detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        detailButton.frame = CGRectMake(20, 15, 220, 60);
        [detailButton addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:detailButton];
        
        addrButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addrButton.frame = CGRectMake(10, 100, 300, 50);
        [addrButton addTarget:self action:@selector(addrAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addrButton];
        
    }
    return self;
}

- (void)dealloc
{
    [_cImageView release];
    [_cTitleLabel release];
    [_cNameLabel release];
    [_cAddressLabel release];
    [super dealloc];
}

- (void)detailAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (cellDelegate != nil) {
        [cellDelegate toDetail:btn];
    }
}

- (void)addrAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (cellDelegate != nil) {
        [cellDelegate toAddress:btn];
    }
}

- (void)callAction:(id)sender
{
    if (cellDelegate != nil) {
        [cellDelegate callPhone:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
