//
//  NetworkFail.h
//  cw
//
//  Created by yunlai on 13-11-7.
//
//

#import <UIKit/UIKit.h>

typedef void (^CwNetworkFailBlock)(void);

typedef enum cwViewType{
    CwTypeViewNormal        = 0,
    CwTypeViewNoNetWork     = 1, // 无网络页面
    CwTypeViewNoCity        = 2, // 城市没分店，选择城市页面
    CwTypeViewNoService     = 3, // 服务器请求超时
    CwTypeViewNoRequest     = 4, // 网络请求超时
    CwTypeViewCloseShop     = 5, // 店铺关闭
    CWTypeViewNoShop        = 6, // 当前分店没商品页面
}CwTypeView;

@protocol NetworkFailDelegate;

@interface NetworkFail : UIView
{
    CwNetworkFailBlock cwNetworkFail;
    
    CwTypeView stateType;
    
    id <NetworkFailDelegate> delegate;
}

@property (assign, nonatomic) id <NetworkFailDelegate> delegate;
@property (copy , nonatomic) CwNetworkFailBlock cwNetworkFail;
@property (assign, nonatomic) CwTypeView stateType;

+ (id)initCreateNetworkView:(UIView *)bgView frame:(CGRect)frame failView:(NetworkFail *)failView delegate:(id)adelegate andType:(CwTypeView)type;

- (void)removeFromSuperviewSelf;

@end

@protocol NetworkFailDelegate <NSObject>

@optional
- (void)networkFailAgain;

- (void)selectCity;

- (void)selectShop;//12.9 chenfeng

@end