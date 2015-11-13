//
//  OrderShopViewController.m
//  cw
//
//  Created by yunlai on 13-8-23.
//
//

#import "OrderShopViewController.h"
#import "address_list_model.h"
#import "Common.h"
#import "Global.h"
#import "PreferentialObject.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"
#import "CustomTabBar.h"
#import "OrderListViewController.h"
#import "CustomPicker.h"
#import "PreferentialObject.h"

#define OrderShopDownBarH       50.f

#define OrderAddCellLeftW       5.f
#define OrderAddCellUpH         5.f
#define OrderAddCellBGLeftW     10.f
#define OrderAddCellBGUpH       10.f
#define OrderAddCellBgH         50.f
#define OrderInfoUpBarH         50.f
#define OrderInfoLabelH         40.f
#define OrderInfoLabelW         100.f
#define OrderBackLabelW         190.f
#define OrderInfoBGH            410.f

#define OrderAddFontSize        15.f
#define OrderInfoFontSize       15.f

#define OrderMessage            @"备注"
#define InvoiceMessage          @"个人或者公司名称"

typedef enum
{
    OrderShopPayType,           // 支付方式
    OrderShopTimeType,          // 送货时间
    OrderShopInvoiceType,       // 发票信息
    OrderShopticketType,        // 优惠
}OrderShopEnum;                 // btn点击事件

@interface OrderShopViewController () <MBProgressHUDDelegate>
{
    NSMutableDictionary *addressDict;
    PopBookSucceedView *succeedView;
    PopAddressPickerView *payPickerView;
    
    UIView *_upView;
    UIView *_downView;
    UILabel *_nameLabel;
    UILabel *_phoneLabel;
    UILabel *_addresslabel;
    UIImageView *_imgView;
    UIButton *_bgButton;
    
    UILabel *shopLable;                 // 分店名称
    UILabel *_goodsType;                // 送货方式
    UILabel *_timeLabel;                // 送货时间
    //    UILabel *_companyName;            // 发票抬头
    UITextView *_invoiceHeadText;       // 发票抬头
    UILabel *_invoiceLabel;             // 发票类型
    UILabel *_ticketLabel;              // 优惠金钱
    UITextView *_textView;              // 备注
    
    int invoiceType;                    // 发票类型
    int payType;                        // 送货方式
    int pay_money;                      // 需要支付金额
    int couponsMoney;                   // 优惠金额
    int couponsID;                      // 优惠ID
    CGFloat keyboardHeight;             // 键盘高度
    
    MBProgressHUD *progressHUD;
    NSMutableArray *dataArr;
    
    UIButton *exitButton;               // 键盘button
    NSDate *sendTime;                   // 送货时间
    NSString *defaultShopID;            // 默认分店ID
}

@property (retain, nonatomic) NSMutableDictionary *addressDict;
@property (retain, nonatomic) MBProgressHUD *progressHUD;
@property (retain, nonatomic) NSMutableArray *dataArr;
@property (retain, nonatomic) NSDate *sendTime;
@property (retain, nonatomic) NSString *defaultShopID;

- (void)createDownBarView;

@end

@implementation OrderShopViewController

@synthesize scrollViewC = _scrollViewC;
@synthesize addressDict;
@synthesize shopDict;
@synthesize shopList;
@synthesize progressHUD;
@synthesize delegate;
@synthesize dataArr;
@synthesize sendTime;
@synthesize defaultShopID;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.title = @"预  订";
    
    // 键盘将要显示的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘将要隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self closeTextField];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KCWViewBgColor;
    
    [self dataLoad];
    
    [self viewLoad];
    
    [self createScrollViewC];
    
    _scrollViewC.contentSize = CGSizeMake(0.f, CGRectGetMaxY(_downView.frame)+10.f);
    
    payType = 1;
    
    pay_money = [[self.shopDict objectForKey:@"price"] intValue];
}

- (void)dataLoad
{
    self.defaultShopID = [NSString stringWithFormat:@"%d",[[[self.shopList objectAtIndex:0] objectForKey:@"id"] intValue]];

    [self judge_address_list];
}

- (void)viewLoad
{
    _scrollViewC = [[UIScrollView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight - KUpBarHeight - OrderShopDownBarH)];
    _scrollViewC.backgroundColor = KCWViewBgColor;
    [self.view addSubview:_scrollViewC];
    
    [self createDownBarView];
    
    succeedView = [[PopBookSucceedView alloc]init];
    succeedView.delegate = self;
    payPickerView = [[PopAddressPickerView alloc]init];
    payPickerView.delegate = self;
}

