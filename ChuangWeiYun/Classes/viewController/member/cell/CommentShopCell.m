//
//  CommentShopCell.m
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import "CommentShopCell.h"

#define leftSpan 10

@implementation CommentShopCell

@synthesize commentTime=_commentTime;
@synthesize content=_content;
@synthesize shopImage=_shopImage;
@synthesize shopAbout=_shopAbout;
@synthesize typeNum=_typeNum;
@synthesize cellView=_cellView;
@synthesize rtLabel;
@synthesize lineView=_lineView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _cellView=[[UICustomView alloc]initWithFrame:CGRectZero];//CGRectMake(leftSpan, 10, 300, 140)
        _cellView.layer.borderColor=[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.6].CGColor;
        _cellView.layer.borderWidth=1;
        _cellView.layer.cornerRadius=3;
        _cellView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:_cellView];
        
        self.backgroundColor = [UIColor clearColor];
        
        _commentTime=[[UILabel alloc]initWithFrame:CGRectMake(leftSpan, 10, 200, 10)];
        _commentTime.font=[UIFont systemFontOfSize:13];
        _commentTime.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        _commentTime.backgroundColor=[UIColor clearColor];
        [_cellView addSubview:_commentTime];
        
        
        rtLabel = [[RCLabel alloc] initWithFrame:CGRectZero];
        [rtLabel setBackgroundColor:[UIColor clearColor]];
        [_cellView addSubview:rtLabel];
        
        
//        _content=[[UILabel alloc]initWithFrame:CGRectZero];//CGRectMake(leftSpan, 25, 280, 30)
//        _content.numberOfLines=0;
//        _content.lineBreakMode=NSLineBreakByWordWrapping;
//        _content.textAlignment = NSTextAlignmentLeft;
//        _content.font=[UIFont systemFontOfSize:12];
//        _content.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
//        _content.backgroundColor=[UIColor clearColor];
//        [_cellView addSubview:_content];
        
        
        _typeNum=[[UILabel alloc]initWithFrame:CGRectMake(0, 70, 83, 16)];
        _typeNum.backgroundColor=[UIColor colorWithRed:130/255.0 green:130/255.0 blue:131/255.0 alpha:1];
        _typeNum.textColor=[UIColor whiteColor];
        _typeNum.textAlignment=NSTextAlignmentCenter;
        _typeNum.font=[UIFont systemFontOfSize:10];
        [_cellView addSubview:_typeNum];
        
        //虚线
        _lineView = [[UICutLineView alloc]initWithFrame:CGRectMake(0, 83, 300, 2)];
        _lineView.backgroundColor = [UIColor clearColor];
        [_cellView addSubview:_lineView];
        
        _shopImage=[[UIImageView alloc]initWithFrame:CGRectMake(leftSpan, 88, 74, 50)];
        _shopImage.backgroundColor=[UIColor clearColor];
        _shopImage.contentMode = UIViewContentModeScaleAspectFit;
        [_cellView addSubview:_shopImage];
        
        _shopAbout=[[UILabel alloc]initWithFrame:CGRectMake(90, 90, 205, 40)];
        _shopAbout.numberOfLines=0;
        _shopAbout.lineBreakMode=NSLineBreakByTruncatingTail;
        _shopAbout.font=[UIFont systemFontOfSize:12];
        _shopAbout.backgroundColor=[UIColor clearColor];
        _shopAbout.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [_cellView addSubview:_shopAbout];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc
{
    RELEASE_SAFE(_cellView);
    RELEASE_SAFE(_commentTime);
    RELEASE_SAFE(_shopAbout);
    RELEASE_SAFE(_shopImage);
//    RELEASE_SAFE(_content);
    RELEASE_SAFE(_typeNum);
    RELEASE_SAFE(rtLabel);
    [super dealloc];
}
@end
