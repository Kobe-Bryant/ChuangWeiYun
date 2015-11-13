//
//  PreferentialCell.m
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "PreferentialCell.h"
#import "PreferentialObject.h"
#import "Common.h"

#define KPreferCFontSize15      15.f
#define KPreferCFontSize12      12.f

#define KPreferCLeftW           10.f
#define KPreferCUpH             10.f
#define KPreferCBGLeftW         5.f
#define KPreferCBGUpH           5.f
#define KPreferCLabelH          30.f
#define KPreferCImageH          163.f
#define KPreferCBGH             203.f

@implementation PreferentialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5.f;
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.borderWidth = 1.f;
        _bgView.layer.borderColor = [UIColor colorWithRed:0.8392 green:0.8392 blue:0.8392 alpha:1.0].CGColor;
        [self.contentView addSubview:_bgView];
        
        self.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];
        _titleLabel.font = KCWSystemFont(KPreferCFontSize15);
        [_bgView addSubview:_titleLabel];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor colorWithRed:232.f/255.f green:51.f/255.f blue:45.f/255.f alpha:1.f];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = KCWSystemFont(KPreferCFontSize12);
        [_bgView addSubview:_timeLabel];
        
        _smallImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_bgView addSubview:_smallImageView];
        
        _bigImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_bgView addSubview:_bigImageView];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"preferentialcell dealloc........");
    [_bgView release], _bgView = nil;
    [_titleLabel release], _titleLabel = nil;
    [_timeLabel release], _timeLabel = nil;
    [_smallImageView release], _smallImageView = nil;
    [_bigImageView release], _bigImageView = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSDictionary *)dict
{
    _bgView.frame = CGRectMake(KPreferCLeftW, KPreferCUpH, KUIScreenWidth - 2*KPreferCLeftW, KPreferCBGH);
    
    CGFloat frontWidth = KPreferCBGLeftW;
    CGFloat height = KPreferCBGUpH;
    
    _titleLabel.text = [dict objectForKey:@"title"];
    _titleLabel.frame = CGRectMake(frontWidth, height, 190.f, KPreferCLabelH);

    frontWidth += 190.f;
    
    _smallImageView.image = [UIImage imageCwNamed:@"icon_countdown_store.png"];
    _smallImageView.frame = CGRectMake(frontWidth+35.f, KPreferCBGUpH + KPreferCLabelH/2-_smallImageView.image.size.height/2, _smallImageView.image.size.width, _smallImageView.image.size.height);
    
    frontWidth += KPreferCLabelH;

    NSString *numStr = [PreferentialObject getTheLastDays:[[dict objectForKey:@"start_date"]intValue]
                                             end:[[dict objectForKey:@"end_date"]intValue]];
    
    _timeLabel.text = numStr;
    _timeLabel.frame = CGRectMake(frontWidth, height, CGRectGetWidth(_bgView.frame) - frontWidth - KPreferCBGLeftW, KPreferCLabelH);
    
    height += KPreferCLabelH;

    _bigImageView.frame = CGRectMake(KPreferCBGLeftW, height, CGRectGetWidth(_bgView.frame) - 2*KPreferCBGLeftW, KPreferCImageH);
}

- (void)setBigImageView:(UIImage *)img
{
    _bigImageView.image = img;
}

+ (CGFloat)getCellHeight
{
    return 2*KPreferCUpH + KPreferCBGH;
}

@end
