//
//  TalkStatusView.h
//  TestTalkToLuohui
//
//  Created by meng on 13-10-12.
//  Copyright (c) 2013年 meng. All rights reserved.
//

typedef enum{
    
    TALKSUCCESS = 0, //成功发送聊天信息
    TALKFAILD, //发送失败
    TALKISSENDING, // 正在发送
    TALKINIT //   初始化
    
}TalkType;

@protocol TalkStatusViewDelegate <NSObject>

- (void)reSendaTalk:(int)talkTime;

@end

#import <UIKit/UIKit.h>

@interface TalkStatusView : UIView

@property (nonatomic, assign) int                    talkStatus;
@property (nonatomic, strong) UIImageView           *myImageView;
@property (nonatomic, assign) int                    count;
@property (nonatomic, assign) BOOL                   isRounding;
@property (nonatomic, strong) NSTimer               *timer;
@property (nonatomic, assign) int                    currentTime;
@property (nonatomic, assign) id<TalkStatusViewDelegate> delegate;

- (void)setCurrectStatus:(int)status;

@end
