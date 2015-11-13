//
//  PopAddressPickerView.m
//  cw
//
//  Created by yunlai on 13-9-9.
//
//

#import "PopAddressPickerView.h"
#import "Common.h"
#import "cwAppDelegate.h"
#import "dqxx_model.h"

#define PAPVHeight      220.f

@implementation PopAddressPickerView

@synthesize provinceDict;
@synthesize cityDict;
@synthesize areaDict;
@synthesize type;
@synthesize delegate;
@synthesize dataArr;

- (id)init
{
    CGFloat bgwidth = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat bgheight = [UIScreen mainScreen].applicationFrame.size.height + 20.f;
    
    self = [super initWithFrame:CGRectMake(0.f, bgheight, bgwidth, PAPVHeight)];
    
    if (self) {
        _upBarView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.frame), 40.f)];
        if (IOS_7) {
            _upBarView.backgroundColor = [UIColor whiteColor];
        }else{
            _upBarView.backgroundColor = [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:0.5f];
        }
        
        
        // 关闭按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20.f, 8.f, 24.f, 24.f);
        [btn setBackgroundImage:[UIImage imageCwNamed:@"icon_close_comments.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1;
        [_upBarView addSubview:btn];
        
        // 选择按钮
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(CGRectGetWidth(self.frame) - 40.f, 8.f, 24.f, 24.f);
        [btn setBackgroundImage:[UIImage imageCwNamed:@"icon_submit_comments.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 2;
        [_upBarView addSubview:btn];
        
        
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0.f, 40.f, CGRectGetWidth(self.frame), PAPVHeight-40.f)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.showsSelectionIndicator = YES;
        
        if (IOS_7) {
            _pickerView.backgroundColor = [UIColor whiteColor];
        }
        [self addSubview:_pickerView];
        
        
        [self addSubview:_upBarView];
    }
    return self;
}

- (void)addPopupSubviewType:(PopPickerType)atype arr:(NSMutableArray *)arr
{
    [super addPopupSubview];
    
    type = atype;
    self.dataArr = arr;
    //    if (type == PopPickerTypeTime) {
    //        dataArr =
    //        selectRow = 0;
    //    } else if (type == PopPickerTypeInvoice) {
    //        dataArr = ;
    //        selectRow = 0;
    //    } else if (type == PopPickerTypePay) {
    //        dataArr = ;
    //
    //    }
    selectRow = 0;
    provinceSelectRow = 0;
    citySelectRow = 0;
    areaSelectRow = 0;
    
    cwAppDelegate *app = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([self.provinceDict indexOfObject:app.province] != NSNotFound) {
        int index = [self.provinceDict indexOfObject:app.province];
        [self.provinceDict exchangeObjectAtIndex:0 withObjectAtIndex:index];
    }

    popupView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.f];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = popupView.bounds;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 3;
    [popupView addSubview:btn];
    
    [popupView addSubview:self];
    
    [self pickerViewReload];
    
    [UIView animateWithDuration:0.23 animations:^{
        CGRect rect = self.frame;
        rect.origin.y -= PAPVHeight;
        self.frame = rect;
    }];
}

- (void)dealloc
{
    [_pickerView release], _pickerView = nil;
    [_upBarView release], _upBarView = nil;
    [provinceDict release], provinceDict = nil;
    [cityDict release], cityDict = nil;
    [areaDict release], areaDict = nil;
    if (type != PopPickerTypeAddress) {
        [dataArr release], dataArr = nil;
    }
    
    [super dealloc];
}

