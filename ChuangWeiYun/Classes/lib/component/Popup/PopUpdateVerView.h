//
//  PopUpdateVerView.h
//  cw
//
//  Created by yunlai on 13-9-11.
//
//

#import "PopupView.h"

@protocol PopUpdateVerDelegate <NSObject>

-(void)OKCheckUpdate;

@end

@interface PopUpdateVerView : PopupView
{
    id<PopUpdateVerDelegate>delegate;
}
@property(nonatomic, assign)id<PopUpdateVerDelegate>delegate;

- (id)init:(NSString *)marked andBtnTitle:(NSString *)yesTitle andTitle:(NSString *)noTitle;

- (void)closeView;
@end
