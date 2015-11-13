//
//  BackViewController.h
//  SideSlip
//
//  Created by yunlai on 13-8-5.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "Global.h"
#import "cloudLoadingView.h"

@interface BackViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, IconDownloaderDelegate>
{
    UITableView *_tableViewC;
    
    NSMutableArray *dataArr;
    NSMutableArray *twodataArr;
    
    UIView *upBarView;
    
}

@property (retain, nonatomic) UITableView *tableViewC;
@property (retain, nonatomic) NSMutableArray *dataArr;
@property (retain, nonatomic) NSMutableArray *twodataArr;
@property (retain, nonatomic) UIView *upBarView;

@property (nonatomic,assign) CwStatusType _statusType; //hui add
@property (nonatomic,retain) cloudLoadingView *cloudLoading;

@end
