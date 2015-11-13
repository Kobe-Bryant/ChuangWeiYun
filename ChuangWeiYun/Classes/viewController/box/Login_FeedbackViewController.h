//
//  Login_FeedbackViewController.h
//  cw
//
//  Created by LuoHui on 13-9-12.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "HPGrowingTextView.h"
#import "EGORefreshTableHeaderView.h"
#import "IconDownLoader.h"
#import "cloudLoadingView.h"
#import "TalkStatusView.h"

@protocol Login_FeedbackViewControllerDelegate <NSObject>

- (void)accessServiceItemsSuccess;

@end

@interface Login_FeedbackViewController : UIViewController <HPGrowingTextViewDelegate,UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,IconDownloaderDelegate,TalkStatusViewDelegate>
{
    UITableView *_myTableView;
    NSMutableArray *__listArray;
    
    UIView *containerView;
    HPGrowingTextView *textView;
    NSString *tempTextContent;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) NSString *tempTextContent;
@property (nonatomic, retain) cloudLoadingView *cloudLoading;
@property (nonatomic, assign) id <Login_FeedbackViewControllerDelegate> delegate;
@end
