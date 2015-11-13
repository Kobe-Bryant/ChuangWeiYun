//
//  HotProductsViewController.h
//  cw
//
//  Created by LuoHui on 13-8-26.
//
//

#import <UIKit/UIKit.h>
#import "HotProductsCell.h"
#import "IconDownLoader.h"
#import "cloudLoadingView.h"

@interface HotProductsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate,HotProductsCellDelegate>
{
    UITableView *_myTableView;
    NSMutableArray *__listArray;
    CGFloat viewHeight;
    CGFloat picWidth;
    CGFloat picHeight;
}
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property(nonatomic,retain) cloudLoadingView *cloudLoading;
@end