// 创建_scrollViewC视图
- (void)createScrollViewC
{
    _upView = [[UIView alloc]initWithFrame:CGRectZero];
    _upView.backgroundColor = [UIColor whiteColor];
    _upView.layer.cornerRadius = 3.f;
    _upView.layer.borderWidth = 0.7f;
    _upView.layer.borderColor = [UIColor colorWithRed:201.f/255.f green:201.f/255.f blue:201.f/255.f alpha:1.f].CGColor;
    [_scrollViewC addSubview:_upView];
    
    _downView = [[UIView alloc]initWithFrame:CGRectZero];
    _downView.backgroundColor = [UIColor whiteColor];
    _downView.layer.cornerRadius = 3.f;
    _downView.layer.borderWidth = 0.7f;
    _downView.layer.borderColor = [UIColor colorWithRed:201.f/255.f green:201.f/255.f blue:201.f/255.f alpha:1.f].CGColor;
    [_scrollViewC addSubview:_downView];
    
    [self createUpView];
    
    [self createDownView];
}

// 创建_upView视图
- (void)createUpView
{
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = KCWSystemFont(OrderAddFontSize);
    [_upView addSubview:_nameLabel];
    
    _phoneLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _phoneLabel.backgroundColor = [UIColor clearColor];
    _phoneLabel.textColor = [UIColor blackColor];
    _phoneLabel.font = KCWSystemFont(OrderAddFontSize);
    [_upView addSubview:_phoneLabel];
    
    _addresslabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _addresslabel.backgroundColor = [UIColor clearColor];
    _addresslabel.textColor = [UIColor blackColor];
    _addresslabel.font = KCWSystemFont(OrderAddFontSize);
    _addresslabel.numberOfLines = 2;
    _addresslabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_upView addSubview:_addresslabel];
    
    _imgView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [_upView addSubview:_imgView];
    
    _bgButton = [UIButton buttonWithType:UIControlStateNormal];
    [_bgButton addTarget:self action:@selector(addModButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bgButton setImage:[UIImage imageCwNamed:@"icon_right_store.png"] forState:UIControlStateNormal];
    [_bgButton setImageEdgeInsets:UIEdgeInsetsMake(0.f,270.f,0.f,0.f)];
    [_upView addSubview:_bgButton];
    
    [self setUpViewData];
}

// 设置upView的属性值
- (void)setUpViewData
{
    CGFloat height = OrderAddCellBGUpH;
    CGFloat width = OrderAddCellBGLeftW;
    
    if (self.addressDict == nil) {
        
        height = OrderAddCellBgH;
        width = 100.f;
        
        _upView.frame = CGRectMake(OrderAddCellLeftW, OrderAddCellUpH, KUIScreenWidth - 2*OrderAddCellLeftW, height);
        _bgButton.frame = _upView.bounds;
        
        _imgView.image = [UIImage imageCwNamed:@"icon_plus_store.png"];
        _imgView.frame = CGRectMake(width , CGRectGetHeight(_upView.frame)/2 - _imgView.image.size.height/2, _imgView.image.size.width, _imgView.image.size.height);
        _imgView.hidden = NO;
        
        _addresslabel.text = @"添加收货地址";
        _addresslabel.textColor = [UIColor colorWithRed:1.f/255.f green:105.f/255.f blue:187.f/255.f alpha:1.f];
        _addresslabel.frame = CGRectMake(CGRectGetMaxX(_imgView.frame), CGRectGetMinY(_imgView.frame), 200.f, _imgView.image.size.height);
        
    } else {
        _nameLabel.text = [self.addressDict objectForKey:@"name"];
        CGSize size = [_nameLabel.text sizeWithFont:KCWSystemFont(OrderAddFontSize)];
        _nameLabel.frame = CGRectMake(width, height, size.width, size.height);
        
        width += size.width + 10.f;
        
        _phoneLabel.text = [self.addressDict objectForKey:@"mobile"];
        size = [_phoneLabel.text sizeWithFont:KCWSystemFont(OrderAddFontSize)];
        _phoneLabel.frame = CGRectMake(width, height, size.width, size.height);
        
        height += size.height + 10.f;

        _addresslabel.text = [NSString stringWithFormat:@"%@%@%@",[self.addressDict objectForKey:@"city"],[self.addressDict objectForKey:@"area"],[self.addressDict objectForKey:@"address"]];
        _addresslabel.textColor = [UIColor blackColor];
        NSString *str = @"您";
        CGSize one = [str sizeWithFont:KCWSystemFont(OrderAddFontSize)];
        size = [_addresslabel.text sizeWithFont:KCWSystemFont(OrderAddFontSize) constrainedToSize:CGSizeMake(KUIScreenWidth - 6*OrderAddCellBGLeftW - 2*OrderAddCellLeftW, 1000.f)];
        if (size.height > one.height) {
            _addresslabel.frame = CGRectMake(OrderAddCellBGLeftW, height, size.width, 2*one.height);
            
            height += 2*one.height + OrderAddCellBGUpH;
        } else {
            _addresslabel.frame = CGRectMake(OrderAddCellBGLeftW, height, size.width, one.height);
            
            height += one.height + OrderAddCellBGUpH;
        }
        
        _upView.frame = CGRectMake(OrderAddCellLeftW, OrderAddCellUpH, KUIScreenWidth - 2*OrderAddCellLeftW, height);
        _bgButton.frame = _upView.bounds;
        
        _imgView.hidden = YES;
    }
}

