//
//  AddAddressViewController.m
//  cw
//
//  Created by yunlai on 13-8-24.
//
//

#import "AddAddressViewController.h"
#import "address_list_model.h"
#import "CityDataObject.h"
#import "Common.h"
#import "Global.h"
#import "MBProgressHUD.h"

#define AddAddressBgLineColor   [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:0.9f]

#define KAddAddressScrollHeight     220.f
#define KAddAddressPickerHeight     220.f

@interface AddAddressViewController () <UITextFieldDelegate>
{
    UIScrollView *_scrollView;
    UIView *_bgView;
    UITextField *_nameText;
    UITextField *_phoneText;
    UITextField *_addressText;
//    UITextField *_zipcodeText;
    UILabel *_arealabel;
    PopAddressPickerView *popPickerView;
    UIButton *btnDone;
    
    NSMutableArray *IDArr;
}

@property (retain, nonatomic) NSMutableArray *IDArr;

@end

@implementation AddAddressViewController

@synthesize type;
@synthesize IDArr;
@synthesize addressDict;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (type == 1) {
        self.title = @"新增收货地址";
    } else if (type == 2) {
        self.title = @"修改收货地址";
    }
    
    // 键盘将要显示的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘将要隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // KVO 给_textView添加一个观察者，_textView.contentSize.height的高度改变时，使用
    [self addObserver:self forKeyPath:@"_scrollView.frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self hidekeyboard];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self removeObserver:self forKeyPath:@"_scrollView.frame"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataLoad];

    [self viewLoad];
}

- (void)dataLoad
{
    
}

- (void)viewLoad
{
    self.view.backgroundColor = KCWViewBgColor;
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KAddAddressScrollHeight)];
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
    
    _bgView = [[UIView alloc]initWithFrame:CGRectMake(10.f, 10.f, KUIScreenWidth - 20.f, 160.f)];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.cornerRadius = 5.f;
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.borderWidth = 0.3f;
    _bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [_scrollView addSubview:_bgView];
    
    UIImage *img = [UIImage imageCwNamed:@"complete.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, img.size.width, img.size.height);
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageCwNamed:@"complete_click.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(rightUpBarClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barBtn;
    [barBtn release];
    
    [self createBgView];
}

- (void)createBgView
{
    CGFloat height = 0.f;
    CGFloat labelHeight = 40.f;
    CGFloat frontlabelW = 10.f;
    CGFloat backlabelW = 290.f;
    
    // 请输入收货人名字
    _nameText = [[UITextField alloc]initWithFrame:CGRectMake(frontlabelW, height, backlabelW, labelHeight)];
    _nameText.autocorrectionType = UITextAutocorrectionTypeNo;
    _nameText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _nameText.returnKeyType = UIReturnKeyDefault;
    _nameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
    _nameText.placeholder = @"收货人";
    _nameText.text = [self.addressDict objectForKey:@"name"];
    _nameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameText.delegate = self;
    [_bgView addSubview:_nameText];
    
    height += labelHeight;
    
    // 线
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_bgView.frame), 0.9f)];
    line.backgroundColor = AddAddressBgLineColor;
    [_bgView addSubview:line];
    [line release], line = nil;
    
    // 请输入手机号码
    _phoneText = [[UITextField alloc]initWithFrame:CGRectMake(frontlabelW, height, backlabelW, labelHeight)];
    _phoneText.autocorrectionType = UITextAutocorrectionTypeNo;
    _phoneText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneText.returnKeyType = UIReturnKeyDefault;
    _phoneText.keyboardType = UIKeyboardTypeNumberPad; // 键盘显示类型
    _phoneText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
    _phoneText.placeholder = @"手机号码";
    _phoneText.text = [self.addressDict objectForKey:@"mobile"];
    _phoneText.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneText.delegate = self;
    [_bgView addSubview:_phoneText];
    
    height += labelHeight;
    
    // 线
    line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_bgView.frame), 0.9f)];
    line.backgroundColor = AddAddressBgLineColor;
    [_bgView addSubview:line];
    [line release], line = nil;
    
    // 省份地址
    UIButton *areaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    areaBtn.frame = CGRectMake(frontlabelW, height, backlabelW, labelHeight);
    [areaBtn addTarget:self action:@selector(areaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:areaBtn];
    
    _arealabel = [[UILabel alloc]initWithFrame:CGRectMake(frontlabelW, height, backlabelW, labelHeight)];
    _arealabel.backgroundColor = [UIColor clearColor];
    _arealabel.font = KCWSystemFont(17.f);
    [self setArealabelTextAndTextColor:@"所在地区"];
    NSString *address = [NSString stringWithFormat:@"%@%@%@",
                         [self.addressDict objectForKey:@"province"],
                         [self.addressDict objectForKey:@"city"],
                         [self.addressDict objectForKey:@"area"]];
    if (self.addressDict.count != 0) {
        [self setArealabelTextAndTextColor:address];
    }
    
    [_bgView addSubview:_arealabel];
    
    height += labelHeight;
    
    // 线
    line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_bgView.frame), 0.9f)];
    line.backgroundColor = AddAddressBgLineColor;
    [_bgView addSubview:line];
    [line release], line = nil;
    
    // 请输入详细地址
    _addressText = [[UITextField alloc]initWithFrame:CGRectMake(frontlabelW, height, backlabelW, labelHeight)];
    _addressText.autocorrectionType = UITextAutocorrectionTypeNo;
    _addressText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _addressText.returnKeyType = UIReturnKeyDefault;
    _addressText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
    _addressText.placeholder = @"详细地址";
    _addressText.text = [self.addressDict objectForKey:@"address"];
    _addressText.clearButtonMode = UITextFieldViewModeWhileEditing;
    _addressText.delegate = self;
    [_bgView addSubview:_addressText];

    popPickerView = [[PopAddressPickerView alloc]init];
    popPickerView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_bgView release], _bgView = nil;
    [_nameText release], _nameText = nil;
    [_phoneText release], _phoneText = nil;
    [_addressText release], _addressText = nil;
    [_arealabel release], _arealabel = nil;
    [popPickerView release], popPickerView = nil;
    
    [super dealloc];
}

