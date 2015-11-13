//
//  CouponsCell.m
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import "CouponsCell.h"
#import "Common.h"
#import "PreferentialObject.h"

#define CouponsLeftW 10.f
#define CouponsUPH 10.f
#define CouponsBGImageVH 95.f

#define CouponsFontSize12   12.f
#define CouponsFontSize17   17.f
#define CouponsFontSize20   20.f

@implementation CouponsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        UIImage *img = [UIImage imageCwNamed:@"coupons_invalid_member.png"];
        _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(KUIScreenWidth/2-img.size.width/2, CouponsUPH, img.size.width, CouponsBGImageVH)];
        [self.contentView addSubview:_bgImageView];
        
        CGFloat leftHeight = CouponsUPH;
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CouponsLeftW, leftHeight, CGRectGetWidth(_bgImageView.frame) - 120.f, 30.f)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = KCWSystemFont(CouponsFontSize12);
        [_bgImageView addSubview:_titleLabel];
        
        leftHeight += 30.f;
        
        _moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(CouponsLeftW, leftHeight, 90.f, 40.f)];
        _moneyLabel.backgroundColor = [UIColor clearColor];
        _moneyLabel.textColor = [UIColor whiteColor];
        _moneyLabel.font = KCWSystemFont(CouponsFontSize20);
        [_bgImageView addSubview:_moneyLabel];
        
        CGFloat frontWidth = CouponsLeftW + 90.f;
        
        // 优惠券
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(frontWidth, leftHeight, 90.f, 40.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = KCWSystemFont(CouponsFontSize17);
        label.text = @"优惠券";
        [_bgImageView addSubview:label];
        [label release], label = nil;
        
        CGFloat rightHeight = 3*CouponsUPH/2;
        frontWidth += 90.f;
        
        // 有效期
        label = [[UILabel alloc]initWithFrame:CGRectMake(frontWidth, rightHeight, 90.f, 20.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentRight;
        label.font = KCWSystemFont(CouponsFontSize12);
        label.text = @"有效期";
        [_bgImageView addSubview:label];
        [label release], label = nil;
        
        rightHeight += 20.f;
        
        _startTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(frontWidth, rightHeight, 90.f, 20.f)];
        _startTimeLabel.backgroundColor = [UIColor clearColor];
        _startTimeLabel.textColor = [UIColor whiteColor];
        _startTimeLabel.textAlignment = NSTextAlignmentRight;
        _startTimeLabel.font = KCWSystemFont(CouponsFontSize12);
        [_bgImageView addSubview:_startTimeLabel];
        
        rightHeight += 20.f;
        
        _endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(frontWidth, rightHeight, 90.f, 20.f)];
        _endTimeLabel.backgroundColor = [UIColor clearColor];
        _endTimeLabel.textColor = [UIColor whiteColor];
        _endTimeLabel.textAlignment = NSTextAlignmentRight;
        _endTimeLabel.font = KCWSystemFont(CouponsFontSize12);
        [_bgImageView addSubview:_endTimeLabel];
    }
    return self;
}

- (void)dealloc
{
    [_titleLabel release], _titleLabel = nil;
    [_endTimeLabel release], _endTimeLabel = nil;
    [_bgImageView release], _bgImageView = nil;
    [_moneyLabel release], _moneyLabel = nil;
    [_startTimeLabel release], _startTimeLabel = nil;

    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSDictionary *)dict
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    int start = [[dict objectForKey:@"start_date"] intValue];
    int end = [[dict objectForKey:@"end_date"] intValue];
    
    _titleLabel.text = [dict objectForKey:@"title"];
    _moneyLabel.text = [NSString stringWithFormat:@"¥%@",[dict objectForKey:@"discount"]];
    _startTimeLabel.text = [PreferentialObject getTheDate:start symbol:1];
    _endTimeLabel.text = [PreferentialObject getTheDate:end symbol:1];
    
    if ([[dict objectForKey:@"used"] intValue] == 1) {
        _bgImageView.image = [UIImage imageCwNamed:@"coupons_invalid_member.png"];
    } else {
        if (![PreferentialObject isPastDueDate:start end:end]) {
            _bgImageView.image = [UIImage imageCwNamed:@"coupons_expired_member.png"];
        } else {
            _bgImageView.image = [UIImage imageCwNamed:@"coupons_member.png"];
        }
    }
    
    [pool release];
}

+ (CGFloat)getCellHeight
{
    return CouponsBGImageVH + CouponsUPH;
}

@end
