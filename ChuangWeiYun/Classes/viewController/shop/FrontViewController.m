//
//  FrontViewController.m
//  SideSlip
//
//  Created by yunlai on 13-8-5.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "FrontViewController.h"
#import "WaterFallViewController.h"
#import "ProductListViewController.h"
#import "IconPictureProcess.h"
#import "Common.h"
#import "Global.h"

@interface FrontViewController ()
{
    ListFatherViewType *requestType;
    int cat_ID;
}

@property (retain, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (retain, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (retain, nonatomic) UIView *maskView;
@property (retain, nonatomic) UIView *bgview;

@end

@implementation FrontViewController

@synthesize panGestureRecognizer;
@synthesize tapGestureRecognizer;
@synthesize waterFallViewC;
@synthesize productListViewC;

@synthesize maskView;
@synthesize bgview;
@synthesize cloudLoading;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight);

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateRightNotification:) name:@"updateRight" object:nil];
    [center addObserver:self selector:@selector(updateLeftNotification:) name:@"updateLeft" object:nil];
    [center addObserver:self selector:@selector(addPanGesture:) name:@"addPan" object:nil];
    [center addObserver:self selector:@selector(removePanGesture:) name:@"removePan" object:nil];
    [center addObserver:self selector:@selector(recvRequestMessage:) name:SendResquest object:nil];
    [center addObserver:self selector:@selector(recvRequestMessageMore:) name:SendResquestMore object:nil];
    [center addObserver:self selector:@selector(recvCatRequestMessage:) name:@"catSendRequest" object:nil];
    
    [self viewLoad];
}

- (void)viewLoad
{
    bgview = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight)];
    [self.view addSubview:bgview];
    
    self.view.backgroundColor = KCWViewBgColor;
    
    waterFallViewC = [[WaterFallViewController alloc]init];
    
    [self _addControllerToViewController:waterFallViewC];

    waterFallViewC.delegate = self;
    waterFallViewC.view.frame = self.view.bounds;
    waterFallViewC.view.hidden = NO;
    [bgview addSubview:waterFallViewC.view];
    
    productListViewC = [[ProductListViewController alloc]init];
    
    [self _addControllerToViewController:productListViewC];
    
    productListViewC.delegate = self;
    productListViewC.view.frame = self.view.bounds;
    productListViewC.view.hidden = YES;
    [bgview addSubview:productListViewC.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"nininininininniniinnininininini.....");

    if ([self.parentViewController respondsToSelector:@selector(revealGesture:)]) {
        if (![[self.view gestureRecognizers] containsObject:self.panGestureRecognizer]) {
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(revealGesture:)];
            self.panGestureRecognizer = pan;
            [pan release];
            [self.view addGestureRecognizer:self.panGestureRecognizer];
        }
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)dealloc
{
    [self.view removeGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer release], panGestureRecognizer = nil;
    [self.view removeGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release], tapGestureRecognizer = nil;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"updateRight" object:nil];
    [center removeObserver:self name:@"updateLeft" object:nil];
    [center removeObserver:self name:@"addPan" object:nil];
    [center removeObserver:self name:@"removePan" object:nil];
    [center removeObserver:self name:SendResquest object:nil];
    [center removeObserver:self name:SendResquestMore object:nil];
    [center removeObserver:self name:@"catSendRequest" object:nil];
    
    [waterFallViewC release], waterFallViewC = nil;
    [productListViewC release], productListViewC = nil;
    
    [bgview release], bgview = nil;
    [maskView release], maskView = nil;
    [super dealloc];
}

// 添加子控制器
- (void)_addControllerToViewController:(UIViewController *)ViewController
{
	[self addChildViewController:ViewController];
    
	if ([ViewController respondsToSelector:@selector(didMoveToParentViewController:)]) {
		[ViewController didMoveToParentViewController:self];
	}
}

//动画切换
-(void)showViewWithAnimated:(int)tag
{
    if (tag == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PageOverWaterTurn object:nil];
        self.productListViewC.view.hidden = YES;
        [UIView beginAnimations:nil context:self.waterFallViewC.view];
        [UIView setAnimationDuration:1];
        self.waterFallViewC.view.hidden = NO;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.bgview cache:YES];
        [UIView commitAnimations];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PageOverProductTurn object:nil];
        self.waterFallViewC.view.hidden = YES;
        [UIView beginAnimations:nil context:self.productListViewC.view];
        [UIView setAnimationDuration:1];
        self.productListViewC.view.hidden = NO;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.bgview cache:YES];
        [UIView commitAnimations];
    }
}

