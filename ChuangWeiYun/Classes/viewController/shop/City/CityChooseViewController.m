//
//  CityChooseViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "CityChooseViewController.h"
#import "CitySubbranchViewController.h"
#import "search_list_model.h"
#import "CityDataObject.h"
#import "Common.h"
#import "Global.h"
#import "ShopObject.h"

@interface CityChooseViewController ()
{
    NSMutableDictionary *cityDict;
    NSArray *keyArr;
    NSArray *locationCityArr;
    NSMutableArray *searchArr;
    BOOL searchFlag;

    BOOL skipFlag;
    
    UIView *statusView;
}

@property (retain, nonatomic) NSMutableDictionary *cityDict;
@property (retain, nonatomic) NSArray *keyArr;
@property (retain, nonatomic) NSMutableArray *searchArr;

@end

@implementation CityChooseViewController

@synthesize tableViewC = _tableViewC;
@synthesize searchBarC = _searchBarC;
@synthesize arrHistory;
@synthesize cityDict;
@synthesize keyArr;
@synthesize cwStatusType;
@synthesize delegate;
@synthesize cityDelegate;
@synthesize searchArr;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"选择城市";
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    if (cwStatusType == StatusTypeAPP) {
//        return;
//    }
    
//    if (cwStatusType != StatusTypeMemberChooseCity) {
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dataLoad];
    
    [self viewLoad];
    
//    if (cwStatusType == StatusTypeAPP) {
        
//    }
}

// 数据加载
- (void)dataLoad
{
    arrHistory = [[NSMutableArray alloc]init];
    
    skipFlag = NO;
    
    locationCityArr = [[NSArray alloc]initWithObjects:@"北京市",@"上海市",@"广州市",@"深圳市",@"成都市",@"南京市",@"武汉市", nil];
    
    [self getCity];
}

// 加载视图
- (void)viewLoad
{
    self.view.frame = CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight);
    
//    if (cwStatusType == StatusTypeAPP) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
//        self.navigationItem.leftBarButtonItem = leftBtn;
//        [leftBtn release], leftBtn = nil;
//    }
    
    _tableViewC = [[UITableView alloc]initWithFrame:CGRectMake(0.f, KUpBarHeight, KUIScreenWidth, KUIScreenHeight - 2*KUpBarHeight) style:UITableViewStylePlain];
    _tableViewC.dataSource = self;
    _tableViewC.delegate = self;
    [self.view addSubview:_tableViewC];

    _searchBarC = [[CustomSearchBar alloc]initWithColor:[UIColor whiteColor]
                                      bghighlightColor:[UIColor whiteColor]
                                           searchColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]
                                  searchhighlightColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]];
    _searchBarC.placeholder = @"请输入要搜索的城市";
    _searchBarC.delegate = self;
    [self.view addSubview:_searchBarC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_tableViewC release], _tableViewC = nil;
    [_searchBarC release], _searchBarC = nil;
    [arrHistory removeAllObjects];
    [arrHistory release], arrHistory = nil;
    [locationCityArr release], locationCityArr = nil;
    self.keyArr = nil;
    self.cityDict = nil;
    self.cityDelegate = nil;
    [statusView release];
    
    [super dealloc];
}

// 得到城市数据
- (void)getCity
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        // 根据城市首字母排列数据
        self.cityDict = [CityDataObject accordingFirstLetterGetCity];
        
        [self.cityDict removeObjectForKey:@""];
        
        self.keyArr = [[self.cityDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableViewC reloadData];
        });
        
        [pool release];
    });
}

// 数据插入删除操作
- (void)search_list_model:(NSString *)str
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"content = '%@'",str];
    NSArray *arr = [slMod getList];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str,@"content",@"city",@"type", nil];
    if ([arr count] > 0) {
        [slMod updateDB:dict];
    } else {
        [slMod insertDB:dict];
    }
    // 保证数据只有5条
    slMod.where = @"type = 'city'";
    slMod.orderBy = @"id";
    slMod.orderType = @"desc";
    NSMutableArray *slItems = [slMod getList];
    for (int i = [slItems count] - 1; i > 4; i--) {
        NSDictionary *slDic = [slItems objectAtIndex:i];
        NSString *slStr = [slDic objectForKey:@"id"];
        
        slMod.where = [NSString stringWithFormat:@"id = %@",slStr];
        [slMod deleteDBdata];
    }
    [slMod release];
    
    [pool release];
}

