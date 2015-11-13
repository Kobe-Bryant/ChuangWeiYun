//
//  InformationDetailViewController.h
//  cw
//
//  Created by LuoHui on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "UITableScrollView.h"
#import "DetailViewDownBar.h"
#import "ShareAPIAction.h"
#import "WeiboView.h"
#import "cloudLoadingView.h"
#import "LoginViewController.h"
#import "MediaPopView.h"
#import "InformationDetailView.h"

// 12. 4chenfeng
@protocol InformationDetailViewDelegate <NSObject>

- (void)isInformationDellikeSelectRow:(NSNumber *)selectNum;

@end

@interface InformationDetailViewController : UIViewController <UITableScrollViewDelagate,DetailViewDownBarDelegate,ShareAPIActionDelegate,WeiboViewDelegate,LoginViewDelegate,InformationViewDelegate,MediaPopViewDelegate>//
{
    UITableScrollView *_scrollViewC;
    DetailViewDownBar *_downBarView;
    
    NSMutableArray *dataArr;
    
    BOOL _isLike;
    
    LoginBack loginBack;
    
    id<InformationDetailViewDelegate>delegate; //12.4chenfeng
}

@property (retain, nonatomic) UITableScrollView *scrollViewC;
@property (retain, nonatomic) DetailViewDownBar *downBarView;
@property (retain, nonatomic) NSMutableArray *dataArr;
@property (nonatomic) int indexValue;
@property (nonatomic, retain) NSString *inforId;
@property (nonatomic,retain) cloudLoadingView *cloudLoading;
@property (assign, nonatomic) CwStatusType cwStatusType;
@property (assign, nonatomic) id<InformationDetailViewDelegate>delegate; //12.4chenfeng

@end

