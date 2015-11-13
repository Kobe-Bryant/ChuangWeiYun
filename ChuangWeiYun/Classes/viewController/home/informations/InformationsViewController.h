//
//  InformationsViewController.h
//  cw
//
//  Created by LuoHui on 13-8-28.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "cloudLoadingView.h"

@interface InformationsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate>
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
@property(nonatomic,retain) cloudLoadingView *cloudLoading;

@end
