//
//  PfImageView.m
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import "PfImageView.h"

#define PfImageViewUpH          10.f
#define PfImageViewLeftW        10.f
#define PfImgFontSize12         12.f
#define PfImgFontSize30         30.f
#define PfImgFontSize17         17.f

@implementation PfImageView

@synthesize titellabel;
@synthesize moneylabel;
@synthesize pfLabel;
@synthesize usefullabel;
@synthesize startlabel;
@synthesize endlabel;
@synthesize imgView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat height = PfImageViewUpH;
        
        // 优惠券的标题
        titellabel = [[UILabel alloc]initWithFrame:CGRectMake(PfImageViewLeftW, height, CGRectGetWidth(self.frame) - 2*PfImageViewLeftW - 80.f, 20.f)];
        titellabel.backgroundColor = [UIColor clearColor];
        titellabel.textColor = [UIColor whiteColor];
        titellabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titellabel.font = KCWSystemFont(PfImgFontSize12);
        [self addSubview:titellabel];
        
        height += 20.f;
        
        // 优惠券的价格
        moneylabel = [[UILabel alloc]initWithFrame:CGRectMake(PfImageViewLeftW, height, 90.f, 30.f)];
        moneylabel.backgroundColor = [UIColor clearColor];
        moneylabel.textColor = [UIColor whiteColor];
        moneylabel.font = KCWboldSystemFont(PfImgFontSize30);
        [self addSubview:moneylabel];
        
        CGFloat frontw = PfImageViewLeftW + 90.f;
        // 优惠券
        pfLabel = [[UILabel alloc]initWithFrame:CGRectMake(frontw, height, 90.f, 30.f)];
        pfLabel.backgroundColor = [UIColor clearColor];
        pfLabel.textColor = [UIColor whiteColor];
        pfLabel.font = KCWSystemFont(PfImgFontSize17);
        pfLabel.text = @"优惠券";
        [self addSubview:pfLabel];
        
        CGFloat height2 = 3*PfImageViewUpH/2;
        frontw += 90.f;
        
        // 有效期
        usefullabel = [[UILabel alloc]initWithFrame:CGRectMake(frontw, height2, 90.f, 15.f)];
        usefullabel.backgroundColor = [UIColor clearColor];
        usefullabel.textColor = [UIColor whiteColor];
        usefullabel.textAlignment = NSTextAlignmentRight;
        usefullabel.font = KCWSystemFont(PfImgFontSize12);
        usefullabel.text = @"有效期";
        [self addSubview:usefullabel];
        
        height2 += 15.f;
        
        // 起始时间
        startlabel = [[UILabel alloc]initWithFrame:CGRectMake(frontw, height2, 90.f, 15.f)];
        startlabel.backgroundColor = [UIColor clearColor];
        startlabel.textColor = [UIColor whiteColor];
        startlabel.textAlignment = NSTextAlignmentRight;
        startlabel.font = KCWSystemFont(PfImgFontSize12);
        [self addSubview:startlabel];
        
        height2 += 15.f;
        
        // 结束时间
        endlabel = [[UILabel alloc]initWithFrame:CGRectMake(frontw, height2, 90.f, 15.f)];
        endlabel.backgroundColor = [UIColor clearColor];
        endlabel.textColor = [UIColor whiteColor];
        endlabel.textAlignment = NSTextAlignmentRight;
        endlabel.font = KCWSystemFont(PfImgFontSize12);
        [self addSubview:endlabel];
        
        imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imgView.hidden = YES;
        [self addSubview:imgView];
    }
    return self;
}

- (void)setImgViewImg:(UIImage *)img hide:(BOOL)hide
{
    imgView.hidden = hide;
    CGFloat x = 2*CGRectGetWidth(self.frame)/3;
    CGFloat y = CGRectGetHeight(self.frame)/2 - img.size.height/2;
    imgView.frame = CGRectMake(x, y, img.size.width, img.size.height);
    imgView.image = img;
}


- (void)dealloc
{
    self.titellabel = nil;
    self.moneylabel = nil;
    self.pfLabel = nil;
    self.usefullabel = nil;
    self.startlabel = nil;
    self.endlabel = nil;
    self.imgView = nil;
    
    [super dealloc];
}

@end
