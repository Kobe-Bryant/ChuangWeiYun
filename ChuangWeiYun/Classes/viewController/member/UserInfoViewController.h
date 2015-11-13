//
//  UserInfoViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "HttpRequest.h"
#import "CityChooseViewController.h"

@interface UserInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,MBProgressHUDDelegate,CityChooseViewControllerDelegate,UIActionSheetDelegate,HttpRequestDelegate>
{
    //主视图表格
    UITableView   *_tableView;
    //姓名输入框
    UITextField   *_contentField;
    //长居住地输入框
    UITextField   *_usuallyAddress;
    //性别输入框
    UITextField   *_gender;
    //姓名
    NSString      *_userName;
    //性别
    NSString      *_sex;
    //生日
    NSString      *_birthday;
    //地址
    NSString      *_address;
    //长居住地
    NSString      *_permanent;
    //提示框
    MBProgressHUD *_progressHUD;
    //会员信息
    NSArray       *_userInfoArray;

}
@property(nonatomic ,retain) UITextField    *contentField;
@property(nonatomic ,retain) UITextField    *usuallyAddress;
@property(nonatomic ,retain) UITextField    *gender;
@property(nonatomic ,retain) MBProgressHUD  *progressHUD;
@property(nonatomic ,retain) NSArray        *userInfoArray;
@property(nonatomic ,copy) NSString         *userName;
@property(nonatomic ,copy) NSString         *sex;
@property(nonatomic ,copy) NSString         *birthday;
@property(nonatomic ,copy) NSString         *address;
@property(nonatomic ,copy) NSString         *permanent;


@end
