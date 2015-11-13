//
//  CustomPicker.m
//  cw
//
//  Created by LuoHui on 13-9-2.
//
//

#import "CustomPicker.h"

#define kDuration 0.3

@implementation CustomPicker

@synthesize Label           = _Label;
@synthesize pickerArray     = _pickerArray;
@synthesize pickerView      = _pickerView;
@synthesize obj             = _obj;
@synthesize displayLabel    = _displayLabel;
@synthesize datepickerView  = _datepickerView;
@synthesize myDate          = _myDate;
@synthesize pickerType      = _pickerType;

- (id)initWithTitle:(NSString *)title withFrame:(CGRect)frame delegate:(id)delegate PickerArray:(NSMutableArray *)picker_Array Obj:(id)object_done
{
    self = [super init];
    
    if (self)
    {
        
        _displayLabel = [[UILabel alloc] initWithFrame:frame];
        _displayLabel.backgroundColor = [UIColor clearColor];
        _displayLabel.userInteractionEnabled = YES;
        
        self.title = title;
        self.pickerArray = picker_Array;
        self.obj = object_done;
        self.frame = CGRectMake(0, _displayLabel.frame.size.height + 200, 320,220);
        [self setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 7.0f, 200.0f, 30.0f)];
        labelTitle.textAlignment = 1;
        labelTitle.text = self.title;
        labelTitle.font = [UIFont systemFontOfSize:13];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.backgroundColor = [UIColor clearColor];
        [self addSubview:labelTitle];
        [labelTitle release];
        
//        UISegmentedControl *cancleButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"取消"]];
//        cancleButton.momentary = YES;
//        cancleButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
//        cancleButton.segmentedControlStyle = UISegmentedControlStyleBar;
//        cancleButton.tintColor = [UIColor blackColor];
//        [cancleButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventValueChanged];
//        [self addSubview:cancleButton];
        
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"确定"]];
        closeButton.momentary = YES;
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
        [self addSubview:closeButton];
        
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 100)];
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
        
    }
    
    return self;
    
}

/*
 *  type = 0  _datepickerView.datePickerMode=UIDatePickerModeDateAndTime;
 *  type = 1  _datepickerView.datePickerMode = UIDatePickerModeDate;
 */    
- (id)initWithDateAndTimePicker:(CGRect)frame withTime:(NSString *)timeStr type:(int)type
{
    self = [super init];
    if (self) {
        _displayLabel = [[UILabel alloc] initWithFrame:frame];
        _displayLabel.backgroundColor = [UIColor clearColor];
        _displayLabel.userInteractionEnabled = YES;
        
        self.frame = CGRectMake(0, _displayLabel.frame.size.height + 200, 320,220);
        [self setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 7.0f, 200.0f, 30.0f)];
        labelTitle.textAlignment = 1;
        labelTitle.text = self.title;
        labelTitle.font = [UIFont systemFontOfSize:13];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.backgroundColor = [UIColor clearColor];
        [self addSubview:labelTitle];
        [labelTitle release];
        
        UISegmentedControl *cancleButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"取消"]];
        cancleButton.momentary = YES;
        cancleButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
        cancleButton.segmentedControlStyle = UISegmentedControlStyleBar;
        
        if (IOS_7) {
            cancleButton.backgroundColor = [UIColor whiteColor];
        }else{
            cancleButton.backgroundColor = [UIColor clearColor];
            cancleButton.tintColor = [UIColor blackColor];
        }
        
        
        [cancleButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventValueChanged];
        [self addSubview:cancleButton];
        
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"确定"]];
        closeButton.momentary = YES;
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        if (IOS_7) {
            closeButton.backgroundColor = [UIColor whiteColor];
        }else{
            closeButton.backgroundColor = [UIColor clearColor];
            closeButton.tintColor = [UIColor blackColor];
        }
        
        [closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
        [self addSubview:closeButton];
        
        _datepickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 37, 320, 180)];
        
        if (IOS_7) {
            _datepickerView.backgroundColor = [UIColor whiteColor];
        }
        
        if (timeStr != nil && timeStr.length > 0) {
            NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"yyyy年MM月dd日 HH点mm分"];
            NSDate *currentDate = [dateFormate dateFromString:timeStr];
            _datepickerView.date = currentDate;
            [dateFormate release];
        }else {
            NSDate *now = [NSDate date];
            _datepickerView.date = now;
        }
        
        _pickerType = type;
        if (_pickerType == 1) {
            NSDate *minDate = [CustomPicker getFormatterDate];

            NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"yyyy-MM-dd"];
            NSString *dateStr = [dateFormate stringFromDate:minDate];
            NSDate *currentDate = [dateFormate dateFromString:dateStr];
            [dateFormate release];
            
            self.myDate = [CustomPicker getZoneDate:currentDate];
            _datepickerView.date = minDate;
