//
//  PopClearChcheView.h
//  cw
//
//  Created by yunlai on 13-11-6.
//
//

#import "PopupView.h"


@protocol PopChearDelegate <NSObject>

-(void)OKClearChche;

@end

@interface PopClearChcheView : PopupView
{
    id<PopChearDelegate>delegate;
}
@property(nonatomic, assign)id<PopChearDelegate>delegate;

- (id)init:(NSString *)marked andBtnTitle:(NSString *)yesTitle andTitle:(NSString *)noTitle;

- (void)closeView;
@end