// 执行动画
- (void)pageOverTurnView:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[waterFallViewC class]]) {
        requestType = ListProductViewType;
        [self showViewWithAnimated:1];
    } else {
        requestType = ListWaterViewType;
        [self showViewWithAnimated:0];
    }
}

#pragma mark - RevealView NSNotification
// 添加单击手势
- (void)updateLeftNotification:(NSNotification *)notification
{
    if ([self.parentViewController respondsToSelector:@selector(tapGesture:)]) {
        if (![[self.view gestureRecognizers] containsObject:self.tapGestureRecognizer]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(tapGesture:)];
            self.tapGestureRecognizer = tap;
            [tap release];
            [self.view addGestureRecognizer:self.tapGestureRecognizer];
        }
    }
    
    if (maskView == nil) {
        maskView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight)];
        maskView.backgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:maskView];
    
    waterFallViewC.tableViewC.scrollEnabled = NO;
    productListViewC.tableViewC.scrollEnabled = NO;
}

// 移出拖拽手势
- (void)updateRightNotification:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:tapGestureRecognizer];
    [maskView removeFromSuperview];
    waterFallViewC.tableViewC.scrollEnabled = YES;
    productListViewC.tableViewC.scrollEnabled = YES;
}

// 添加拖拽手势
- (void)addPanGesture:(NSNotification *)notification
{
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    waterFallViewC.tableViewC.scrollEnabled = YES;
    productListViewC.tableViewC.scrollEnabled = YES;
}

// 移出拖拽手势
- (void)removePanGesture:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:self.panGestureRecognizer];
    waterFallViewC.tableViewC.scrollEnabled = NO;
    productListViewC.tableViewC.scrollEnabled = NO;
}

// 分类请求
- (void)recvCatRequestMessage:(NSNotification *)notification
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    int cat = [notification.object intValue];
    
//    if (cat_ID == cat) {
//        return;
//    }
    
    cat_ID = cat;
    
    if (cat_ID == 123456789) {
        NSNumber *failFlag = [NSNumber numberWithInt:3];
        NSMutableDictionary *mutlDict1 = [NSMutableDictionary dictionaryWithCapacity:0];
        [mutlDict1 setObject:[NSNumber numberWithInt:cat_ID] forKey:@"cat_ID"];
        [mutlDict1 setObject:failFlag forKey:@"failFlag"];
        
        NSMutableDictionary *mutlDict2 = [NSMutableDictionary dictionaryWithCapacity:0];
        [mutlDict2 setObject:[NSNumber numberWithInt:cat_ID] forKey:@"cat_ID"];
        [mutlDict2 setObject:failFlag forKey:@"failFlag"];
        
        if (requestType == ListWaterViewType) {
            [mutlDict1 setObject:[NSNumber numberWithBool:NO] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateProductList
                                                                object:mutlDict1];
            [mutlDict2 setObject:[NSNumber numberWithBool:YES] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateWaterList
                                                                object:mutlDict2];
        } else {
            [mutlDict1 setObject:[NSNumber numberWithBool:YES] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateProductList
                                                                object:mutlDict1];
            [mutlDict2 setObject:[NSNumber numberWithBool:NO] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateWaterList
                                                                object:mutlDict2];
        }
    } else {
        if (requestType == ListWaterViewType) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SendResquest object:[NSString stringWithFormat:@"%d",ListWaterViewType]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SendResquest object:[NSString stringWithFormat:@"%d",ListProductViewType]];
        }
    }
    
    [pool release];
}

