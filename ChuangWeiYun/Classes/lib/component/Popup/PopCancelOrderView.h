//
//  PopCancelOrderView.h
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import "PopupView.h"

@protocol PopCancelOrderDelegate <NSObject>

-(void)OKCancel;

@end

@interface PopCancelOrderView : PopupView
{
    id<PopCancelOrderDelegate>delegate;
}
@property(nonatomic, assign)id<PopCancelOrderDelegate>delegate;

- (void)closeView;

@end
