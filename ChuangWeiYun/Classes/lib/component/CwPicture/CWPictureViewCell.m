//
//  CWPictureViewCell.m
//  ImageDemo
//
//  Created by yunlai on 13-8-20.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "CWPictureViewCell.h"
#import "MBProgressHUD.h"

static const CGFloat kMaxImageScale = 2.5f;
static const CGFloat kMinImageScale = 1.0f;

@implementation CWPictureViewCell

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize urlStr = _urlStr;
@synthesize blackMask = _blackMask;
@synthesize imageViewRect;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)createView
{
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    _scrollView.minimumZoomScale = kMinImageScale;
    _scrollView.maximumZoomScale = kMaxImageScale;
    _scrollView.zoomScale = 1;
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:_imageView];
    
    [self addGestureRecognizers];
}

- (void)setPictureViewCellContent:(UIImageView *)imageView rect:(CGRect)conRect
{
    NSLog(@"kkjkljkl");
    imageViewRect = conRect;
    _imageView.frame = conRect;
    _imageView.image = imageView.image;
    
    [UIView animateWithDuration:0.4f animations:^{
        _imageView.frame = [self centerFrameFromImage:imageView.image];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [_scrollView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(twoTapGesture:)];
    twoTap.numberOfTapsRequired = 2;
    twoTap.numberOfTouchesRequired = 1;
    [_scrollView addGestureRecognizer:twoTap];
    
    [tap requireGestureRecognizerToFail:twoTap];
    
    [twoTap release], twoTap = nil;
    [tap release], tap = nil;

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGesture:)];
    [_scrollView addGestureRecognizer:pinch];
    [pinch release], pinch = nil;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [_scrollView addGestureRecognizer:longPress];
    [longPress release], pinch = nil;
}

// 单击事件
- (void)tapGesture:(UITapGestureRecognizer *)tap
{
//    NSLog(@"dufu sssss tapGesture");

    _imageView.clipsToBounds = YES;

    [UIView animateWithDuration:0.23 animations:^{
        _imageView.frame = imageViewRect;
        _blackMask.alpha = 0.f;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide] ;
    } completion:^(BOOL finished) {
        _imageView.image = nil;

        if ([delegate respondsToSelector:@selector(removePictureView)]) {
            [delegate removePictureView];
        }
        
        [_scrollView removeGestureRecognizer:tap];
    }];
}

// 双击事件
- (void)twoTapGesture:(UITapGestureRecognizer *)twoTap
{
//    NSLog(@"ddddd");
    CGPoint pointInView = [twoTap locationInView:_imageView];
    [self zoomInZoomOut:pointInView];
}

// 捏合事件
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinch
{
    CGFloat newZoomScale = _scrollView.zoomScale / 1.5f;
    
    newZoomScale = MAX(newZoomScale, _scrollView.minimumZoomScale);
    
    [_scrollView setZoomScale:newZoomScale animated:YES];
}

// 长按事件
- (void)longPressGesture:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"保存到相册" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
    }
}

// 设置_scrollView的大小比例
- (void)zoomInZoomOut:(CGPoint)point
{
    CGFloat newZoomScale =
    _scrollView.zoomScale > (_scrollView.maximumZoomScale/2) ? _scrollView.minimumZoomScale : _scrollView.maximumZoomScale;
//    NSLog(@"newZoomScale = %f",newZoomScale);
    CGSize scrollViewSize = _scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
//    NSLog(@"rectToZoomTo = %f,%f,%f,%f",rectToZoomTo.origin.x,rectToZoomTo.origin.y,rectToZoomTo.size.width,rectToZoomTo.size.height);
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
}

// 设置_scrollView的大小比例
- (void)zoomInZoomIn:(CGPoint)point
{
    if (_scrollView.zoomScale > (_scrollView.maximumZoomScale/2)) {
        CGFloat newZoomScale = _scrollView.minimumZoomScale;
        CGSize scrollViewSize = _scrollView.bounds.size;
        CGFloat w = scrollViewSize.width / newZoomScale;
        CGFloat h = scrollViewSize.height / newZoomScale;
        CGFloat x = point.x - (w / 2.0f);
        CGFloat y = point.y - (h / 2.0f);
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        [_scrollView zoomToRect:rectToZoomTo animated:YES];
    }
}

// 返回image的大小
- (CGRect)centerFrameFromImage:(UIImage *)image
{
    if(!image)
        return CGRectZero;
    
    CGSize newImageSize = [self imageResizeBaseOnWidth:self.bounds.size.width oldWidth:image.size.width oldHeight:image.size.height];

    newImageSize.height = MIN(self.bounds.size.height,newImageSize.height);
    
    return CGRectMake(0.0f, self.bounds.size.height/2 - newImageSize.height/2, newImageSize.width, newImageSize.height);
}

- (CGSize)imageResizeBaseOnWidth:(CGFloat)newWidth oldWidth:(CGFloat)oldWidth oldHeight:(CGFloat)oldHeight
{
    CGFloat scaleFactor = newWidth / oldWidth;
    CGFloat newHeight = oldHeight * scaleFactor;
    
    return CGSizeMake(newWidth, newHeight);
}

// 设置_imageView的大小
- (void)centerScrollViewContents
{
    CGSize boundsSize = self.frame.size;
    CGRect contentsFrame = _imageView.frame;
    
//    NSLog(@"boundsSize = %f,%f",boundsSize.width,boundsSize.height);
//    NSLog(@"contentsFrame = %f,%f,%f,%f",contentsFrame.origin.x,contentsFrame.origin.y,contentsFrame.size.width,contentsFrame.size.height);
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    _imageView.frame = contentsFrame;
    imageViewRect = _imageView.frame;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidZoom...");
    [self centerScrollViewContents];
}

- (void)progressHUDTmp:(NSString *)str
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self];
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ok_normal.png"]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    [[UIApplication sharedApplication].delegate.window addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1.5];
    progressHUDTmp.labelText = str;
    [progressHUDTmp release];
}
#pragma mark -
#pragma mark 保存图片委托
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
	if (!error) {
		NSLog(@"codeImage written success");
        [self progressHUDTmp:@"已保存到本地相册"];
    } else {
		NSLog(@"Error writing to photo album: %@", [error localizedDescription]);
        [self progressHUDTmp:@"保存失败"];
    }
}


#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)dealloc
{
    NSLog(@"CWPictureViewCell dealloc....");
    
    [_scrollView release], _scrollView = nil;
    [_imageView release], _imageView = nil;
    [_blackMask release], _blackMask = Nil;
    [_urlStr release], _urlStr = nil;
    
    [super dealloc];
}


@end
