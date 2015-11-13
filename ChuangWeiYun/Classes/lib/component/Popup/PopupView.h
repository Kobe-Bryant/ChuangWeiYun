//
//  PopupView.h
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView
{
    UIView *popupView;
}

// 子类创建的视图需要放置到此view上面
@property (retain, nonatomic) UIView *popupView;

// 需要子类来继承
- (void)addPopupSubview;

- (void)addPopupSubview:(int)animationType;

@end
