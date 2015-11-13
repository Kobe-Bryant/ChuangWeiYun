//
//  EnterShopLookViewController.h
//  cw
//
//  Created by yunlai on 13-10-21.
//
//

#import <UIKit/UIKit.h>
#import "adView.h"
#import "myImageView.h"
#import "IconDownLoader.h"
#import "MRZoomScrollView.h"

@interface EnterShopLookViewController : UIViewController<myImageViewDelegate,IconDownloaderDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    UIPageControl *_pageControl;
    
    NSInteger _totalPages;
    NSInteger _curPage;
}
@property (nonatomic, retain) UIScrollView      *scrollView;
@property (nonatomic,readonly) UIPageControl    *pageControl;
@property (nonatomic, retain) MRZoomScrollView  *zoomScrollView;
@property(nonatomic,retain) NSArray *adsArray;
@property(nonatomic,retain) NSString *pics;
@end
