//
//  MediaPopView.h
//  cw
//
//  Created by LuoHui on 13-12-6.
//
//

#import "PopupView.h"
#import "IconDownLoader.h"

@protocol MediaPopViewDelegate;

@interface MediaPopView : PopupView <IconDownloaderDelegate>
{
    id <MediaPopViewDelegate> delegate;
}

@property (assign, nonatomic) id <MediaPopViewDelegate> delegate;

- (void)addPopupSubviews:(NSArray *)mediaArr;

@end

@protocol MediaPopViewDelegate <NSObject>

@optional
- (void)mediaPopView:(MediaPopView *)view Index:(int)tag;

@end


//#import <UIKit/UIKit.h>
//
//typedef void (^MediaPopViewBlock)(void);
//
//@interface MediaPopView : UIView
//{
//    UIView *_bgView;
//}
//
//@property (copy, nonatomic) MediaPopViewBlock mediaPopViewBlock;
//
//- (void)addPopupSubviews:(UIView *)view media:(NSArray *)mediaArr;
//
//@end
