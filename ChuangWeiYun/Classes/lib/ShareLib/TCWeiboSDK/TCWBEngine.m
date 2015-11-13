//
//  TCWBEngine.m
//  TCWeiBoSDK
//  Based on OAuth 2.0
//
//

#import "TCWBEngine.h"
#import "TCWBGlobalUtil.h"

#include "GetIPAddress.h"

#define BUFFERSIZE    4000  
#define MAXADDRS    32  

#define TCURLSchemePrefix              @"TC_"

#define TCKeychainServiceNameSuffix    @"_WeiBoServiceName"
#define TCKeychainAccessToken          @"WeiBoAccessToken"
#define TCKeychainExpireTime           @"WeiBoExpireTime"
#define TCKeychainOpenId               @"WeiBoOpenId"
#define TCKeychainOpenKey              @"WeiBoOpenKey"
#define TCKeychainRefreshToken         @"WeiBoRefreshToken"
#define TCKeychainName                 @"WeiBoName"

@implementation DelegateObject

@synthesize delegate;

@end

static BOOL G_LOGOUT = NO;

static id   handurldelegate = nil;

@interface TCWBEngine (Private)

- (NSString *)urlSchemeString;

//存储到keychain
- (BOOL)saveAuthorizeDataToKeychain;
//从keychain中删除
- (BOOL)deleteAuthorizeDataInKeychain;

- (void) managerRequestWithRequest:(TCWBRequest *)request
                          delegate:(id)delegate
                           success:(SEL)successCallback
                        andFailure:(SEL)failureCallback;
@end

@implementation TCWBEngine

@synthesize appKey;
@synthesize appSecret;
@synthesize accessToken;
@synthesize name;
@synthesize openId;
@synthesize openKey;
@synthesize refreshToken;
@synthesize expireTime;
@synthesize redirectURI;
@synthesize ip_iphone;
@synthesize publishContent;
@synthesize publishImage;
@synthesize isRefreshTokenSuccess;
@synthesize rootViewController;
@synthesize isUIDelegate;
@synthesize auth_delegate;
@synthesize isSSOAuth;
#pragma mark - TCWBEngine Life Circle

- (id)initWithAppKey:(NSString *)theAppKey andSecret:(NSString *)theAppSecret andRedirectUrl:(NSString *)theRedirectUrl{

    if ((self = [super init])){
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
        self.redirectURI = theRedirectUrl;
        httpRequests = [[NSMutableArray alloc] initWithCapacity:2];
        self.rootViewController = nil;
        self.isSSOAuth = YES;
        self.isRefreshTokenSuccess = YES;
    }
    
    return self;
}

- (void)dealloc{
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    [accessToken release],accessToken = nil;
    [refreshToken release],refreshToken = nil;
    [openId release],openId = nil;
    [openKey release],openKey = nil;
    [redirectURI release],redirectURI = nil;
    [ip_iphone release],ip_iphone = nil;
    
    [self cancelAllRequest];
    [httpRequests release];
    publishContent = nil;
    publishImage = nil;
    [super dealloc];
}
 

#pragma mark - TCWBEngine Private Methods

- (void)cancelAllRequest {
	for (int i = 0; i < [httpRequests count]; i++) {
		NSDictionary *dicItem = [httpRequests objectAtIndex:i];
		TCWBRequest *requestItem = (TCWBRequest *)[dicItem objectForKey:@"Request"];
		if (!(requestItem.complete)) {
			[requestItem disconnect];
		}
	}
}

// 取消某个Delegate下所有请求
- (void)cancelSpecifiedDelegateAllRequest:(id)requestDelegate {
    for (int i = 0; i < [httpRequests count]; i++) {
		NSDictionary *dicItem = [httpRequests objectAtIndex:i];
        id del = ((DelegateObject *)[dicItem objectForKey:@"Delegate"]).delegate;
        if (requestDelegate == del) {
            TCWBRequest *requestItem = (TCWBRequest *)[dicItem objectForKey:@"Request"];
            if (!(requestItem.complete)) {
                [requestItem disconnect];
            }
        }
    } 
}

- (NSString *)urlSchemeString{
    return [NSString stringWithFormat:@"%@%@", TCURLSchemePrefix, appKey];
}


#pragma mark - private method