// 按钮事件
- (void)btnClick:(UIButton *)btn
{
    [UIView animateWithDuration:0.23 animations:^{
        CGRect rect = self.frame;
        rect.origin.y += rect.size.height;
        self.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if (type != PopPickerTypeAddress) {
        if (btn.tag == 2) {
            if ([delegate respondsToSelector:@selector(getID:text:type:)]) {
                [delegate getID:type text:[dataArr objectAtIndex:selectRow] type:selectRow];
            }
        }
    } else {
        if (btn.tag == 2) {
            if ([delegate respondsToSelector:@selector(getAddressGroup:arrID:)]) {
                
                NSString *address = nil;
                NSString *province = nil;
                NSString *city = nil;
                NSString *area = nil;
                
                if (self.provinceDict.count > provinceSelectRow) {
                    
                    province = [self.provinceDict objectAtIndex:provinceSelectRow];
                    
                    address = [NSString stringWithFormat:@"%@",province];
                    
                    if (self.cityDict.count > citySelectRow) {
                        city = [self.cityDict objectAtIndex:citySelectRow];
                        
                        address = [NSString stringWithFormat:@"%@%@",province,city];
                        
                        if (self.areaDict.count > areaSelectRow) {
                            area = [self.areaDict objectAtIndex:areaSelectRow];
                            
                            address = [NSString stringWithFormat:@"%@%@%@",province,city,area];
                        } else {
                            area = @" ";
                        }
                    } else {
                        city = @" ";
                    }
                } else {
                    province = @" ";
                }
                
                dqxx_model *dMod = [[dqxx_model alloc]init];
                dMod.where = [NSString stringWithFormat:@"DQXX03 = '1' and DQXX02 = '%@'",province];
                NSMutableArray *dModArr = [dMod getList];
                
                NSString *id1 = [NSString stringWithFormat:@"%d",[[[dModArr lastObject] objectForKey:@"DQXX01"] intValue]];
                
                dMod.where = [NSString stringWithFormat:@"DQX_DQXX01 = '%@' and DQXX02 = '%@'",id1,city];
                NSMutableArray *cModArr = [dMod getList];
                
                NSString *id2 = [NSString stringWithFormat:@"%d",[[[cModArr lastObject] objectForKey:@"DQXX01"] intValue]];
                
                dMod.where = [NSString stringWithFormat:@"DQX_DQXX01 = '%@' and DQXX02 = '%@'",id2,area];
                NSMutableArray *aModArr = [dMod getList];

                NSString *id3 = [NSString stringWithFormat:@"%d",[[[aModArr lastObject] objectForKey:@"DQXX01"] intValue]];
                
                [dMod release];
                
                NSMutableArray *idArr = [NSMutableArray arrayWithObjects:
                                         id1,
                                         province,
                                         id2,
                                         city,
                                         id3,
                                         area, nil];
                [delegate getAddressGroup:address arrID:idArr];
            }
        }
    }
}

// 刷新数据
- (void)pickerViewReload
{
    [_pickerView reloadAllComponents];
    [_pickerView selectRow:0 inComponent:0 animated:YES];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (type != PopPickerTypeAddress) {
        return 1;
    }
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger count = 0;
    
    if (component == 0) {
        if (type != PopPickerTypeAddress) {
            count = dataArr.count;
        } else {
            count = self.provinceDict.count;
        }
    } else if (component == 1) {
        if (self.provinceDict.count > 0) {
            if ([delegate respondsToSelector:@selector(getAddressCity:)]) {
                self.cityDict = [delegate getAddressCity:[self.provinceDict objectAtIndex:provinceSelectRow]];
                cwAppDelegate *app = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
                if ([self.cityDict indexOfObject:app.city] != NSNotFound) {
                    int index = [self.cityDict indexOfObject:app.city];
                    [self.cityDict exchangeObjectAtIndex:0 withObjectAtIndex:index];
                }
            } else {
                self.cityDict = nil;
            }
        }
        count = self.cityDict.count;
    } else {
        if (self.cityDict.count > 0) {
            if ([delegate respondsToSelector:@selector(getAddressArea:)]) {
                self.areaDict = [delegate getAddressArea:[self.cityDict objectAtIndex:citySelectRow]];
                cwAppDelegate *app = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
                if ([self.areaDict indexOfObject:app.area] != NSNotFound) {
                    int index = [self.areaDict indexOfObject:app.area];
                    [self.areaDict exchangeObjectAtIndex:0 withObjectAtIndex:index];
                }
            } else {
                self.areaDict = nil;
            }
        }
        count = self.areaDict.count;
    }
    
    return count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    
    if (type != PopPickerTypeAddress) {
        myView.frame = CGRectMake(0.0, 0.0, 250, 30);
    } else {
        myView.frame = CGRectMake(0.0, 0.0, 100, 30);
    }
    
    myView.textAlignment = UITextAlignmentCenter;
    
    myView.font = [UIFont systemFontOfSize:14];         //用label来设置字体大小
    
    myView.backgroundColor = [UIColor clearColor];
    
    NSString *str = nil;
    
    if (component == 0) {
        if (type != PopPickerTypeAddress) {
            str = [dataArr objectAtIndex:row];
        } else {
            str = [self.provinceDict objectAtIndex:row];
            if (str.length > 5) {
                str = [str substringWithRange:NSMakeRange(0,5)];
            }
        }
    } else if (component == 1) {
        str = [self.cityDict objectAtIndex:row];
        if (str.length > 5) {
            str = [str substringWithRange:NSMakeRange(0,5)];
        }
    } else {
        str = [self.areaDict objectAtIndex:row];
        if (str.length > 5) {
            str = [str substringWithRange:NSMakeRange(0,5)];
        }
    }
    myView.text = str;
    
    return myView;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = nil;
    
    if (component == 0) {
        if (type != PopPickerTypeAddress) {
            str = [dataArr objectAtIndex:row];
        } else {
            str = [self.provinceDict objectAtIndex:row];
        }
    } else if (component == 1) {
        str = [self.cityDict objectAtIndex:row];
    } else {
        str = [self.areaDict objectAtIndex:row];
    }
    
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        if (type != PopPickerTypeAddress) {
            selectRow = row;
        } else {
            provinceSelectRow = row;
            citySelectRow = 0;
            areaSelectRow = 0;
            [_pickerView selectRow:citySelectRow inComponent:1 animated:NO];
            [_pickerView selectRow:areaSelectRow inComponent:2 animated:NO];
            [_pickerView reloadComponent:1];
            [_pickerView reloadComponent:2];
        }
    } else if (component == 1) {
        citySelectRow = row;
        areaSelectRow = 0;
        [_pickerView selectRow:areaSelectRow inComponent:2 animated:NO];
        [_pickerView reloadComponent:2];
    } else {
        areaSelectRow = row;
    }
}

@end
