//
//  PopCheckUpdateView.h
//  cw
//
//  Created by yunlai on 13-9-26.
//
//

#import "PopupView.h"

@protocol PopUpdateCheckDelegate <NSObject>

-(void)OKCheckUpdates;

@end



@interface PopCheckUpdateView : PopupView
{
    id<PopUpdateCheckDelegate>delegate;
}
@property(nonatomic, assign)id<PopUpdateCheckDelegate>delegate;

- (id)initWithTitle:(NSString *)titleStr andContent:(NSString *)marked andBtnTitle:(NSString *)yesTitle andTitle:(NSString *)noTitle;

- (void)closeView;
@end
