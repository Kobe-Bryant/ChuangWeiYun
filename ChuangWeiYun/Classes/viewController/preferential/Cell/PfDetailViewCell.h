//
//  PfDetailViewCell.h
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "UITableScrollViewCell.h"
#import "DoubleView.h"

@interface PfDetailViewCell : UITableScrollViewCell <UITableViewDataSource, UITableViewDelegate, DoubleViewDelegate>
{
    UITableView *_tableViewC;
    
    NSDictionary *dataDict;
}

@property (retain, nonatomic) UINavigationController *navViewController;
@property (retain, nonatomic) UITableView *tableViewC;
@property (retain, nonatomic) NSDictionary *dataDict;

- (void)createView;

// type 为 0 走的是刷新界面，为 1 时 是在返回详情页面返回时做一些事情
- (void)tableViewReloadData:(NSDictionary *)adict type:(int)type;

@end
