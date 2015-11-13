//
//  OnlineReserveViewController.m
//  cw
//
//  Created by LuoHui on 13-8-31.
//
//

#import "OnlineReserveViewController.h"
#import "Common.h"
#import "cwAppDelegate.h"
#import "CustomPicker.h"
#import "CityDataObject.h"
#import "Global.h"

@interface OnlineReserveViewController ()

@end

@implementation OnlineReserveViewController
@synthesize typeTextField = _typeTextField;
@synthesize modelTextField = _modelTextField;
@synthesize nameTextField = _nameTextField;
@synthesize telTextField = _telTextField;
@synthesize timeTextField = _timeTextField;
@synthesize areaTextField = _areaTextField;
@synthesize addressTextField = _addressTextField;
@synthesize contentTextView = _contentTextView;
@synthesize userIdValue;
@synthesize IDArr;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"在线预约";
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = KCWViewBgColor;
    
    [self initallStaticUI];
    
    _isHandle = YES;
}

- (void)initallStaticUI
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( 10, 5, 80, 30)];
    
    _typeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30)];
    _typeTextField.font = [UIFont systemFontOfSize:16.0f];
    _typeTextField.delegate = self;
    _typeTextField.textAlignment = UITextAlignmentLeft;
    _typeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _typeTextField.returnKeyType = UIReturnKeyNext;
    _typeTextField.borderStyle = UITextBorderStyleNone;
    _typeTextField.backgroundColor = [UIColor clearColor];
    [_typeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _typeTextField.placeholder = @"请选择服务类型";
    //_typeTextField.text = @"安装";
    
    _modelTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30)];
    _modelTextField.font = [UIFont systemFontOfSize:16.0f];
    _modelTextField.delegate = self;
    _modelTextField.textAlignment = UITextAlignmentLeft;
    _modelTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _modelTextField.returnKeyType = UIReturnKeyNext;
    _modelTextField.borderStyle = UITextBorderStyleNone;
    _modelTextField.backgroundColor = [UIColor clearColor];
    [_modelTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _modelTextField.placeholder = @"产品型号";
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30)];
    _nameTextField.font = [UIFont systemFontOfSize:16.0f];
    _nameTextField.delegate = self;
    _nameTextField.textAlignment = UITextAlignmentLeft;
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTextField.returnKeyType = UIReturnKeyNext;
    _nameTextField.borderStyle = UITextBorderStyleNone;
    _nameTextField.backgroundColor = [UIColor clearColor];
    [_nameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _nameTextField.placeholder = @"姓名";
    
    _telTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30)];
    _telTextField.font = [UIFont systemFontOfSize:16.0f];
    _telTextField.textAlignment = UITextAlignmentLeft;
    _telTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _telTextField.returnKeyType = UIReturnKeyNext;
    _telTextField.keyboardType = UIKeyboardTypeNumberPad;
    _telTextField.borderStyle = UITextBorderStyleNone;
    _telTextField.backgroundColor = [UIColor clearColor];
    [_telTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _telTextField.placeholder = @"电话";
    
    _timeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30)];
    _timeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _timeTextField.returnKeyType = UIReturnKeyNext;
    _timeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _timeTextField.font = [UIFont systemFontOfSize:16.0f];
    _timeTextField.textAlignment = UITextAlignmentLeft;
    _timeTextField.borderStyle = UITextBorderStyleNone;
    _timeTextField.backgroundColor = [UIColor clearColor];
    [_timeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _timeTextField.placeholder = @"时间";
    
    _areaTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30)];
    _areaTextField.font = [UIFont systemFontOfSize:16.0f];
    _areaTextField.delegate = self;
    _areaTextField.textAlignment = UITextAlignmentLeft;
    _areaTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _areaTextField.returnKeyType = UIReturnKeyNext;
    _areaTextField.borderStyle = UITextBorderStyleNone;
    _areaTextField.backgroundColor = [UIColor clearColor];
    [_areaTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _areaTextField.placeholder = @"所在地区";
    
    _addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30)];
    _addressTextField.font = [UIFont systemFontOfSize:16.0f];
    _addressTextField.delegate = self;
    _addressTextField.textAlignment = UITextAlignmentLeft;
    _addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _addressTextField.returnKeyType = UIReturnKeyNext;
    _addressTextField.borderStyle = UITextBorderStyleNone;
    _addressTextField.backgroundColor = [UIColor clearColor];
    [_addressTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    _addressTextField.placeholder = @"详细地址";
    
    _contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 280, 90)];
    _contentTextView.font = [UIFont systemFontOfSize:16.0f];
    _contentTextView.delegate = self;
    _contentTextView.backgroundColor = [UIColor clearColor];
    _contentTextView.textColor = [UIColor grayColor];
    _contentTextView.text = @"描述";
    _contentTextView.returnKeyType = UIReturnKeyDone;
    
    [label release];
}

