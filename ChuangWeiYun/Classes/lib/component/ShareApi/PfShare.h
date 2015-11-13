//
//  PfShare.h
//  cw
//
//  Created by yunlai on 13-9-30.
//
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "PopPfShareView.h"
#import "HttpRequest.h"

typedef enum
{
    Share_Get_Pf_Normal,        
    Share_Get_Pf_Info,          // 资讯分享
    Share_Get_Pf_Pf,            // 优惠分享
    Share_Get_Pf_Shop,          // 商品分享
    Share_Get_Pf_ShopCen,       // 产品商品分享
    Share_Get_Pf_Box,           // 好友分享
}Share_Get_Pf;

@class PopPfShareFail;

@interface PfShare : NSObject <PopPfShareViewDelegate,HttpRequestDelegate,LoginViewDelegate>
{
    PopPfShareView *shareView;
    PopPfShareFail *pfshare;
    
    Share_Get_Pf getPf;
    // 商品是否可以被分享
    int share_gift;
    
    int pfFlag;
}

@property (assign, nonatomic) Share_Get_Pf getPf;
@property (assign, nonatomic) int share_gift;

+ (PfShare *)defaultSingle;

- (void)pfShareRequest;

@end
