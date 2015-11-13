//
//  AfterServiceCell.m
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import "AfterServiceCell.h"
#import "Common.h"

@implementation AfterServiceCell
@synthesize orderNum=_orderNum;
@synthesize orderNumLabel=_orderNumLabel;
@synthesize newstatus=_newstatus;
@synthesize statusLabel=_statusLabel;
@synthesize serviceContent=_serviceContent;
@synthesize statusTime=_statusTime;
@synthesize address=_address;
@synthesize userMobile=_userMobile;
@synthesize userName=_userName;
@synthesize serviceType=_serviceType;


#define kleftpan 15
#define kabovepan 10

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellView=[[UIView alloc]initWithFrame:CGRectMake(kleftpan-5, kabovepan+5, 300, 115)];
        _cellView.layer.borderColor=[UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:0.4].CGColor;
        _cellView.layer.borderWidth=1;
        _cellView.layer.cornerRadius=3;
        _cellView.backgroundColor=[UIColor whiteColor];
        [self.contentView addSubview:_cellView];
        
        _orderNum=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, kabovepan+5, 60, 20)];
        _orderNum.backgroundColor=[UIColor clearColor];
        _orderNum.text=@"单号 :";
        _orderNum.font=[UIFont systemFontOfSize:12];
        _orderNum.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellView addSubview:_orderNum];
        
        _orderNumLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+40, kabovepan+5, 150, 20)];
        _orderNumLabel.backgroundColor=[UIColor clearColor];
        _orderNumLabel.font=[UIFont systemFontOfSize:12];
        _orderNumLabel.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [_cellView addSubview:_orderNumLabel];
        
        
        _serviceType=[[UILabel alloc]initWithFrame:CGRectMake(220, 0, 58, 25)];
        _serviceType.textColor=[UIColor whiteColor];
        _serviceType.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageCwNamed:@"label_member.png"]];
        _serviceType.textAlignment=NSTextAlignmentCenter;
        _serviceType.font=[UIFont systemFontOfSize:12];
        [_cellView addSubview:_serviceType];
        
        _newstatus=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, kabovepan+25, 80, 20)];
        _newstatus.backgroundColor=[UIColor clearColor];
        _newstatus.font=[UIFont systemFontOfSize:12];
        _newstatus.text=@"预约时间 :";
        _newstatus.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellView addSubview:_newstatus];
        
        _statusLabel=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+60, kabovepan+25, 120, 20)];
        _statusLabel.backgroundColor=[UIColor clearColor];
        _statusLabel.font=[UIFont systemFontOfSize:12];
        _statusLabel.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [_cellView addSubview:_statusLabel];
        
        _statusTime=[[UILabel alloc]initWithFrame:CGRectMake(280, kabovepan+25, 60, 20)];
        _statusTime.backgroundColor=[UIColor clearColor];
        _statusTime.font=[UIFont systemFontOfSize:12];
        _statusTime.textColor=[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1];
        [_cellView addSubview:_statusTime];
        
        _userName=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, kabovepan+50, 50, 20)];
        _userName.backgroundColor=[UIColor clearColor];
        _userName.font=[UIFont systemFontOfSize:12];
        _userName.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellView addSubview:_userName];
        
        _userMobile=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan+55, kabovepan+50, 120, 20)];
        _userMobile.backgroundColor=[UIColor clearColor];
        _userMobile.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _userMobile.font=[UIFont systemFontOfSize:12];
        [_cellView addSubview:_userMobile];

        
        
        _address=[[UILabel alloc]initWithFrame:CGRectMake(kleftpan, kabovepan+75, 280, 20)];
        _address.backgroundColor=[UIColor clearColor];
        _address.font=[UIFont systemFontOfSize:12];
        _address.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_cellView addSubview:_address];
        
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_cellView);
    RELEASE_SAFE(_orderNumLabel);
    RELEASE_SAFE(_orderNum);
    RELEASE_SAFE(_newstatus);
    RELEASE_SAFE(_statusLabel);
    RELEASE_SAFE(_statusTime);
    RELEASE_SAFE(_serviceContent);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