//收货地址中的直辖市去掉重复的名字 12.4 chenfeng
- (NSString *)isIncludeString:(NSString *)addressString{
    if([addressString rangeOfString:@"北京市"].location !=NSNotFound ||[addressString rangeOfString:@"天津市"].location !=NSNotFound||[addressString rangeOfString:@"上海市"].location !=NSNotFound||[addressString rangeOfString:@"重庆市"].location !=NSNotFound)
    {
        NSLog(@"yes");
        addressString = [addressString substringFromIndex:3];
    }
    else
    {
        NSLog(@"no");
    }
    
    return addressString;
}

- (void)setArealabelTextAndTextColor:(NSString *)text
{
    _arealabel.text = [self isIncludeString:text];
    
    if ([text isEqualToString:@"所在地区"]) {
        _arealabel.textColor = [UIColor grayColor];
    } else {
        _arealabel.textColor = [UIColor blackColor];
    }
}

// 键盘左下角添加完成按钮
- (void)addbtn
{
    btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setTitle:@"完成" forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(btnDoneOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnDone.frame = CGRectMake(0.f, KUIScreenHeight-33.f, 106.f, 53.f);
    
    UIWindow* window = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    [window insertSubview:btnDone atIndex:0];
}

// 确定按钮
- (void)rightUpBarClick:(UIButton *)btn
{
    [self hidekeyboard];
    
    if ([self judgeSure]) {
        [self accessItemService];
    }
}

// 点击确定按钮，先判断后联网
- (BOOL)judgeSure
{
    BOOL sure = YES;
    
    if (_nameText.text.length == 0) {
        [Common MsgBox:@"提示" messege:@"收货人不可以为空" cancel:@"确定" other:nil delegate:nil];
        sure = NO;
    } else if (_phoneText.text.length == 0) {
        [Common MsgBox:@"提示" messege:@"手机号码不可以为空" cancel:@"确定" other:nil delegate:nil];
    } else if (![Common phoneNumberChecking:_phoneText.text]) {
        [Common MsgBox:@"提示" messege:@"手机号码填写不正确" cancel:@"确定" other:nil delegate:nil];
        sure = NO;
    } else if ([_arealabel.text isEqualToString:@"所在地区"]) {
        [Common MsgBox:@"提示" messege:@"所在地区不可以为空" cancel:@"确定" other:nil delegate:nil];
        sure = NO;
    } else if (_addressText.text.length == 0) {
        [Common MsgBox:@"提示" messege:@"详细地址不可以为空" cancel:@"确定" other:nil delegate:nil];
        sure = NO;
    } else {
        sure = YES;
    }
    
    return sure;
}

// 地址选择器
- (void)areaBtnClick:(UIButton *)btn
{
    [self hidekeyboard];
    popPickerView.provinceDict = [CityDataObject getProvinces];
    [popPickerView pickerViewReload];
    [popPickerView addPopupSubviewType:PopPickerTypeAddress arr:nil];
}

// 数字键盘完成按钮
- (void)btnDoneOnClicked:(UIButton *)btn
{
    if ([_phoneText isFirstResponder]) {
        [_phoneText resignFirstResponder];
    }
    [UIView beginAnimations:@"hideKeyboardButton" context:nil];
    [UIView setAnimationDuration:0.25f];
    ((UIButton *) btn).frame = CGRectMake(0.f, KUIScreenHeight, 108.0f, 53.0f);
    [UIView commitAnimations];
}

// 隐藏键盘
- (void)hidekeyboard
{
    if ([_phoneText isFirstResponder]) {
        [_phoneText resignFirstResponder];
    }
    if ([_addressText isFirstResponder]) {
        [_addressText resignFirstResponder];
    }
    if ([_nameText isFirstResponder]) {
        [_nameText resignFirstResponder];
    }
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result type:(int)atype
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y + 120);
    
    UIImage *img = nil;
    if (atype == 1) {
        img = [UIImage imageCwNamed:@"icon_ok_normal.png"];
    } else if (atype == 0) {
        img = [UIImage imageCwNamed:@"icon_tip_normal.png"];
    } 
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = result;
    [self.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:2];
    [progressHUDTmp release];
}

