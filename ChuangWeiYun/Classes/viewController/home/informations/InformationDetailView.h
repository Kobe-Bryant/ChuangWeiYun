//
//  InformationDetailView.h
//  cw
//
//  Created by LuoHui on 13-8-29.
//
//

#import "UITableScrollViewCell.h"
#import "SingleScrollView.h"
#import "myImageView.h"
#import "IconDownLoader.h"
#import "CWImageView.h"
#import "CWPictureView.h"
#import "RollImageView.h"

typedef enum
{
    From_Enum_List,    // 首页资讯列表
    From_Enum_Member,  // 会员
} From_Enum;

@protocol InformationViewDelegate;

@interface InformationDetailView : UITableScrollViewCell <UITableViewDataSource,UITableViewDelegate,SingleScrollViewDelegate,CWImageViewDelegate,IconDownloaderDelegate,CWPictureViewDelegate>
{
    UITableView *tableViewC;
    
    NSMutableDictionary *itemDic;
    NSMutableArray *commentArr;
    
    CGFloat picWidth;
    CGFloat picHeight;
    
    SingleScrollView *picsScrollView;
    NSMutableArray *picsArray;
    
    CWPictureView *CWPview;
    
    UIActivityIndicatorView *indicatorView;
    BOOL loading;
    
    int commentSum;
    CGFloat cwHeight;
    
    id <InformationViewDelegate> delegate;
}

@property (retain, nonatomic) UITableView *tableViewC;
@property (retain, nonatomic) NSMutableDictionary *itemDic;
@property (assign, nonatomic) id <InformationViewDelegate> delegate;

- (void)createView:(From_Enum)_type;

- (void)tableViewReloadData:(NSMutableDictionary *)dic type:(int)type;


@end

@protocol InformationViewDelegate <NSObject>

@optional
- (void)InformationView:(InformationDetailView *)infoView;

@end
