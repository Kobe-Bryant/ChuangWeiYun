//
//  TCWBEngine.h
//  TCWeiBoSDK
//  Based on OAuth 2.0
//
//

#import <Foundation/Foundation.h>

#import "TCWBRequest.h"
#import "TCWBGlobalUtil.h"
#import "WBApi.h"

#define USE_UI_TWEET

@protocol SSODelegate   <NSObject>

/*! @brief 登录错误回调
 *
 * 发生错误时，客户端根据错误码作相应处理，可选择显示SDK返回的错误码
 * @param errCode 错误码
 * @param msg 错误提示信息
 */
-(void)onLoginFailed:(WBErrCode)errCode msg:(NSString*)msg;

/*! @brief 登录成功回调
 *
 * 成功后返回用户openid及token
 * @param name 微博中使用的用户名
 * @param token 凭证，由客户端保存
 */
-(void)onLoginSuccessed:(NSString*)name token:(WBToken*)token;

@end


@interface DelegateObject : NSObject
{
	id		delegate;	// 用来保存委托接收体对象, 同时又不会增加delegate的引用计数
}
@property (nonatomic, assign) id		delegate;

@end




@interface TCWBEngine : NSObject <WBRequestDelegate,WBApiDelegate>{
    
    NSString            *appKey;
    NSString            *appSecret;
    
    NSString            *accessToken;
    NSString            *name;
    NSString            *openId;
    NSString            *openKey;
    NSString            *refreshToken;
    NSString            *redirectURI;
    NSString            *ip_iphone;
    
    NSString            *publishContent;
    UIImage             *publishImage;
    
    
    NSTimeInterval      expireTime;             //超时时间
    BOOL                isRefreshTokenSuccess;//刷新token是否成功返回，yes成功，no失败
    BOOL                isUIDelegate;           //标识是否是 wb组件 
    BOOL                isSSOAuth;
    id                  temp_delegate;
    id                  auth_delegate;
    //id                  handurldelegate;
	SEL                 onSuccessCallback;
	SEL                 onFailureCallback;

    NSMutableArray      *httpRequests;          //存放request请求数组
    //UIViewController    *rootViewController;
    UINavigationController    *rootViewController;
}

@property (nonatomic, retain) NSString          *appKey;
@property (nonatomic, retain) NSString          *appSecret;
@property (nonatomic, retain) NSString          *accessToken;
@property (nonatomic, retain) NSString          *name;
@property (nonatomic, retain) NSString          *openId;
@property (nonatomic, retain) NSString          *openKey;
@property (nonatomic, retain) NSString          *refreshToken;
@property (nonatomic, retain) NSString          *redirectURI;
@property (nonatomic, retain) NSString          *ip_iphone;
@property (nonatomic, retain) NSString          *publishContent;
@property (nonatomic, retain) UIImage           *publishImage;

           
@property (nonatomic, assign) UINavigationController  *rootViewController;
@property (nonatomic, assign) NSTimeInterval    expireTime;
@property (nonatomic, assign) BOOL              isRefreshTokenSuccess;
@property (nonatomic, assign) BOOL              isUIDelegate;
@property (nonatomic, assign) BOOL              isSSOAuth;
@property (nonatomic, assign) id                auth_delegate;




/*
 *
 * 初始化TCWBEngine对象
 *
 * @param theAppKey      申请应用时分配给第三方应用程序的App key,
 * @param error          申请应用时分配给第三方应用程序的App secrect,
 * @return id            生成的TCWBEngine对象实例
 */
- (id)initWithAppKey:(NSString *)theAppKey andSecret:(NSString *)theAppSecret 
                andRedirectUrl:(NSString *)theRedirectUrl; 

/*
 * 判断授权是否过期
 *
 * return       过期返回YES，否则返回NO
 */
- (BOOL)isAuthorizeExpired;


/*
 * 基础接口请求
 *
 * @param  methodName        访问的接口,比如,"t/add"代表发表一条微博
 * @param  params            请求参数
 * @param  httpMethod        请求类型:"GET"或者"POST"
 * @param  postDataType      请求方式
 * @param  httpHeaderFields  包含httpHeader的信息（字典）
 * @param  requestDelegate   回调方法接收对象
 * @param  successCallback   接口调用成功回调方法
 * @param  failureCallback   接口调用失败回调方法
 */
- (void)initRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
              andHttpHeaderFields:(NSDictionary *)httpHeaderFields
                         delegate:(id)requestDelegate
                        onSuccess:(SEL)successCallback
                        onFailure:(SEL)failureCallback;

/*
 * 发表一条微博(t/add)
 *
 * @param  format            返回数据的格式（当前只支持方式: @"json"）
 * @param  content           微博内容
 * @param  clentip           用户ip
 * @param  longitude         经度
 * @param  latitude          纬度
 * @param  parReserved       附加参数
 * @param  requestDelegate   回调方法接收对象
 * @param  successCallback   接口调用成功回调方法
 * @param  failureCallback   接口调用失败回调方法
 */
- (void)postTextTweetWithFormat:(NSString *)format 
                        content:(NSString *)content 
                       clientIP:(NSString *)clientip  
                      longitude:(NSString *)longitude 
                    andLatitude:(NSString *)latitude 
                    parReserved:(NSDictionary *)parReserved
                       delegate:(id)requestDelegate 
                      onSuccess:(SEL)successCallback 
                      onFailure:(SEL)failuerCallback; 

/*
 * 发表一条带图片的微博(t/add_pic)
 *
 * @param  format           返回数据的格式（当前只支持方式: @"json"）
 * @param  content          微博内容
 * @param  clentip          用户ip
 * @param  compatibleFlag   容错标志
 * @param  longitude        经度
 * @param  latitude         纬度
 * @param  picture          文件域表单名
 * @param  parReserved       附加参数
 * @param  requestDelegate  回调方法接收对象
 * @param  successCallback  接口调用成功回调方法
 * @param  failureCallback  接口调用失败回调方法
 *
 */
- (void)postPictureTweetWithFormat:(NSString *)format 
                              content:(NSString *)content 
                             clientIP:(NSString *)clentip  
                                  pic:(NSData *)picture
                       compatibleFlag:(NSString *)compatibleflag
                            longitude:(NSString *)longitude 
                          andLatitude:(NSString *)latitude
                          parReserved:(NSDictionary *)parReserved
                             delegate:(id)requestDelegate 
                            onSuccess:(SEL)successCallback 
                            onFailure:(SEL)failuerCallback; 


//取消未完成的请求操作    
- (void)cancelAllRequest;
// 取消某个Delegate下所有请求
- (void)cancelSpecifiedDelegateAllRequest:(id)requestDelegate;


/*
 * 获取视频缩略图(t/getvideoinfo)
 * @param  url   回调url               
 * @param  delegate  回调
 */
-(BOOL) handleOpenURL:(NSURL *) url delegate:(id<SSODelegate>) delegate;


@end
