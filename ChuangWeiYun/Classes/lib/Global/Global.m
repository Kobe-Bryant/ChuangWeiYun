//
//  Global.m
//  cw
//
//  Created by siphp on 12-8-13.
//  Copyright 2013 yunlai. All rights reserved.
//

#import "Global.h"
#import "PfShare.h"

/* 线程安全的实现 */
@implementation Global

static id sharedGlobal = nil;

@synthesize locManager;
@synthesize myLocation;
@synthesize locationAddress;
@synthesize locationCity;
@synthesize currCity;
@synthesize netWorkQueue;
@synthesize netWorkQueueArray;
@synthesize user_id;
@synthesize shop_id;
@synthesize info_id;
@synthesize isLogin;
@synthesize isChangedImage;
@synthesize isLoction = _isLoction;
@synthesize shop_state;
@synthesize loctionFlag;
@synthesize countObj_id;
@synthesize _countType;
@synthesize isRefShop = _isRefShop;
@synthesize isCloseCity = _isCloseCity;
@synthesize push_id;

+ (void)initialize
{
    if (self == [Global class])
    {
        sharedGlobal = [[self alloc] init];
    }
}

+ (Global *)sharedGlobal
{
    return sharedGlobal;
}

- (void)dealloc
{
    self.locManager = nil;
    self.locationAddress = nil;
    self.locationCity = nil;
    self.currCity = nil;
    self.netWorkQueue = nil;
    self.netWorkQueueArray = nil;
    self.user_id = nil;
    self.shop_id = nil;
    self.info_id = nil;
    self.shop_state = nil;
    self.countObj_id = nil;

    [super dealloc];
}

- (void)registerWXApi
{
    // 微信注册
    [WXApi registerApp:WEICHATID];
}

- (BOOL)handleOpenURL:(NSURL *)url delegate:(id)delegate
{
    return [WXApi handleOpenURL:url delegate:self];
}

// Weixin分享回调
- (void)onResp:(BaseResp*)resp
{
    if (resp.errCode == WXSuccess) {
        [[PfShare defaultSingle] pfShareRequest];
    }
}

@end
