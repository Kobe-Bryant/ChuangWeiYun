//
//  WeiboShare.h
//  yunPai
//
//  Created by yunlai on 13-7-17.
//
//

#import <Foundation/Foundation.h>

#import "SinaWeibo.h"

typedef enum
{
    WeiboResultSuccess,
    WeiboResultFail,
}WEIBORESULT;

@protocol WeiboShareDelegate <NSObject>

@optional
- (void)WeiboShareResult:(WEIBORESULT)result;

@end

@interface WeiboShare : NSObject <SinaWeiboRequestDelegate,SinaWeiboDelegate>
{
    SinaWeibo *sinaWeibo;

    id <WeiboShareDelegate> delegate;
}

@property (assign, nonatomic) id <WeiboShareDelegate> delegate;

- (void)sinaWeiboShareImage:(UIImage *)image text:(NSString *)text;

- (void)tencentWeiboShareImage:(UIImage *)image text:(NSString *)text;

@end