// 页面跳转
//- (void)skipPage:(NSString *)city
//{
//    CitySubbranchViewController *citySubbranch = [[CitySubbranchViewController alloc]init];
//    citySubbranch.cityStr = city;
//    if (cwStatusType == StatusTypeAPP) {
//        citySubbranch.cwStatusType = self.cwStatusType;
//    }
//    citySubbranch.delegate = self.cityDelegate;
//    [self.navigationController pushViewController:citySubbranch animated:YES];
//    [citySubbranch release], citySubbranch = nil;
//}

#pragma mark - CustomSearchBarDelegate
// 键盘弹出
- (void)textFieldSearchBarDidBeginEditing:(UITextField *)textField
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    
    [_searchBarC setShowCanelButton:YES blackBG:YES animation:YES];
    
    [UIView animateWithDuration:0.23 animations:^{
        statusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    } completion:^(BOOL finished) {
        [statusView setBackgroundColor:[UIColor whiteColor]];
        
        [[[UIApplication sharedApplication]keyWindow] addSubview:statusView];
    }];
    
}

//- (BOOL)prefersStatusBarHidden//状态栏隐藏
//{
//    if (statusIsShow) {
//        return YES;
//    }else{
//        return NO;
//    }
//    
//}


// 搜索按钮
- (BOOL)textFieldSearchBarShouldSearch:(UITextField *)textField
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    if (textField.text.length > 20) {
        [Common MsgBox:@"提示" messege:@"您输入的字符太多" cancel:@"确定" other:nil delegate:nil];
    } else if (textField.text.length != 0) {
        
        if ([Common illegalCharacterChecking:textField.text]) {

            NSMutableArray *arr = [ShopObject searchCity:self.cityDict key:self.keyArr city:textField.text];

            if (arr.count != 0 && arr.count >= 1) {
                [self search_list_model:textField.text];
                
                self.searchArr = arr;
                [self.searchArr addObject:@"返回城市列表"];

//                [self skipPage:str];
            
                [self.navigationController setNavigationBarHidden:NO animated:YES];

                [_searchBarC setShowCanelButton:NO blackBG:YES animation:YES];

                _tableViewC.frame = CGRectMake(0.f, KUpBarHeight, KUIScreenWidth, KUIScreenHeight - 2*KUpBarHeight);
                
                searchFlag = YES;
                
                _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
                [_tableViewC reloadData];
                
                return YES;
            } else {
                [Common MsgBox:@"提示" messege:@"您输入的城市没有找到" cancel:@"确定" other:nil delegate:nil];
            }
        } else {
            [Common MsgBox:@"提示" messege:@"您输入的字符中包含特殊字符" cancel:@"确定" other:nil delegate:nil];
        }
    } else {
        _tableViewC.frame = CGRectMake(0.f, KUpBarHeight, KUIScreenWidth, KUIScreenHeight - 2*KUpBarHeight);
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        [_searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
        
        return YES;
    }
    
    [pool release];
    
    return NO;
}

// 清楚按钮
- (BOOL)textFieldSearchBarShouldClear:(UITextField *)textField
{
    return YES;
}

// 搜索输入
- (BOOL)textFieldSearchBar:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

// 取消按钮
- (void)textFieldSearchBarClickCanelButton
{
    _tableViewC.frame = CGRectMake(0.f, KUpBarHeight, KUIScreenWidth, KUIScreenHeight - 2*KUpBarHeight);
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [_searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
    
    [statusView removeFromSuperview];
 
}

// 返回的历史记录数据
- (NSArray *)clickSearchBar
{
    [self.arrHistory removeAllObjects];
    
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"type = 'city'"];
    slMod.orderBy = @"id";
    slMod.orderType = @"desc";
    NSArray *arr = [slMod getList];
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dict = [arr objectAtIndex:i];
        [arrHistory addObject:[dict objectForKey:@"content"]];
    }
    [slMod release];
    return self.arrHistory;
}

