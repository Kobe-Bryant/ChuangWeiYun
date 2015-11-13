//
//  PopLikeView.h
//  cw
//
//  Created by yunlai on 13-9-22.
//
//

#import "PopupView.h"

typedef enum
{
    PopLikeEnumAdd,
    PopLikeEnumMinusAdd,
} PopLikeEnum;

@interface PopLikeView : PopupView
{
    UIImageView *imgView;
}

- (void)addPopupSubviewType:(PopLikeEnum)type;

@end
