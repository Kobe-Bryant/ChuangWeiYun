//
//  UIImageScale.h
//  飞飞Q信
//
//  Created by Eamon.Lin on 11-6-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (scale)

- (UIImage *)scaleToSize:(CGSize)viewsize;
- (UIImage *)fillSize:(CGSize)viewsize;

// 图片路径
+ (UIImage *)imageCwNamed:(NSString *)named;

// UIScrollView截图
- (UIImage *)captureScrollView:(UIScrollView *)scrollView;

// 等比缩放返回新的CGSize
+ (CGSize)fitsize:(CGSize)thisSize size:(CGSize)oldSize;

// 等比缩放返回新的CGSize (按宽度)
+ (CGSize)fitsize:(CGSize)thisSize width:(CGFloat)width;

// 等比缩放返回新的CGSize (按高度)
+ (CGSize)fitsize:(CGSize)thisSize height:(CGFloat)height;

@end 
