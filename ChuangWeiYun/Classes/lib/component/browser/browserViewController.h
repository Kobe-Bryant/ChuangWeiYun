//
//  browserViewController.h
//  yunPai
//
//  Created by LuoHui on 13-7-16.
//
//

#import <UIKit/UIKit.h>
#import "ShareAPIAction.h"
#import "MBProgressHUD.h"

@protocol browserAddDelegate <NSObject>
- (void)addToContent:(NSString *)infoId;
@end

@class cloudLoadingView;

@interface browserViewController : UIViewController <UIWebViewDelegate,UIScrollViewDelegate,ShareAPIActionDelegate,MBProgressHUDDelegate>
{
    UIWebView *webView;
	NSString *url;
    NSString *webTitle;
    UIImage *shareImage;
	cloudLoadingView *cloudLoading;
    UILabel *loadingLabel;
    BOOL _isHideToolBar;
    
    UIButton *lastBtn;
    UIButton *nextBtn;
    UIButton *shareBtn;
    
    UIImageView *toolBarView;
    int lastContentOffsetY;
    
    BOOL _isFromList;
    NSString *listInfoId;
    id <browserAddDelegate> delegate;
    
    UIButton *addButton;
    MBProgressHUD *progressHUDTmp;
    
    BOOL _isFromAbout;
    BOOL isAnimation;
}
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *webTitle;
@property (nonatomic, retain) UIImage *shareImage;
@property (nonatomic, retain) cloudLoadingView *cloudLoading;
@property (nonatomic, assign) BOOL isHideToolBar;
@property (nonatomic, assign) BOOL isFromList;
@property (nonatomic, retain) NSString *listInfoId;
@property (nonatomic, assign) id <browserAddDelegate> delegate;
@property (nonatomic, assign) BOOL isFromAbout;

@property (nonatomic, assign) BOOL isFromService;
@end
