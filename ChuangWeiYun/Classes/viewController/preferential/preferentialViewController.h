//
//  preferentialViewController.h
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "IconDownLoader.h"
#import "LoadTableView.h"

@interface preferentialViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HttpRequestDelegate, IconDownloaderDelegate, UIScrollViewDelegate, LoadTableViewDelegate>
{
    LoadTableView *_tableViewC;
    NSMutableArray *dataArr;
}

@property (retain, nonatomic) LoadTableView *tableViewC;
@property (retain, nonatomic) NSMutableArray *dataArr;

@end
