//
//  AfterSaleViewController.h
//  cw
//
//  Created by yunlai on 13-9-7.
//
//

#import <UIKit/UIKit.h>
#import "CWLabel.h"
@interface AfterSaleViewController : UIViewController
{
    UILabel         *_productService;
    CWLabel         *_serviceContent;
    UILabel         *_repair;
    CWLabel         *_repairContent;
    UILabel         *_repairCycle;
    CWLabel         *_repairCycleContent;
    
    CGFloat kWidth;
    CGFloat kHeight;
    //背景滚动视图
    UIScrollView    *_mainScrollView;
}

@end