// 创建_downView视图
- (void)createDownView
{
    CGFloat height = OrderAddCellBGUpH;
    CGFloat width = 0.f;
    
    _downView.frame = CGRectMake(OrderAddCellLeftW, OrderAddCellUpH + CGRectGetHeight(_upView.frame), KUIScreenWidth - 2*OrderAddCellLeftW, OrderInfoBGH);
    
    // 店铺背景
    UIView *imgBgView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth - 2*OrderAddCellLeftW, 50.f)];
    imgBgView.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:239.f/255.f alpha:1.f];
    [_downView addSubview:imgBgView];
    [imgBgView release], imgBgView = nil;
    
    // 店铺图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(OrderAddCellLeftW, 5.f, 40.f, 40.f)];
    imageView.image = [UIImage imageCwNamed:@"icon_branch_store.png"];
    [_downView addSubview:imageView];
    
    // 店铺名称btn
    if (self.shopList.count > 1) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 10.f, 5.f, CGRectGetMaxX(_downView.frame) - CGRectGetMaxX(imageView.frame) - 10.f, 40.f);
        [btn setImage:[UIImage imageCwNamed:@"icon_right_store.png"] forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.f, 210.f, 0.f, 0.f)];
        [btn addTarget:self action:@selector(btnShopClick:) forControlEvents:UIControlEventTouchUpInside];
        [_downView addSubview:btn];
    }
    // 店铺名称
    shopLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10.f, 5.f, CGRectGetMaxX(_downView.frame) - CGRectGetMaxX(imageView.frame) - 40.f, 40.f)];
    shopLable.backgroundColor = [UIColor clearColor];
    shopLable.textColor = [UIColor blackColor];
    shopLable.font = KCWSystemFont(OrderAddFontSize);
    shopLable.text = [[self.shopList objectAtIndex:0] objectForKey:@"name"];
    [_downView addSubview:shopLable];
    [imageView release], imageView = nil;

    height += OrderInfoUpBarH - 8;
    width += OrderAddCellBGLeftW + OrderInfoLabelW;
    
    // 支付方式
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(OrderAddCellBGLeftW, height, OrderInfoLabelW, OrderInfoLabelH)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = KCWSystemFont(OrderInfoFontSize);
    label.text = @"支付方式";
    [_downView addSubview:label];
    [label release], label = nil;
    
    // 送货方式   button
    UIButton *goodsbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    goodsbtn.frame = CGRectMake(width, height, OrderBackLabelW, OrderInfoLabelH);
    [goodsbtn setImage:[UIImage imageCwNamed:@"icon_right_store.png"] forState:UIControlStateNormal];
    [goodsbtn setImageEdgeInsets:UIEdgeInsetsMake(0.f, 170.f, 0.f, 0.f)];
    [goodsbtn setTag:OrderShopPayType];
    [goodsbtn addTarget:self action:@selector(orderInfoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:goodsbtn];
    
    // 货到付款
    _goodsType = [[UILabel alloc] initWithFrame:CGRectMake(width, height, OrderInfoLabelW, OrderInfoLabelH)];
    _goodsType.backgroundColor = [UIColor clearColor];
    _goodsType.textColor = [UIColor grayColor];
    _goodsType.font = KCWSystemFont(OrderInfoFontSize);
    _goodsType.text = @"到店付款";
    [_downView addSubview:_goodsType];
    
    height += OrderInfoLabelH;
    
    // 线
    UILabel *lines = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_downView.frame), 0.9f)];
    lines.backgroundColor = [UIColor colorWithRed:241.f/255.f green:241.f/255.f blue:241.f/255.f alpha:0.9f];
    [_downView addSubview:lines];
    [lines release], lines = nil;
    
    // 配送方式
    label = [[UILabel alloc] initWithFrame:CGRectMake(OrderAddCellBGLeftW, height+2, OrderInfoLabelW, OrderInfoLabelH)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = KCWSystemFont(OrderInfoFontSize);
    label.text = @"配送方式";
    [_downView addSubview:label];
    [label release], label = nil;
    
    // 厂家物流
    label = [[UILabel alloc] initWithFrame:CGRectMake(width, height+2, OrderInfoLabelW, OrderInfoLabelH)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.font = KCWSystemFont(OrderInfoFontSize);
    label.text = @"厂家物流";
    [_downView addSubview:label];
    [label release], label = nil;
    
    height += OrderInfoLabelH +5 ;
    
    // 线
    UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_downView.frame), 0.9f)];
    line2.backgroundColor = [UIColor colorWithRed:241.f/255.f green:241.f/255.f blue:241.f/255.f alpha:0.9f];
    [_downView addSubview:line2];
    [line2 release], line2 = nil;
    
    // 送货时间
    label = [[UILabel alloc] initWithFrame:CGRectMake(OrderAddCellBGLeftW, height+5, OrderInfoLabelW, OrderInfoLabelH)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = KCWSystemFont(OrderInfoFontSize);
    label.text = @"送货时间";
    [_downView addSubview:label];
    [label release], label = nil;
    
    // 送货时间   button
    UIButton *bgbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgbtn.frame = CGRectMake(width, height+5, OrderBackLabelW, OrderInfoLabelH);
    [bgbtn setImage:[UIImage imageCwNamed:@"icon_right_store.png"] forState:UIControlStateNormal];
    [bgbtn setImageEdgeInsets:UIEdgeInsetsMake(0.f, 170.f, 0.f, 0.f)];
    [bgbtn setTag:OrderShopTimeType];
    [bgbtn addTarget:self action:@selector(orderInfoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:bgbtn];
    
    // 送货时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height+5, OrderBackLabelW, OrderInfoLabelH)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.font = KCWSystemFont(OrderInfoFontSize);
    self.sendTime = [CustomPicker getFormatterDate];
    _timeLabel.text = [PreferentialObject getTypeDate:self.sendTime symbol:2];
    [_downView addSubview:_timeLabel];
    
    height += OrderInfoLabelH + OrderAddCellBGUpH;
    
    // 线
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_downView.frame), 0.9f)];
    line.backgroundColor = [UIColor colorWithRed:241.f/255.f green:241.f/255.f blue:241.f/255.f alpha:0.9f];
    [_downView addSubview:line];
    [line release], line = nil;
    
    // 发票抬头
    label = [[UILabel alloc] initWithFrame:CGRectMake(OrderAddCellBGLeftW, height, OrderInfoLabelW, OrderInfoLabelH)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = KCWSystemFont(OrderInfoFontSize);
    label.text = @"发票抬头";
    [_downView addSubview:label];
    [label release], label = nil;

// 发票抬头 名称
//    _invoiceHeadText = [[UITextField alloc]initWithFrame:CGRectMake(width, height, OrderBackLabelW, OrderInfoLabelH + 20.f)];
//    _invoiceHeadText.placeholder = @"请输入发票抬头(个人或者公司)";
//    _invoiceHeadText.font = KCWSystemFont(OrderInfoFontSize);
//    _invoiceHeadText.autocorrectionType = UITextAutocorrectionTypeNo;
//    _invoiceHeadText.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    _invoiceHeadText.returnKeyType = UIReturnKeyDefault;
//    _invoiceHeadText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;  // 设置为居中输入
////    _invoiceHeadText.delegate = self;
//    [_downView addSubview:_invoiceHeadText];
    
    // 文本框输入
    _invoiceHeadText = [[UITextView alloc]initWithFrame:CGRectMake(width-10.f, height + 1.f, OrderBackLabelW, OrderInfoLabelH)];
    _invoiceHeadText.delegate = self;
    _invoiceHeadText.text = InvoiceMessage;
    _invoiceHeadText.textColor = [UIColor grayColor];
    _invoiceHeadText.font = KCWSystemFont(OrderInfoFontSize);
    _invoiceHeadText.returnKeyType = UIReturnKeyDone;//返回键的类型
    _invoiceHeadText.keyboardType = UIKeyboardTypeDefault;
    [_downView addSubview:_invoiceHeadText];
    
    height += OrderInfoLabelH;
    
    line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_downView.frame), 0.9f)];
    line.backgroundColor = [UIColor colorWithRed:241.f/255.f green:241.f/255.f blue:241.f/255.f alpha:0.9f];
    [_downView addSubview:line];
    [line release], line = nil;
    
    // 优惠劵
    label = [[UILabel alloc] initWithFrame:CGRectMake(OrderAddCellBGLeftW, height, OrderInfoLabelW, OrderInfoLabelH + 10.f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = KCWSystemFont(OrderInfoFontSize);
    label.text = @"优惠劵";
    [_downView addSubview:label];
    [label release], label = nil;
    
    // 优惠   button
    bgbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgbtn.frame = CGRectMake(width, height, OrderBackLabelW, OrderInfoLabelH + 10.f);
    [bgbtn setImage:[UIImage imageCwNamed:@"icon_right_store.png"] forState:UIControlStateNormal];
    [bgbtn setImageEdgeInsets:UIEdgeInsetsMake(0.f,170.f,0.f,0.f)];
    [bgbtn setTag:OrderShopticketType];
    [bgbtn addTarget:self action:@selector(orderInfoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:bgbtn];
    
    // 优惠
    _ticketLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height, OrderBackLabelW-40.f, OrderInfoLabelH + 10.f)];
    _ticketLabel.backgroundColor = [UIColor clearColor];
    _ticketLabel.textColor = [UIColor grayColor];
    _ticketLabel.font = KCWSystemFont(OrderInfoFontSize);
    _ticketLabel.text = @"";
    [_downView addSubview:_ticketLabel];
    
    height += OrderInfoLabelH + 10.f;
    
    // 线
    line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, height, CGRectGetWidth(_downView.frame), 0.9f)];
    line.backgroundColor = [UIColor colorWithRed:241.f/255.f green:241.f/255.f blue:241.f/255.f alpha:0.9f];
    [_downView addSubview:line];
    [line release], line = nil;
    
    height += OrderAddCellBGUpH;
    
    // 文本框输入
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(OrderAddCellBGLeftW, height, CGRectGetWidth(_downView.frame) - 2*OrderAddCellBGLeftW, 80.f)];
    _textView.delegate = self;
    _textView.text = OrderMessage;
    _textView.textColor = [UIColor grayColor];
    _textView.font = KCWSystemFont(OrderInfoFontSize);
    _textView.returnKeyType = UIReturnKeyDone;//返回键的类型
    _textView.keyboardType = UIKeyboardTypeDefault;
    [_downView addSubview:_textView];
    
    [self setdownViewFrame];
}

