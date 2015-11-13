//
//  PfAdImageCell.h
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import <UIKit/UIKit.h>
#import "SingleScrollView.h"
#import "IconDownLoader.h"
#import "CWImageView.h"
#import "CWPictureView.h"

@interface PfAdImageCell : UITableViewCell <SingleScrollViewDelegate, IconDownloaderDelegate, CWImageViewDelegate, CWPictureViewDelegate>
{
    SingleScrollView *_scrollView;
    NSMutableArray *picArr;
    CWPictureView *CWPview;
    
    BOOL clickFlag;
}

- (void)scrollinvalidate;

+ (CGFloat)getCellHeight;

- (void)setCellContentAndFrame:(NSMutableArray *)arr;

@end
