//
//  PfImageView.h
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import <UIKit/UIKit.h>

@interface PfImageView : UIImageView
{
    UILabel *titellabel;
    UILabel *moneylabel;
    UILabel *pfLabel;
    UILabel *usefullabel;
    UILabel *startlabel;
    UILabel *endlabel;
    UIImageView *imgView;
}

// 优惠券标题
@property (retain, nonatomic) UILabel *titellabel;
// 优惠券金钱
@property (retain, nonatomic) UILabel *moneylabel;
// 优惠券
@property (retain, nonatomic) UILabel *pfLabel;
// 优惠券有效期
@property (retain, nonatomic) UILabel *usefullabel;
// 优惠券开始时间
@property (retain, nonatomic) UILabel *startlabel;
// 优惠券结束时间
@property (retain, nonatomic) UILabel *endlabel;
// 优惠券是否可用标签
@property (retain, nonatomic) UIImageView *imgView;

- (void)setImgViewImg:(UIImage *)img hide:(BOOL)hide;

@end
