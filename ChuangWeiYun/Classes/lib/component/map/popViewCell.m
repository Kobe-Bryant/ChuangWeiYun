//
//  popViewCell.m
//  cw
//
//  Created by yunlai on 14-2-10.
//
//

#import "popViewCell.h"

@implementation popViewCell
@synthesize iconImg;
@synthesize contentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:bgView];
        
        iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 2, 40, 40)];

        [self.contentView addSubview:iconImg];
        
        contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 2, 200, 40)];
        [self.contentView addSubview:contentLabel];
        
    }
    return self;
}

- (void)dealloc
{
    [iconImg release];
    [contentLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
