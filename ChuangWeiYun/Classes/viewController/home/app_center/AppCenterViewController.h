//
//  AppCenterViewController.h
//  cw
//
//  Created by LuoHui on 13-9-3.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "cloudLoadingView.h"
#import "MBProgressHUD.h"

@protocol AppCenterViewDelegate <NSObject>
- (void)addToContent:(BOOL)_isAdd;
@end

@interface AppCenterViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate>
{
    UITableView *_myTableView;
    NSMutableArray *__listArray;
    
    CGFloat picWidth;
    CGFloat picHeight;
    
    BOOL _isAllowLoadingMore;
    BOOL _loadingMore;
    UIActivityIndicatorView *indicatorView;
    
    BOOL _noMore;
}
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic,retain) cloudLoadingView *cloudLoading;
@property (nonatomic,assign) id <AppCenterViewDelegate> delegate;

@end
