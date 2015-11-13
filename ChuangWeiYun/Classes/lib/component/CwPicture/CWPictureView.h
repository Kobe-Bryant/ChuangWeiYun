//
//  CWPictureView.h
//  ImageDemo
//
//  Created by yunlai on 13-8-20.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableScrollView.h"
#import "CWPictureViewCell.h"

typedef void (^CwPictureViewClosingBlock)(void);

@protocol CWPictureViewDelegate;

@interface CWPictureView : UIView <UITableScrollViewDelagate,CWPictureViewCellDelegate>
{
    UITableScrollView *_scrollView;
    
    UIImageView *fromImageView;
    NSString *urlStr;
    
    UIView *_appView;
    UIView *_blackMask;
    UIPageControl *_pageControl;
    UIButton *leftBtn;
    UIButton *rightBtn;
    
    CwPictureViewClosingBlock CwPictureViewClose;
    int selectIndex;
    int currIndex;
    
    id <CWPictureViewDelegate> delegate;
}

@property (retain, nonatomic) UITableScrollView *scrollView;
@property (retain, nonatomic) UIImageView *fromImageView;
@property (retain, nonatomic) NSString *urlStr;
@property (retain, nonatomic) UIView *appView;
@property (retain, nonatomic) UIView *blackMask;
@property (retain, nonatomic) NSMutableArray *imgViewArr;
@property (copy, nonatomic) CwPictureViewClosingBlock CwPictureViewClose;
@property (assign, nonatomic) id <CWPictureViewDelegate> delegate;
@property (assign, nonatomic) int selectIndex;

- (id)initWithclickIndex:(NSInteger)aclickIndex;

//- (void)setPictureView:(UIImageView *)imageView url:(NSString *)url;
- (void)setPictureView:(NSMutableArray *)imgArr;

@end

@protocol CWPictureViewDelegate <NSObject>

@required
- (void)cwPictureViewSetPage:(int)page;

@end
