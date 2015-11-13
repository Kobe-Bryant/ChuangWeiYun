//
//  RecommendAppCell.m
//  cw
//
//  Created by yunlai on 13-9-11.
//
//

#import "RecommendAppCell.h"
#import "Common.h"

@implementation RecommendAppCell
@synthesize iconImageView=_iconImageView;
@synthesize appNameLabel=_appNameLabel;
@synthesize appBanner=_appBanner;
@synthesize downloadBtn=_downloadBtn;

#define kLeftPan 10
#define kAbovePan 10

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(kLeftPan, kAbovePan, 60, 60)];
        _iconImageView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_iconImageView];
        
        
        _appNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(kLeftPan+70, kAbovePan+6, 170, 25)];
        _appNameLabel.font=[UIFont systemFontOfSize:15];
        _appNameLabel.backgroundColor=[UIColor clearColor];
        _appNameLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.contentView addSubview:_appNameLabel];
        
        _appBanner=[[UILabel alloc]initWithFrame:CGRectMake(kLeftPan+70, kAbovePan+30, 170, 25)];
        _appBanner.font=[UIFont systemFontOfSize:12];
        _appBanner.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        _appBanner.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_appBanner];
        
        _downloadBtn=[[UIButton alloc]initWithFrame:CGRectMake(250, 25, 64, 30)];
        _downloadBtn.layer.cornerRadius=3;
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadBtn setTintColor:[UIColor whiteColor]];
        [_downloadBtn setBackgroundColor:[UIColor colorWithRed:112/255.0 green:182/255.0 blue:66/255.0 alpha:1]];
        [self.contentView addSubview:_downloadBtn];
        
        self.contentView.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_iconImageView);
    RELEASE_SAFE(_appNameLabel);
    RELEASE_SAFE(_appBanner);
    RELEASE_SAFE(_downloadBtn);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
