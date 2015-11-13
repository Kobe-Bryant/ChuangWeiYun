//
//  ListFatherViewController.m
//  SideSlip
//
//  Created by yunlai on 13-8-12.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "ListFatherViewController.h"
#import "WaterListBigCell.h"
#import "ProductListCell.h"
#import "WaterListSmallCell.h"
#import "ShopDetailsViewController.h"
#import "SearchResultViewController.h"
#import "CityChooseViewController.h"
#import "IconPictureProcess.h"
#import "search_list_model.h"
#import "FileManager.h"
#import "ShopObject.h"
#import "Common.h"
#import "shop_near_list_model.h"

@interface ListFatherViewController ()
{
    UIImageView *cityView;
    UIButton *chooseCityBtn;
    UIView *headerView;
    BOOL searchFlag;
    BOOL searchViewFlag;
}

// 创建上bar
- (void)createUpBar;

// UIButton按钮
- (void)cityBtnClick:(UIButton *)btn;

@end

@implementation ListFatherViewController

@synthesize tableViewC = _tableViewC;
@synthesize searchBarC;
@synthesize historyArr;
@synthesize listViewType;
@synthesize delegate;
@synthesize lfDelegate;
@synthesize upBarView;
@synthesize subbranchLabel;
@synthesize statusType;
@synthesize nullView = _nullView;
@synthesize catTitle;
@synthesize isLoading;

- (void)setIsLoading:(BOOL)aisLoading
{
    isLoading = aisLoading;
    
    if (isLoading) {
        self.view.userInteractionEnabled = NO;
    } else {
        self.view.userInteractionEnabled = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    historyArr = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self createUpBar];
    
    _tableViewC = [[LoadTableView alloc] initWithFrame:CGRectMake(0.f, KUpBarHeight, KUIScreenWidth, KUIScreenHeight - KUpBarHeight - KDownBarHeight)];
    _tableViewC.backgroundColor = [UIColor clearColor];
    _tableViewC.isShowFooterView = NO;
    [self.view addSubview:_tableViewC];
    
    searchBarC = [[CustomSearchBar alloc]initWithColor:[UIColor whiteColor]
                                       bghighlightColor:[UIColor whiteColor]
                                            searchColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]
                                   searchhighlightColor:[UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:238.f/255.f alpha:1.f]];
    searchBarC.placeholder = @"请输入商品名称/描述";
    searchBarC.delegate = self;
    _tableViewC.tableHeaderView = searchBarC;
    _tableViewC.contentOffset = CGPointMake(0.f, 66.f);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    shop_near_list_model *snlMod = [[shop_near_list_model alloc]init];
    snlMod.where = [NSString stringWithFormat:@"city = '%@' and id = '%@'",
                    [Global sharedGlobal].currCity,[Global sharedGlobal].shop_id];
    NSArray *arr = [snlMod getList];
    [snlMod release], snlMod = nil;
    if (arr.count > 0) {
        [self setSubbranchLabelText:[[arr lastObject] objectForKey:@"name"]];
    }else{
        [self setSubbranchLabelText:@"请先选择分店"];
    }
    
    [pool release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_tableViewC release], _tableViewC = nil;
    [searchBarC release], searchBarC = nil;
    [historyArr release], historyArr = nil;
    RELEASE_SAFE(chooseCityBtn);
    RELEASE_SAFE(subbranchLabel);
    RELEASE_SAFE(cityView);
    [_nullView release], _nullView = nil;
    self.catTitle = nil;
    if (headerView) {
        [headerView release], headerView = nil;
    }
    [super dealloc];
}

- (void)setSubbranchLabelText:(NSString *)text
{    
    subbranchLabel.text = text;
    
    CGSize size = [subbranchLabel.text sizeWithFont:subbranchLabel.font constrainedToSize:CGSizeMake(KUIScreenWidth-160.f, KUpBarHeight)];
    UIImage *img = [UIImage imageCwNamed:@"locate_store.png"];
    //cityBtn.frame = CGRectMake(KUIScreenWidth/2 - size.width/2 - img.size.width, KUpBarHeight/2 - img.size.height/2, img.size.width, img.size.height);
    cityView.frame = CGRectMake(KUIScreenWidth/3 +size.width/3 + 5, KUpBarHeight/2 - img.size.height/2, img.size.width, img.size.height);
    
}

