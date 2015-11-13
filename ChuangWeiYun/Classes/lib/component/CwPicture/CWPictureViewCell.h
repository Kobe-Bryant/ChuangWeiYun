//
//  CWPictureViewCell.h
//  ImageDemo
//
//  Created by yunlai on 13-8-20.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "UITableScrollViewCell.h"

@protocol CWPictureViewCellDelegate;

@interface CWPictureViewCell : UITableScrollViewCell <UIScrollViewDelegate, UIAlertViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    NSString *_urlStr;
    UIView *_blackMask;
    
    BOOL clickFlag;
    
    CGRect imageViewRect;
    id <CWPictureViewCellDelegate> delegate;
}

@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) NSString *urlStr;
@property (retain, nonatomic) UIView *blackMask;
@property (assign, nonatomic) CGRect imageViewRect;
@property (assign, nonatomic) id <CWPictureViewCellDelegate> delegate;

- (void)createView;

- (void)setPictureViewCellContent:(UIImageView *)imageView rect:(CGRect)conRect;

- (void)zoomInZoomIn:(CGPoint)point;

@end

@protocol CWPictureViewCellDelegate <NSObject>

@optional
- (void)removePictureView;

@end
