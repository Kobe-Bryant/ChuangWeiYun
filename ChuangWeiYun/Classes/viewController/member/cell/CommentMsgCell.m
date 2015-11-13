//
//  CommentMsgCell.m
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import "CommentMsgCell.h"

@implementation CommentMsgCell
@synthesize commentTime=_commentTime;
@synthesize content=_content;
@synthesize shopImage=_shopImage;
@synthesize shopAbout=_shopAbout;
@synthesize shopName=_shopName;
@synthesize cellView=_cellView;
@synthesize rtLabel;
@synthesize lineView=_lineView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _cellView=[[UICustomView alloc]initWithFrame:CGRectZero];//CGRectMake(10, 10, 300, 125)
        _cellView.layer.borderColor=[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.6].CGColor;
        _cellView.layer.borderWidth=1;
        _cellView.layer.cornerRadius=3;
        _cellView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:_cellView];
        
        self.backgroundColor = [UIColor clearColor];
        
        _commentTime=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 10)];
        _commentTime.font=[UIFont systemFontOfSize:13];
        _commentTime.backgroundColor=[UIColor clearColor];
        _commentTime.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [_cellView addSubview:_commentTime];
        
        rtLabel = [[RCLabel alloc] initWithFrame:CGRectZero];
        [rtLabel setBackgroundColor:[UIColor clearColor]];
        [_cellView addSubview:rtLabel];
        
//        _content=[[UILabel alloc]initWithFrame:CGRectMake(10, 15, 280, 40)];
//        _content.numberOfLines=0;
//        _content.lineBreakMode=NSLineBreakByWordWrapping;
//        _content.font=[UIFont systemFontOfSize:12];
//        _content.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
//        _content.backgroundColor=[UIColor clearColor];
//        [_cellView addSubview:_content];
        
        //虚线
        _lineView = [[UICutLineView alloc]initWithFrame:CGRectMake(0, 60, 300, 2)];
        _lineView.backgroundColor = [UIColor clearColor];
        [_cellView addSubview:_lineView];
        
        _shopImage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 65, 74, 53)];
        _shopImage.backgroundColor=[UIColor clearColor];
        _shopImage.contentMode = UIViewContentModeScaleAspectFit;
        [_cellView addSubview:_shopImage];
        
        _shopName=[[UILabel alloc]initWithFrame:CGRectMake(90, 65, 180, 20)];
        _shopName.font=[UIFont boldSystemFontOfSize:12];
        _shopName.backgroundColor=[UIColor clearColor];
        _shopName.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellView addSubview:_shopName];
        
        _shopAbout=[[UILabel alloc]initWithFrame:CGRectMake(90, 80, 200, 40)];
        _shopAbout.numberOfLines=0;
        _shopAbout.lineBreakMode=NSLineBreakByTruncatingTail;
        _shopAbout.font=[UIFont systemFontOfSize:12];
        _shopAbout.backgroundColor=[UIColor clearColor];
        _shopAbout.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [_cellView addSubview:_shopAbout];
        
    }
    return self;
}
- (void)dealloc
{
    RELEASE_SAFE(_cellView);
    RELEASE_SAFE(_commentTime);
    RELEASE_SAFE(_shopAbout);
    RELEASE_SAFE(_shopImage);
    RELEASE_SAFE(rtLabel);
    RELEASE_SAFE(_shopName);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
