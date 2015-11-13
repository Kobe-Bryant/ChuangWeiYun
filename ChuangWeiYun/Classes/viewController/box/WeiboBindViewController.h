//
//  WeiboBindViewController.h
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import <UIKit/UIKit.h>
#import "SinaWeiboViewController.h"
#import "TencentWeiboViewController.h"
#import "SevenSwitch.h"

@interface WeiboBindViewController : UIViewController<OauthSinaWeiSuccessDelegate,OauthTencentWeiSuccessDelegate>
{
    //新浪开关
    SevenSwitch     *_sinaSwitch;
    //腾讯开关
    SevenSwitch     *_tencentSwitch;
    
    NSMutableArray  *sinaItems;
    NSMutableArray  *tencentItems;
}
@property(nonatomic ,retain) NSMutableArray *sinaItems;
@property(nonatomic ,retain) NSMutableArray *tencentItems;

//sina微博设置
- (void)sinaSwitchChanged:(id)sender;

//tencent微博设置
- (void)tencentSwitchChanged:(id)sender;


@end
