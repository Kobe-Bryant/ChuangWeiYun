//
//  PfDetailViewController.h
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "UITableScrollView.h"
#import "ShareAPIAction.h"
#import "PopOtherUnionView.h"
#import "LoginViewController.h"

@interface PfDetailViewController : UIViewController <UITableScrollViewDelagate, HttpRequestDelegate, ShareAPIActionDelegate, PopOtherUnionViewDelegate, LoginViewDelegate>
{
    UITableScrollView *_scrollViewC;
    
    NSMutableArray *dataArr;
    NSString *promotionId;
    
    int clickRow;  
}

//@property (retain, nonatomic) UITableScrollView *scrollViewC;
@property (retain, nonatomic) NSMutableArray *dataArr;
// 优惠券id
@property (retain, nonatomic) NSString *promotionId;
// 得到点击的row
@property (assign, nonatomic) int clickRow;

@end
