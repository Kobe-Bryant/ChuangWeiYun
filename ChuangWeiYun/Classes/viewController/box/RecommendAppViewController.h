//
//  RecommendAppViewController.h
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import <UIKit/UIKit.h>
#import "XLCycleScrollView.h"
#import "adView.h"
#import "myImageView.h"
#import "IconDownLoader.h"
#import "HttpRequest.h"
#import "cloudLoadingView.h"
#import "NullstatusView.h"

@interface RecommendAppViewController : UIViewController<XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,myImageViewDelegate,IconDownloaderDelegate,HttpRequestDelegate>
{
    UITableView *_appTableView;

    cloudLoadingView *cloudLoading;
    //上拉加载更多
    BOOL _isAllowLoadingMore;
    BOOL _loadingMore;
    UIActivityIndicatorView *indicatorView;
    NSString           *adsVer;
    NSString           *appVer;
    
    //空状态视图
    NullstatusView  *_nullView;
}
@property(nonatomic, retain) XLCycleScrollView  *bannerScrollView;
@property(nonatomic, retain) NSMutableArray     *adsArray;
@property(nonatomic, retain) NSMutableArray     *appItemArray;
@property(nonatomic, retain) cloudLoadingView   *cloudLoading;

@end
