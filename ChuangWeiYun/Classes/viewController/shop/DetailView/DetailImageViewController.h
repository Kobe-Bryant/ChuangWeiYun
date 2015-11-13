//
//  DetailImageViewController.h
//  cw
//
//  Created by yunlai on 13-11-11.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"

@interface DetailImageViewController : UIViewController <IconDownloaderDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *imgArr;
    // 需要加载的总个数
    NSMutableArray *loadSums;
}

@property (retain, nonatomic) NSMutableArray *imgArr;
@property (retain, nonatomic) NSMutableArray *loadSums;

@end
