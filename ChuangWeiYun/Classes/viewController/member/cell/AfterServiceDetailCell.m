//
//  AfterServiceDetailCell.m
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import "AfterServiceDetailCell.h"
#import "Common.h"

@implementation AfterServiceDetailCell

@synthesize imgView=_imgView;
@synthesize line=_line;
@synthesize contentLabel=_contentLabel;
@synthesize serviceTime=_serviceTime;
@synthesize beyondCycle=_beyondCycle;
@synthesize normalCycle=_normalCycle;

#define kleftPan 20
#define kabovePan 15

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *aboveLine=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 1)];
        aboveLine.backgroundColor=[UIColor colorWithRed:167/255.0 green:167/255.0 blue:167/255.0 alpha:0.3];
        [self.contentView addSubview:aboveLine];
        RELEASE_SAFE(aboveLine);
        
        UIView *cellView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        [self.contentView addSubview:cellView];
        
        
        _imgView=[[UIImageView alloc]initWithFrame:CGRectMake(kleftPan, kabovePan, 30, 30)];
        _imgView.backgroundColor=[UIColor clearColor];
        _imgView.image=[UIImage imageCwNamed:@"past_member.png"];
        [self.contentView addSubview:_imgView];
        
        _line=[[UILabel alloc]initWithFrame:CGRectMake(_imgView.center.x, _imgView.center.y, 2, 90-_imgView.center.y)];
        _line.backgroundColor=[UIColor colorWithRed:182/255.0 green:182/255.0 blue:182/255.0 alpha:1];
//        _line.layer.borderColor=[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:0.7].CGColor;
    
        [cellView addSubview:_line];
        
        _contentLabel=[[UILabel alloc]initWithFrame:CGRectZero];
        _contentLabel.backgroundColor=[UIColor clearColor];
        _contentLabel.font=[UIFont systemFontOfSize:13];
        _contentLabel.numberOfLines=0;
        _contentLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.contentView addSubview:_contentLabel];
        
        _serviceTime=[[UILabel alloc]initWithFrame:CGRectMake(_imgView.center.x*2, kabovePan, 220, 20)];
        _serviceTime.backgroundColor=[UIColor clearColor];
        _serviceTime.font=[UIFont systemFontOfSize:12];
        _serviceTime.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.contentView addSubview:_serviceTime];
        
        _normalCycle=[[UILabel alloc]initWithFrame:CGRectMake(_imgView.center.x*2, kabovePan+65, 100, 20)];
        _normalCycle.backgroundColor=[UIColor clearColor];
        _normalCycle.font=[UIFont systemFontOfSize:12];
        _normalCycle.hidden=YES;
        _normalCycle.textColor=[UIColor colorWithRed:157/255.0 green:157/255.0 blue:157/255.0 alpha:1];
        [self.contentView addSubview:_normalCycle];
        
        _beyondCycle=[[UILabel alloc]initWithFrame:CGRectMake(_imgView.center.x*2+100, kabovePan+65, 100, 20)];
        _beyondCycle.backgroundColor=[UIColor clearColor];
        _beyondCycle.font=[UIFont systemFontOfSize:15];
        _beyondCycle.hidden=YES;
        _beyondCycle.textColor=[UIColor colorWithRed:244/255.0 green:33/255.0 blue:49/255.0 alpha:1];
        [self.contentView addSubview:_beyondCycle];
        
        RELEASE_SAFE(cellView);
    }
    return self;
}
- (void)dealloc
{
    RELEASE_SAFE(_imgView);
    RELEASE_SAFE(_line);
    RELEASE_SAFE(_contentLabel);
    RELEASE_SAFE(_serviceTime);
    RELEASE_SAFE(_normalCycle);
    RELEASE_SAFE(_beyondCycle);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