//处理request请求，存入数组
- (void) managerRequestWithRequest:(TCWBRequest *)request 
                          delegate:(id)delegates
                           success:(SEL)successCallback
                        andFailure:(SEL)failureCallback{
    NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:3];
	for (int i = 0; i < [httpRequests count]; i++) {
		NSDictionary *dicItem = [httpRequests objectAtIndex:i];
		TCWBRequest *wBRequest = (TCWBRequest *)[dicItem objectForKey:@"Request"];
		if (YES == wBRequest.complete) {
			[tmpArray addObject:dicItem]; 
		}
	}
	[httpRequests removeObjectsInArray:tmpArray];
	[tmpArray release];
    
	NSMutableDictionary *dicItem = [[NSMutableDictionary alloc] initWithCapacity:3];
    if (request != nil) {
        [dicItem setObject:request forKey:@"Request"];
    }
    if (delegates != nil) {
        DelegateObject *del = [[DelegateObject alloc] init];
        del.delegate = delegates;
    	[dicItem setObject:del forKey:@"Delegate"];
        [del release];
    }
	if (successCallback != nil) {
		[dicItem setObject:NSStringFromSelector(successCallback) forKey:@"SuccessCallBack"];
	}
	if (failureCallback != nil) {
		[dicItem setObject:NSStringFromSelector(failureCallback)  forKey:@"FailureCallback"];
	}
	[httpRequests addObject:dicItem];
	[dicItem release];
}

#pragma mark - public method


// 存储刷新accesstoken信息
- (void)saveWBTokenInfo:(WBToken *)token name:(NSString*)sname{
   
    if(token != nil)
    {
        //NSString *abc = [[NSString alloc ] init]
        self.accessToken = [NSString stringWithFormat:@"%@",token.accessToken];
        self.openId = [NSString stringWithFormat:@"%@",token.openid];
        self.name = [NSString stringWithFormat:@"%@",sname];
        
        
    }
   
}

//请求刷新accessToken接口
- (NSString *)refreshAccessToken:(NSString *)appkey 
                grant_type:(NSString *)grantType
          andRefresh_token:(NSString *)refreshtoken {
    NSDictionary *params = [[NSDictionary alloc]initWithObjectsAndKeys:appkey, CLIENT_ID,
                            grantType, GRANT_TYPE,
                            refreshtoken, REFRESH_TOKEN,nil];
    NSString *urlString = [TCWBRequest serializeURL:kWBAccessTokenURL params:params httpMethod:@"GET"];
    [params release];
    
    TCWBRequest *accessTokenRequest = [TCWBRequest requestWithURL:urlString];
    NSData *returnData = [accessTokenRequest connect:urlString];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return  [returnString autorelease];
}

//基础接口
- (void)initRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
              andHttpHeaderFields:(NSDictionary *)httpHeaderFields
                         delegate:(id)requestDelegate
                        onSuccess:(SEL)successCallback
                        onFailure:(SEL)failureCallback{
    
    temp_delegate = requestDelegate;
    onSuccessCallback = successCallback;
    onFailureCallback = failureCallback;

    NSString *url = [[NSString alloc]initWithFormat:@"%@%@?",TCWBSDKAPIDomain,methodName];

    // 2012-09-17 增加appfrom参数
    NSMutableDictionary *dicParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if (![[params allKeys] containsObject:@"appfrom"]) {
        [dicParams setObject:@"ios-sdk-2.0" forKey:@"appfrom"];
    }
    
    if ([ip_iphone length] == 0) {
        self.ip_iphone = [NSString stringWithFormat:@"%@",[self deviceIPAdress]];
    }
    
    
    TCWBRequest *request = [TCWBRequest requestWithURL:url
                                           AccessToken:accessToken 
                                                appkey:self.appKey
                                                openId:openId 
                                              clientip:ip_iphone
                                         oauth_version:@"2.a" 
                                                 scope:@"all"
                                          postDataType:postDataType
                                            httpMethod:httpMethod
                                                params:dicParams
                                      httpHeaderFields:nil
                                              delegate:self];
    [request connect];
    [url release];
    
    [self managerRequestWithRequest:request 
                           delegate:requestDelegate
                            success:successCallback 
                         andFailure:failureCallback];
}


#pragma mark - 发表相关

