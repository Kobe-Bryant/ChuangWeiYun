//
//  PfContentCell.m
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "PfContentCell.h"

#define KPfConSystemFont15 15.f
#define KPfConSystemFont13 14.f

#define PfContentLeftW          10.f
#define PfContentUPH            5.f
#define PfContentBGLeftW        10.f
#define PfContentBGUPH          10.f
#define PfContentImageH         20.f
#define PfContentLableH         20.f
#define PfContentUpLableH       30.f

@implementation PfContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5.f;
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.borderWidth = 0.3f;
        _bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:_bgView];
        
        _bgLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _bgLabel.backgroundColor = [UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:248.f/255.f alpha:1.f];
        [_bgView addSubview:_bgLabel];
        
        _titleImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_bgView addSubview:_titleImageView];
        
        _titlelabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titlelabel.backgroundColor = [UIColor clearColor];
        _titlelabel.textColor = [UIColor blackColor];
        _titlelabel.font = KCWboldSystemFont(KPfConSystemFont15);
        [_bgView addSubview:_titlelabel];
        
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.font = KCWSystemFont(KPfConSystemFont13);
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_bgView addSubview:_contentLabel];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"pfcontentcell dealloc........");
    [_bgView release], _bgView = nil;
    [_bgLabel release], _bgLabel = nil;
    [_contentLabel release], _contentLabel = nil;
    [_titleImageView release], _titleImageView = nil;
    [_titlelabel release], _titlelabel = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(UIImage *)titleImage title:(NSString *)title content:(NSString *)content
{
    CGFloat height = 0.f;
    
    if (titleImage) {
        _titleImageView.image = titleImage;
    }
    _titleImageView.frame = CGRectMake(PfContentBGLeftW, height + 5.f, PfContentImageH, PfContentImageH);
    
    CGFloat frontWidth = PfContentImageH + 2*PfContentBGLeftW;
    
    _titlelabel.text = title;
    _titlelabel.frame = CGRectMake(frontWidth, height, 100.f, PfContentUpLableH);
    
    height += PfContentLableH + PfContentBGUPH;
    
    CGFloat width = KUIScreenWidth - 2*PfContentBGLeftW - 2*PfContentLeftW;
    _contentLabel.text = content;
    CGSize size = [content sizeWithFont:KCWSystemFont(KPfConSystemFont13) constrainedToSize:CGSizeMake(width, 1000.f)];
    _contentLabel.frame = CGRectMake(PfContentBGLeftW, height+5, width, size.height);
    
    height += size.height + PfContentBGUPH;
    
    _bgView.frame = CGRectMake(PfContentLeftW, PfContentUPH, KUIScreenWidth - 2*PfContentLeftW, height);
    _bgLabel.frame = CGRectMake(0.f, 0.f, KUIScreenWidth - 2*PfContentLeftW, PfContentUpLableH);
}

+ (CGFloat)getCellHeight:(NSString *)content
{
    CGFloat height = PfContentUPH;
    
    height += PfContentLableH + PfContentBGUPH;
    
    CGFloat width = KUIScreenWidth - 2*PfContentBGLeftW - 2*PfContentLeftW;
    CGSize size = [content sizeWithFont:KCWSystemFont(KPfConSystemFont13) constrainedToSize:CGSizeMake(width, 1000.f)];
    
    height += size.height + PfContentBGUPH;
    
    height += PfContentUPH;
    
    return height;
}

@end
