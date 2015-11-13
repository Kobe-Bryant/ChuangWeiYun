//
//  WeiboViewController.h
//  cw
//
//  Created by yunlai on 13-9-29.
//
//

#import <UIKit/UIKit.h>
#import "SinaWeiboViewController.h"
#import "TencentWeiboViewController.h"
#import "WeiboShare.h"
#import "MBProgressHUD.h"

// 微博类型
typedef enum
{
    WeiboEnumSina,
    WeiboEnumTencent,
    WeiboEnum
}WEIBOENUM;

@interface WeiboViewController : UIViewController <OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate,WeiboShareDelegate,MBProgressHUDDelegate>
{
    UIImage *weiboImage;
    NSString *weiboText;
    
    WEIBOENUM type;
    WeiboShare *weiboShare;
    NSString *strP;
    
    MBProgressHUD *progressHUD;
}

@property (retain, nonatomic) UIImage *weiboImage;
@property (retain, nonatomic) NSString *weiboText;

@property (retain, nonatomic) WeiboShare *weiboShare;
@property (retain, nonatomic) NSString *strP;
@property (retain, nonatomic) MBProgressHUD *progressHUD;

// 微博类型，type = 0 新浪 = 1 腾讯  2 普通评论
@property (assign, nonatomic) WEIBOENUM type;

@end
