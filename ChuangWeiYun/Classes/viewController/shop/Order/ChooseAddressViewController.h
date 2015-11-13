//
//  ChooseAddressViewController.h
//  cw
//
//  Created by yunlai on 13-8-24.
//
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "OrderAddressListCell.h"
#import "Global.h"
#import "NullstatusView.h"
#import "LoadTableView.h"

@protocol ChooseAddressViewControllerDelegate;

@interface ChooseAddressViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,HttpRequestDelegate,OrderAddressCellDelegate,LoadTableViewDelegate>
{
    LoadTableView *_tableViewC;
    
    NSMutableArray *dataArr;
    
    //空状态视图
    NullstatusView  *_nullView;
    
    CwStatusType cwStatusType;
    
    id <ChooseAddressViewControllerDelegate> delegate;
}

@property (retain, nonatomic) LoadTableView *tableViewC;
@property (retain, nonatomic) NSMutableArray *dataArr;

// 其他页面进入到详情的状态类型
@property (assign, nonatomic) CwStatusType cwStatusType;

@property (assign, nonatomic) id <ChooseAddressViewControllerDelegate> delegate;

@end


@protocol ChooseAddressViewControllerDelegate <NSObject>

@optional
- (void)chooseAddressViewObject:(NSMutableDictionary *)dict;

@end