// 清除历史记录
- (void)clearSearchBarHistory
{
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"type = 'city'"];
    NSMutableArray *slItems = [slMod getList];

    for (int i = 0; i < [slItems count]; i++) {
        [slMod deleteDBdata];
    }
    [slMod release];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (searchFlag) {
        return 1;
    } else {
        return self.keyArr.count + 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searchFlag) {
        return self.searchArr.count;
    } else {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return locationCityArr.count;
        } else {
            NSArray *arr = [self.cityDict objectForKey:[self.keyArr objectAtIndex:section - 2]];
            return arr.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchFlag) {
        static NSString *str = @"cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 1.f)];
            CGFloat cc = 217.f/255.f;
            line.backgroundColor = [UIColor colorWithRed:cc green:cc blue:cc alpha:1.f];
            [cell addSubview:line];
            [line release], line = nil;
        }
        
        NSLog(@"self.searchArr.count = %d",self.searchArr.count);
        if (indexPath.row == self.searchArr.count - 1) {
            cell.textLabel.textColor = [UIColor grayColor];
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        cell.textLabel.text = [self.searchArr objectAtIndex:indexPath.row];
        
        return cell;
    } else {
        static NSString *str = @"cellline";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str]autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.section == 0) {
            cell.textLabel.text = [Global sharedGlobal].locationCity;
//            if (cwStatusType == StatusTypeAPP) {
//                [indicatorView stopAnimating];
//
                
//                if (!skipFlag) {
//                    skipFlag = YES;
//                    [self performSelector:@selector(skipPage:) withObject:[Global sharedGlobal].locationCity afterDelay:1];
//                }
//            }
//        }
        } else if (indexPath.section == 1) {
            cell.textLabel.text = [locationCityArr objectAtIndex:indexPath.row];
        } else {
            NSArray *arr = [self.cityDict objectForKey:[self.keyArr objectAtIndex:indexPath.section - 2]];
            
            cell.textLabel.text = [arr objectAtIndex:indexPath.row];
        }
        return cell;
    }
}

// 返回header视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 40.f)];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10.f, 0.f, KUIScreenWidth-20.f, 40.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        [view addSubview:label];
        if (section == 0) {
            view.backgroundColor = [UIColor colorWithRed:232.f/255.f green:234.f/255.f blue:239.f/255.f alpha:1.f];
            if (searchFlag) {
                label.text = @"搜索结果";
            } else {
                label.text = @"定位城市";
            }
        } else {
            view.backgroundColor = [UIColor colorWithRed:234.f/255.f green:234.f/255.f blue:234.f/255.f alpha:1.f];
            label.text = @"热门城市";
        }
        
        [label release], label = nil;
        
        return [view autorelease];
    }
    return nil;
}
// 返回section的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (searchFlag) {
        return nil;
    } else {
        if (section != 1 && section != 0) {
            return [self.keyArr objectAtIndex:section - 2];
        } else {
            return nil;
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 40.f;
    }
    return 20.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *city = nil;
    
    if (searchFlag) {
        if (indexPath.row != self.searchArr.count - 1) {
            city = [self.searchArr objectAtIndex:indexPath.row];
        } else {
            searchFlag = NO;
            _tableViewC.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [_tableViewC reloadData];
            return;
        }
    } else {
        if (indexPath.section == 0) {
            city = [Global sharedGlobal].locationCity;
        } else if (indexPath.section == 1) {
            city = [locationCityArr objectAtIndex:indexPath.row];
        } else {
            NSArray *arr = [self.cityDict objectForKey:[self.keyArr objectAtIndex:indexPath.section - 2]];
            
            city = [arr objectAtIndex:indexPath.row];
        }
    }

//    if (cwStatusType == StatusTypeMemberChooseCity) {
//        if ([delegate respondsToSelector:@selector(returnChooseCityName:)]) {
//            [delegate returnChooseCityName:city];
//        }
//        [self.navigationController popViewControllerAnimated:NO];
//    } else {
    
//        if (cwStatusType == StatusTypeSelectCity) {
//            [self skipPage:city];
//        }else {
            if ([delegate respondsToSelector:@selector(returnChooseCityName:)]) {
                [delegate returnChooseCityName:city];
            }
            [self.navigationController popViewControllerAnimated:NO];
//        }
//    }
}

// 返回索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (searchFlag) {
        return nil;
    } else {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        [arr addObjectsFromArray:self.keyArr];
        [arr insertObject:@"热门" atIndex:0];
        [arr insertObject:@"GPS" atIndex:0];
        return arr;
    }
}

@end