#pragma mark -
#pragma mark Responding to keyboard events
// 键盘将要显示
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // 键盘显示需要的frame
    CGRect keyboardRect = [aValue CGRectValue];
    
    if ((KUIScreenHeight - keyboardRect.size.height) <= CGRectGetHeight(_scrollView.frame) + KUpBarHeight) {
        CGRect scrRect = _scrollView.frame;
        scrRect.size.height = KUIScreenHeight - keyboardRect.size.height - KUpBarHeight;
        _scrollView.frame = scrRect;
    }
}

// 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notification
{    
    CGRect scrRect = _scrollView.frame;
    scrRect.size.height = KAddAddressScrollHeight;
    _scrollView.frame = scrRect;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"keypath......");
    if ([keyPath isEqualToString:@"_scrollView.frame"]) {
        _scrollView.contentSize = CGSizeMake(0.f, KAddAddressScrollHeight);
        if ([_addressText isFirstResponder]) {
            [UIView animateWithDuration:0.23 animations:^{
                _scrollView.contentOffset = CGPointMake(0.f, KAddAddressScrollHeight - CGRectGetHeight(_scrollView.frame));
            }];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _phoneText) {
        [self performSelector:@selector(addbtn) withObject:nil afterDelay:0.23f];
    } 
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _phoneText) {
        btnDone.frame = CGRectMake(0.f, KUIScreenHeight, 108.0f, 53.0f);
        [btnDone removeFromSuperview];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _phoneText) {
        if (_phoneText.text.length >= 11 && ![string isEqualToString:@""]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - network
// 网络请求
- (void)accessItemService
{
    NSString *reqUrl = @"member/addorupdateaddress.do?param=";
    
    NSMutableDictionary *requestDic = nil;

    if (type == 2) {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [Global sharedGlobal].user_id,@"user_id",
                        _nameText.text,@"name",
                        _phoneText.text,@"mobile",
                        [self.addressDict objectForKey:@"province_id"],@"province_id",
                        [self.addressDict objectForKey:@"city_id"],@"city_id",
                        [self.addressDict objectForKey:@"area_id"],@"area_id",
                        _addressText.text,@"address",
                        [NSString stringWithFormat:@"%d",self.type],@"type",
                        [NSString stringWithFormat:@"%d",[[self.addressDict objectForKey:@"id"] intValue]],@"id",nil];
    } else {
        requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [Global sharedGlobal].user_id,@"user_id",
                                           _nameText.text,@"name",
                                           _phoneText.text,@"mobile",
                                           [self.IDArr objectAtIndex:0],@"province_id",
                                           [self.IDArr objectAtIndex:2],@"city_id",
                                           [self.IDArr objectAtIndex:4],@"area_id",
                                           _addressText.text,@"address",
                                           [NSString stringWithFormat:@"%d",self.type],@"type", nil];
    }
    
    
    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:ADD_UPDATE_ADDRESS_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 成功返回
- (void)success
{
    [self hidekeyboard];

    [self.navigationController popViewControllerAnimated:YES];
}

// 失败
- (void)fail:(NSMutableArray *)arr
{
    if ([[arr lastObject] isEqual:CwRequestTimeout]) {
        [self progressHUD:KCWServerBusyPrompt type:3];
    } else {
        if ([Common connectedToNetwork]) {
            if (type == 1) {
                [self progressHUD:@"添加地址失败" type:0];
            } else if (type == 2) {
                [self progressHUD:@"修改地址失败" type:0];
            }
        } else {
            [self progressHUD:KCWNetNOPrompt type:3];
        }
    }
}

// 网络请求成功后的数据解析
- (void)updateDataArr:(NSMutableArray *)arr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (arr.count > 0) {
            if ([[arr objectAtIndex:0] intValue] == 1) {
                NSLog(@"arr = %@",arr);
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            _nameText.text,@"name",
                                            _phoneText.text,@"mobile",
                                            _addressText.text,@"address",
                                            @"0",@"used",nil];
//                NSString *area = [NSString stringWithFormat:@"%@%@%@",
//                                  [self.IDArr objectAtIndex:1],
//                                  [self.IDArr objectAtIndex:3],
//                                  [self.IDArr objectAtIndex:5]];
                if (type == 1) {
                    [dic setObject:[arr objectAtIndex:1] forKey:@"id"];
                    [dic setObject:[self.IDArr objectAtIndex:0] forKey:@"province_id"];
                    [dic setObject:[self.IDArr objectAtIndex:1] forKey:@"province"];
                    [dic setObject:[self.IDArr objectAtIndex:2] forKey:@"city_id"];
                    [dic setObject:[self.IDArr objectAtIndex:3] forKey:@"city"];
                    [dic setObject:[self.IDArr objectAtIndex:5] forKey:@"area"];
                    [dic setObject:[self.IDArr objectAtIndex:4] forKey:@"area_id"];
                    [dic setObject:[arr objectAtIndex:1] forKey:@"created"];
                } else {
                    [dic setObject:[self.addressDict objectForKey:@"id"] forKey:@"id"];
                    [dic setObject:@"0" forKey:@"created"];
                    [dic setObject:[self.addressDict objectForKey:@"used"] forKey:@"used"];
                    
                    if (self.IDArr.count > 0) {
                        [dic setObject:[self.IDArr objectAtIndex:0] forKey:@"province_id"];
                        [dic setObject:[self.IDArr objectAtIndex:1] forKey:@"province"];
                        [dic setObject:[self.IDArr objectAtIndex:2] forKey:@"city_id"];
                        [dic setObject:[self.IDArr objectAtIndex:3] forKey:@"city"];
                        [dic setObject:[self.IDArr objectAtIndex:5] forKey:@"area"];
                        [dic setObject:[self.IDArr objectAtIndex:4] forKey:@"area_id"];
                    } else {
                        [dic setObject:[self.addressDict objectForKey:@"province_id"] forKey:@"province_id"];
                        [dic setObject:[self.addressDict objectForKey:@"province"] forKey:@"province"];
                        [dic setObject:[self.addressDict objectForKey:@"city_id"] forKey:@"city_id"];
                        [dic setObject:[self.addressDict objectForKey:@"city"] forKey:@"city"];
                        [dic setObject:[self.addressDict objectForKey:@"area"] forKey:@"area"];
                        [dic setObject:[self.addressDict objectForKey:@"area_id"] forKey:@"area_id"];
                    }
                }
                
                address_list_model *alMod = [[address_list_model alloc]init];
                NSLog(@"type = %d",type);
                if (type == 1) {
                    [alMod insertDB:dic];
                } else if (type == 2) {
                    alMod.where = [NSString stringWithFormat:@"id = '%d'",[[self.addressDict objectForKey:@"id"] intValue]];
                    [alMod updateDB:dic];
                }
                [alMod release], alMod = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self success];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self fail:arr];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fail:arr];
            });
        }
    });
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == ADD_UPDATE_ADDRESS_COMMAND_ID) {
        if (![[resultArray lastObject] isEqual:CwRequestFail]) {
            [self updateDataArr:resultArray];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fail:resultArray];
            });
        }
    } 
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
    NSLog(@"idArr = %@",idArr);
}

@end