// 设置downView视图的frame
- (void)setdownViewFrame
{
    _downView.frame = CGRectMake(OrderAddCellLeftW, OrderAddCellUpH + CGRectGetMaxY(_upView.frame), KUIScreenWidth - 2*OrderAddCellLeftW, OrderInfoBGH);
}

- (void)createDownBarView
{
    UIView *downBarView = [[UIView alloc]initWithFrame:CGRectMake(0.f, KUIScreenHeight- KUpBarHeight- OrderShopDownBarH, KUIScreenWidth, OrderShopDownBarH)];
    downBarView.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(70.f, 5.f, 180.f, 40.f);
    [btn setTitle:@"提交预订" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:234.f/255.f green:50.f/255.f blue:43.f/255.f alpha:1.f]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5.f;
    [downBarView addSubview:btn];
    
    [self.view addSubview:downBarView];
    [downBarView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog(@"ordershopview  dealloc.....");
    [_scrollViewC release], _scrollViewC = nil;
    self.addressDict = nil;
    [succeedView release], succeedView = nil;
    [payPickerView release], payPickerView = nil;
    [_upView release], _upView = nil;
    [_downView release], _downView = nil;
    
    [_imgView release], _imgView = nil;
    [_phoneLabel release], _phoneLabel = nil;
    [_addresslabel release], _addresslabel = nil;
    [_nameLabel release], _nameLabel = nil;
    
    [_timeLabel release], _timeLabel = nil;
    //    [_companyName release], _companyName = nil;
    [_invoiceHeadText release], _invoiceHeadText = nil;
    [_invoiceLabel release], _invoiceLabel = nil;
    [_ticketLabel release], _ticketLabel = nil;
    [_textView release], _textView = nil;
    [_goodsType release], _goodsType = nil;
    
    self.progressHUD = nil;
    self.sendTime = nil;
    [exitButton release],exitButton = nil;
    self.shopList = nil;
    [shopLable release], shopLable = nil;
    
    [super dealloc];
}

// 预订中
- (void)progress
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
    self.progressHUD = progressHUDTmp;
    [progressHUDTmp release];
    self.progressHUD.delegate = self;
    self.progressHUD.labelText = @"预订中...";
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
}

