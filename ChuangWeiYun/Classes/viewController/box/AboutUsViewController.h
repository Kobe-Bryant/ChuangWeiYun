//
//  AboutUsViewController.h
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "HttpRequest.h"
#import "cloudLoadingView.h"
#import "CWLabel.h"

@interface AboutUsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate>
{
    //创维Logo
    UIImageView    *_companyLogo;
    //简介内容
    CWLabel        *_contentLabel;
    //联系我们表格
    UITableView    *_contactTabelView;
    //关于我们总部数据
    NSMutableArray *_aboutArray;
    //关于我们分店数据
    NSMutableArray *_shoplistArray;
    //背景滚动视图
    UIScrollView   *_mainScrollView;
    
    CGFloat kWidth;
    CGFloat kHeight;
    CGFloat kContentHeight;
    
}
@property(nonatomic, retain) NSMutableArray *aboutArray;
@property(nonatomic, retain) NSMutableArray *shoplistArray;
@property(nonatomic, retain) cloudLoadingView *cloudLoading;

@end
