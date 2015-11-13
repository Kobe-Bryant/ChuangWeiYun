//
//  CustomPicker.h
//  cw
//
//  Created by LuoHui on 13-9-2.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface CustomPicker : UIActionSheet <UIPickerViewDelegate,UIPickerViewDataSource>
{
    
}
@property (nonatomic, strong) UIPickerView   *pickerView;
@property (nonatomic, strong) UIDatePicker   *datepickerView;
@property (nonatomic, strong) NSMutableArray *pickerArray;
@property (nonatomic, strong) UILabel        *Label;
@property (nonatomic, strong) id             obj;
@property (nonatomic, strong) UILabel        *displayLabel;
@property (nonatomic, strong) NSDate       *myDate;
@property (nonatomic, assign) int           pickerType;

- (id)initWithTitle:(NSString *)title withFrame:(CGRect)frame delegate:(id)delegate PickerArray:(NSMutableArray *)picker_Array Obj:(id)object_done;

- (void)showInView:(UIView *)view;
- (void)showInDelegateView:(UIView *)view;
- (id)initWithDateAndTimePicker:(CGRect)frame withTime:(NSString *)timeStr type:(int)type;
- (id)initWithDatePicker:(CGRect)frame withTime:(NSString *)timeStr;
- (id)initWithTimePicker:(CGRect)frame withTime:(NSString *)timeStr;
- (void)timePickShowInView:(UIView *) view;
+ (NSDate *)getFormatterDate;

@end
