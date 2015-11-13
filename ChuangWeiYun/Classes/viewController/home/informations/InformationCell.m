//
//  InformationCell.m
//  cw
//
//  Created by LuoHui on 13-8-28.
//
//

#import "InformationCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageScale.h"

#define kXSpace 10
#define kYSpace 10

@implementation InformationCell
@synthesize iImageView =  _iImageView;
@synthesize iTitleLabel = _iTitleLabel;
@synthesize iTimeLabel = _iTimeLabel;
@synthesize iContentLabel = _iContentLabel;
@synthesize recommendView = _recommendView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kXSpace, kYSpace, 300, 320)];
        bgView.layer.cornerRadius = 3;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0].CGColor;
        bgView.layer.borderWidth = 1;
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        self.backgroundColor = [UIColor clearColor];
        
        _iImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, bgView.frame.size.width - 20, 210)];
        _iImageView.backgroundColor = [UIColor clearColor];
        _iImageView.contentMode = UIViewContentModeScaleAspectFit;
        [bgView addSubview:_iImageView];
        
        _iTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_iImageView.frame) + 5, bgView.frame.size.width - 20, 40)];
        _iTitleLabel.backgroundColor = [UIColor clearColor];
        _iTitleLabel.textColor = [UIColor blackColor];
        _iTitleLabel.text = @"2013中国数字电视产业发展高峰论坛创维荣获“消费者最喜爱的平板电视品牌”";
        _iTitleLabel.numberOfLines = 2;
        _iTitleLabel.font = [UIFont systemFontOfSize:15.0f];
        [bgView addSubview:_iTitleLabel];
        
        _iTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_iTitleLabel.frame), bgView.frame.size.width - 20, 15)];
        _iTimeLabel.backgroundColor = [UIColor clearColor];
        _iTimeLabel.textColor = [UIColor grayColor];
        _iTimeLabel.text = @"2013年08月16日 14:00";
        _iTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        [bgView addSubview:_iTimeLabel];
        
        _iContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_iTimeLabel.frame), bgView.frame.size.width - 20, 35)];
        _iContentLabel.backgroundColor = [UIColor clearColor];
        _iContentLabel.textColor = [UIColor darkGrayColor];
        _iContentLabel.text = @"ddddddddd";
        _iContentLabel.numberOfLines = 2;
        _iContentLabel.font = [UIFont systemFontOfSize:14.0f];
        [bgView addSubview:_iContentLabel];
        
        UIImage *img = [UIImage imageCwNamed:@"hot.png"];
        _recommendView = [[UIImageView alloc] initWithFrame:CGRectMake(bgView.frame.size.width - img.size.width - 10, 0, img.size.width, img.size.height)];
        _recommendView.image = img;
        [bgView addSubview:_recommendView];
        _recommendView.hidden = YES;
        
        self.contentView.backgroundColor = KCWViewBgColor;
        [bgView release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [_iImageView release];
    [_iTitleLabel release];
    [_iTimeLabel release];
    [_iContentLabel release];
    [_recommendView release];
    [super dealloc];
}
@end
