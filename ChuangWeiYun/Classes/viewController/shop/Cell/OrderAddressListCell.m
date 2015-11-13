//
//  OrderAddressListCell.m
//  cw
//
//  Created by yunlai on 13-8-24.
//
//

#import "OrderAddressListCell.h"
#import "Common.h"

#define OrderAddressListFontSize    14.f

#define OrderAddCellBGUpH           10.f
#define OrderAddCellBGLeftW         10.f
#define OrderAddCellLeftW           2.f
#define OrderAddCellUpH             5.f

@implementation OrderAddressListCell

@synthesize delegate;
@synthesize area;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 3.f;
        _bgView.layer.borderWidth = 1.f;
        [self.contentView addSubview:_bgView];
        self.backgroundColor = [UIColor clearColor];
        
        
        _modBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modBtn setBackgroundImage:[UIImage imageCwNamed:@"icon_editor_member.png"] forState:UIControlStateNormal];
        [_modBtn addTarget:self action:@selector(modBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_modBtn];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = KCWSystemFont(OrderAddressListFontSize);
        [_bgView addSubview:_nameLabel];
        
        _phoneLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        _phoneLabel.textColor = [UIColor blackColor];
        _phoneLabel.font = KCWSystemFont(OrderAddressListFontSize);
        [_bgView addSubview:_phoneLabel];
        
        _addresslabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _addresslabel.backgroundColor = [UIColor clearColor];
        _addresslabel.textColor = [UIColor blackColor];
        _addresslabel.font = KCWSystemFont(OrderAddressListFontSize);
        _addresslabel.numberOfLines = 2;
        _addresslabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_bgView addSubview:_addresslabel];
    }
    return self;
}

- (void)dealloc
{
    [_phoneLabel release], _phoneLabel = nil;
    [_bgView release], _bgView = nil;
    [_addresslabel release], _addresslabel = nil;
    [_nameLabel release], _nameLabel = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)modBtnClick:(UIButton *)btn
{
    if ([delegate respondsToSelector:@selector(modOrderAddressListCellBtn:)]) {
        [delegate modOrderAddressListCellBtn:self];
    }
}

- (void)set_bgViewborderColorState:(BOOL)_bool
{
    if (_bool == YES) {
        _bgView.layer.borderColor = [UIColor colorWithRed:132.f/255.f green:192.f/255.f blue:99.f/255.f alpha:1.f].CGColor;
    } else {
        _bgView.layer.borderColor = [UIColor colorWithRed:234.f/255.f green:234.f/255.f blue:234.f/255.f alpha:1.f].CGColor;
    }
}

//收货地址中的直辖市去掉 //11.20 chenfeng add
- (NSString *)isIncludeString:(NSString *)addressString andCity:(NSDictionary *)dic{
    if([addressString rangeOfString:@"市辖区"].location !=NSNotFound)
    {
        NSLog(@"yes");
        NSRange ranges = NSMakeRange(6, 3);
        addressString = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"city"],[addressString substringWithRange:ranges]];
    }
    else
    {
        NSLog(@"no");
    }
    
    return addressString;
}

- (void)setCellContentAndFrame:(NSDictionary *)dict
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    UIImage *modImage = [UIImage imageCwNamed:@"icon_editor_member.png"];
    
    CGFloat height = OrderAddCellBGUpH;
    CGFloat width = OrderAddCellBGLeftW;
    CGFloat leftwidth = modImage.size.width + 2*OrderAddCellBGLeftW;
    CGFloat labelW = KUIScreenWidth - 2*OrderAddCellLeftW - leftwidth - OrderAddCellLeftW;
    CGSize labelSize = CGSizeMake(labelW, 1000.f);

    _nameLabel.text = [dict objectForKey:@"name"];
    CGSize size = [_nameLabel.text sizeWithFont:KCWSystemFont(OrderAddressListFontSize) constrainedToSize:labelSize];
    _nameLabel.frame = CGRectMake(leftwidth, height, size.width, size.height);
    
    width += leftwidth + size.width + 10.f;
    
    _phoneLabel.text = [dict objectForKey:@"mobile"];
    size = [_phoneLabel.text sizeWithFont:KCWSystemFont(OrderAddressListFontSize)];
    _phoneLabel.frame = CGRectMake(width, height, size.width, size.height);
    
    height += size.height + 10.f;
    
    //_addresslabel.text = [NSString stringWithFormat:@"%@%@%@",[dict objectForKey:@"city"],[dict objectForKey:@"area"],[dict objectForKey:@"address"]];
    //11.20 chenfeng add
    self.area = [self isIncludeString:[dict objectForKey:@"area"]andCity:dict];
    _addresslabel.text = [NSString stringWithFormat:@"%@%@%@",[dict objectForKey:@"city"],self.area,[dict objectForKey:@"address"]];
    
    NSString *str = @"您";
    CGSize one = [str sizeWithFont:KCWSystemFont(OrderAddressListFontSize)];
    size = [_addresslabel.text sizeWithFont:KCWSystemFont(OrderAddressListFontSize) constrainedToSize:labelSize];
    if (size.height > one.height) {
        _addresslabel.frame = CGRectMake(leftwidth, height, size.width, 2*one.height);
        
        height += 2*one.height + OrderAddCellBGUpH;
    } else {
        _addresslabel.frame = CGRectMake(leftwidth, height, size.width, one.height);
        
        height += one.height + OrderAddCellBGUpH;
    }
    
    _bgView.frame = CGRectMake(OrderAddCellLeftW, OrderAddCellUpH, KUIScreenWidth - 2*OrderAddCellLeftW, height);
    
    _modBtn.frame = CGRectMake(OrderAddCellBGLeftW, CGRectGetHeight(_bgView.frame)/2 - modImage.size.height/2, modImage.size.width, modImage.size.height);
    
    [pool release];
}

+ (CGFloat)getCellHeight:(NSDictionary *)dict
{
    CGFloat height = 0.f;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    UIImage *modImage = [UIImage imageCwNamed:@"icon_editor_member.png"];
    CGFloat leftwidth = modImage.size.width + OrderAddCellBGLeftW;
    CGFloat labelW = KUIScreenWidth - 2*OrderAddCellLeftW - leftwidth - OrderAddCellLeftW;
    CGSize labelSize = CGSizeMake(labelW, 1000.f);
    
    height += OrderAddCellBGUpH + OrderAddCellUpH;
    NSString *str1 = [dict objectForKey:@"name"];
    
    NSString *str2 = [NSString stringWithFormat:@"%@%@%@",[dict objectForKey:@"city"],[dict objectForKey:@"area"],[dict objectForKey:@"address"]];

    NSString *str = @"您";
    
    CGSize size = [str1 sizeWithFont:KCWSystemFont(OrderAddressListFontSize)];
    
    height += size.height + 10.f;
    
    CGSize one = [str sizeWithFont:KCWSystemFont(OrderAddressListFontSize)];
    size = [str2 sizeWithFont:KCWSystemFont(OrderAddressListFontSize) constrainedToSize:labelSize];
    if (size.height > one.height) {
        height += 2*one.height;
    } else {
        height += one.height;
    }
    
    height += OrderAddCellBGUpH;
    
    NSLog(@"getCellHeight  height = %f",height);
    
    [pool release];
    
    return height;
}

@end
