//
//  GuessLikeCell.h
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "TableViewCell.h"
#import "XLCycleScrollView.h"
#import "IconDownLoader.h"
#import "myImageView.h"
#import "Global.h"

@protocol GuessLikeCellDelegate;

@interface GuessLikeCell : TableViewCell <XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,IconDownloaderDelegate, myImageViewDelegate>
{
    UIView *_bgView;
    UIImageView *_imageV;
    UILabel *_label;
    
    XLCycleScrollView *_scrollView;
    NSMutableArray *picsArr;
    
    CwStatusType cwStatusType;
    
    id <GuessLikeCellDelegate> delegate;
}

@property (retain, nonatomic) XLCycleScrollView *scrollView;
@property (retain, nonatomic) NSMutableArray *picsArr;
@property (assign, nonatomic) CwStatusType cwStatusType;

@property (assign, nonatomic) id <GuessLikeCellDelegate> delegate;

- (void)setCellContentAndFrame:(NSMutableArray *)arr;

+ (CGFloat)getCellHeight;

@end

@protocol GuessLikeCellDelegate <NSObject>

@optional
- (void)guessLikeCellClickImg:(GuessLikeCell *)cell proID:(NSString *)pid;

@end
