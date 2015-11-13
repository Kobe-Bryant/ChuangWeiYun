//
//  SearchResultViewController.h
//  cw
//
//  Created by yunlai on 13-8-19.
//
//

#import <UIKit/UIKit.h>
#import "CustomSearchBar.h"
#import "Common.h"
#import "IconDownLoader.h"
#import "Global.h"
#import "LoadTableView.h"

@interface SearchResultViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CustomSearchBarDelegate,IconDownloaderDelegate,LoadTableViewDelegate>
{
    LoadTableView *_tableViewC;
    CustomSearchBar *_searchBarC;
    NSMutableArray *dataArr;

    int listViewType;
    NSString *searchText;
    CwStatusType statusType;
}

@property (retain, nonatomic) UITableView *tableViewC;
@property (retain, nonatomic) CustomSearchBar *searchBarC;

// 联网获取数据数组
@property (retain, nonatomic) NSMutableArray *dataArr;

// 搜索内容，需要上个页面传入
@property (retain, nonatomic) NSString *searchText;

@property (assign, nonatomic) CwStatusType statusType;

@end