// 操作返回的结果视图
- (void)progressHUD:(NSString *)result type:(int)atype
{
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center = CGPointMake(self.view.center.x, self.view.center.y + 60);
    
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

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (self.progressHUD) {
        [progressHUD removeFromSuperview];
    }
}

#pragma mark ----UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CustomPicker *picer = (CustomPicker *)actionSheet;
        
        NSDate *currentDate = [PreferentialObject getdateDate:picer.myDate];
        
        NSTimeInterval t = [currentDate timeIntervalSince1970];     // 转化为时间戳
        long long int time = (long long int)t;
        
        NSNumber *value = [NSNumber numberWithLongLong:time];
        
        NSDate *nowDate = [PreferentialObject getdateDate:[NSDate date]];
        
        NSTimeInterval t1 = [nowDate timeIntervalSince1970];        // 转化为时间戳
        long long int time1 = (long long int)t1;
        NSNumber *num = [NSNumber numberWithLongLong:time1];
        int currentInt = [num intValue];
        
        if ([value intValue] <= currentInt) {
            [self progressHUD:@"预约时间小于当前时间" type:3];
        }else {
            self.sendTime = picer.myDate;
            _timeLabel.text = [PreferentialObject getTypeDate:picer.myDate symbol:2];;
        }
    }
}

