//
//  PfShare.m
//  cw
//
//  Created by yunlai on 13-9-30.
//
//

#import "PfShare.h"
#import "Global.h"
#import "promotion_model.h"
#import "PopPfShareFail.h"
#import "CustomTabBar.h"
#import "CouponsViewController.h"
#import "promotion_model.h"

static PfShare *share = nil;

@implementation PfShare

@synthesize getPf;
@synthesize share_gift;

+ (PfShare *)defaultSingle
{
    @synchronized(self) {
        if (share == nil) {
            share = [[PfShare alloc]init];
        }
    }
    return share;
}

- (void)pfShareRequestisLogin
{
    promotion_model *pMod = [[promotion_model alloc]init];
    NSArray *arr = [pMod getList];
    [pMod release], pMod = nil;
    if (arr.count > 0) {
        NSString *shopstr = [[arr lastObject] objectForKey:@"shop_id"];
        NSArray *shopArr = [shopstr componentsSeparatedByString:@","];
        NSLog(@"shopArr = %@",shopArr);
        NSLog(@"pfShareRequestisLogin  pfFlag = %d",pfFlag);
        if ([Global sharedGlobal].isLogin) {
            if (pfFlag != 2) {
                pfFlag = 1;
            }
            [self accessSharePfService];
        } else {
            pfFlag = 2;
            if (shareView == nil) {
                shareView = [[PopPfShareView alloc]initType:1];
            }
            shareView.delegate = self;
            
            [shareView addPopupSubview:nil];
            
            shareView.pfShareBlock = ^ {
                [shareView release], shareView = nil;
            };
        }
    }
}

- (void)pfShareRequest
{
    pfFlag = 0;

    if (self.getPf == Share_Get_Pf_Shop
        || self.getPf == Share_Get_Pf_Pf
        || self.getPf == Share_Get_Pf_Box) {
        if (self.getPf == Share_Get_Pf_Shop) {
            if ([Global sharedGlobal].shop_id.length == 0) {
                return;
            }
        }
        [self pfShareRequestisLogin];
    }
}

#pragma mark - PopPfShareViewDelegate
- (void)popPfShareViewClick:(int)type
{
    UINavigationController *navController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (type == 0) {
        CouponsViewController *couponCtl = [[CouponsViewController alloc]init];
        couponCtl.cwStatusType = StatusTypeMemberChoosePf;
        [navController pushViewController:couponCtl animated:YES];
        [couponCtl release], couponCtl = nil;
    } else {
        LoginViewController *login = [[LoginViewController alloc] init];
        login.delegate = self;
        login.cwStatusType = StatusTypeMemberLogin;
        login.cwBackType = LoginBackShareBack;
        [navController pushViewController:login animated:YES];
        [login release];
    }
}

#pragma mark - 
- (void)loginSuccessBackCtl:(LoginBack)cwBackType
{
    [self pfShareRequestisLogin];
}

// 分享获得优惠券
- (void)accessSharePfService
{
    NSString *reqUrl = @"receiveprivilege.do?param=";
    
    promotion_model *pMod = [[promotion_model alloc]init];
    NSArray *arr = [pMod getList];
    [pMod release], pMod = nil;
    
    NSString *info_id = [NSString stringWithFormat:@"%d",[[[arr lastObject] objectForKey:@"id"] intValue]];
    NSString *type = nil;
    NSMutableDictionary *requestDic = nil;
    
    NSString *shopid = @"0";
    if ([Global sharedGlobal].shop_id.length != 0) {
        shopid = [Global sharedGlobal].shop_id;
    }
    
    if (self.getPf == Share_Get_Pf_Box) {
        type = @"4";
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      shopid,@"shop_id",
                      info_id,@"coupon_id",
                      [Global sharedGlobal].user_id,@"user_id",
                      type,@"type",
                      @"0",@"info_id",
                      nil];
    } else {
        if (self.getPf == Share_Get_Pf_Shop) {
            type = @"1";
        } else if (self.getPf == Share_Get_Pf_Pf) {
            type = @"3";
        }
        
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      shopid,@"shop_id",
                      info_id,@"coupon_id",
                      [Global sharedGlobal].user_id,@"user_id",
                      type,@"type",
                      [Global sharedGlobal].info_id,@"info_id",
                      nil];
    }

    [[NetManager sharedManager] accessService:requestDic data:nil command:SHARE_GET_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
    [Global sharedGlobal].info_id = nil;
}

// 分享获取
- (void)shareGet:(NSMutableArray*)resultArray
{
    NSLog(@"resultArray = %@",resultArray);
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([[resultArray lastObject] intValue] == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self success];
                });
            } else if ([[resultArray lastObject] intValue] == 3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (pfFlag == 2) {
                        [self fail:1];
                    }
                });
            } else if ([[resultArray lastObject] intValue] == 4) {
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self fail:0];
                });
            }
        });
    }
}

// 分享获取成功
- (void)success
{
    promotion_model *pMod = [[promotion_model alloc]init];
    NSArray *arr = [pMod getList];
    [pMod release], pMod = nil;
    
    NSDictionary *dict = nil;
    if (arr.count > 0) {
        dict = [arr lastObject];
    }
    if (shareView == nil) {
        shareView = [[PopPfShareView alloc]initType:0];
    }
    shareView.delegate = self;

    [shareView addPopupSubview:dict];
    
    shareView.pfShareBlock = ^ {
        [shareView release], shareView = nil;
    };
}

// 分享获取失败
- (void)fail:(int)type
{
    if (pfshare == nil) {
        pfshare = [[PopPfShareFail alloc]initType:type];
    }
    [pfshare addPopupSubview];
    
    pfshare.pfShareClosingBlock = ^ {
        [pfshare release], pfshare = nil;
    };
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch(commandid) {
        case SHARE_GET_COMMAND_ID:      // 分享获取
        {
            [self shareGet:resultArray];
        }
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    if (shareView) {
        [shareView release], shareView = nil;
    }
    if (pfshare) {
        [pfshare release], pfshare = nil;
    }
    [super dealloc];
}

@end
