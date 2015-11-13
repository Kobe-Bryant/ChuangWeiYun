//
//  PopBookSucceedView.h
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import "PopupView.h"

@protocol PopBookSucceedViewDelegate;

@interface PopBookSucceedView : PopupView
{
    id <PopBookSucceedViewDelegate> delegate;
}

@property (assign, nonatomic) id <PopBookSucceedViewDelegate> delegate;

@end

@protocol PopBookSucceedViewDelegate <NSObject>

@optional
- (void)PopBookSucceedViewClick:(PopBookSucceedView *)popBookView;

@end