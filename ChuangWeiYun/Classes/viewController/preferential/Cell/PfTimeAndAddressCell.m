//
//  PfTimeAndAddressCell.m
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "PfTimeAndAddressCell.h"
#import "Common.h"
#import "PreferentialObject.h"

#define PfTimeAddBgLineColor   [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:0.9f]
#define PfTimeAddBGH                70.f
#define PfTimeAddUpH                5.f
#define PfTimeAddLeftW              10.f
#define KPfTimeAddSystemFont12      12.f

@implementation PfTimeAndAddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat imagwh = 20.f;
        CGFloat space = 10.f;
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(PfTimeAddLeftW, PfTimeAddUpH, KUIScreenWidth - 2*PfTimeAddLeftW, PfTimeAddBGH)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 5.f;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderWidth = 0.3f;
        bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:bgView];
        
        CGFloat frontwidth = 2*space + imagwh;
        CGFloat height = 0.f;
        
        // timeImage
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(space, 7.5f, imagwh, imagwh)];
        imageV.image = [UIImage imageCwNamed:@"icon_clock_store.png"];
        [bgView addSubview:imageV];
        [imageV release], imageV = nil;
        
        _timelabel = [[UILabel alloc]initWithFrame:CGRectMake(frontwidth, height, CGRectGetWidth(bgView.frame) - frontwidth - space, PfTimeAddBGH/2)];
        _timelabel.backgroundColor = [UIColor clearColor];
        _timelabel.textColor = [UIColor blackColor];
        _timelabel.font = KCWSystemFont(KPfTimeAddSystemFont12);
        [bgView addSubview:_timelabel];
        
        height += PfTimeAddBGH/2;
        
        // 线
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(bgView.frame), 0.9f)];
        line.backgroundColor = PfTimeAddBgLineColor;
        [bgView addSubview:line];
        [line release], line = nil;
        
        // addressImage
        imageV = [[UIImageView alloc] initWithFrame:CGRectMake(space, height + 7.5f, imagwh, imagwh)];
        imageV.image = [UIImage imageCwNamed:@"icon_shop_store.png"];
        [bgView addSubview:imageV];
        [imageV release], imageV = nil;
        
        _addresslabel = [[UILabel alloc]initWithFrame:CGRectMake(frontwidth, height, CGRectGetWidth(bgView.frame) - frontwidth - space, PfTimeAddBGH/2)];
        _addresslabel.backgroundColor = [UIColor clearColor];
        _addresslabel.textColor = [UIColor blackColor];
        _addresslabel.font = KCWSystemFont(KPfTimeAddSystemFont12);
        [bgView addSubview:_addresslabel];
        
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = _addresslabel.frame;
//        [btn addTarget:self action:@selector(btnMapClick:) forControlEvents:UIControlEventTouchUpInside];
//        [bgView addSubview:btn];
        
        [bgView release], bgView = nil;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"pftimeandaddresscell dealloc........");
    [_timelabel release], _timelabel = nil;
    [_addresslabel release], _addresslabel = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//// 地图跳转
//- (void)btnMapClick:(UIButton *)btn
//{
//    if ([delegate respondsToSelector:@selector(pfAddressCellClick:)]) {
//        [delegate pfAddressCellClick:self];
//    }
//}

- (void)setCellContentAndFrame:(NSDictionary *)dict
{
    _timelabel.text = [NSString stringWithFormat:@"%@ - %@",
                       [PreferentialObject getTheDate:[[dict objectForKey:@"start_date"] intValue] symbol:0],
                       [PreferentialObject getTheDate:[[dict objectForKey:@"end_date"] intValue] symbol:0]];
    _addresslabel.text = [dict objectForKey:@"address"];
}

+ (CGFloat)getCellHeight
{
    return PfTimeAddBGH + 2*PfTimeAddUpH;
}

@end
