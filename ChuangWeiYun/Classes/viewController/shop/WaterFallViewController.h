//
//  WaterFallViewController.h
//  SideSlip
//
//  Created by yunlai on 13-8-9.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "ListFatherViewController.h"
#import "WaterCellView.h"
#import "IconDownLoader.h"
#import "CitySubbranchViewController.h"
#import "cloudLoadingView.h"

#define UpdateWaterList       @"UpdateWaterList"
#define UpdateWaterListMore   @"UpdateWaterListMore"
#define PageOverWaterTurn     @"PageOverWaterTurn"

@interface WaterFallViewController : ListFatherViewController <LoadTableViewDelegate,IconDownloaderDelegate, ListFatherViewControllerDelegate, CitySubbranchViewControllerDelegate>
{
    NSMutableArray *dataArr;
    NSMutableArray *waterArr;
}

// 目前数据
@property (retain, nonatomic) NSMutableArray *dataArr;
// 瀑布流数据
@property (retain, nonatomic) NSMutableArray *waterArr;

@property (nonatomic, retain) NSString *catID;
@property (nonatomic,retain) cloudLoadingView *cloudLoading;

@end
