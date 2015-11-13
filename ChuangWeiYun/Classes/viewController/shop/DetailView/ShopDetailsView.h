//
//  ShopDetailsView.h
//  scrollview
//
//  Created by yunlai on 13-8-16.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "UITableScrollView.h"
#import "Global.h"
#import "NearestStoreCell.h"
#import "IconDownLoader.h"
#import "GuessLikeCell.h"

typedef enum
{
    ShopDetailsEnumNormal,
    ShopDetailsEnumLike,
    ShopDetailsEnumDelike,
    ShopDetailsEnumOrder,
    ShopDetailsEnumComment,
    ShopDetailsEnumReturn,
}ShopDetailsEnum;

@protocol ShopDetailsViewDelegate;

@interface ShopDetailsView : UITableScrollViewCell <UITableViewDataSource,UITableViewDelegate,NearestStoreCellDelegate,IconDownloaderDelegate, GuessLikeCellDelegate>
{
    UITableView *tableViewC;
    
    NSDictionary *dataDict;
    NSMutableArray *guesslikeArr;
    NSMutableArray *commentlistArr;
    
    UINavigationController *navViewController;
    
    BOOL is_guess_like;
    int  currSelect;
    CwStatusType cwStatusType;
    BOOL loading;
    UIActivityIndicatorView *indicatorView;
    
    NSString *proID;
    
    id <ShopDetailsViewDelegate> delegate;
    
    // dufu add 2013.11.11
    BOOL parameterFlag;         // 产品参数标志
    BOOL commentFlag;           // 用户评论标志
    BOOL commentLoadFlag;       // 用户评论联网
    
    NSString *paramStr;         // 参数内容
    NSMutableArray *shopList;   // 地图列表
    int commentSum;             // 评论条数
    UIButton *commentBtn;       // 评论btn
}

@property (retain, nonatomic) UITableView *tableViewC;
@property (retain, nonatomic) NSDictionary *dataDict;
// 状态类型
@property (assign, nonatomic) CwStatusType cwStatusType;
@property (assign, nonatomic) BOOL isEnd;
@property (retain, nonatomic) NSString *proID;

@property (retain, nonatomic) UINavigationController *navViewController;

@property (assign, nonatomic) id <ShopDetailsViewDelegate> delegate;

@property (retain, nonatomic) NSString *paramStr;

@property (retain, nonatomic) NSMutableArray *shopList;   // 地图列表

@property (retain, nonatomic) UIButton *commentBtn;

// 创建视图
- (void)createView;

// 重载view上的视图
- (void)tableViewReloadData:(NSDictionary *)adict shopList:(NSMutableArray *)shoplist type:(ShopDetailsEnum)type;

@end

@protocol ShopDetailsViewDelegate <NSObject>

@optional
- (void)shopDetailsViewFlag:(BOOL)flag;

@end
