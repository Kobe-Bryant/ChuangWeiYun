//
//  IconPictureProcess.m
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import "IconPictureProcess.h"
#import "FileManager.h"
#import "Common.h"
#import "iconDownloader.h"
#import "downloadParam.h"
#import "imageDownLoadInWaitingObject.h"

// 数据返回时需要此锁
static NSRecursiveLock *imgLock = nil;

@implementation IconPictureProcess

@synthesize delegate;
@synthesize imageDownloadsInWaiting;
@synthesize imageDownloadsInProgress;

- (id)init
{
    self = [super init];
    
    if (self) {
        imageDownloadsInProgress = [[NSMutableDictionary alloc]initWithCapacity:0];
        imageDownloadsInWaiting = [[NSMutableArray alloc]initWithCapacity:0];
        
        if (imgLock == nil) {
            imgLock = [[NSRecursiveLock alloc]init];
        }
    }
    return self;
}

- (void)dealloc
{
    [imageDownloadsInWaiting release], imageDownloadsInWaiting = nil;
    [imageDownloadsInProgress release], imageDownloadsInProgress = nil;
    
    [super dealloc];
}

// 单例模式创建实例
+ (IconPictureProcess *)sharedPictureProcess
{
    static IconPictureProcess *iconPictureProcess = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iconPictureProcess = [[self alloc] init];
    });
    return iconPictureProcess;
}

// 获取本地缓存的图片
- (UIImage *)getPhoto:(NSString *)url
{    
    NSString *picName = [Common encodeBase64:(NSMutableData *)[url dataUsingEncoding: NSUTF8StringEncoding]];
    if (picName.length > 1) {
        return [FileManager getPhoto:picName];
    } else {
        return nil;
    }
}

// 保存缓存图片
- (BOOL)savePhoto:(UIImage *)photo url:(NSString *)url
{
    NSString *picName = [Common encodeBase64:(NSMutableData *)[url dataUsingEncoding: NSUTF8StringEncoding]];
    
    // 保存缓存图片
    if([FileManager savePhoto:picName withImage:photo]) {
        return YES;
    } else {
        return NO;
    }
}


- (void)download:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath delegate:(id)adelegate
{
    IconDownLoader *iconDownloader = [[IconDownLoader alloc] init];
    iconDownloader.downloadURL          = photoURL;
    iconDownloader.indexPathInTableView = indexPath;
    iconDownloader.imageType            = CUSTOMER_PHOTO;
    iconDownloader.delegate             = adelegate;
    iconDownloader.requestClass         = object_getClass(adelegate);
    [imageDownloadsInProgress setObject:iconDownloader forKey:photoURL];
    [iconDownloader startDownload];
    [iconDownloader release];
}

- (void)imageDownloadsWaiting:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath delegate:(id)adelegate
{
    imageDownLoadInWaitingObject *one = [[imageDownLoadInWaitingObject alloc] init:photoURL
                                                                     withIndexPath:indexPath
                                                                     withImageType:CUSTOMER_PHOTO
                                                                          delegate:adelegate];

    [imageDownloadsInWaiting insertObject:one atIndex:0];
    
    [one release];
}

// 获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath delegate:(id)adelegate
{
    // 加锁
    [imgLock lock];

    if (photoURL != nil && photoURL.length > 1
        && ![imageDownloadsInProgress.allKeys containsObject:photoURL]) {
        
//        if ([self.delegate isEqual:adelegate]) {
            if ([imageDownloadsInProgress count] >= 10) {
                [self imageDownloadsWaiting:photoURL forIndexPath:indexPath delegate:adelegate];
                return;
            }
            [self download:photoURL forIndexPath:indexPath delegate:adelegate];
            
//        } else {
//            self.delegate = adelegate;
//
//            int count = imageDownloadsInProgress.allKeys.count;
//            
//            if (count >= 5) {
//                for (NSString *url in imageDownloadsInProgress.allKeys) {
//                    IconDownLoader *iconDownloader = [imageDownloadsInProgress objectForKey:url];
//                    [iconDownloader cancelDownload];
//                    
//                    [self imageDownloadsWaiting:iconDownloader.downloadURL
//                                   forIndexPath:iconDownloader.indexPathInTableView
//                                       delegate:iconDownloader.delegate];
//                    
//                    [imageDownloadsInProgress removeObjectForKey:url];
//                }
//            } else {
//                [self download:photoURL forIndexPath:indexPath delegate:adelegate];
//            }
//        }
    }
    
    // 解锁
    [imgLock unlock];
}

- (void)removeImageDownloadsProgress:(NSString *)url
{
    if ([imageDownloadsInProgress.allKeys containsObject:url]) {
        [imageDownloadsInProgress removeObjectForKey:url];
    }

    if ([imageDownloadsInWaiting count] > 0) {
        imageDownLoadInWaitingObject *one = [imageDownloadsInWaiting objectAtIndex:0];
        [self startIconDownload:one.imageURL forIndexPath:one.indexPath delegate:one.delegate];
        [imageDownloadsInWaiting removeObjectAtIndex:0];
    }
}

@end
