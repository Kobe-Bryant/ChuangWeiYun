//
//  AboutViewCell.m
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "AboutViewCell.h"
#import "CrossLabel.h"
#import "Global.h"

@implementation AboutViewCell

@synthesize cwStatusType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 0;
        _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _nameLabel.font = KCWSystemFont(14.f);
        [self.contentView addSubview:_nameLabel];
        
        _moneyLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _moneyLabel.backgroundColor = [UIColor clearColor];
        _moneyLabel.textColor = [UIColor colorWithRed:163.f/255.f green:1.f/255.f blue:0.f alpha:1.f];
        _moneyLabel.font = KCWSystemFont(15.f);
        [self.contentView addSubview:_moneyLabel];
        
        UIColor *loseColor = [UIColor colorWithRed:183.f/255.f green:183.f/255.f blue:183.f/255.f alpha:1.f];
        _markerLabel = [[CrossLabel alloc]initWithFrame:CGRectZero textColor:loseColor lineColor:loseColor];
        _markerLabel.backgroundColor = [UIColor clearColor];
        _markerLabel.font = KCWSystemFont(12.f);
        [self.contentView addSubview:_markerLabel];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"AboutViewCell...");
    [_nameLabel release], _nameLabel = nil;
    [_moneyLabel release], _moneyLabel = nil;
    [_markerLabel release], _markerLabel = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSDictionary *)dict
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    CGFloat height = KCellUpW;
    
    NSString *content = [dict objectForKey:@"content"];
    _nameLabel.text = [content isEqual:[NSNull null]] ? @"" : content;
    CGSize size = [_nameLabel.text sizeWithFont:KCWSystemFont(14.f) constrainedToSize:CGSizeMake(KUIScreenWidth - 2*KCellLeftW, 1000.f)];
    _nameLabel.frame = CGRectMake(KCellLeftW, height, KUIScreenWidth - 2*KCellLeftW, size.height);
    height += size.height + KCellUpW;

    if (cwStatusType == StatusTypeFromCenter
        || cwStatusType == StatusTypeHotShop
        || cwStatusType == StatusTypeMemberShop
        || cwStatusType == StatusTypeHotAD
        || cwStatusType == StatusTypeProductPush) {
        _moneyLabel.text = nil;
        _markerLabel.text = nil;
    } else if (cwStatusType != StatusTypeMemberShop
              && [Common isLoctionAndEqual]) {
        _moneyLabel.text = [NSString stringWithFormat:@"￥%0.2f",[[dict objectForKey:@"price"] doubleValue]];
        size = [_moneyLabel.text sizeWithFont:KCWSystemFont(15.f)];
        _moneyLabel.frame = CGRectMake(KCellLeftW, height, size.width, size.height);
        
        if ([[dict objectForKey:@"market_price"] intValue] == 0) {
            _markerLabel.hidden = YES;
        } else {
            _markerLabel.hidden = NO;
        }
        _markerLabel.text = [NSString stringWithFormat:@"￥%0.2f",[[dict objectForKey:@"market_price"] doubleValue]];
        size = [_markerLabel.text sizeWithFont:KCWSystemFont(12.f)];
        _markerLabel.frame = CGRectMake(CGRectGetMaxX(_moneyLabel.frame) + KCellLeftW, height, size.width, CGRectGetHeight(_moneyLabel.frame));
    } else {
        _moneyLabel.text = nil;
        _markerLabel.text = nil;
    }
    
    [pool release];
}

+ (CGFloat)getCellHeight:(NSDictionary *)dict state:(CwStatusType)status
{
    CGFloat height = KCellUpW;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *content = [dict objectForKey:@"content"];
    content =  [content isEqual:[NSNull null]] ? @"" : content;
    CGSize size = [content sizeWithFont:KCWSystemFont(14.f) constrainedToSize:CGSizeMake(KUIScreenWidth - 2*KCellLeftW, 1000.f)];
    height += size.height;
    
    if ([Common isLoctionAndEqual]) {
        if (!(status == StatusTypeFromCenter
              || status == StatusTypeHotShop
              || status == StatusTypeMemberShop
              || status == StatusTypeHotAD
              || status == StatusTypeProductPush)) {
            NSString *price = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"price"] intValue]];
            size = [price sizeWithFont:KCWSystemFont(15.f)];
            
            height += size.height + KCellUpW;
        }
    }
    
    [pool release];

    return height;
}

@end
