//
//  FrontViewController.h
//  SideSlip
//
//  Created by yunlai on 13-8-5.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerDelegate.h"
#import "HttpRequest.h"
#import "cloudLoadingView.h"

@class WaterFallViewController;
@class ProductListViewController;

@interface FrontViewController : UIViewController <ViewControllerDelegate, HttpRequestDelegate>

@property (retain, nonatomic) WaterFallViewController *waterFallViewC;
@property (retain, nonatomic) ProductListViewController *productListViewC;
@property (nonatomic,retain) cloudLoadingView *cloudLoading;

@end
