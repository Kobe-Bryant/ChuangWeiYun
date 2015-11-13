//
//  DoubleView.h
//  cw
//
//  Created by yunlai on 13-9-17.
//
//

#import <UIKit/UIKit.h>

@protocol DoubleViewDelegate;

@interface DoubleView : UIView
{
    UILabel *_titleLabel;
    UIImageView *_imgView;
    
    id <DoubleViewDelegate> delegate;
}

@property (assign, nonatomic) id <DoubleViewDelegate> delegate;

@property (retain, nonatomic) NSString *pro_id;

- (void)setImageView:(UIImage *)img;

- (void)setTitleLabel:(NSString *)text;

@end


@protocol DoubleViewDelegate <NSObject>

@optional
- (void)doubleViewClick:(DoubleView *)doubleView pro_id:(NSString *)proid;

@end