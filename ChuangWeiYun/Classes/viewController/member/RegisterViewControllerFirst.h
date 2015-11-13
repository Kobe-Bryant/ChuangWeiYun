//
//  RegisterViewControllerFirst.h
//  cw
//
//  Created by yunlai on 13-12-12.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RegisterViewControllerFirst : UIViewController<UITextFieldDelegate>
{
    UITextField *_userName;
    UIButton    *_nextBtn;
    
}
@property (nonatomic,retain) MBProgressHUD *progressHUD;
@end
