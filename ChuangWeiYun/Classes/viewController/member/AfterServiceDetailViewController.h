//
//  AfterServiceDetailViewController.h
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "cloudLoadingView.h"

@interface AfterServiceDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,HttpRequestDelegate>
{
    //详情表格
    UITableView *_tableView;
    UIView      *_bottomView;
    NSString    *_serviceId;
    NSString    *_orderId;
    NSString    *_mobile;
    NSMutableArray *_serviceDataArray;
    
}
@property(nonatomic, retain) NSMutableArray *serviceDataArray;
@property(nonatomic, copy) NSString *serviceId;
@property(nonatomic, copy) NSString *orderId;
@property(nonatomic, copy) NSString *mobile;
@property(nonatomic, retain) cloudLoadingView *cloudLoading;
@end