//function: 发表一条微博
//http://wiki.open.t.qq.com/index.php/微博相关/发布一条微博数据
- (void)postTextTweetWithFormat:(NSString *)format 
                           content:(NSString *)content 
                          clientIP:(NSString *)clentip  
                         longitude:(NSString *)longitude 
                       andLatitude:(NSString *)latitude
                       parReserved:(NSDictionary *)parReserved
                          delegate:(id)requestDelegate 
                         onSuccess:(SEL)successCallback 
                         onFailure:(SEL)failuerCallback{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:5];
    [dic setObject:format forKey:@"format"];
    if (content != nil) {
        [dic setObject:content forKey:@"content"];
    }
    if (clentip != nil) {
        [dic setObject:clentip forKey:@"clientip"];
    }
    if (longitude != nil) {
        [dic setObject:longitude forKey:@"longitude"];
    }
    if (latitude != nil) {
        [dic setObject:latitude forKey:@"latitude"];
    }
    NSArray *arrReservedKeys = [parReserved allKeys];
    for (NSString *keyItem in arrReservedKeys) {
        [dic setObject:[parReserved objectForKey:keyItem] forKey:keyItem];
    }
    [self initRequestWithMethodName:@"t/add"
                         httpMethod:@"POST" 
                             params:dic
                       postDataType:kWBRequestPostDataTypeNormal
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failuerCallback];
    [dic release];
}

//发表一条带图片的微博
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
                            onFailure:(SEL)failuerCallback{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:5];
    [dic setObject:format forKey:@"format"];
    if (compatibleflag != nil) {
        [dic setObject:compatibleflag forKey:@"compatibleflag"];
    }
    if (content != nil) {
        [dic setObject:content forKey:@"content"];
    }
    if (clentip != nil) {
        [dic setObject:clentip forKey:@"clientip"];
    }
    if (picture != nil) {
        [dic setObject:picture forKey:@"pic"];
    }
    if (longitude != nil) {
        [dic setObject:longitude forKey:@"longitude"];
    }
    if (latitude != nil) {
        [dic setObject:latitude forKey:@"latitude"];
    }
    NSArray *arrReservedKeys = [parReserved allKeys];
    for (NSString *keyItem in arrReservedKeys) {
        [dic setObject:[parReserved objectForKey:keyItem] forKey:keyItem];
    }

    [self initRequestWithMethodName:@"t/add_pic"
                         httpMethod:@"POST" 
                             params:dic
                       postDataType:kWBRequestPostDataTypeMultipart
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failuerCallback];

    [dic release];
    
}



- (void)gethtRecentUsedWithFormat:(NSString *)format 
                           reqNum:(NSUInteger)reqnum 
                             page:(NSUInteger)page 
                      andSortType:(NSUInteger)sorttype
                      parReserved:(NSDictionary *)parReserved
                         delegate:(id)requestDelegate
                        onSuccess:(SEL)successCallback
                        onFailure:(SEL)failureCallback{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:4];
    [dic setObject:format forKey:@"format"];
    [dic setObject:[NSNumber numberWithInteger:reqnum] forKey:@"reqnum"];
    [dic setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    [dic setObject:[NSNumber numberWithInteger:sorttype] forKey:@"sorttype"];
    [self initRequestWithMethodName:@"ht/recent_used"
                         httpMethod:@"GET"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNone
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
}

- (void)getTransTweetWithFormat:(NSString *)format 
                           flag:(NSUInteger)flag 
                         rootID:(NSString *)rootid 
                       pageFlag:(NSUInteger)pageflag 
                       pageTime:(NSString *)pagetime 
                         reqNum:(NSUInteger)reqnum 
                   andTweetID:(NSString *)twitterid
                    parReserved:(NSDictionary *)parReserved
                       delegate:(id)requestDelegate 
                      onSuccess:(SEL)successCallback 
                      onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:7];
    [dic setObject:format forKey:@"format"];
    [dic setObject:[NSNumber numberWithInteger:flag] forKey:@"flag"];
    [dic setObject:[NSNumber numberWithInteger:pageflag] forKey:@"pageflag"];
    [dic setObject:[NSNumber numberWithInteger:reqnum] forKey:@"reqnum"];
    if (rootid != nil) {
        [dic setObject:rootid forKey:@"rootid"];
    }
    if (pagetime != nil) {
        [dic setObject:pagetime forKey:@"pagetime"];
    }
    if (twitterid != nil) {
        [dic setObject:twitterid forKey:@"twitterid"];
    }
    [self initRequestWithMethodName:@"t/re_list"
                         httpMethod:@"GET"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNone
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
}

