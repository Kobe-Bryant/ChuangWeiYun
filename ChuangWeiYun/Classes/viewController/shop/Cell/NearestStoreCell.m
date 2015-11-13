//
//  NearestStoreCell.m
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "NearestStoreCell.h"
#import "Common.h"
#import "CrossLabel.h"

#define NearestStoreCellHeight      100.f

@implementation NearestStoreCell

@synthesize cwStatusType;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor colorWithRed:201.f/255.f green:229.f/255.f blue:1.f alpha:1.f];
        _bgView.layer.cornerRadius = 8.f;
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.borderWidth = 1.f;
        _bgView.layer.borderColor = [UIColor colorWithRed:201.f/255.f green:221.f/255.f blue:238.f/255.f alpha:1.f].CGColor;
        [self.contentView addSubview:_bgView];
        
        // 离我最近的店
        _titelLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titelLabel.backgroundColor = [UIColor clearColor];
        _titelLabel.textColor = [UIColor blackColor];
        _titelLabel.font = KCWSystemFont(14.f);
        [_bgView addSubview:_titelLabel];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"NearestStoreCell...");
    [_bgView release], _bgView = nil;
    [_titelLabel release], _titelLabel = nil;
    [super dealloc];
}

- (void)btnClick:(UIButton *)btn
{
    if (btn.tag % 2 == 1) {
        if ([delegate respondsToSelector:@selector(nearestStorePhoneCall:tag:)]) {
            [delegate nearestStorePhoneCall:self tag:btn.tag];
        }
    } else {
        if ([delegate respondsToSelector:@selector(nearestStoreMapClick:tag:)]) {
            [delegate nearestStoreMapClick:self tag:btn.tag];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)setCellContentAndFrame:(NSMutableArray *)arr
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    CGFloat height = 0.f;
    CGFloat width = KUIScreenWidth - 2*KCellLeftW;
    
    if (arr.count > 0) {
        if (self.cwStatusType != StatusTypeFromCenter
            && self.cwStatusType != StatusTypeHotShop
            && self.cwStatusType != StatusTypeHotAD
            && self.cwStatusType != StatusTypeMemberShop
            && self.cwStatusType != StatusTypeProductPush
            && self.cwStatusType != StatusTypePfDetail) {
            NSDictionary *dict = [arr objectAtIndex:0];
            
            _bgView.frame = CGRectMake(KCellLeftW, KCellUpW, width, NearestStoreCellHeight);
            _titelLabel.frame = CGRectMake(KCellLeftW, height, 200.f, 40.f);
            _titelLabel.text = @"导航到店";

            // 地图按钮
            UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            mapBtn.frame = CGRectMake(KCellLeftW, height, 300.f, 40.f);
            [mapBtn setImage:[UIImage imageCwNamed:@"nearby_store.png"] forState:UIControlStateNormal];
            [mapBtn setImage:[UIImage imageCwNamed:@"nearby_click_store.png"] forState:UIControlStateHighlighted];
            [mapBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            mapBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 220.f, 0.f, 0.f);
            [mapBtn setTag:0];
            [_bgView addSubview:mapBtn];
            
            height += 40.f;
            
            // 上线
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, KUIScreenWidth - 2*KCellLeftW, 1.f)];
            line.backgroundColor = [UIColor colorWithRed:201.f/255.f green:221.f/255.f blue:238.f/255.f alpha:1.f];
            [_bgView addSubview:line];
            [line release], line = nil;
            
            // 下线
            line = [[UILabel alloc]initWithFrame:CGRectMake(width-50.f, height + KCellUpW, 1.f, 40.f)];
            line.backgroundColor = [UIColor colorWithRed:201.f/255.f green:221.f/255.f blue:238.f/255.f alpha:1.f];
            [_bgView addSubview:line];
            [line release], line = nil;
            
            height += KCellUpW;
            
            // 店名
            UILabel *_nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCellLeftW, height, width-50.f-KCellLeftW, 20.f)];
            _nameLabel.backgroundColor = [UIColor clearColor];
            _nameLabel.textColor = [UIColor blackColor];
            _nameLabel.font = KCWSystemFont(14.f);
            _nameLabel.text = [dict objectForKey:@"name"];
            [_bgView addSubview:_nameLabel];
            [_nameLabel release], _nameLabel = nil;
            
            height += 20.f;
            
            // 地址
            UILabel *_addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCellLeftW, height, width-50.f-KCellLeftW, 20.f)];
            _addressLabel.backgroundColor = [UIColor clearColor];
            _addressLabel.textColor = [UIColor colorWithRed:119.f/255.f green:119.f/255.f blue:119.f/255.f alpha:1.f];
            _addressLabel.font = KCWSystemFont(12.f);
            _addressLabel.text = [dict objectForKey:@"address"];
            [_bgView addSubview:_addressLabel];
            [_addressLabel release], _addressLabel = nil;
            
            // 地图按钮
            UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            phoneBtn.frame = CGRectMake(KCellLeftW, 50.f, 300.f, 40.f);
            [phoneBtn setImage:[UIImage imageCwNamed:@"icon_phone.png"] forState:UIControlStateNormal];
            [phoneBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            phoneBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 220.f, 0.f, 0.f);
            [phoneBtn setTag:1];
            [_bgView addSubview:phoneBtn];
        } else {
            _titelLabel.frame = CGRectMake(KCellLeftW, height, 200.f, 40.f);
            _titelLabel.text = @"离您最近的店";
            _titelLabel.font = [UIFont systemFontOfSize:17];
            
            height += 40.f;
            
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dict = [arr objectAtIndex:i];
                // 横线
                UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, width, 1.f)];
                line.backgroundColor = [UIColor colorWithRed:201.f/255.f green:221.f/255.f blue:238.f/255.f alpha:1.f];
                [_bgView addSubview:line];
                [line release], line = nil;
                
                height += KCellUpW;
                
                // 下线
                line = [[UILabel alloc]initWithFrame:CGRectMake(width-50.f, height, 1.f, 20.f)];
                line.backgroundColor = [UIColor colorWithRed:201.f/255.f green:221.f/255.f blue:238.f/255.f alpha:1.f];
                [_bgView addSubview:line];
                [line release], line = nil;
                
                // 手机按钮
                UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                phoneBtn.frame = CGRectMake(KCellLeftW, height-10.f, 300.f, 40.f);
                [phoneBtn setImage:[UIImage imageCwNamed:@"icon_phone.png"] forState:UIControlStateNormal];
                [phoneBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [phoneBtn setTag:2*i + 1];
                phoneBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 220.f, 0.f, 0.f);
                [_bgView addSubview:phoneBtn];
                
                // 下线
                line = [[UILabel alloc]initWithFrame:CGRectMake(width-50.f, height + KCellUpW + 30.f, 1.f, 25.f)];
                line.backgroundColor = [UIColor colorWithRed:201.f/255.f green:221.f/255.f blue:238.f/255.f alpha:1.f];
                [_bgView addSubview:line];
                [line release], line = nil;
                
                // 地图按钮
                UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                mapBtn.frame = CGRectMake(KCellLeftW, height + 30.f, 300.f, 40.f);
                [mapBtn setImage:[UIImage imageCwNamed:@"locate.png"] forState:UIControlStateNormal];
                [mapBtn setImage:[UIImage imageCwNamed:@"locate_click.png"] forState:UIControlStateHighlighted];
                [mapBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [mapBtn setTag:2*i];
                mapBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 220.f, 0.f, 0.f);
                [_bgView addSubview:mapBtn];
                
                // 店名
                UILabel *_nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCellLeftW, height-3, width-50.f-KCellLeftW, 30.f)];
                _nameLabel.backgroundColor = [UIColor clearColor];
                _nameLabel.textColor = [UIColor blackColor];
                _nameLabel.font = KCWSystemFont(14.f);
                _nameLabel.text = [dict objectForKey:@"name"];
                [_bgView addSubview:_nameLabel];
                [_nameLabel release], _nameLabel = nil;
                
                height += 30.f;
                
                // 12.10 chenfeng add
                UIFont *font = [UIFont systemFontOfSize:12];
                CGSize size = CGSizeMake( width-50.f-KCellLeftW,60);
                CGSize labelsize = [[dict objectForKey:@"address"] sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
                
                // 地址
                UILabel *_addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(KCellLeftW, height, width-50.f-KCellLeftW, labelsize.height)];
                _addressLabel.backgroundColor = [UIColor clearColor];
                _addressLabel.textColor = [UIColor colorWithRed:119.f/255.f green:119.f/255.f blue:119.f/255.f alpha:1.f];
                _addressLabel.font = KCWSystemFont(12.f);
                _addressLabel.numberOfLines=0;
                _addressLabel.text = [dict objectForKey:@"address"];
                [_bgView addSubview:_addressLabel];
                [_addressLabel release], _addressLabel = nil;
                
                height +=labelsize.height + 5.0f;
                
                // 金钱
                UILabel *_moneyLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                _moneyLabel.backgroundColor = [UIColor clearColor];
                _moneyLabel.textColor = [UIColor colorWithRed:118.f/255.f green:117.f/255.f blue:117.f/255.f alpha:1.f];
                _moneyLabel.font = KCWSystemFont(12.f);
                // 12.10 chenfeng add
                if ([[dict objectForKey:@"price"] intValue] != 0) {
                    _moneyLabel.text = [NSString stringWithFormat:@"¥ %0.2f",[[dict objectForKey:@"price"] doubleValue]];
                    size = [_moneyLabel.text sizeWithFont:KCWSystemFont(12.f)];
                    _moneyLabel.frame = CGRectMake(KCellLeftW, height, size.width,15.f);
                    
                    if ([[dict objectForKey:@"market_price"] intValue]!=0) {
                        UIColor *loseColor = [UIColor colorWithRed:159.f/255.f green:159.f/255.f blue:159.f/255.f alpha:1.f];
                        CrossLabel *_markerLabel = [[CrossLabel alloc]initWithFrame:CGRectZero textColor:loseColor lineColor:loseColor];
                        _markerLabel.backgroundColor = [UIColor clearColor];
                        _markerLabel.font = KCWSystemFont(12.f);
                        _markerLabel.text = [NSString stringWithFormat:@"￥%0.2f",[[dict objectForKey:@"market_price"] doubleValue]];
                        size = [_markerLabel.text sizeWithFont:KCWSystemFont(12.f)];
                        _markerLabel.frame = CGRectMake(CGRectGetMaxX(_moneyLabel.frame) + 10.f, height, size.width,15.f);
                        
                        [_bgView addSubview:_markerLabel];
                        [_markerLabel release],_markerLabel = nil;
                    }
                }
                
                [_bgView addSubview:_moneyLabel];
                [_moneyLabel release], _moneyLabel = nil;
                
                height += 15.f + 10.f;
            }
            _bgView.frame = CGRectMake(KCellLeftW, KCellUpW, width, height);
        }
    }
    
    [pool release];
}