// 创建上bar
- (void)createUpBar
{
    upBarView = [[UIView alloc]initWithFrame:CGRectMake(0.f, -20.f, KUIScreenWidth, 64)];
    if (IOS_7) {
        upBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageCwNamed:IOS7BG_NAV_PIC]];
    }else{
        upBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageCwNamed:BG_NAV_PIC]];
    
    }
    
    [self.view addSubview:upBarView];
    
    // 11.14 chenfeng
    chooseCityBtn = [[UIButton alloc]initWithFrame:CGRectMake(70.f, 20.f, KUIScreenWidth-140.f, KUpBarHeight)];
    [chooseCityBtn addTarget:self action:@selector(cityBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [chooseCityBtn setBackgroundColor:[UIColor clearColor]];
    [upBarView addSubview:chooseCityBtn];
    
    subbranchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth-160.f, KUpBarHeight)];
    subbranchLabel.backgroundColor = [UIColor clearColor];
    subbranchLabel.textColor = [UIColor whiteColor];
    subbranchLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subbranchLabel.font = KCWboldSystemFont(20.f);
    subbranchLabel.textAlignment = NSTextAlignmentCenter;
    [chooseCityBtn addSubview:subbranchLabel];

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    UIImage *img = [UIImage imageCwNamed:@"locate_store.png"];
    cityView = [[UIImageView alloc]initWithImage:img];
    cityView.userInteractionEnabled = NO;
    [chooseCityBtn addSubview:cityView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0.f, 20.f, 50.f, KUpBarHeight);
    leftBtn.tag = 10;
    [leftBtn setImage:[UIImage imageCwNamed:@"drawer.png"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageCwNamed:@"drawer_click.png"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self.parentViewController.parentViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [upBarView addSubview:leftBtn];
    
    [pool release];
}



#pragma mark - UIButton
// 切换城市按钮
- (void)cityBtnClick:(UIButton *)btn
{
    if ([lfDelegate respondsToSelector:@selector(cityChoosePageTurn:)]) {
        [lfDelegate cityChoosePageTurn:subbranchLabel.text];
    }
}

#pragma mark - 
#pragma mark - 搜索框操作的一些方法
// 搜索框激活状态
- (void)beginSearchBar
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removePan" object:nil];
    
    _tableViewC.scrollEnabled = NO;

    if (self.statusType == StatusTypeFromCenter) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        
        //ioS7适配 chenfeng14.2.9 add
        if(IOS_7){
            self.view.bounds = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
            [Common iosCompatibility:self];
        }
        
        [UIView animateWithDuration:0.23 animations:^{
            CGRect rectC = _tableViewC.frame;
            rectC.origin.y = 0.f;
            rectC.size.height = rectC.size.height + KUpBarHeight;
            _tableViewC.frame = rectC;
            
            CGRect upBarRect = upBarView.frame;
            upBarRect.origin.y = -KUpBarHeight-64;
            upBarView.frame = upBarRect;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

// 搜索框去活状态
- (void)endSearchBar
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addPan" object:nil];
    
    _tableViewC.scrollEnabled = YES;
    
    if (self.statusType == StatusTypeFromCenter) {
        if (!searchFlag) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        } else {
            searchFlag = NO;
        }
    } else {
        //ioS7适配 chenfeng14.2.9 add
        if(IOS_7){
            self.view.bounds = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
            [Common iosCompatibility:self];
        }
    
        
        [UIView animateWithDuration:0.23 animations:^{
            CGRect rectC = _tableViewC.frame;
            if (IOS_7) {
                rectC.origin.y = KUpBarHeight + 20.0f;
            }else{
                rectC.origin.y = KUpBarHeight;
            }
            rectC.size.height = rectC.size.height - KUpBarHeight ;
            _tableViewC.frame = rectC;
            
            CGRect upBarRect = CGRectMake(0.f, 0.f, KUIScreenWidth, 64);
            if (IOS_7) {
                upBarRect.origin.y = 0.f;
            }else{
                upBarRect.origin.y = -20.f;
            }
            upBarView.frame = upBarRect;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - CustomSearchBarDelegate
// 键盘弹出
- (void)textFieldSearchBarDidBeginEditing:(UITextField *)textField
{
    [self beginSearchBar];

    [searchBarC setShowCanelButton:YES blackBG:YES animation:YES];
    
    headerView.hidden = YES;
}

- (void)textFieldSearchBarDidEndEditing:(UITextField *)textField
{
    [self endSearchBar];
    
    [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
    
    headerView.hidden = NO;
}

- (void)SearchResultViewC:(NSString *)text
{
    SearchResultViewController *searchView = [[SearchResultViewController alloc]init];
    searchView.searchText = text;
    searchView.statusType = self.statusType;
    [self.navigationController pushViewController:searchView animated:YES];
    [searchView release], searchView = nil;
    
    [searchBarC setTextFieldText:nil];
}

// 搜索按钮
- (BOOL)textFieldSearchBarShouldSearch:(UITextField *)textField
{
    if (textField.text.length > 20) {
        [Common MsgBox:@"提示" messege:@"您输入的字符太多" cancel:@"确定" other:nil delegate:nil];
    } else if (textField.text.length != 0) {
        
        if ([Common illegalCharacterChecking:textField.text]) {
            [ShopObject search_list_model:textField.text];
            
            [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
            
            [self performSelector:@selector(SearchResultViewC:) withObject:textField.text afterDelay:0.23];

            if (self.statusType == StatusTypeFromCenter) {
                searchFlag = YES;
            }

            return YES;
        } else {
            [Common MsgBox:@"提示" messege:@"您输入的字符中包含特殊字符" cancel:@"确定" other:nil delegate:nil];
        }
    } else {
        [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
        
        return YES;
    }

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
    [searchBarC setShowCanelButton:NO blackBG:YES animation:YES];
}

// 返回的历史记录数据
- (NSArray *)clickSearchBar
{
    [self.historyArr removeAllObjects];
    
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"type = 'shop'"];
    slMod.orderBy = @"id";
    slMod.orderType = @"desc";
    NSArray *arr = [slMod getList];
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dict = [arr objectAtIndex:i];
        [historyArr addObject:[dict objectForKey:@"content"]];
    }
    [slMod release];
    return self.historyArr;
}

// 清除历史记录
- (void)clearSearchBarHistory
{
    search_list_model *slMod = [[search_list_model alloc]init];
    slMod.where = [NSString stringWithFormat:@"type = 'shop'"];
    NSMutableArray *slItems = [slMod getList];
    
    for (int i = 0; i < [slItems count]; i++) {
        [slMod deleteDBdata];
    }
    [slMod release];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tableViewC loadTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_tableViewC loadTableViewDidEndDragging:scrollView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.statusType == StatusTypeFromCenter) {
        return nil;
    }
    
    if (headerView == nil) {
        headerView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, HeaderViewHeight)];
        headerView.backgroundColor = [UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:248.f/255.f alpha:1.f];
    } else {
        for (UIView *view in headerView.subviews) {
            [view removeFromSuperview];
        }
    }

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10.f, 0.f, 200.f, HeaderViewHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:131.f/255.f alpha:1.f];
    label.font = KCWSystemFont(12.f);
    label.text = self.catTitle;
    [headerView addSubview:label];
    [label release], label = nil;
    
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 0.5f)];
    line.backgroundColor = [UIColor colorWithRed:221.f/255.f green:221.f/255.f blue:221.f/255.f alpha:1.f];
    [headerView addSubview:line];
    [line release], line = nil;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.statusType == StatusTypeFromCenter) {
        return 0.f;
    }
    return HeaderViewHeight;
}

@end
