//
//  MediaPopView.m
//  cw
//
//  Created by LuoHui on 13-12-6.
//
//

#import "MediaPopView.h"
#import "Common.h"
#import "IconPictureProcess.h"
#import "FileManager.h"

#define MediaPopViewHeight      180.f
#define MediaPopImageWidth      90.f
#define MediaPopImageHeight     70.f

#define MediaNum                100

@implementation MediaPopView

@synthesize delegate;

- (id)init
{
    CGFloat width = [self getScreenWidth];
    CGFloat height = [self getScreenHeight];
    
    self = [super initWithFrame:CGRectMake(0.f, height, width, MediaPopViewHeight)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addPopupSubviews:(NSArray *)mediaArr
{
    [super addPopupSubview];

    popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    int count = mediaArr.count;
    
    if (count > 0) {
        CGFloat width = [self getScreenWidth];
        CGFloat spaceW = (width - count * MediaPopImageWidth)/(count + 1);
        
        for (int i = 0; i < count; i++) {
            
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(spaceW*(i+1) + MediaPopImageWidth*i, 25.f, MediaPopImageWidth, MediaPopImageHeight)];
            imgView.tag = i;
            [self addSubview:imgView];
            //[imgView release];

            UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            imgBtn.frame = CGRectMake(spaceW*(i+1) + MediaPopImageWidth*i, 25.f, MediaPopImageWidth, MediaPopImageHeight);
            [imgBtn setTag:10+i];
            [imgBtn setImage:[UIImage imageCwNamed:@"icon_video_play.png"] forState:UIControlStateNormal];
            [imgBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:imgBtn];
            
            //图片
            NSString *picUrl = [[mediaArr objectAtIndex:i] objectForKey:@"image"];
            NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
            
            if (picUrl.length > 1) {
                UIImage *pic = [FileManager getPhoto:picName];
                if (pic.size.width > 2) {
                    imgView.image = pic;
                } else {
                    //[imgBtn setBackgroundImage:[UIImage imageCwNamed:@"categories_default.png"] forState:UIControlStateNormal];
                    [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] delegate:self];
                }
//            } else {
//                [imgBtn setBackgroundImage:[UIImage imageCwNamed:@"categories_default.png"] forState:UIControlStateNormal];
            }
            
            //[imgView release];
        }
        
        // 关闭按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(30.f, MediaPopViewHeight - 60.f, width - 60.f, 40.f);
        btn.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn setTag:MediaNum];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 3.f;
        btn.layer.masksToBounds = YES;
        [self addSubview:btn];
    }

    [popupView addSubview:self];
    
    [self performSelector:@selector(animationWithPop)];
}

- (CGFloat)getScreenWidth
{
    return [UIScreen mainScreen].applicationFrame.size.width;
}

- (CGFloat)getScreenHeight
{
    return [UIScreen mainScreen].applicationFrame.size.height + 20.f;
}

- (void)animationWithPop
{
    [UIView animateWithDuration:0.23 animations:^{
        self.frame = CGRectMake(0.f, [self getScreenHeight]-MediaPopViewHeight, [self getScreenWidth], MediaPopViewHeight);
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7f];
    }];
}

- (void)btnClick:(UIButton *)btn
{
    if (btn.tag != MediaNum) {
        if ([delegate respondsToSelector:@selector(mediaPopView:Index:)]) {
            [delegate mediaPopView:self Index:btn.tag - 10];
        }
    }

    [UIView animateWithDuration:0.23 animations:^{
        self.frame = CGRectMake(0.f, [self getScreenHeight], [self getScreenWidth], MediaPopViewHeight);
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    } completion:^(BOOL finished) {
        [self removeFromSuperviewSelf];
    }];
}

- (void)removeFromSuperviewSelf
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
            [view release];
        } else {
            [view removeFromSuperview];
        }
    }
    [self removeFromSuperview];
}

#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        if (iconDownloader != nil) {
            if(iconDownloader.cardIcon.size.width > 2.0) {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];

                dispatch_async(dispatch_get_main_queue(), ^{
                    for (UIImageView *imgView in self.subviews) {
                        if (imgView.tag == iconDownloader.indexPathInTableView.row) {
                            imgView.image = iconDownloader.cardIcon;
                            return;
                        }
                    }
                });
            }
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
}

- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}

@end

//#import "MediaPopView.h"
//#import "Common.h"
//#import "IconPictureProcess.h"
//#import "FileManager.h"
//#import "VideoWebView.h"
//#import <MediaPlayer/MediaPlayer.h>
//
//#define MediaPopViewHeight      180.f
//#define MediaPopImageWidth      90.f
//#define MediaPopImageHeight     70.f
//
//#define MediaNum                100
//
//@implementation MediaPopView
//
//@synthesize mediaPopViewBlock;
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
//        
//        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
//        _bgView.backgroundColor = [UIColor whiteColor];
//        
//    }
//    return self;
//}
//
//- (void)addPopupSubviews:(UIView *)view media:(NSArray *)mediaArr
//{
//    CGFloat width = [self getScreenWidth];
//    CGFloat height = [self getScreenHeight];
//    
//    self.frame = CGRectMake(0.f, 0.f, width, height);
//    
//    _bgView.frame = CGRectMake(0.f, height, width, MediaPopViewHeight);
//    
//    [self addSubview:_bgView];
//    
//    int count = mediaArr.count;
//    
//    if (count > 0) {
//        CGFloat width = [self getScreenWidth];
//        CGFloat spaceW = (width - count * MediaPopImageWidth)/(count + 1);
//        
//        for (int i = 0; i < count; i++) {
//            
//            VideoWebView *webView = [[VideoWebView alloc]initWithFrame:CGRectMake(spaceW*(i+1) + MediaPopImageWidth*i, 25.f, MediaPopImageWidth, MediaPopImageHeight)];
//            webView.tag = i;
//            [_bgView addSubview:webView];
//            [webView setWebViewUrl:[[mediaArr objectAtIndex:i] objectForKey:@"url"]];
//        }
//        
//        // 关闭按钮
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(30.f, MediaPopViewHeight - 60.f, width - 60.f, 40.f);
//        btn.backgroundColor = [UIColor colorWithRed:204.f/255.f green:204.f/255.f blue:204.f/255.f alpha:1.f];
//        [btn setTitle:@"取消" forState:UIControlStateNormal];
//        [btn setTag:MediaNum];
//        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//        btn.layer.cornerRadius = 3.f;
//        btn.layer.masksToBounds = YES;
//        [_bgView addSubview:btn];
//    }
//    NSLog(@"self.retainCount = %d",self.retainCount);
//    [view addSubview:self];
//    
//    [self performSelector:@selector(animationWithPop)];
//}
//
//- (CGFloat)getScreenWidth
//{
//    return [UIScreen mainScreen].applicationFrame.size.width;
//}
//
//- (CGFloat)getScreenHeight
//{
//    return [UIScreen mainScreen].applicationFrame.size.height + 20.f;
//}
//
//- (void)animationWithPop
//{
//    [UIView animateWithDuration:0.23 animations:^{
//        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7f];
//        _bgView.frame = CGRectMake(0.f, [self getScreenHeight] - MediaPopViewHeight, [self getScreenWidth], MediaPopViewHeight);
//    }];
//}
//
//- (void)btnClick:(UIButton *)btn
//{
//    [UIView animateWithDuration:0.23 animations:^{
//        self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
//        _bgView.frame = CGRectMake(0.f, [self getScreenHeight], [self getScreenWidth], MediaPopViewHeight);
//    } completion:^(BOOL finished) {
//        [self removeFromSuperviewSelf];
//    }];
//}
//
//- (void)removeFromSuperviewSelf
//{
//    for (UIView *view in _bgView.subviews) {
//        if (view.tag != MediaNum) {
//            [view removeFromSuperview];
//            [view release], view = nil;
//        } else {
//            [view release];
//        }
//    }
//    
//    [_bgView removeFromSuperview];
//    [self removeFromSuperview];
//    self.mediaPopViewBlock();
//    
//    NSLog(@"removeFromSuperviewSelf self.retainCount = %d",self.retainCount);
//}
//
//@end
