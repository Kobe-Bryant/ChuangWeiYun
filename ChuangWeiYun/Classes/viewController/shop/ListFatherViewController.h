//
//  ListFatherViewController.h
//  SideSlip
//
//  Created by yunlai on 13-8-12.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerDelegate.h"
#import "LoadTableView.h"
#import "CustomSearchBar.h"
#import "Global.h"
#import "NullstatusView.h"

#define SendResquest            @"SendResquest"
#define SendResquestMore        @"SendResquestMore"

#define HeaderViewHeight        26

typedef enum
{
    ListWaterViewType,
    ListProductViewType,
    ListViewType
}ListFatherViewType;

@protocol ListFatherViewControllerDelegate;

@interface ListFatherViewController : UIViewController <UIScrollViewDelegate,CustomSearchBarDelegate,UITableViewDataSource, UITableViewDelegate>
{
    LoadTableView *_tableViewC;
    CustomSearchBar *searchBarC;
    UIView *upBarView;

    NSMutableArray *historyArr;
    
    ListFatherViewType listViewType;
    
    UILabel *subbranchLabel;
    
    NullstatusView *_nullView;
    NSString *catTitle;
    
    id <ViewControllerDelegate> delegate;
    id <ListFatherViewControllerDelegate> lfDelegate;
}

@property (assign, nonatomic) id <ViewControllerDelegate> delegate;
@property (assign, nonatomic) id <ListFatherViewControllerDelegate> lfDelegate;

@property (retain, nonatomic) LoadTableView *tableViewC;
@property (retain, nonatomic) CustomSearchBar *searchBarC;
@property (retain, nonatomic) UIView *upBarView;
@property (retain, nonatomic) UILabel *subbranchLabel;
// 历史记录
@property (retain, nonatomic) NSMutableArray *historyArr;

// 需要子类创建的时候去设置
@property (assign, nonatomic) ListFatherViewType listViewType;

@property (nonatomic, assign) CwStatusType statusType; //hui add

@property (retain, nonatomic) NullstatusView *nullView;

@property (retain, nonatomic) NSString *catTitle;

@property (assign, nonatomic) BOOL isLoading;

- (void)setSubbranchLabelText:(NSString *)text;

@end

@protocol ListFatherViewControllerDelegate <NSObject>

@optional
- (void)cityChoosePageTurn:(NSString *)shopName;

@end
