//
//  DetailViewDownBar.h
//  cw
//
//  Created by yunlai on 13-8-19.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    SDButtonDBCommets,
    SDButtonDBOrder,
    SDButtonDBLike,
} SDButtonDB;

typedef enum
{
    SDButtonStateInfo,
    SDButtonStateDetail,
} SDState;

typedef enum
{
    SDImageStateSure,
    SDImageStateCanel,
} SDImageState;

typedef enum
{
    SDOrderBtnStateNO,
    SDOrderBtnStateYes,
} SDOrderBtnState;

@protocol DetailViewDownBarDelegate;

@interface DetailViewDownBar : UIView
{
    UIButton *commentsBtn;
    UIButton *orderBtn;
    UIButton *likeBtn;
    
    id <DetailViewDownBarDelegate> delegate;
}

@property (retain ,nonatomic) UIButton *commentsBtn;
@property (retain ,nonatomic) UIButton *orderBtn;
@property (retain ,nonatomic) UIButton *likeBtn;
@property (assign, nonatomic) id <DetailViewDownBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame type:(SDState)type;

- (void)setLikeBtnImageState:(SDImageState)state;

- (void)setOrderBtnState:(SDOrderBtnState)state;

@end

@protocol DetailViewDownBarDelegate <NSObject>

@optional
- (void)detailDownBarEvent:(SDButtonDB)sdButton;

@end