//
//  PopOtherUnionView.h
//  cw
//
//  Created by yunlai on 13-9-13.
//
//

#import "PopupView.h"

@protocol PopOtherUnionViewDelegate;

@interface PopOtherUnionView : PopupView <UITextFieldDelegate>
{
    UITextField *_codeText;
    UITextField *_phoneText;
    
    id <PopOtherUnionViewDelegate> delegate;
}

@property (assign, nonatomic) id <PopOtherUnionViewDelegate> delegate;

@end

@protocol PopOtherUnionViewDelegate <NSObject>

@optional
// 异业联盟获取优惠券
- (void)getOtherUnionCoupons:(NSString *)code phone:(NSString *)phone;

@end
