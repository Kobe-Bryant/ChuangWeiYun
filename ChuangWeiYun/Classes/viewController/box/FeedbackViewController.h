//
//  FeedbackViewController.h
//  cw
//
//  Created by yunlai on 13-9-6.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface FeedbackViewController : UIViewController <UITextViewDelegate,MBProgressHUDDelegate>
{
    UITextView *myTextView;
    UITextField *telTextField;
	MBProgressHUD *progressHUD;
}

@property(nonatomic,retain) UITextView *myTextView;
@property(nonatomic,retain) UITextField *telTextField;;
@property(nonatomic,retain) MBProgressHUD *progressHUD;

//编辑中
-(void) doEditing;

//发表反馈
-(void)publishFeedback;

@end