+ (CGFloat)getCellHeight:(NSMutableArray *)shoplist state:(CwStatusType)status
{
    NSLog(@"shoplist.count = %d",shoplist.count);
    if (shoplist.count > 0) {
        if (status == StatusTypeFromCenter
            || status == StatusTypeHotShop
            || status == StatusTypeHotAD
            || status == StatusTypeMemberShop
            || status == StatusTypeProductPush
            || status == StatusTypePfDetail) {
            
            CGFloat height = 40.f;
            
            for (int i = 0; i < shoplist.count; i++) {

                height += KCellUpW;
                
                height += 30.f;

                CGFloat width = KUIScreenWidth - 2*KCellLeftW;
                UIFont *font = [UIFont systemFontOfSize:12];
                CGSize size = CGSizeMake(width-50.f-KCellLeftW,60);
                CGSize labelsize = [[[shoplist objectAtIndex:i] objectForKey:@"address"]
                                    sizeWithFont:font
                                    constrainedToSize:size
                                    lineBreakMode:UILineBreakModeWordWrap];
                
                height += labelsize.height + 5.0f;
                
                height += 15.f + 10.f;
            }

            return height + KCellUpW;
        } else {
            return NearestStoreCellHeight + KCellUpW;
        }
    }
    
    return 0.f;
}

@end
