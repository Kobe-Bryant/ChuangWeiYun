//
//  ServiceViewController.h
//  cw
//
//  Created by LuoHui on 13-8-31.
//
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
 
@interface ServiceViewController : UIViewController <LoginViewDelegate,UIScrollViewDelegate>
{
    UIScrollView *mainScrollView;
}
@end
