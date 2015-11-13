//
//  IconPictureProcess.h
//  cw
//
//  Created by yunlai on 13-9-2.
//
//

#import <Foundation/Foundation.h>

@interface IconPictureProcess : NSObject
{
    id delegate;
}

@property (retain, nonatomic) id delegate;

@property(nonatomic,retain) NSMutableArray *imageDownloadsInWaiting;
@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress;


// 单例模式创建实例
+ (IconPictureProcess *)sharedPictureProcess;

//获取本地缓存的图片
- (UIImage *)getPhoto:(NSString *)url;

//保存缓存图片
- (BOOL)savePhoto:(UIImage *)photo url:(NSString *)url;

//获取网络图片
- (void)startIconDownload:(NSString*)photoURL forIndexPath:(NSIndexPath*)indexPath delegate:(id)delegate;

- (void)removeImageDownloadsProgress:(NSString *)url;

@end
