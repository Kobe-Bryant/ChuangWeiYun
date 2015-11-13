//
//  boxViewController.h
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import <UIKit/UIKit.h>
#import "IconDownLoader.h"
#import "MBProgressHUD.h"
#import "ShareAPIAction.h"
#import "WeiboView.h"
#import "PopUpdateVerView.h"
#import "PopUpdateSucessView.h"
#import "PopCheckUpdateView.h"
#import "PopClearChcheView.h"
#import "CitySubbranchViewController.h"
#import "Login_FeedbackViewController.h"
#import "boxView.h"

@interface boxViewController : UIViewController<IconDownloaderDelegate,MBProgressHUDDelegate,PopUpdateCheckDelegate,PopUpdateVerDelegate,ShareAPIActionDelegate,CitySubbranchViewControllerDelegate,PopChearDelegate,Login_FeedbackViewControllerDelegate, UIAlertViewDelegate,boxBtnDelegate>
{
    UIScrollView            *mainScrollView;
    UIView                  *introductionView;
    UIView                  *moreView;
    UIActivityIndicatorView *spinner;
    
    CGFloat                 iconWidth;
    CGFloat                 iconHeight;
    CGFloat                 iconBgWidth;
    CGFloat                 iconBgHeight;
    UIImageView             *btnBgImageView;
    
    NSMutableArray          *_listArray;
    NSMutableArray          *_gradeArray;
    NSMutableArray          *_updateArray;
    
    PopCheckUpdateView      *_popUpdateView;
    PopUpdateVerView        *_popCommentView;
    PopUpdateSucessView     *_popUpdateSucess;
    PopClearChcheView       *_popClearChche;
    
    UIImageView *numView;//hui add
    
}

@property (nonatomic, retain) UIScrollView              *mainScrollView;
@property (nonatomic, retain) UIView                    *introductionView;
@property (nonatomic, retain) UIView                    *moreView;
@property (nonatomic, retain) NSMutableArray            *updateArray;
@property (nonatomic, retain) NSMutableArray            *listArray;
@property (nonatomic, retain) NSMutableArray            *gradeArray;
@property (nonatomic, retain) MBProgressHUD             *progressHUD;
@property (nonatomic, retain) UIActivityIndicatorView   *spinner;
@property (nonatomic, retain) UIButton *shareButton;
@property (nonatomic, retain) UILabel  *shareLabel;

//创建介绍视图
- (void)createIntroductionView;

//创建更多功能视图
- (void)createMoreView;

//关于我们
- (void)aboutUs;

//微博设置
- (void)weiboSet;

//在线反馈
-(void)feedback;

//推荐应用
- (void)recommendApp;

@end
