//
//  OnlineReserveViewController.h
//  cw
//
//  Created by LuoHui on 13-8-31.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PopAddressPickerView.h"

@interface OnlineReserveViewController : UITableViewController <UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,PopAddressPickerViewDelegate,MBProgressHUDDelegate>
{
    UITextField *_typeTextField;
    UITextField *_modelTextField;
    UITextField *_nameTextField;
    UITextField *_telTextField;
    UITextField *_timeTextField;
    UITextField *_areaTextField;
    UITextField *_addressTextField;
    UITextView *_contentTextView;
    
    int timeValue;
    
    BOOL _isHandle;
    
    MBProgressHUD *mbProgressHUD;
}
@property (nonatomic, retain) UITextField *typeTextField;
@property (nonatomic, retain) UITextField *modelTextField;
@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain) UITextField *telTextField;
@property (nonatomic, retain) UITextField *timeTextField;
@property (nonatomic, retain) UITextField *areaTextField;
@property (nonatomic, retain) UITextField *addressTextField;
@property (nonatomic, retain) UITextView *contentTextView;
@property (nonatomic, retain) NSString *userIdValue;
@property (retain, nonatomic) NSMutableArray *IDArr;
@end