//            NSTimeInterval interval = 24*60*60;
//            _datepickerView.minimumDate = [NSDate date];
            _datepickerView.datePickerMode = UIDatePickerModeDate;
        } else {
            _datepickerView.datePickerMode = UIDatePickerModeDateAndTime;
        }
        
        [self addSubview:_datepickerView];
        
    }
    return self;
}

+ (NSDate *)getFormatterDate
{
    NSDate *minDate = [NSDate date];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateformatter stringFromDate:minDate];
    NSString *str = [NSString stringWithFormat:@"%@ 16:30:00",dateStr];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *bDate = [dateformatter dateFromString:str];
    [dateformatter release], dateformatter = nil;
    bDate = [CustomPicker getZoneDate:bDate];
    
    if ([bDate compare:[CustomPicker getZoneDate:minDate]] == NSOrderedAscending) {
        NSTimeInterval  interval = 24*60*60*2;
        minDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    } else {
        NSTimeInterval  interval = 24*60*60;
        minDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    }
    
    return minDate;
}

+ (NSDate *)getZoneDate:(NSDate *)date
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *reDate = [date dateByAddingTimeInterval:interval];
    
    return reDate;
}

- (id)initWithDatePicker:(CGRect)frame withTime:(NSString *)timeStr
{
    self = [super init];
    if (self) {
        _displayLabel = [[UILabel alloc] initWithFrame:frame];
        _displayLabel.backgroundColor = [UIColor clearColor];
        _displayLabel.userInteractionEnabled = YES;
        
        self.frame = CGRectMake(0, _displayLabel.frame.size.height + 200, 320,220);
        [self setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 7.0f, 200.0f, 30.0f)];
        labelTitle.textAlignment = 1;
        labelTitle.text = self.title;
        labelTitle.font = [UIFont systemFontOfSize:13];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.backgroundColor = [UIColor clearColor];
        [self addSubview:labelTitle];
        [labelTitle release];
        
        UISegmentedControl *cancleButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"取消"]];
        cancleButton.momentary = YES;
        cancleButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
        cancleButton.segmentedControlStyle = UISegmentedControlStyleBar;
        cancleButton.tintColor = [UIColor blackColor];
        [cancleButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventValueChanged];
        [self addSubview:cancleButton];
        
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"确定"]];
        closeButton.momentary = YES;
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
        [self addSubview:closeButton];

        _datepickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 200)];
        
        if (timeStr != nil && timeStr.length > 0) {
            NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"yyyy-MM-dd"];
            NSDate *currentDate = [dateFormate dateFromString:timeStr];
            _datepickerView.date = currentDate;
            [dateFormate release];
        }else {
            NSDate *now=[NSDate date];
            _datepickerView.date=now;
        }
        
        _datepickerView.datePickerMode = UIDatePickerModeDate;
        [self addSubview:_datepickerView];
        
    }
    return self;
}