- (void)gethtFavListWithFormat:(NSString *)format 
                         reqNum:(NSUInteger)reqnum  
                       pageFlag:(NSUInteger)pageflag 
                       pageTime:(NSString*)pagetime 
                      andLastID:(NSString *)lastid
                    parReserved:(NSDictionary *)parReserved
                       delegate:(id)requestDelegate 
                      onSuccess:(SEL)successCallback 
                      onFailure:(SEL)failureCallback{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:5];
    [dic setObject:format forKey:@"format"];
    [dic setObject:[NSNumber numberWithInteger:reqnum] forKey:@"reqnum"];
    [dic setObject:[NSNumber numberWithInteger:pageflag] forKey:@"pageflag"];
    if (pagetime != nil) {
        [dic setObject:pagetime forKey:@"pagetime"];
    }
    if (lastid != nil) {
        [dic setObject:lastid forKey:@"lastid"];
    }
    [self initRequestWithMethodName:@"fav/list_ht" 
                         httpMethod:@"GET"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNone
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
}
#pragma mark - 用户相关

- (void)getUserInfoWithFormat:(NSString *)format
                  parReserved:(NSDictionary *)parReserved
                     delegate:(id)requestDelegate 
                    onSuccess:(SEL)successCallback 
                    onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dic setObject:format forKey:@"format"];
    [self initRequestWithMethodName:@"user/info" 
                         httpMethod:@"GET"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNone
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
}

- (void)getOtherUserInfoWithFormat:(NSString *)format
                              name:(NSString *)username 
                           andOpenID:(NSString *)fopenid 
                       parReserved:(NSDictionary *)parReserved
                          delegate:(id)requestDelegate
                         onSuccess:(SEL)successCallback
                         onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:3];
    [dic setObject:format forKey:@"format"];
    if (username != nil) {
        [dic setObject:username forKey:@"name"];
    }
    if (fopenid != nil) {
        [dic setObject:fopenid forKey:@"fopenid"];
    }
    if (username != nil || fopenid != nil) {
        [self initRequestWithMethodName:@"user/other_info"
                             httpMethod:@"GET"
                                 params:dic
                           postDataType:kWBRequestPostDataTypeNone
                    andHttpHeaderFields:nil
                               delegate:requestDelegate
                              onSuccess:successCallback
                              onFailure:failureCallback];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"用户名和fopenid至少选填一个" 
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    [dic release];
}

- (void)getInfosWithFormat:(NSString *)format 
                     names:(NSString *)names
                  fopenids:(NSString *)fopenids
               parReserved:(NSDictionary *)parReserved
                  delegate:(id)requestDelegate
                 onSuccess:(SEL)successCallback
                 onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:3];
    [dic setObject:format forKey:@"format"];
    if (names != nil) {
        [dic setObject:names forKey:@"names"];
    }
    if (fopenids != nil) {
        [dic setObject:fopenids forKey:@"fopenids"];
    }
    [self initRequestWithMethodName:@"user/infos"
                         httpMethod:@"GET"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNone
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
}

#pragma mark - 关系链相关
- (void)getFriendIdolListWithFormat:(NSString *)format  
                             reqNum:(NSUInteger)reqnum  
                         startIndex:(NSUInteger)startindex 
                            andInstall:(NSUInteger)install 
                        parReserved:(NSDictionary *)parReserved
                           delegate:(id)requestDelegate                  
                          onSuccess:(SEL)successCallback
                          onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:4];
    [dic setObject:format forKey:@"format"];
    [dic setObject:[NSNumber numberWithInteger:reqnum] forKey:@"reqnum"];
    [dic setObject:[NSNumber numberWithInteger:startindex] forKey:@"startindex"];
    [dic setObject:[NSNumber numberWithInteger:install] forKey:@"install"];
    [self initRequestWithMethodName:@"friends/idollist"
                         httpMethod:@"GET"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNone
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
    
}

