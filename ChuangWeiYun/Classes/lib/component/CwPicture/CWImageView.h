//
//  CWImageView.h
//  ImageDemo
//
//  Created by yunlai on 13-8-20.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CWImageViewDelegate;

@interface CWImageView : UIImageView
{
    NSString *urlStr;
    
    id <CWImageViewDelegate> delegate;
}

@property (assign, nonatomic) id <CWImageViewDelegate> delegate;

- (void)setCWPictureUrlStr:(NSString *)str;

@end


@protocol CWImageViewDelegate <NSObject>

@optional
- (void)touchCWImageView:(CWImageView *)imageView;

@end