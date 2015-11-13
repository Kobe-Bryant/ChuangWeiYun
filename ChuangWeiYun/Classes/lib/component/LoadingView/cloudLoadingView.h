//
//  cloudLoadingView.h
//  yunPai
//
//  Created by siphp on 13-8-3.
//
//

#import <UIKit/UIKit.h>

@interface cloudLoadingView : UIView
{
    UIImageView *_backgroundImageView;
    UIImageView *_loadingImageView;
}

@property(nonatomic,retain) UIImageView *backgroundImageView;
@property(nonatomic,retain) UIImageView *loadingImageView;

@end
