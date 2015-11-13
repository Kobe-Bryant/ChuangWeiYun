//
//  InvoiceViewController.m
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import "InvoiceViewController.h"
#import "Common.h"
#import "PopAddressPickerView.h"

#define KCWInvoiceFontSize 17.f
#define InvoiceBgLineColor   [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:0.9f]

@interface InvoiceViewController () <UITextFieldDelegate, PopAddressPickerViewDelegate>
{
    UITextField *_invoiceHeadText;
    UILabel *_invoiceLabel;
    PopAddressPickerView *invoicePickerView;
    int itype;
}

@property (retain, nonatomic) UITextField *invoiceHeadText;

@end

@implementation InvoiceViewController

@synthesize invoiceHeadText = _invoiceHeadText;
@synthesize delegate;
@synthesize invoiceTitle;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"发票信息";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self viewLoad];
    
    itype = 1;
}

- (void)viewLoad
{
    self.view.backgroundColor = KCWViewBgColor;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = self.view.bounds;
    btn.tag = 0;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    CGFloat height = 0.f;           // 总体的高度累加
    CGFloat labelHeight = 50.f;     // label高度
    CGFloat fLabelWidth = 100.f;    // 前面label宽度
    CGFloat lineHeight = 0.9f;      // 线的高度
    CGFloat bLabelwidth = KUIScreenWidth - fLabelWidth - 30.f;  // 后面label宽度
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10.f, 10.f, KUIScreenWidth - 20.f, 2*labelHeight)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 5.f;
    bgView.layer.masksToBounds = YES;
    bgView.layer.borderWidth = 0.3f;
    bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.view addSubview:bgView];
    
    // 发票类型
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, fLabelWidth, labelHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = KCWSystemFont(KCWInvoiceFontSize);
    label.textAlignment = NSTextAlignmentRight;
    label.text = @"发票类型：";
    [bgView addSubview:label];
    [label release], label = nil;
    
    // 普通发票
    _invoiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(fLabelWidth, height, bLabelwidth, labelHeight)];
    _invoiceLabel.backgroundColor = [UIColor clearColor];
    _invoiceLabel.textColor = [UIColor blackColor];
    _invoiceLabel.font = KCWSystemFont(KCWInvoiceFontSize);
    _invoiceLabel.textAlignment = NSTextAlignmentLeft;
    _invoiceLabel.text = @"普通发票";
    [bgView addSubview:_invoiceLabel];
    
    UIButton *inBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inBtn.frame = CGRectMake(fLabelWidth, height, bLabelwidth, labelHeight);
    inBtn.tag = 1;
    [inBtn setImage:[UIImage imageCwNamed:@"icon_right_store.png"] forState:UIControlStateNormal];
    [inBtn setImageEdgeInsets:UIEdgeInsetsMake(0.f,170.f,0.f,0.f)];
    [inBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:inBtn];
    
    height += labelHeight;
    
    // 线
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(bgView.frame), lineHeight)];
    line.backgroundColor = InvoiceBgLineColor;
    [bgView addSubview:line];
    [line release], line = nil;
    
    // 发票抬头
    label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, fLabelWidth, labelHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = KCWSystemFont(KCWInvoiceFontSize);
    label.textAlignment = NSTextAlignmentRight;
    label.text = @"发票抬头：";
    [bgView addSubview:label];
    [label release], label = nil;
    
    // 发票抬头 名称
    _invoiceHeadText = [[UITextField alloc]initWithFrame:CGRectMake(fLabelWidth, height, bLabelwidth, labelHeight)];
    _invoiceHeadText.placeholder = @"请输入发票抬头(个人或者公司)";
    _invoiceHeadText.text= self.invoiceTitle;
    _invoiceHeadText.font = KCWSystemFont(KCWInvoiceFontSize);
    _invoiceHeadText.autocorrectionType = UITextAutocorrectionTypeNo;
    _invoiceHeadText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _invoiceHeadText.returnKeyType = UIReturnKeyDefault;
    _invoiceHeadText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
    _invoiceHeadText.delegate = self;
    [bgView addSubview:_invoiceHeadText];
    
    [bgView release], bgView = nil;
    
    UIImage *img = [UIImage imageCwNamed:@"complete.png"];
    UIButton *btns = [UIButton buttonWithType:UIButtonTypeCustom];
    btns.frame = CGRectMake(0.f, 0.f, img.size.width, img.size.height);
    [btns setBackgroundImage:img forState:UIControlStateNormal];
    [btns setBackgroundImage:[UIImage imageCwNamed:@"complete_click.png"] forState:UIControlStateHighlighted];
    [btns addTarget:self action:@selector(rightUpBarClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:btns];
    self.navigationItem.rightBarButtonItem = barBtn;
    [barBtn release];
    
    invoicePickerView = [[PopAddressPickerView alloc]init];
    invoicePickerView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_invoiceHeadText release], _invoiceHeadText = nil;
    [_invoiceLabel release], _invoiceLabel = nil;
    [invoicePickerView release], invoicePickerView = nil;
    self.invoiceTitle = nil;
    
    [super dealloc];
}

- (void)rightUpBarClick:(UIButton *)btn
{
    [Common MsgBox:@"温馨提示" messege:@"确定填写信息没有错误？" cancel:@"确定" other:@"取消" delegate:self];
}

- (void)btnClick:(UIButton *)btn
{
    if ([_invoiceHeadText isFirstResponder]) {
        [_invoiceHeadText resignFirstResponder];
    }
    
    if (btn.tag == 1) {
        [invoicePickerView addPopupSubviewType:PopPickerTypeInvoice arr:[NSMutableArray arrayWithObjects:@"普通发票",@"增值税发票", nil]];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([delegate respondsToSelector:@selector(getInvoiceInfo:typeText:type:)]) {
            [delegate getInvoiceInfo:_invoiceHeadText.text typeText:_invoiceLabel.text type:itype];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    if (textField.text.length == 0) {
        [Common MsgBox:@"温馨提示" messege:@"发票信息不可以为空。" cancel:@"确定" other:nil delegate:nil];
    } else {
        [Common MsgBox:@"温馨提示" messege:@"确定填写信息没有错误？" cancel:@"确定" other:@"取消" delegate:self];
    }
    
    return YES;
}

#pragma mark - PopAddressPickerViewDelegate
- (void)getID:(PopPickerType)pickerType text:(NSString *)text type:(int)type
{
    itype = type + 1;
    _invoiceLabel.text = text;
}
@end