// 键盘button
- (void)CancelBackKeyboard:(UIButton *)btn
{
    [self closeTextField];
}

- (void)setBtnexitButton
{
    if (exitButton == nil) {
        exitButton = [[UIButton alloc]initWithFrame:CGRectZero];
        exitButton.frame = CGRectMake(KUIScreenWidth-77.f, KUIScreenHeight - 23, 75, 40);
        exitButton.adjustsImageWhenHighlighted = NO;
        [exitButton.titleLabel setFont:KCWboldSystemFont(17.f)];
        [exitButton setTitle:@"确定" forState:UIControlStateNormal];
        [exitButton setBackgroundImage:[UIImage imageCwNamed:@"keyboard_btn.png"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(CancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        exitButton.tag = 10000;
    }
    UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    if (![[tempWindow viewWithTag:10000] isKindOfClass:[UIButton class]]) {
        [tempWindow addSubview:exitButton];    // 注意这里直接加到window上
    }
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
    
    // 键盘显示需要的时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    if ((KUIScreenHeight - keyboardRect.size.height) <= CGRectGetHeight(_scrollViewC.frame) + KUpBarHeight) {
        
        CGRect scrRect = _scrollViewC.frame;
        scrRect.size.height = KUIScreenHeight - keyboardRect.size.height - KUpBarHeight;
        [UIView animateWithDuration:animationDuration animations:^{
            _scrollViewC.frame = scrRect;
        } completion:^(BOOL finished) {
//            [self setBtnexitButton];
            _scrollViewC.contentOffset = CGPointMake(0.f, _scrollViewC.contentSize.height - CGRectGetHeight(_scrollViewC.frame));
        }];
    }
}

// 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    // 键盘显示需要的时间
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect scrRect = _scrollViewC.frame;
    scrRect.size.height = KUIScreenHeight - KUpBarHeight - OrderShopDownBarH;
    
    [UIView animateWithDuration:0.23 animations:^{
        [exitButton removeFromSuperview];
        _scrollViewC.frame = scrRect;
    }];
}

// 分店选择
- (void)btnShopClick:(UIButton *)btn
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in self.shopList) {
        [arr addObject:[dict objectForKey:@"name"]];
    }
    NSLog(@"arr = %@",arr);
    [payPickerView addPopupSubviewType:PopPickerTypeShop arr:arr];
}

// 时间  优惠券   发票
- (void)orderInfoBtnClick:(UIButton *)btn
{
    if (btn.tag == OrderShopTimeType) {                     // 送货时间
        [self closeTextField];
        CustomPicker *picker = [[CustomPicker alloc]initWithDateAndTimePicker:CGRectMake(0, 0, KUIScreenWidth, self.view.frame.size.height - 130) withTime:nil type:1];
        [picker timePickShowInView:[UIApplication sharedApplication].delegate.window];
        picker.delegate = self;
        [picker release];
    } else if (btn.tag == OrderShopInvoiceType) {           // 发票信息
        InvoiceViewController *invoiceView = [[InvoiceViewController alloc]init];
        invoiceView.delegate = self;
        //invoiceView.invoiceTitle = _companyName.text;
        [self.navigationController pushViewController:invoiceView animated:YES];
        [invoiceView release], invoiceView = nil;
    } else if (btn.tag == OrderShopticketType){             // 优惠信息
        CouponsViewController *couponsView = [[CouponsViewController alloc]init];
        couponsView.delegate = self;
        couponsView.productID = [self.shopDict objectForKey:@"product_id"];
        //couponsView.dataArr = self.dataArr;
        couponsView.shopID = self.defaultShopID;
        [self.navigationController pushViewController:couponsView animated:YES];
        [couponsView release], couponsView = nil;
    } else if (btn.tag == OrderShopPayType) {               // 支付方式
        [self closeTextField];
        [payPickerView addPopupSubviewType:PopPickerTypePay arr:[NSMutableArray arrayWithObjects:@"到店付款",@"货到付款", nil]];
    }
}

// 添加或者修改地址
- (void)addModButtonClick:(UIButton *)btn
{
    [self closeTextField];
    
    ChooseAddressViewController *chooseAdd = [[ChooseAddressViewController alloc]init];
    chooseAdd.delegate = self;
    [self.navigationController pushViewController:chooseAdd animated:YES];
    [chooseAdd release], chooseAdd = nil;
}