- (void)getFriendFansListWithFormat:(NSString *)format
                             reqNum:(NSUInteger)reqnum
                         startIndex:(NSUInteger)startindex
                               mode:(NSUInteger)mode
                            install:(NSUInteger)install
                             andSex:(NSUInteger)sex
                        parReserved:(NSDictionary *)parReserved
                           delegate:(id)requestDelegate 
                          onSuccess:(SEL)successCallback
                          onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:5];
    [dic setObject:format forKey:@"format"];
    [dic setObject:[NSNumber numberWithInteger:reqnum] forKey:@"reqnum"];
    [dic setObject:[NSNumber numberWithInteger:startindex] forKey:@"startindex"];
    [dic setObject:[NSNumber numberWithInteger:mode] forKey:@"mode"];
    [dic setObject:[NSNumber numberWithInteger:install] forKey:@"install"];
    [dic setObject:[NSNumber numberWithInteger:sex] forKey:@"sex"];
    [self initRequestWithMethodName:@"friends/fanslist"
                         httpMethod:@"GET"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNone
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
}

- (void)getFriendMutualListWithFormat:(NSString *)format
                                 name:(NSString *)username
                              fopenID:(NSString *)fopenid
                               reqNum:(NSUInteger)reqnum
                           startIndex:(NSUInteger)startindex
                              andInstall:(NSUInteger)install
                          parReserved:(NSDictionary *)parReserved
                             delegate:(id)requestDelegate 
                            onSuccess:(SEL)successCallback
                            onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:6];
    [dic setObject:format forKey:@"format"];
    if (name != nil) {
        [dic setObject:username forKey:@"name"];
    }
    if (fopenid != nil) {
        [dic setObject:fopenid forKey:@"fopenid"];
    }
    [dic setObject:[NSNumber numberWithInteger:reqnum] forKey:@"reqnum"];
    [dic setObject:[NSNumber numberWithInteger:startindex] forKey:@"startindex"];
    [dic setObject:[NSNumber numberWithInteger:install] forKey:@"install"];
    if (fopenid != nil || name != nil) {
        [self initRequestWithMethodName:@"friends/mutual_list"
                             httpMethod:@"GET"
                                 params:dic
                           postDataType:kWBRequestPostDataTypeNone
                    andHttpHeaderFields:nil
                               delegate:requestDelegate
                              onSuccess:successCallback
                              onFailure:failureCallback];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"用户名和fopenid至少选填一个" 
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    [dic release];
}


#pragma mark - lbs

- (void)getAroundNewsWithFormat:(NSString *)format
                   longitude:(NSString *)longitude
                    latitude:(NSString *)latitude
                    pageInfo:(NSString *)pageinfo
                    andPageSize:(NSUInteger)pagesize 
                 parReserved:(NSDictionary *)parReserved
                    delegate:(id)requestDelegate
                   onSuccess:(SEL)successCallback 
                   onFailure:(SEL)failureCallback{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:5];
    [dic setObject:format forKey:@"format"];
    if (longitude != nil) {
        [dic setObject:longitude forKey:@"longitude"];
    }
    if (latitude != nil) {
        [dic setObject:latitude forKey:@"latitude"];
    }
    [dic setObject:pageinfo forKey:@"pageinfo"];
    [dic setObject:[NSNumber numberWithInteger:pagesize] forKey:@"pagesize"];
    [self initRequestWithMethodName:@"lbs/get_around_new"
                         httpMethod:@"POST"
                             params:dic
                       postDataType:kWBRequestPostDataTypeNormal
                andHttpHeaderFields:nil
                           delegate:requestDelegate
                          onSuccess:successCallback
                          onFailure:failureCallback];
    [dic release];
}


#pragma mark - TCWBEngine Public Methods

//判断授权是否过期
//比如 你换token的时间是 A， 返回的过期时间是expire_in，当前时间是B
//A+expire_in < B 就是过期了
//A+expire_in > B就是没有过期
- (BOOL)isAuthorizeExpired{
    if(expireTime == 0)
        return  NO;
    if ([[NSDate date] timeIntervalSince1970] > expireTime){
        [self deleteAuthorizeDataInKeychain];
        return YES;
    }
    return NO;
}

- (BOOL)isLoggedIn
{
    return name && accessToken;
}



