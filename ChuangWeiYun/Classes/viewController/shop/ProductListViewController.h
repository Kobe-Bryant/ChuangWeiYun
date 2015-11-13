//
//  ProductListViewController.h
//  SideSlip
//
//  Created by yunlai on 13-8-9.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "ListFatherViewController.h"
#import "IconDownLoader.h"
#import "CitySubbranchViewController.h"

#define UpdateProductList       @"UpdateProductList"
#define UpdateProductListMore   @"UpdateProductListMore"
#define PageOverProductTurn     @"PageOverProductTurn"

@interface ProductListViewController : ListFatherViewController <LoadTableViewDelegate,IconDownloaderDelegate, ListFatherViewControllerDelegate,CitySubbranchViewControllerDelegate>
{
    NSMutableArray *dataArr;
}

// 目前数据
@property (retain, nonatomic) NSMutableArray *dataArr;

@end