// 提交预订 button函数
- (void)btnClick:(UIButton *)btn
{
    if ([[self.addressDict objectForKey:@"address"] length] == 0) {
        [Common MsgBox:@"提示" messege:@"您还没有填写收货地址" cancel:@"确定" other:nil delegate:nil];
        return;
    } else if (_invoiceHeadText.text.length == 0 || [_invoiceHeadText.text isEqualToString:InvoiceMessage]) {
        [Common MsgBox:@"提示" messege:@"发票抬头不可以为空" cancel:@"确定" other:nil delegate:nil];
        return;
    }
    [self progress];
    [self accessItemService];
}

// 判断有没有默认的地址
- (void)judge_address_list
{
    self.addressDict = nil;
    
    address_list_model *alMod = [[address_list_model alloc]init];
    alMod.orderBy = @"created";
    alMod.orderType = @"desc";
    NSMutableArray *arr = [alMod getList];
    if (arr.count > 0) {
        for (int i = 0; i < arr.count; i++) {
            NSMutableDictionary *dict = [arr objectAtIndex:i];
            if ([[dict objectForKey:@"used"] intValue] == 1) {
                self.addressDict = dict;
            }
        }
        if (self.addressDict == nil) {
            self.addressDict = [arr objectAtIndex:0];
        }
    }
    [alMod release], alMod = nil;
}
// 设置留言框字体颜色
- (void)setTextViewText:(NSString *)text begin:(BOOL)begin
{
    if (begin) {
        if ([_textView isFirstResponder]) {
            if ([_textView.text isEqualToString:OrderMessage]) {
                _textView.text = nil;
            }
            _textView.textColor = [UIColor blackColor];
        } else {
            if ([_invoiceHeadText.text isEqualToString:InvoiceMessage]) {
                _invoiceHeadText.text = nil;
            }
            _invoiceHeadText.textColor = [UIColor blackColor];
        }
    } else {
        if ([_textView isFirstResponder]) {
            if (_textView.text.length == 0) {
                _textView.text = OrderMessage;
                _textView.textColor = [UIColor grayColor];
            } else {
                _textView.textColor = [UIColor blackColor];
            }
        } else {
            if (_invoiceHeadText.text.length == 0) {
                _invoiceHeadText.text = InvoiceMessage;
                _invoiceHeadText.textColor = [UIColor grayColor];
            } else {
                _invoiceHeadText.textColor = [UIColor blackColor];
            }
        }
    }
}

// 关闭文本框
- (void)closeTextField
{
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    } else {
        [_invoiceHeadText resignFirstResponder];
    }
}

// 输入框
#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_textView isFirstResponder]) {
        [self setTextViewText:_textView.text begin:YES];
    } else {
        [self setTextViewText:_invoiceHeadText.text begin:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_textView isFirstResponder]) {
        [self setTextViewText:_textView.text begin:NO];
    } else {
        [self setTextViewText:_invoiceHeadText.text begin:NO];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {//按下return键
        //这里隐藏键盘，不做任何处理
        [self closeTextField];
        return NO;
    }
    return YES;
}

// 选中地址返回
#pragma mark - ChooseAddressViewControllerDelegate
- (void)chooseAddressViewObject:(NSMutableDictionary *)dict
{
    self.addressDict = dict;
    
    [self setUpViewData];
    
    [self setdownViewFrame];
}

// 优惠券返回数据
#pragma mark - CouponsViewControllerDelegate
- (void)getCouponsTitle:(NSString *)title money:(int)pmoney couponsid:(int)acouponsID
{
    _ticketLabel.text = title;
    couponsMoney = pmoney;
    couponsID = acouponsID;
    NSLog(@"couponsID = %d",couponsID);
//    pay_money = [[self.shopDict objectForKey:@"price"] intValue] - pmoney;
}

// 时间选择器返回数据
#pragma mark - PopAddressPickerViewDelegate
- (void)getID:(PopPickerType)pickerType text:(NSString *)text type:(int)type
{
    if (pickerType == PopPickerTypePay) {
        _goodsType.text = text;
        payType = type + 1;
        NSLog(@"payType = %d",payType);
    } else if (pickerType == PopPickerTypeShop) {
        shopLable.text = text;
        self.defaultShopID = [NSString stringWithFormat:@"%d",[[[self.shopList objectAtIndex:type] objectForKey:@"id"] intValue]];
    }
}

// 发票返回数据
#pragma mark - InvoiceViewControllerDelegate
- (void)getInvoiceInfo:(NSString *)text typeText:(NSString *)typeText type:(int)type
{
    invoiceType = type;
    _invoiceLabel.text = typeText;
    //    _companyName.text = text;
}