//使用已有授权信息登录
- (void)logInWithAccessToken:(NSString *)theAccessToken 
                 expiredTime:(NSString *)theExpiredTime  
                      openID:(NSString *)theOpenid
             andRefreshToken:(NSString *)theRefreshToken 
                    delegate:(id)delegate 
                   onSuccess:(SEL)successCallback 
                   onFailure:(SEL)failureCallback{
    temp_delegate = delegate;
    onSuccessCallback = successCallback;
    onFailureCallback = failureCallback;
    self.accessToken = theAccessToken;
    self.expireTime = [theExpiredTime intValue]+ [[NSDate date] timeIntervalSince1970];
    self.openId = theOpenid;
    self.refreshToken = theRefreshToken;
    [self saveAuthorizeDataToKeychain];
    if (![self isAuthorizeExpired]) {
        if ([temp_delegate respondsToSelector:onSuccessCallback]) {
            [temp_delegate performSelector:onSuccessCallback withObject:nil];
        }
    }
    else{    
        if ([temp_delegate respondsToSelector:onFailureCallback]) {
            [temp_delegate performSelector:onFailureCallback withObject:nil];
        }
    }
}

- (NSString *)deviceIPAdress {
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    return [NSString stringWithFormat:@"%s", ip_names[1]];
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(TCWBRequest *)req didFinishLoadingWithResult:(id)result{
    id delegates = nil;
    SEL successCallback = nil;
	for (int i = 0; i < [httpRequests count]; i++) {
		NSDictionary *dicItem = [httpRequests objectAtIndex:i];
		TCWBRequest *requestItem = (TCWBRequest *)[dicItem objectForKey:@"Request"];
		if (req == requestItem) {
			delegates = ((DelegateObject *)[dicItem objectForKey:@"Delegate"]).delegate;
			successCallback = NSSelectorFromString([dicItem objectForKey:@"SuccessCallBack"]);
            break;
		}
    }    
    if ([delegates respondsToSelector:successCallback]) {
        [delegates performSelector:successCallback withObject:result];
    }
}

- (void)request:(TCWBRequest *)req didFailWithError:(NSError *)error{
    // 2012-09-11 By Yi Minwen: 失败处理增加判断
    id delegate = nil;
    //SEL failureCallback = nil;
	for (int i = 0; i < [httpRequests count]; i++) {
		NSDictionary *dicItem = [httpRequests objectAtIndex:i];
		TCWBRequest *requestItem = (TCWBRequest *)[dicItem objectForKey:@"Request"];
		if (req == requestItem) {
			delegate = ((DelegateObject *)[dicItem objectForKey:@"Delegate"]).delegate;
			//failureCallback = NSSelectorFromString([dicItem objectForKey:@"FailureCallback"]);
            break;
		}
    }
    if ([delegate respondsToSelector:onFailureCallback]) {
        [delegate performSelector:onFailureCallback withObject:error];
    }
}

#pragma mark - WBApiDelegate

#pragma mark - WBApiDelegate
-(void)onLoginFailed:(WBErrCode)errCode msg:(NSString*)msg;
{
    G_LOGOUT = YES;
    if ([temp_delegate respondsToSelector:onFailureCallback]) {
        [temp_delegate performSelector:onFailureCallback withObject:nil];
    }
    [handurldelegate    onLoginFailed:errCode msg:msg];
    

}

-(void)onLoginSuccessed:(NSString*)sname token:(WBToken*)token;
{
    G_LOGOUT = NO;
    
    isSSOAuth = YES;
    [self saveWBTokenInfo:token name:sname];
    //self.name = [[NSString alloc] initWithFormat:@"%@",sname ];
    self.expireTime = token.expires +[[NSDate date] timeIntervalSince1970];
    
    BOOL saveKeychainOK = [self saveAuthorizeDataToKeychain];
    if (!saveKeychainOK) {
        BOOL deleteKeychainOK = [self deleteAuthorizeDataInKeychain];
        if (deleteKeychainOK) {
            [self saveAuthorizeDataToKeychain];
        }
    }
    
    if ([temp_delegate respondsToSelector:onSuccessCallback]) {
        [temp_delegate performSelector:onSuccessCallback withObject:nil];
    }
    [handurldelegate    onLoginSuccessed:sname token:token];

}


-(BOOL) handleOpenURL:(NSURL *) url delegate:(id<SSODelegate>) delegate
{
    handurldelegate = delegate;
    if(isUIDelegate == YES && auth_delegate!=nil)
    {
        return [WBApi handleOpenURL:url delegate:auth_delegate];
    }
    else
    {
        return [WBApi handleOpenURL:url delegate:self];
    }
    
}


@end
