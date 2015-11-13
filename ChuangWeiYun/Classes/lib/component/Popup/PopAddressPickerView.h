//
//  PopAddressPickerView.h
//  cw
//
//  Created by yunlai on 13-9-9.
//
//

#import "PopupView.h"

typedef enum
{
    PopPickerTypeAddress,           // 地址
    PopPickerTypeTime,              // 时间
    PopPickerTypeInvoice,           // 发票
    PopPickerTypePay,               // 支付方式
    PopPickerTypeShop,              // 分店选择
}PopPickerType;

@protocol PopAddressPickerViewDelegate;

@interface PopAddressPickerView : PopupView <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIPickerView *_pickerView;
    UIView *_upBarView;
    NSMutableArray *provinceDict;
    NSMutableArray *cityDict;
    NSMutableArray *areaDict;
    
    int provinceSelectRow;
    int citySelectRow;
    int areaSelectRow;
    
    PopPickerType type;
    NSMutableArray *dataArr;
    int selectRow;
    
    id <PopAddressPickerViewDelegate> delegate;
}

@property (retain, nonatomic) NSMutableArray *provinceDict;
@property (retain, nonatomic) NSMutableArray *cityDict;
@property (retain, nonatomic) NSMutableArray *areaDict;
@property (retain, nonatomic) NSMutableArray *dataArr;

@property (assign, nonatomic) PopPickerType type;

@property (assign, nonatomic) id <PopAddressPickerViewDelegate> delegate;

- (id)init;

- (void)addPopupSubviewType:(PopPickerType)atype arr:(NSArray *)arr;

// 刷新数据
- (void)pickerViewReload;

@end

@protocol PopAddressPickerViewDelegate <NSObject>

@optional
// 得到城市数据
- (NSMutableArray *)getAddressCity:(NSString *)province;
// 得到地区数据
- (NSMutableArray *)getAddressArea:(NSString *)city;
// 返回地址
- (void)getAddressGroup:(NSString *)address arrID:(NSMutableArray *)idArr;
// 得到数据根据创建ID
- (void)getID:(PopPickerType)pickerType text:(NSString *)text type:(int)type;

@end