// 预订成功跳转
#pragma mark - PopBookSucceedViewDelegate
- (void)PopBookSucceedViewClick:(PopBookSucceedView *)popBookView
{
    OrderListViewController *ordelView = [[OrderListViewController alloc]init];
    ordelView.StatusType = StatusTypeOrderToMember;
    [self.navigationController pushViewController:ordelView animated:YES];
    [ordelView release], ordelView = nil;
}

#pragma mark - network
// 网络请求
- (void)accessItemService
{
    NSString *reqUrl = @"order.do?param=";
    NSLog(@"self.shopDict = %@",self.shopDict);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [self.shopDict objectForKey:@"product_id"],@"id",
                          [self.shopDict objectForKey:@"name"],@"name",
                          @"1",@"num",
                          [NSString stringWithFormat:@"%d",pay_money],@"price", nil];
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    [arr addObject:[dict JSONString]];
    
    NSString *textView = nil;
    if (_textView.text.length == 0 || [_textView.text isEqualToString:OrderMessage]) {
        textView = @" ";
    } else {
        textView = _textView.text;
    }
    
    NSString *textInvoice = nil;
    if (_invoiceHeadText.text.length == 0 || [_invoiceHeadText.text isEqualToString:InvoiceMessage]) {
        textInvoice = @" ";
    } else {
        textInvoice = _invoiceHeadText.text;
    }
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN_KEY];
    
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [Global sharedGlobal].user_id,@"user_id",
                                       [self.addressDict objectForKey:@"name"],@"user_name",
                                       [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]],@"reserve_time",
                                       self.defaultShopID,@"shop_id",
                                       [self.addressDict objectForKey:@"id"],@"address_id",
                                       [NSString stringWithFormat:@"%d",couponsID],@"promotion_id",
                                       [NSString stringWithFormat:@"%d",couponsMoney],@"discount",
                                       [self.addressDict objectForKey:@"province"],@"province",
                                       [self.addressDict objectForKey:@"city"],@"city",
                                       [self.addressDict objectForKey:@"area"],@"area",
                                       [self.addressDict objectForKey:@"address"],@"address",
                                       [NSString stringWithFormat:@"%d",payType],@"pay_way",
                                       [NSString stringWithFormat:@"%d",(int)[self.sendTime timeIntervalSince1970]],@"send_time",
                                       [NSString stringWithFormat:@"%d",invoiceType],@"invoice_type",
                                       textInvoice,@"invoice_title",
                                       textView,@"remark",
                                       [self.shopDict objectForKey:@"price"],@"money",
                                       [NSString stringWithFormat:@"%d",pay_money],@"pay_money",
                                       [self.addressDict objectForKey:@"mobile"],@"mobile",
                                       arr,@"productinfo",
                                       token,@"token",
                                       nil];
    
    NSLog(@"requestDic = %@",requestDic);

    [[NetManager sharedManager]accessService:requestDic
                                        data:nil
                                     command:ORDER_COMMAND_ID
                                accessAdress:reqUrl
                                    delegate:self
                                   withParam:nil];
}

// 网络请求成功后的数据解析
- (void)updateDataArr:(NSMutableArray *)arr
{
    if (![[arr lastObject] isEqual:CwRequestFail]) {
        if ([[arr lastObject] isEqual:CwRequestTimeout]) {
            [self progressHUD:KCWServerBusyPrompt type:3];
        } else {
            if (arr.count > 0) {
                if ([[arr lastObject] intValue] == 1) {
                    if ([delegate respondsToSelector:@selector(orderShopViewSuccessNum)]) {
                        [delegate orderShopViewSuccessNum];
                    }
                    [self.progressHUD hide:YES afterDelay:0.f];
                    [succeedView addPopupSubview];
                } else if ([[arr lastObject] intValue] == 2) {
                    [self.progressHUD hide:YES afterDelay:0.f];
                    [self progressHUD:@"没有库存了" type:0];
                } else if ([[arr lastObject] intValue] == 4) {
                    [self.progressHUD hide:YES afterDelay:0.f];
                    [self progressHUD:@"该型号的商品您预定的次数太多了额" type:0];
                } else {
                    [self.progressHUD hide:YES afterDelay:0.f];
                    [self progressHUD:@"预订失败" type:0];
                }
            } else {
                [self.progressHUD hide:YES afterDelay:0.f];
                [self progressHUD:@"预订失败" type:0];
            }
        }
    } else {
        [self.progressHUD hide:YES afterDelay:0.f];
        if ([Common connectedToNetwork]) {
            [self progressHUD:@"网络繁忙，预订失败，请稍后再试" type:0];
        } else {
            [self progressHUD:KCWNetNOPrompt type:3];
        }
    }
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver
{
    if (commandid == ORDER_COMMAND_ID) {
        [self updateDataArr:resultArray];
    } 
}

@end
