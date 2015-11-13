//
//  CWImageView.m
//  ImageDemo
//
//  Created by yunlai on 13-8-20.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "CWImageView.h"

@implementation CWImageView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        twoTap.numberOfTapsRequired = 2;
        twoTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:twoTap];
        
        [tap requireGestureRecognizerToFail:twoTap];
        
        [twoTap release], twoTap = nil;
        [tap release], tap = nil;
    }
    return self;
}

- (void)setCWPictureUrlStr:(NSString *)str
{
    if (urlStr) {
        [urlStr release], urlStr = nil;
    }
    urlStr = [[NSString alloc]initWithString:str];
}

- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    if ([delegate respondsToSelector:@selector(touchCWImageView:)]) {
        [delegate touchCWImageView:self];
    }
}

- (void)dealloc
{
    [urlStr release], urlStr = nil;
    
    [super dealloc];
}


@end
