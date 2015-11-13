//
//  AfterServiceViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "NullstatusView.h"
#import "HttpRequest.h"
#import "cloudLoadingView.h"

@interface AfterServiceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HttpRequestDelegate>
{
    //售后服务列表
    UITableView     *_tableView;
    //售后服务数据
    NSMutableArray  *_afterServiceArray;
    //空状态视图
    NullstatusView  *_nullView;
    
}
@property(nonatomic, retain) cloudLoadingView   *cloudLoading;
@property(nonatomic, retain) NSMutableArray     *afterServiceArray;
@end
