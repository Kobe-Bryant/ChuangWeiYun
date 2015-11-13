//
//  PfDetailViewCell.m
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "PfDetailViewCell.h"
#import "PfTimeAndAddressCell.h"
#import "PfContentCell.h"
#import "PfAdImageCell.h"
#import "PfShopCell.h"
#import "Common.h"
#import "shop_near_list_model.h"
#import "Global.h"
#import "BaiduMapViewController.h"
#import "ShopDetailsViewController.h"

@implementation PfDetailViewCell

@synthesize tableViewC = _tableViewC;
@synthesize dataDict;
@synthesize navViewController;

- (void)createView
{
    [super createView];
    
    _tableViewC = [[UITableView alloc]initWithFrame:self.bounds];
    _tableViewC.backgroundColor = KCWViewBgColor;
    _tableViewC.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewC.delegate = self;
    _tableViewC.dataSource = self;
    [self addSubview:_tableViewC];
}

- (void)dealloc
{
    NSLog(@"pfdetailviewcell dealloc.......");
    [_tableViewC release], _tableViewC = nil;
    self.dataDict = nil;
    self.navViewController = nil;
    
    [super dealloc];
}

- (void)tableViewReloadData:(NSDictionary *)adict type:(int)type
{
    if (type == 1) {
        PfAdImageCell *cell = (PfAdImageCell *)[_tableViewC cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell scrollinvalidate];
    } else {
        _tableViewC.contentOffset = CGPointMake(0.f, 0.f);
        
        self.dataDict = adict;
        
        [_tableViewC reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 3;
    NSMutableArray *arr = [self.dataDict objectForKey:@"partner_pics"];
   // NSLog(@"partner_pics = %@",arr);
    if (arr.count > 0) {
        count++;
    }
    
    NSString *intro = [self.dataDict objectForKey:@"intro"];
    if (intro.length != 0) {
        count++;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *str = @"PfAdImageCell";
        
        PfAdImageCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[[PfAdImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSMutableArray *arr = [self.dataDict objectForKey:@"pics"];
        //NSLog(@"pics = %@",arr);
        if (arr.count > 0) {
           [cell setCellContentAndFrame:arr];
        }

        return cell;
        
    } else if (indexPath.row == 1) {
        static NSString *str = @"PfTimeAndAddressCell";
        
        PfTimeAndAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[[PfTimeAndAddressCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell setCellContentAndFrame:self.dataDict];
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    } else if (indexPath.row == 2 || indexPath.row == 4) {
        static NSString *str = @"PfContentCell";
        
        PfContentCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[[PfContentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        if (indexPath.row == 2) {
            NSString *content = [dataDict objectForKey:@"content"];
            [cell setCellContentAndFrame:[UIImage imageCwNamed:@"icon_balloon_store.png"] title:@"活动简介" content:content];
        } else {
            NSString *intro = [dataDict objectForKey:@"intro"];
            [cell setCellContentAndFrame:[UIImage imageCwNamed:@"icon_detailed_store.png"] title:@"活动说明" content:intro];
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        
        NSMutableArray *arr = [self.dataDict objectForKey:@"partner_pics"];

        if (arr.count > 0) {
            static NSString *str = @"PfShopCell";
            
            PfShopCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
            
            if (cell == nil) {
                cell = [[[PfShopCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.controllerDelegate = self;
            
            NSMutableArray *arr = [self.dataDict objectForKey:@"partner_pics"];
            
            if (arr.count > 0) {
                [cell setCellContentAndFrame:arr];
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            static NSString *str = @"PfContentCell";
            
            PfContentCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
            
            if (cell == nil) {
                cell = [[[PfContentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            NSString *intro = [dataDict objectForKey:@"intro"];
            [cell setCellContentAndFrame:[UIImage imageCwNamed:@"icon_detailed_store.png"] title:@"活动说明" content:intro];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    
    if (indexPath.row == 0) {
        height = [PfAdImageCell getCellHeight];
    } else if (indexPath.row == 1) {
        height = [PfTimeAndAddressCell getCellHeight];
    } else if (indexPath.row == 2 || indexPath.row == 4) {
        if (indexPath.row == 2) {
            height = [PfContentCell getCellHeight:[dataDict objectForKey:@"content"]];
        } else {
            height = [PfContentCell getCellHeight:[dataDict objectForKey:@"intro"]];
        }
    } else {
        NSMutableArray *arr = [self.dataDict objectForKey:@"partner_pics"];
        
        if (arr.count > 0) {
            height = [PfShopCell getCellHeight:arr];
        } else {
            height = [PfContentCell getCellHeight:[dataDict objectForKey:@"intro"]];
        }
    }
    
    return height;
}

#pragma mark - DoubleViewDelegate
- (void)doubleViewClick:(DoubleView *)doubleView pro_id:(NSString *)proid
{
    NSLog(@"proid = %@",proid);
    ShopDetailsViewController *shopView = [[ShopDetailsViewController alloc]init];
    shopView.productID = proid;
    shopView.cwStatusType = StatusTypePfDetail;
    [self.navViewController pushViewController:shopView animated:YES];
    [shopView release], shopView = nil;
}

@end
