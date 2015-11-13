//
//  SinaWeiboViewController.h
//  yunPai
//
//  Created by yunlai on 13-7-17.
//
//

#import <UIKit/UIKit.h>

#import "SinaWeibo.h"
#import "cwAppDelegate.h"

@protocol OauthSinaWeiSuccessDelegate <NSObject>

@required
- (void)oauthSinaSuccessIsFail:(BOOL)isSuccess;

@end

@interface SinaWeiboViewController : UIViewController <SinaWeiboDelegate,SinaWeiboRequestDelegate,APPlicationDelegate>
{
    SinaWeibo *sinaWeibo;

    BOOL _isRequest;
    
    id <OauthSinaWeiSuccessDelegate> delegate;
}

@property (retain, nonatomic) SinaWeibo *sinaWeibo;
@property (nonatomic ,assign) BOOL isRequest;
// 授权成功会调用此委托
@property (assign, nonatomic) id <OauthSinaWeiSuccessDelegate> delegate;


@end