- (void)dealloc
{
    [_typeTextField release];
    [_modelTextField release];
    [_nameTextField release];
    [_telTextField release];
    [_timeTextField release];
    [_addressTextField release];
    [_contentTextView release];
    [IDArr release];
    [mbProgressHUD release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isHandle == YES) {
        if (indexPath.row == 7) {
            return 100.0f;
        }else {
            return 40.0f;
        }
    }else{
        if (indexPath.row == 7) {
            return 100.0f;
        }else if (indexPath.row == 1) {
            return 0.0f;
        }else {
            return 40.0f;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(15, 10, 290, 40)];
    bgView.layer.cornerRadius = 3;
    bgView.layer.masksToBounds = YES;
    bgView.backgroundColor = [UIColor colorWithRed:0.1098 green:0.4118 blue:0.7529 alpha:1.0f];
    [view addSubview:bgView];
    
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)];
    strLabel.backgroundColor = [UIColor clearColor];
    strLabel.textColor = [UIColor whiteColor];
    strLabel.text = @"预   约";
    strLabel.font = [UIFont systemFontOfSize:18.0f];
    strLabel.textAlignment = UITextAlignmentCenter;
    [bgView addSubview:strLabel];
    [strLabel release];
    [bgView release];
    
    UIButton *reserveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reserveButton.frame = bgView.frame;
    [reserveButton addTarget:self action:@selector(reserveAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:reserveButton];
    
    return [view autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( 10, 5, 80, 30)];
    label.font = [UIFont systemFontOfSize:16.0f];
    label.textAlignment = UITextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];
    
    switch (indexPath.row) {
        case 0:
        {
            label.text = @"服务类型";
            
            [cell.contentView addSubview:_typeTextField];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 1;
            btn.frame = CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30);
            [cell.contentView addSubview:btn];
        }
            break;
        case 1:
        {
            label.text = @"产品型号";
            
            [cell.contentView addSubview:_modelTextField];
        }
            break;
        case 2:
        {
            label.text = @"姓名";
            
            [cell.contentView addSubview:_nameTextField];
        }
            break;
        case 3:
        {
            label.text = @"电话";
            
            [cell.contentView addSubview:_telTextField];
            
        }
            break;
        case 4:
        {
            label.text = @"预约时间";
            
            [cell.contentView addSubview:_timeTextField];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 2;
            btn.frame = CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30);
            [cell.contentView addSubview:btn];
        }
            break;
        case 5:
        {
            label.text = @"所在地区";
            
            [cell.contentView addSubview:_areaTextField];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(selectArea) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(CGRectGetMaxX(label.frame), 5, 210, 30);
            [cell.contentView addSubview:btn];
        }
            break;
        case 6:
        {
            label.text = @"详细地址";
            
            [cell.contentView addSubview:_addressTextField];
        }
            break;
        case 7:
        {
            [cell.contentView addSubview:_contentTextView];
        }
            break;
            
        default:
            break;
    }
    
    [label release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
}

