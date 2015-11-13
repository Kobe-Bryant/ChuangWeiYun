//
//  NetworkFail.m
//  cw
//
//  Created by yunlai on 13-11-7.
//
//

#import "NetworkFail.h"
#import "Global.h"

@implementation NetworkFail

@synthesize cwNetworkFail;
@synthesize delegate;
@synthesize stateType;

// 移出视图
- (void)removeSelfSubviews
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

- (id)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)addCreateViewFrame:(CGRect)frame delegate:(id)adelegate andCwType:(CwTypeView)type
{
    [self removeSelfSubviews];
    
    self.delegate = adelegate;
    
    self.frame = frame;
    
    self.stateType = type;

    UIImageView *_imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self addSubview:_imgView];
    
    UILabel *_label = [[UILabel alloc]initWithFrame:CGRectZero];
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor colorWithRed:191/255.f green:191/255.f blue:191/255.0f alpha:1];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    _label.font = [UIFont systemFontOfSize:15.f];
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_label];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 5;
    btn.backgroundColor = [UIColor colorWithRed:0/255.0 green:106/255.0 blue:193/255.0 alpha:1];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

    CGFloat width = CGRectGetWidth(frame) - 100.f;
    CGFloat height = CGRectGetHeight(frame)/4;
    NSString *str = nil;
    UIImage *img = nil;
    if (type == CwTypeViewNoNetWork) {
        img = [UIImage imageNamed:@"icon_prompt_default2.png"];
        _imgView.frame = CGRectMake(KUIScreenWidth/2-img.size.width/2, height, img.size.width, img.size.height);
        str = @"请检查您的手机是否联网\n点击按钮重新加载";
    } else if (type == CwTypeViewNoCity){
        img = [UIImage imageNamed:@"icon_noshop_default.png"];
        _imgView.frame = CGRectMake(KUIScreenWidth/2-img.size.width/2, height, img.size.width, img.size.height);
        str = @"当前城市暂未开通分店\n请选择其他城市";
    } else if (type == CwTypeViewNoService) {
        img = [UIImage imageNamed:@"icon_prompt_default.png"];
        _imgView.frame = CGRectMake(KUIScreenWidth/2-img.size.width/2, height, img.size.width, img.size.height);
        str = @"服务器繁忙，请稍后再试";
    } else if (type == CwTypeViewNoRequest){
        img = [UIImage imageNamed:@"icon_prompt_default.png"];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.frame = CGRectMake(KUIScreenWidth/2-img.size.width/2+5, height, img.size.width-10, img.size.height-10);
        str = @"网络繁忙，请稍后再试";
    } else if (type == CwTypeViewCloseShop) {
        img = [UIImage imageNamed:@"icon_prompt_default.png"];
        _imgView.frame = CGRectMake(KUIScreenWidth/2-img.size.width/2, height, img.size.width, img.size.height);
        str = @"店铺已经关闭，请选择其他店铺继续浏览";
    }else if (type == CWTypeViewNoShop) {// 12.8 chenfeng
        img = [UIImage imageNamed:@"icon_class_default.png"];
        _imgView.frame = CGRectMake(KUIScreenWidth/2-img.size.width/2, height, img.size.width, img.size.height);
        str = @"当前分店无商品，请选择其他分店";
    }
    
    height += img.size.height + 13.f;
    
    _imgView.image = img;
    [_imgView release];
    
    _label.text = str;
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:15.f] constrainedToSize:CGSizeMake(width, 1000.f)];
    _label.frame = CGRectMake(50.f, height, width+10, size.height);
    [_label release];
    
    height += size.height + 13.f;

    if (type == CwTypeViewNoNetWork || type == CwTypeViewNoRequest) {
        [btn setTitle:@"重新加载" forState:UIControlStateNormal];
        btn.tag = 1;
        btn.frame = CGRectMake(95.f, height, 130.f, 40.f);
    } else if (type == CwTypeViewNoCity) {
        [btn setTitle:@"选择其他城市" forState:UIControlStateNormal];
        btn.tag = 2;
        btn.frame = CGRectMake(95.f, height, 130.f, 40.f);
    }else if (type == CWTypeViewNoShop) { // 12.9 chenfeng
        [btn setTitle:@"切换分店" forState:UIControlStateNormal];
        btn.tag = 3;
        btn.frame = CGRectMake(95.f, height, 130.f, 40.f);
    }
}

+ (id)initCreateNetworkView:(UIView *)bgView frame:(CGRect)frame failView:(NetworkFail *)failView delegate:(id)adelegate andType:(CwTypeView)type
{
    if (failView == nil) {
        failView = [[NetworkFail alloc]init];
    }
    [failView addCreateViewFrame:frame delegate:adelegate andCwType:type];
    [bgView addSubview:failView];
    
    return failView;
}

- (void)btnClick:(UIButton *)btn
{
    if (btn.tag == 1) {
        if ([delegate respondsToSelector:@selector(networkFailAgain)] && delegate != nil) {
            [delegate networkFailAgain];
        }
        [self removeFromSuperviewSelf];
    }else if (btn.tag == 2){
        if ([delegate respondsToSelector:@selector(selectCity)] && delegate != nil) {
            [delegate selectCity];
        }
        [self removeFromSuperviewSelf];
    }else if (btn.tag == 3){
        if ([delegate respondsToSelector:@selector(selectShop)] && delegate != nil) {
            [delegate selectShop];
        }
    }
}

- (void)removeFromSuperviewSelf
{
    [self removeFromSuperview];
    self.cwNetworkFail();
}

- (void)dealloc
{
    //self.cwNetworkFail = nil;
    [super dealloc];
}

@end
