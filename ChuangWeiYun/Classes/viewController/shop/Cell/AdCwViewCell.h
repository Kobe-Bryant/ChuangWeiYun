//
//  AdCwViewCell.h
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "TableViewCell.h"
#import "SingleScrollView.h"
//#import "XLCycleScrollView.h"
#import "IconDownLoader.h"
#import "CWImageView.h"
#import "CWPictureView.h"
#import "Global.h"

// XLCycleScrollViewDatasource,XLCycleScrollViewDelegate

@interface AdCwViewCell : TableViewCell <SingleScrollViewDelegate,IconDownloaderDelegate,CWImageViewDelegate, CWPictureViewDelegate>
{
    UILabel *_modelLabel;
    UILabel *_likeLabel;
    UILabel *_orderLabel;
    UIImageView *_likeImage;
    UIImageView *_orderImage;
    SingleScrollView *_scrollViewC;
//    XLCycleScrollView *_scrollViewC;
    NSMutableArray *picsArr;
    
    CWPictureView *CWPview;
    
    UIView *_maskView;
    CwStatusType statusType;
}

@property (retain, nonatomic) SingleScrollView *scrollViewC;
//@property (retain, nonatomic) XLCycleScrollView *scrollViewC;
@property (retain, nonatomic) NSMutableArray *picsArr;
@property (assign, nonatomic) CwStatusType statusType;

- (void)scrollinvalidate;

- (void)setCellContentAndFrame:(NSDictionary *)dict index:(int)index state:(BOOL)state from:(BOOL)_isFromProCenter;

+ (CGFloat)getCellHeight;

@end
