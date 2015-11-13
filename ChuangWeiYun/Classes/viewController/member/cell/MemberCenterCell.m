//
//  MemberCenterCell.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "MemberCenterCell.h"

@implementation MemberCenterCell
@synthesize imgView=_imgView;
@synthesize labelText=_labelText;
@synthesize afterView=_afterView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _imgView=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
        _imgView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_imgView];
        
        _labelText=[[UILabel alloc]initWithFrame:CGRectMake(40, 5, 200, 30)];
        _labelText.font=[UIFont systemFontOfSize:15];
        _labelText.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        _labelText.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_labelText];
        
        _afterView=[[UIImageView alloc]initWithFrame:CGRectMake(280, 15, 12, 12)];
        _afterView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_afterView];
        
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_imgView);
    RELEASE_SAFE(_labelText);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
