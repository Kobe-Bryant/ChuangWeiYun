//
//  CommentsCell.m
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "CommentsCell.h"
#import "Common.h"
#import "PreferentialObject.h"

#define KCommentsCellLeftW  10.f
#define KCommentsCellUpH  10.f
#define KCommentsCellImageWH  45.f

@implementation CommentsCell
@synthesize rtLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_bgView];
        
        _imageV = [[UIImageView alloc]initWithFrame:CGRectZero];
        _imageV.layer.cornerRadius = 22.0f;
        _imageV.layer.masksToBounds = YES;
        [_bgView addSubview:_imageV];
        
        _namelabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _namelabel.backgroundColor = [UIColor clearColor];
        _namelabel.textColor = [UIColor blackColor];
        _namelabel.font = KCWSystemFont(15.f);
        [_bgView addSubview:_namelabel];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = KCWSystemFont(12.f);
        [_bgView addSubview:_timeLabel];

        rtLabel = [[RCLabel alloc] initWithFrame:CGRectZero];
        [rtLabel setBackgroundColor:[UIColor clearColor]];
        [_bgView addSubview:rtLabel];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"commentscell dealloc.......");
    [_imageV release], _imageV = nil;
    [_namelabel release], _namelabel = nil;
    [_bgView release], _bgView = nil;
    [_timeLabel release], _timeLabel = nil;
    [rtLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSDictionary *)dic imgFlag:(BOOL)flag
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    CGFloat height = KCommentsCellUpH;
    CGFloat width = KCommentsCellLeftW;
    
    _imageV.frame = CGRectMake(KCommentsCellLeftW, height, KCommentsCellImageWH, KCommentsCellImageWH);
    
    width += KCommentsCellImageWH + KCommentsCellLeftW;
    
    NSString *name = [dic objectForKey:@"username"];
    if (name.length == 11) {
        _namelabel.text = [NSString stringWithFormat:@"%@****",[name substringWithRange:NSMakeRange(0, 7)]];
    }

    CGSize size = [_namelabel.text sizeWithFont:_namelabel.font];
    _namelabel.frame = CGRectMake(width, height, size.width, size.height);
    
    CGFloat temheight = size.height;
    
    int createTime = [[dic objectForKey:@"created"] intValue];
    
    NSString *dateString = [PreferentialObject getTheDate:createTime symbol:3];
    
    _timeLabel.text = dateString;
    size = [_timeLabel.text sizeWithFont:_timeLabel.font];
    _timeLabel.frame = CGRectMake(KUIScreenWidth - 3*KCommentsCellLeftW - size.width , height, size.width, size.height);
    
    height += temheight;
    
    CGFloat sizeWidth = KUIScreenWidth-3*KCommentsCellLeftW - width;
    
    NSString *text = [dic objectForKey:@"content"];
    size = [text sizeWithFont:KCWSystemFont(13.f)
            constrainedToSize:CGSizeMake(sizeWidth, 1000.f)
                lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.rtLabel setFrame:CGRectMake(width, height + 3, size.width, size.height)];
    NSString *str1 = @"<font size = 14>";
    NSString *str2 = @"</font>";
    NSString *str3 = @"<img src='";
    NSString *str4 = @".png'> ";
    NSString *str =[dic objectForKey:@"content"];
    str = [NSString stringWithFormat:@"%@%@%@",str1,str,str2];
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:str3];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:str4];
    
    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:str];
    self.rtLabel.componentsAndPlainText = componentsDS;
    
    CGSize optimumSize = [self.rtLabel optimumSize];
    [self.rtLabel setFrame:CGRectMake(width, height + 3, sizeWidth - 10, optimumSize.height)]; 

    height += optimumSize.height + 3;
    
    if (height < KCommentsCellImageWH + 2*KCommentsCellUpH) {
        height = KCommentsCellImageWH + 2*KCommentsCellUpH;
    } else {
        height += KCommentsCellUpH;
    }
    
    UIImage *bgimg = nil;
    if (flag) {
        bgimg = [[UIImage imageCwNamed:@"central_form_comments.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    } else {
        bgimg = [[UIImage imageCwNamed:@"next_form_comments.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    }
    _bgView.image = bgimg;
    _bgView.frame = CGRectMake(KCommentsCellLeftW, 0.f, KUIScreenWidth-2*KCommentsCellLeftW, height);
    
    //[pool release];
}

- (void)setImageView:(UIImage *)img
{
    _imageV.image = img;
}

+ (CGFloat)getCellHeight:(NSDictionary *)dict
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    CGFloat height = KCommentsCellUpH;
    CGFloat width = 2*KCommentsCellLeftW + KCommentsCellImageWH;
    CGFloat sizeWidth = KUIScreenWidth-3*KCommentsCellLeftW - width;
    
    NSString *name = [dict objectForKey:@"username"];
    CGSize size = [name sizeWithFont:KCWSystemFont(15.f)];
    
    height += size.height;
    
    NSString *content = [dict objectForKey:@"content"];
    size = [content sizeWithFont:KCWSystemFont(14.f) constrainedToSize:CGSizeMake(sizeWidth, 1000.f) lineBreakMode:NSLineBreakByWordWrapping];

    RCLabel *label = [[RCLabel alloc] initWithFrame:CGRectMake(width, height + 3, size.width, size.height)];
    NSString *str1 = @"<font size = 14>";
    NSString *str2 = @"</font>";
    NSString *str3 = @"<img src='";
    NSString *str4 = @".png'> ";
    NSString *str = [dict objectForKey:@"content"];
    str = [NSString stringWithFormat:@"%@%@%@",str1,str,str2];
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:str3];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:str4];
    
    RTLabelComponentsStructure *componentsDS = [RCLabel extractTextStyle:str];
    label.componentsAndPlainText = componentsDS;
    
    CGSize optimumSize = [label optimumSize];
    [label setFrame:CGRectMake(width, height + 3, sizeWidth, optimumSize.height)];
    //NSLog(@"hui == %f",optimumSize.height);
    [label release];
 
    height += optimumSize.height + 3;
    
    if (height < KCommentsCellImageWH + 2*KCommentsCellUpH) {
        height = KCommentsCellImageWH + 2*KCommentsCellUpH;
    } else {
        height += KCommentsCellUpH;
    }
    //[pool release];
    //NSLog(@"height == %f",height);
    return height;
}
@end
