//
//  DetailImageCell.m
//  cw
//
//  Created by yunlai on 13-11-21.
//
//

#import "DetailImageCell.h"
#import "Common.h"

@implementation DetailImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:imgView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc
{
    [imgView release], imgView = nil;
    [super dealloc];
}

- (void)setImgViewContent:(UIImage *)img
{
    CGSize size = [UIImage fitsize:img.size width:KUIScreenWidth];
    imgView.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, size.height);
    imgView.image = img;
}

+ (CGFloat)getImgViewHeight:(UIImage *)img
{
    CGSize size = [UIImage fitsize:img.size width:KUIScreenWidth];
    
    return size.height;
}

@end