#pragma mark ----UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.tableView.scrollEnabled = YES;
    if (buttonIndex == 1) {
        if (actionSheet.tag == 100) {
            if (self.typeTextField.text == nil) {
                self.typeTextField.text = @"安装";
                _isHandle = NO;
                return;
            }
            
            if ([self.typeTextField.text isEqualToString:@"维修"]) {
                _isHandle = NO;
                
                NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [deleteIndexPaths addObject:newPath];
                
                [self.tableView reloadRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                [deleteIndexPaths release];
            }else {
                if (_isHandle == NO) {
                    _isHandle = YES;
                    
                    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    [insertIndexPaths addObject:newPath];
                    
                    [self.tableView reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [insertIndexPaths release];
                }
            }
        }else{
            CustomPicker *picer = (CustomPicker *)actionSheet;
            NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"yyyy年MM月dd日 HH点mm分"];
            NSString *str=[dateFormate stringFromDate:picer.myDate];
            [dateFormate release];
            
            NSDateFormatter *dateFormate1 = [[NSDateFormatter alloc] init];
            [dateFormate1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateStr = [dateFormate1 stringFromDate:picer.myDate];
            NSDate *currentDate = [dateFormate1 dateFromString:dateStr];
            [dateFormate1 release];
            NSTimeInterval t = [currentDate timeIntervalSince1970];   //转化为时间戳
            long long int time = (long long int)t;
            
            NSNumber *value = [NSNumber numberWithLongLong:time];
            
            NSDate* nowDate = [NSDate date];
            NSTimeInterval t1 = [nowDate timeIntervalSince1970];   //转化为时间戳
            long long int time1 = (long long int)t1;
            NSNumber *num = [NSNumber numberWithLongLong:time1];
            int currentInt = [num intValue];
            
            if ([value intValue] <= currentInt) {
                MBProgressHUD *mprogressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
                [self.view addSubview:mprogressHUD];
                [self.view bringSubviewToFront:mprogressHUD];
                mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal"]] autorelease];
                mprogressHUD.mode = MBProgressHUDModeCustomView;
                [mprogressHUD show:YES];
                mprogressHUD.labelText = [NSString stringWithFormat:@"预约时间小于当前时间"];   // @"预约时间小于当前时间"
                [mprogressHUD hide:YES afterDelay:1.5];
                [mprogressHUD release];
            }else {
                self.timeTextField.text = str;
                timeValue = [value intValue];
            }
        }
    }
}

#pragma mark ----UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == self.contentTextView) {
        if ([self.contentTextView.text isEqualToString:@"描述"]) {
            self.contentTextView.text = @"";
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    //[self performSelectorOnMainThread:@selector(doEditing) withObject:nil waitUntilDone:NO];
    return YES;
}

#pragma mark ----UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.modelTextField) {
        [self.modelTextField resignFirstResponder];
        [self.nameTextField becomeFirstResponder];
    }else if (textField == self.nameTextField) {
        [self.nameTextField resignFirstResponder];
        [self.telTextField becomeFirstResponder];
    }else if (textField == self.addressTextField) {
        [self.addressTextField resignFirstResponder];
        [self.contentTextView becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - PopAddressPickerViewDelegate
// 选择器
- (NSMutableArray *)getAddressCity:(NSString *)province
{
    return [CityDataObject getCitys:province];
}

- (NSMutableArray *)getAddressArea:(NSString *)city
{
    return [CityDataObject getAreas:city];
}

- (void)getAddressGroup:(NSString *)address arrID:(NSMutableArray *)idArr
{
    [self setArealabelTextAndTextColor:address];
    self.IDArr = idArr;
    //NSLog(@"idArr = %@",idArr);
}

- (void)setArealabelTextAndTextColor:(NSString *)text
{
    _areaTextField.text = text;
    
    if ([text isEqualToString:@"所在地区"]) {
        _areaTextField.textColor = [UIColor grayColor];
    } else {
        _areaTextField.textColor = [UIColor blackColor];
    }
}

#pragma mark progressHUD委托
//在该函数 [progressHUD hide:YES afterDelay:1.0f] 执行后回调
- (void)hudWasHidden:(MBProgressHUD *)hud{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- methods
- (void)hideKeyboard
{
    [_typeTextField resignFirstResponder];
    [_modelTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    [_telTextField resignFirstResponder];
    [_timeTextField resignFirstResponder];
    [_addressTextField resignFirstResponder];
    [_contentTextView resignFirstResponder];
}

- (void)selectBtn:(id)sender
{
    [self hideKeyboard];
    
    UIButton *btn = (UIButton *)sender;
    
    cwAppDelegate *delegate =  (cwAppDelegate *)[UIApplication sharedApplication].delegate;
    
    CustomPicker *picker = nil;
    switch (btn.tag) {
        case 1:
        {
            picker = [[CustomPicker alloc] initWithTitle:nil withFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 130) delegate:self PickerArray:[NSMutableArray arrayWithObjects:@"安装",@"维修", nil]  Obj:self.typeTextField];
            
            picker.tag = 100;
            [picker showInDelegateView:delegate.window];
        }
            break;
        case 2:
        {
            picker = [[CustomPicker alloc] initWithDateAndTimePicker:CGRectMake(0, 0, 320, self.view.frame.size.height - 130) withTime:self.timeTextField.text type:0];
            picker.tag = 101;
            
            [picker timePickShowInView:delegate.window];
        }
            break;
        default:
            break;
    }
    picker.delegate = self;
    [picker release];
}

- (void)selectArea
{
    [self hideKeyboard];
    
    PopAddressPickerView *popPickerView = [[PopAddressPickerView alloc]init];
    popPickerView.delegate = self;
    popPickerView.provinceDict = [CityDataObject getProvinces];
    [popPickerView pickerViewReload];
    [popPickerView addPopupSubviewType:PopPickerTypeAddress arr:nil];
}

- (void)reserveAction
{
    [self hideKeyboard];
    
    MBProgressHUD *mprogressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
    mprogressHUD.mode = MBProgressHUDModeCustomView;
    [mprogressHUD hide:YES afterDelay:1.5];
    
    if (self.typeTextField.text.length == 0) {
        mprogressHUD.labelText = @"请选择服务类型";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
    }else if ([self.typeTextField.text isEqualToString:@"安装"] && self.modelTextField.text.length == 0) {
        mprogressHUD.labelText = @"请填写产品型号";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
    }else if (self.nameTextField.text.length == 0) {
        mprogressHUD.labelText = @"请填写姓名";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
    }else if (self.telTextField.text.length == 0) {
        mprogressHUD.labelText = @"请填写电话";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
    }else if (self.telTextField.text.length != 11) {
        
        mprogressHUD.labelText = @"请填写正确的手机号码";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
        
    }else if (self.timeTextField.text.length == 0) {
        mprogressHUD.labelText = @"请选择预约时间";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
    }else if (self.areaTextField.text.length == 0) {
        
        mprogressHUD.labelText = @"请选择所在地区";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
    }else if (self.addressTextField.text.length == 0) {
        mprogressHUD.labelText = @"请填写详细地址";
        [self.view addSubview:mprogressHUD];
        [self.view bringSubviewToFront:mprogressHUD];
        [mprogressHUD show:YES];
    }else {
        [self accessService];
    }
    
    //    if (self.typeTextField.text.length == 0 && self.modelTextField.text.length == 0 && self.nameTextField.text.length == 0 && self.telTextField.text.length == 0 && self.timeTextField.text.length == 0 && self.addressTextField.text.length == 0) {
    //
    //        mprogressHUD.labelText = @"请填写完整的预约信息";
    //        [self.view addSubview:mprogressHUD];
    //        [self.view bringSubviewToFront:mprogressHUD];
    //        [mprogressHUD show:YES];
    //
    //    }else if ([self.typeTextField.text isEqualToString:@"维修"] && (self.nameTextField.text.length == 0 || self.telTextField.text.length == 0 || self.timeTextField.text.length == 0 || self.addressTextField.text.length == 0)) {
    //
    //        mprogressHUD.labelText = @"请填写完整的预约信息";
    //        [self.view addSubview:mprogressHUD];
    //        [self.view bringSubviewToFront:mprogressHUD];
    //        [mprogressHUD show:YES];
    //
    //    }else if ([self.typeTextField.text isEqualToString:@"安装"] && ( self.modelTextField.text.length == 0 || self.nameTextField.text.length == 0 || self.telTextField.text.length == 0 || self.timeTextField.text.length == 0 || self.addressTextField.text.length == 0)) {
    //
    //        mprogressHUD.labelText = @"请填写完整的预约信息";
    //        [self.view addSubview:mprogressHUD];
    //        [self.view bringSubviewToFront:mprogressHUD];
    //        [mprogressHUD show:YES];
    //
    //    }else if (self.telTextField.text.length != 11) {
    //
    //        mprogressHUD.labelText = @"请填写正确的手机号码";
    //        [self.view addSubview:mprogressHUD];
    //        [self.view bringSubviewToFront:mprogressHUD];
    //        [mprogressHUD show:YES];
    //
    //    }else if (self.areaTextField.text.length == 0) {
    //
    //        mprogressHUD.labelText = @"请选择所在地区";
    //        [self.view addSubview:mprogressHUD];
    //        [self.view bringSubviewToFront:mprogressHUD];
    //        [mprogressHUD show:YES];
    //
    //    }else {
    //        [self accessService];
    //    }
    
    [mprogressHUD release];
}

- (void)accessService
{
    mbProgressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    mbProgressHUD.labelText = @"预约中...";
    mbProgressHUD.mode = MBProgressHUDModeCustomView;
    [self.view addSubview:mbProgressHUD];
    [self.view bringSubviewToFront:mbProgressHUD];
    [mbProgressHUD show:YES];
    
    NSString *reqUrl = @"aftersalel.do?param=";
	
    int type;
    if ([self.typeTextField.text isEqualToString:@"安装"]) {
        type = 1;
    }else {
        type = 2;
        self.modelTextField.text = @"";
    }
    
    if ([self.contentTextView.text isEqualToString:@"描述"] || self.contentTextView.text.length == 0 || [self.contentTextView.text isEqualToString:@"\n"]) {
        self.contentTextView.text = @"";
    }
    
    NSString *shopId = nil;
    if ([Global sharedGlobal].shop_id == nil) {
        shopId = @"0";
    }else {
        shopId = [Global sharedGlobal].shop_id;
    }
    NSArray *arr = [self.areaTextField.text componentsSeparatedByString:@" "];
    NSString *addr = [NSString stringWithFormat:@"%@%@%@%@",[arr objectAtIndex:0],[arr objectAtIndex:1],[arr objectAtIndex:2],self.addressTextField.text];
    //NSLog(@"addr == %@",addr);
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       shopId,@"shop_id",
                                       [NSNumber numberWithInt:[userIdValue intValue]],@"user_id",
                                       [NSNumber numberWithInt:type],@"service_type",
                                       self.modelTextField.text,@"model",
                                       self.nameTextField.text,@"name",
                                       self.telTextField.text,@"mobile",
                                       [self.IDArr objectAtIndex:0],@"province_id",
                                       [self.IDArr objectAtIndex:2],@"city_id",
                                       [self.IDArr objectAtIndex:4],@"area_id",
                                       addr,@"address",
                                       self.contentTextView.text,@"description",
                                       [NSNumber numberWithInt:timeValue],@"appointment",nil];
    
  
//    NSLog(@"requestDic== %@",requestDic);
    
    [[NetManager sharedManager] accessService:requestDic data:nil command:SALE_SERVICE_COMMAND_ID accessAdress:reqUrl delegate:self withParam:nil];
}

//网络请求回调函数
- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver
{
    switch (commandid) {
        case SALE_SERVICE_COMMAND_ID:
        {
            [self performSelectorOnMainThread:@selector(update:) withObject:resultArray waitUntilDone:NO];
        }
            break;
        default:
            break;
    }
}

- (void)update:(NSMutableArray*)resultArray
{
    if (mbProgressHUD != nil) {
        [mbProgressHUD removeFromSuperview];
    }
    
    MBProgressHUD *mprogressHUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    
    if (![[resultArray lastObject] isEqual:CwRequestFail])
    {
        if ([[resultArray lastObject] isEqual:CwRequestTimeout]) {
            mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
            mprogressHUD.labelText = CwRequestTip;
        }else {
            if ([resultArray count] > 0) {
                NSString *ret = [resultArray objectAtIndex:0];
                if ([ret intValue] == 1) {
                    mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ok_normal.png"]] autorelease];
                    mprogressHUD.delegate = self;
                    mprogressHUD.labelText = @"预约成功";
                }else {
                    mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
                    mprogressHUD.labelText = @"预约失败";
                }
            }
        }
    }else {
        mprogressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tip_normal.png"]] autorelease];
        mprogressHUD.labelText = @"网络不好,预约失败";
    }
    
    mprogressHUD.mode = MBProgressHUDModeCustomView;
    [self.view addSubview:mprogressHUD];
    [self.view bringSubviewToFront:mprogressHUD];
    [mprogressHUD show:YES];
    [mprogressHUD hide:YES afterDelay:1.5];
    [mprogressHUD release];
}
@end
