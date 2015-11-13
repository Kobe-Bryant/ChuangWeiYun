//
//  ProductPamraCell.m
//  cw
//
//  Created by yunlai on 13-11-12.
//
//

#import "ProductPamraCell.h"

@implementation ProductPamraCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor clearColor];
        _bgView.layer.borderWidth = 1.f;
        _bgView.layer.borderColor = [UIColor colorWithRed:213.f/255.f green:213.f/255.f blue:213.f/255.f alpha:1.f].CGColor;
        [self.contentView addSubview:_bgView];
        
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor grayColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = KCWSystemFont(14.f);
        _contentLabel.lineBreakMode= NSLineBreakByWordWrapping;
        [_bgView addSubview:_contentLabel];
    }
    return self;
}

- (void)dealloc
{
    [_bgView release], _bgView = nil;
    [_contentLabel release], _contentLabel = nil;
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSString *)str
{
    if (str.length == 0) {
        return;
    }
    CGFloat width = 280.f;
    CGFloat height = 10.f;
    CGSize constrainedSize = CGSizeMake(width, 1000.f);
    CGSize size = [str sizeWithFont:KCWSystemFont(14.f) constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    _contentLabel.frame = CGRectMake(10.f, height, width, size.height);
    _contentLabel.text = str;
    
    height += size.height + 10.f;
    
    _bgView.frame = CGRectMake(10.f, 0.f, width + 20.f, height);
}

+ (CGFloat)getCellHeight:(NSString *)str
{
    CGFloat height = 0.f;
    if (str.length == 0) {
        return height;
    }
    CGFloat width = 280.f;
    height = 10.f;
    CGSize constrainedSize = CGSizeMake(width, 1000.f);
    CGSize size = [str sizeWithFont:KCWSystemFont(14.f) constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    
    height += size.height + 10.f;
    
    return height;
}

@end
