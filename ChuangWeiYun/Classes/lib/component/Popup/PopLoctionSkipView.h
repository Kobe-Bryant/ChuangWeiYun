//
//  PopLoctionSkipView.h
//  cw
//
//  Created by yunlai on 13-10-25.
//
//

#import "PopupView.h"

@protocol PopLoctionSkipViewDelegate;

@interface PopLoctionSkipView : PopupView
{
    UILabel *_textlabel;
    UIButton *_skipBtn;
    UIButton *_goBtn;
    
    id <PopLoctionSkipViewDelegate> delegate;
}

@property (assign, nonatomic) id <PopLoctionSkipViewDelegate> delegate;

- (void)addPopupSubview:(NSString *)locCity city:(NSString *)currCity;

@end

@protocol PopLoctionSkipViewDelegate <NSObject>

@optional
- (void)popLoctionSkipViewClick:(PopLoctionSkipView *)skip;
- (void)popLoctionSkipViewClose:(PopLoctionSkipView *)skip;

@end