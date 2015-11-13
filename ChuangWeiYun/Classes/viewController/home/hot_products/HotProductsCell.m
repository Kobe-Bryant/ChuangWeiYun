//
//  HotProductsCell.m
//  cw
//
//  Created by LuoHui on 13-8-26.
//
//

#import "HotProductsCell.h"
#import "UIImageScale.h"

@implementation HotProductsCell
@synthesize pNameLabel = _pNameLabel;
@synthesize pImageView = _pImageView;
@synthesize pLoveLabel = _pLoveLabel;
@synthesize pOrderLabel = _pOrderLabel;
@synthesize pContent = _pContent;
@synthesize indexLabel = _indexLabel;
@synthesize goButton;
@synthesize cellDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier with:(float)height
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _pImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        _pImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_pImageView];
        
        _pNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 90, 20)];
        _pNameLabel.backgroundColor = [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:0.5f];
        _pNameLabel.textColor = [UIColor whiteColor];
        _pNameLabel.text = @"";
        _pNameLabel.textAlignment = UITextAlignmentCenter;
        _pNameLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:_pNameLabel];
        
        UIView *_maskView = [[UIView alloc]initWithFrame:CGRectZero];
        _maskView.frame = CGRectMake(0.f, CGRectGetMaxY(_pImageView.frame), KUIScreenWidth, 30.f);
        _maskView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_maskView];
        
        UIImage *loveImg = [UIImage imageCwNamed:@"icon_like_store.png"];
        UIImageView *loveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, (_maskView.frame.size.height - loveImg.size.height) * 0.5, loveImg.size.width, loveImg.size.height)];
        loveImageView.image = loveImg;
        [_maskView addSubview:loveImageView];
        [loveImageView release];
        
        _pLoveLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(loveImageView.frame) + 5, loveImageView.frame.origin.y, 50, loveImageView.frame.size.height)];
        _pLoveLabel.backgroundColor = [UIColor clearColor];
        _pLoveLabel.textColor = [UIColor darkGrayColor];
        _pLoveLabel.text = @"56";
        _pLoveLabel.font = [UIFont systemFontOfSize:14.0f];
        [_maskView addSubview:_pLoveLabel];
        
        UIImage *orderImg = [UIImage imageCwNamed:@"icon_cart_store.png"];
        UIImageView *orderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(210, loveImageView.frame.origin.y, orderImg.size.width, orderImg.size.height)];
        orderImageView.image = orderImg;
        [_maskView addSubview:orderImageView];
        [orderImageView release];
        
        _pOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orderImageView.frame) + 5, loveImageView.frame.origin.y, 50, loveImageView.frame.size.height)];
        _pOrderLabel.backgroundColor = [UIColor clearColor];
        _pOrderLabel.textColor = [UIColor darkGrayColor];
        _pOrderLabel.text = @"19";
        _pOrderLabel.font = [UIFont systemFontOfSize:14.0f];
        [_maskView addSubview:_pOrderLabel];
        
        [_maskView release];
        
        goButton = [UIButton buttonWithType:UIButtonTypeCustom];
        goButton.frame = CGRectMake(0, 0, 320, 270);
        goButton.backgroundColor = [UIColor clearColor];
        [goButton addTarget:self action:@selector(goToAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:goButton];
        
//        UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, goButton.frame.size.width, goButton.frame.size.height)];
//        strLabel.backgroundColor = [UIColor clearColor];
//        strLabel.textColor = [UIColor whiteColor];
//        strLabel.text = @"去最近的店看看";
//        strLabel.font = [UIFont systemFontOfSize:16.0f];
//        strLabel.textAlignment = UITextAlignmentCenter;
//        [goButton addSubview:strLabel];
//        [strLabel release];
        
        UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_maskView.frame), 320, height - 50 - CGRectGetMaxY(_maskView.frame))];
        grayView.backgroundColor = [UIColor colorWithRed:0.9333 green:0.9333 blue:0.9333 alpha:1.0];
        [self.contentView addSubview:grayView];
        
        // 11. 15 chenfeng
        _pContent = [[UIWebView alloc] initWithFrame:CGRectMake(10, 12, 300, grayView.frame.size.height - 20)];
        _pContent.backgroundColor = [UIColor clearColor];
        _pContent.opaque = NO;
        _pContent.scrollView.scrollEnabled=NO;
        [grayView addSubview:_pContent];
        
//        _pContent.textColor =  [UIColor colorWithRed:0.211 green:0.211 blue:0.211 alpha:1.0];
//        _pContent.text = @"";
//        _pContent.font = [UIFont systemFontOfSize:17.f];
//        _pContent.editable = NO;
//        _pContent.scrollEnabled = NO;
        
        
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_pContent.frame) - 5, 300, 15)];
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor grayColor];
        _indexLabel.text = @"";
        _indexLabel.font = [UIFont systemFontOfSize:12.0f];
        _indexLabel.textAlignment = UITextAlignmentCenter;
        [grayView addSubview:_indexLabel];
        
        [grayView release];
        
    }
    return self;
}

- (void)dealloc
{
    [_pNameLabel release];
    [_pImageView release];
    [_pLoveLabel release];
    [_pOrderLabel release];
    [_pContent release];
    [_indexLabel release];
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)goToAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (cellDelegate != nil && [cellDelegate respondsToSelector:@selector(goToSee:)]) {
        [cellDelegate goToSee:btn];
    }
}
@end