// 网络请求
- (void)recvRequestMessage:(NSNotification *)notification
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removePan" object:nil];
    
    NSString *type = nil;
    
    if ([notification.object isKindOfClass:[NSString class]]) {
        //添加loading图标
        cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
        [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2 +10, ([UIScreen mainScreen].bounds.size.height - 43.0f) / 2)];
        self.cloudLoading = tempLoadingView;
        [self.view addSubview:self.cloudLoading];
        [tempLoadingView release];
        
        type = notification.object;
    } else {
        NSDictionary *dict = notification.object;
        type = [dict objectForKey:@"Type"];
    }

    NSLog(@"recvRequestMessage type = %@",type);
    requestType = [type intValue];
    
    NSString *reqUrl = @"productlist.do?param=";

    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       //[Common getCatVersion:SHOP_LIST_COMMAND_ID withId:cat_ID],@"ver",
                                       @"0",@"ver",
                                       [Global sharedGlobal].shop_id,@"shop_id",
                                       [NSString stringWithFormat:@"%d",cat_ID],@"catalog_id",nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SHOP_LIST_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

// 网络请求 更多
- (void)recvRequestMessageMore:(NSNotification *)notification
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSDictionary *dict = notification.object;
    
    NSLog(@"recvRequestMessageMore  dict = %@",dict);
    
    requestType = [[dict objectForKey:@"type"] intValue];
    NSString *position = [dict objectForKey:@"position"];
    
    NSString *reqUrl = @"productlist.do?param=";
	
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"-1",@"ver",
                                       [Global sharedGlobal].shop_id,@"shop_id",
                                       [NSString stringWithFormat:@"%d",cat_ID],@"catalog_id",
                                       position,@"position", nil];
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:SHOP_LIST_MORE_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
    
    [pool release];
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSNumber *failFlag = nil;
    if ([[resultArray lastObject] isEqual:CwRequestFail]) {
        failFlag = [NSNumber numberWithInt:1];
    } else {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
            failFlag = [NSNumber numberWithInt:2];
        } else {
            failFlag = [NSNumber numberWithInt:0];
        }
    }
    
    if (commandid == SHOP_LIST_COMMAND_ID) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addPan" object:nil];
        
        NSMutableDictionary *mutlDict1 = [NSMutableDictionary dictionaryWithCapacity:0];
        [mutlDict1 setObject:[NSNumber numberWithInt:cat_ID] forKey:@"cat_ID"];
        [mutlDict1 setObject:failFlag forKey:@"failFlag"];
        
        NSMutableDictionary *mutlDict2 = [NSMutableDictionary dictionaryWithCapacity:0];
        [mutlDict2 setObject:[NSNumber numberWithInt:cat_ID] forKey:@"cat_ID"];
        [mutlDict2 setObject:failFlag forKey:@"failFlag"];

        //loading图标移除
        [self.cloudLoading removeFromSuperview]; 

        if (requestType == ListWaterViewType) {
            NSLog(@"requestType == ListWaterViewType");
            [mutlDict1 setObject:[NSNumber numberWithBool:NO] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateProductList
                                                                object:mutlDict1];
            [mutlDict2 setObject:[NSNumber numberWithBool:YES] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateWaterList
                                                                object:mutlDict2];
        } else {
            [mutlDict1 setObject:[NSNumber numberWithBool:YES] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateProductList
                                                                object:mutlDict1];
            [mutlDict2 setObject:[NSNumber numberWithBool:NO] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateWaterList
                                                                object:mutlDict2];
        }
    } else if (commandid == SHOP_LIST_MORE_COMMAND_ID) {
        
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithCapacity:0];
        if (resultArray.count > 0) {
            [dict1 setObject:resultArray forKey:@"data"];
        }
        [dict1 setObject:failFlag forKey:@"failFlag"];
        
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithCapacity:0];
        if (resultArray.count > 0) {
            [dict2 setObject:resultArray forKey:@"data"];
        }
        [dict2 setObject:failFlag forKey:@"failFlag"];
        
        if (requestType == ListWaterViewType) {
            [dict1 setObject:[NSNumber numberWithBool:NO] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateProductListMore object:dict1];
            
            [dict2 setObject:[NSNumber numberWithBool:YES] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateWaterListMore object:dict2];
        } else {
            [dict1 setObject:[NSNumber numberWithBool:YES] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateProductListMore object:dict1];
            
            [dict2 setObject:[NSNumber numberWithBool:NO] forKey:@"bool"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateWaterListMore object:dict2];
        }
    }
    
    [pool release];
}

@end
