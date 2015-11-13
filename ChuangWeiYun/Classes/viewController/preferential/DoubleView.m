//
//  DoubleView.m
//  cw
//
//  Created by yunlai on 13-9-17.
//
//

#import "DoubleView.h"
#import "Common.h"

@implementation DoubleView

@synthesize delegate;
@synthesize pro_id;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:_imgView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 5.f, 100.f, 15.f)];
        _titleLabel.backgroundColor = [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:1.f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = KCWSystemFont(12.f);
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
        [tap release], tap = nil;
    }
    return self;
}

// 单机事件
- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    if ([delegate respondsToSelector:@selector(doubleViewClick:pro_id:)]) {
        [delegate doubleViewClick:self pro_id:self.pro_id];
    }
}

- (void)setTitleLabel:(NSString *)text 
{
    _titleLabel.text = text;
}

- (void)setImageView:(UIImage *)img
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGSize imgSie = CGSizeMake(width-20.f, width-20.f);
    CGSize size = [UIImage fitsize:img.size size:imgSie];
    _imgView.frame = CGRectMake(10.f, 25.f, size.width, size.height);
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.image = img;
}

- (void)dealloc
{
    [_titleLabel release], _titleLabel = nil;
    [_imgView release], _imgView = nil;
    self.pro_id = nil;
    [super dealloc];
}

@end
