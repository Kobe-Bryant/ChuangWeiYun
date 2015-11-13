//
//  PfShopCell.h
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import <UIKit/UIKit.h>
#import "DoubleScrollView.h"
#import "IconDownLoader.h"
#import "CWImageView.h"

@interface PfShopCell : UITableViewCell <DoubleScrollViewDelegate,IconDownloaderDelegate,CWImageViewDelegate>
{
    DoubleScrollView *_scrollView;
    UIView *bgView;
    
    NSMutableArray *partner_pics;
    
    id controllerDelegate;
}

@property (assign, nonatomic) id controllerDelegate;

+ (CGFloat)getCellHeight:(NSMutableArray *)arr;

- (void)setCellContentAndFrame:(NSMutableArray *)arr;

@end
