//
//  ShopDetailsViewController.h
//  cw
//
//  Created by yunlai on 13-8-15.
//
//

#import <UIKit/UIKit.h>

#import "OrderShopViewController.h"
#import "LoginViewController.h"
#import "ShopDetailsView.h"
#import "UITableScrollView.h"
#import "DetailViewDownBar.h"
#import "ShareAPIAction.h"
#import "WeiboView.h"
#import "Global.h"

@protocol ShopDetailsViewControllerDelegate;

@interface ShopDetailsViewController : UIViewController <UITableScrollViewDelagate,DetailViewDownBarDelegate,ShareAPIActionDelegate,WeiboViewDelegate, OrderShopViewControllerDelegate, ShopDetailsViewDelegate, LoginViewDelegate>
{
    UITableScrollView *_scrollViewC;
    DetailViewDownBar *_downBarView;
    
    NSMutableArray *dataArr;
    
    int clickNum;
    NSString *productID;
    
    CwStatusType cwStatusType;
    
    id <ShopDetailsViewControllerDelegate> delegate;
}

@property (retain, nonatomic) UITableScrollView *scrollViewC;
@property (retain, nonatomic) DetailViewDownBar *downBarView;

// 如果数组为空，则表示是需要单个商品请求的，从上个页面传入
@property (retain, nonatomic) NSMutableArray *dataArr;
// 选中的产品，在数组中的位置，默认为0  需要从上个页面传入
@property (assign, nonatomic) int clickNum;
// 单个商品请求的时候用到，需要从上个页面传入
@property (retain, nonatomic) NSString *productID;
// 预定详情用到，需要从上个页面传入
@property (retain, nonatomic) NSString *shop_ID;

@property (assign, nonatomic) BOOL isEnd;
// 其他页面进入到详情的状态类型
@property (assign, nonatomic) CwStatusType cwStatusType;

@property (assign, nonatomic) id <ShopDetailsViewControllerDelegate> delegate;

@end

@protocol ShopDetailsViewControllerDelegate <NSObject>

@optional
- (void)shopDetailsViewLikeNum:(BOOL)islike;
// 12.4 chenfeng
- (void)isShopDelLikeSelectRow:(NSNumber *)num;

@end