- (id)initWithTimePicker:(CGRect)frame withTime:(NSString *)timeStr
{
    self = [super init];
    if (self) {
        _displayLabel = [[UILabel alloc] initWithFrame:frame];
        _displayLabel.backgroundColor = [UIColor clearColor];
        _displayLabel.userInteractionEnabled = YES;
        
        self.frame = CGRectMake(0, _displayLabel.frame.size.height + 200, 320,220);
        [self setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 7.0f, 200.0f, 30.0f)];
        labelTitle.textAlignment = 1;
        labelTitle.text = self.title;
        labelTitle.font = [UIFont systemFontOfSize:13];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.backgroundColor = [UIColor clearColor];
        [self addSubview:labelTitle];
        [labelTitle release];
        
        UISegmentedControl *cancleButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"取消"]];
        cancleButton.momentary = YES;
        cancleButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
        cancleButton.segmentedControlStyle = UISegmentedControlStyleBar;
        cancleButton.tintColor = [UIColor blackColor];
        [cancleButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventValueChanged];
        [self addSubview:cancleButton];
        
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"确定"]];
        closeButton.momentary = YES;
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
        [self addSubview:closeButton];
        
        
        _datepickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 200)];
        
        if (timeStr != nil && timeStr.length > 0) {
            NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
            [dateFormate setDateFormat:@"HH:mm"];
            NSDate *currentDate = [dateFormate dateFromString:timeStr];
            _datepickerView.date = currentDate;
            [dateFormate release];
        }else {
            NSDate *now=[NSDate date];
            _datepickerView.date=now;
        }
        
        _datepickerView.datePickerMode = UIDatePickerModeTime;
        [self addSubview:_datepickerView];
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if ([self.obj isKindOfClass:[UIButton class]])
    {
        UIButton *btn = (UIButton *)self.obj;
        
        if ([self.pickerArray containsObject:btn.titleLabel.text])
        {
            
            int index = [self.pickerArray indexOfObject:btn.titleLabel.text];
            [_pickerView selectRow:index inComponent:0 animated:YES];
            
        }
        
    }
    
    if ([self.obj isKindOfClass:[UILabel class]])
    {
        
        UILabel *label = (UILabel *)self.obj;
        
        if ([self.pickerArray containsObject:label.text])
        {
            
            int index = [self.pickerArray indexOfObject:label.text];
            NSLog(@"%d",index);
            [_pickerView selectRow:index inComponent:0 animated:YES];
            
        }
        
    }
    
    if ([self.obj isKindOfClass:[UITextField class]])
    {
        
        UITextField *field = (UITextField *)self.obj;
        
        if ([self.pickerArray containsObject:field.text])
        {
            
            int index = [self.pickerArray indexOfObject:field.text];
            [_pickerView selectRow:index inComponent:0 animated:YES];
            
        }
    }
    
}

- (void)showInView:(UIView *) view
{
    [view addSubview:self];
    [view addSubview:self.displayLabel];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.frame = CGRectMake(0, view.frame.size.height - 320, 320,220 );
    [UIView commitAnimations];
}

- (void)showInDelegateView:(UIView *) view
{
    [view addSubview:self];
    [view addSubview:self.displayLabel];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.frame = CGRectMake(0, view.frame.size.height - 200, 320,260 );
    [UIView commitAnimations];
}

- (void)timePickShowInView:(UIView *) view
{
    [view addSubview:self];
    [view addSubview:self.displayLabel];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.frame = CGRectMake(0, view.frame.size.height - 210, 320,220 );
    [UIView commitAnimations];
}
#pragma mark - Button lifecycle

- (void)cancel
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.frame = CGRectMake(0, 550, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    
    [_displayLabel removeFromSuperview];
    
    if(self.delegate)
    {
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
}

- (void)dismissActionSheet
{
    if (_pickerType == 1) {        
        if ([_datepickerView.date compare:self.myDate] == NSOrderedAscending
            || [_datepickerView.date compare:self.myDate] == NSOrderedSame) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                               message:@"不可以选择之前的日期"
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles: nil];
            [alertView show];
            [alertView release];
            return;
        } else {
            NSString *message = nil;
            NSDateComponents *comps = [[NSDateComponents alloc]init];
            [comps setMinute:30];
            [comps setHour:16];
            [comps setMonth:01];
            [comps setDay:31];
            [comps setYear:2013];
            NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *adate = [calendar dateFromComponents:comps];
            [comps release];
            [calendar release];
            NSDate *date = [NSDate date];
            if ([date compare:adate] == NSOrderedAscending) {
                message = @"今天16：30之前预订的商品，最早只能选择明天送货哦~";
            } else {
                message = @"今天16：30之后预订的商品，最早只能选择后天送货哦~";
            }
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles: nil];
            [alertView show];
            [alertView release];
        }
    }
    
    if (_datepickerView!=nil) {
        self.myDate = _datepickerView.date;
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.frame = CGRectMake(0, 550, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    
    [_displayLabel removeFromSuperview];

    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
}


#pragma mark - picker delegate and datasouce

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.obj isKindOfClass:[UIButton class]])
    {
        UIButton *btn = (UIButton *)self.obj;
        [btn setTitle:[self.pickerArray objectAtIndex:row] forState:UIControlStateNormal];
        
    }
    
    if ([self.obj isKindOfClass:[UILabel class]])
    {
        UILabel *label = (UILabel *)self.obj;
        label.text = [self.pickerArray objectAtIndex:row];
    }
    
    if ([self.obj isKindOfClass:[UITextField class]])
    {
        UITextField *field = (UITextField *)self.obj;
        field.text = [self.pickerArray objectAtIndex:row];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[self.pickerArray objectAtIndex:row] forKey:@"checktime"];
}

@end

