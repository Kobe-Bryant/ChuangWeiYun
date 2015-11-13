//
//  PopPfShareView.h
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import "PopupView.h"

typedef void (^CwPfShareBlock)(void);

@class PfImageView;
@protocol PopPfShareViewDelegate;

@interface PopPfShareView : PopupView
{
    PfImageView *pfimage;
    
    id <PopPfShareViewDelegate> delegate;
    
    CwPfShareBlock pfShareBlock;
    
    int shareType;
}

@property (assign, nonatomic) id <PopPfShareViewDelegate> delegate;

@property (copy, nonatomic) CwPfShareBlock pfShareBlock;

@property (assign, nonatomic) int shareType;

- (id)initType:(int)type;

- (void)addPopupSubview:(NSDictionary *)dict;

@end


@protocol PopPfShareViewDelegate <NSObject>

@optional
- (void)popPfShareViewClick:(int)type;

@end