//
//  CouponsViewController.h
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "LoadTableView.h"
#import "NullstatusView.h"
#import "HttpRequest.h"

@protocol CouponsViewControllerDelegate;

@interface CouponsViewController : UIViewController <LoadTableViewDelegate,HttpRequestDelegate>
{
    CwStatusType cwStatusType;
    //空状态视图
    NullstatusView  *_nullView;
    
    NSMutableArray *dataArr;
    
    NSString *shopID;
    
    NSString *productID;
    
    id <CouponsViewControllerDelegate> delegate;
}

// 其他页面进入到详情的状态类型
@property (assign, nonatomic) CwStatusType cwStatusType;

@property (assign, nonatomic) id <CouponsViewControllerDelegate> delegate;

@property (retain, nonatomic) NSMutableArray *dataArr;

@property (retain, nonatomic) NSString *shopID;
@property (retain, nonatomic) NSString *productID;

@end

@protocol CouponsViewControllerDelegate <NSObject>

@optional
- (void)getCouponsTitle:(NSString *)title money:(int)pmoney couponsid:(int)acouponsID;

@end
