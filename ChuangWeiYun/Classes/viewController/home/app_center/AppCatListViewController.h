//
//  AppCatListViewController.h
//  cw
//
//  Created by LuoHui on 13-9-5.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "cloudLoadingView.h"
#import "AppCatListCell.h"

@interface AppCatListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,AppCatListCellDelegate>
{
    UITableView *_myTableView;
    NSMutableArray *__listArray;
    
    CGFloat picWidth;
    CGFloat picHeight;
    
    BOOL _isAllowLoadingMore;
    BOOL _loadingMore;
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, retain) NSString *navTitle;
@property (nonatomic, retain) NSString *catId;

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property(nonatomic,retain) cloudLoadingView *cloudLoading;
@end
