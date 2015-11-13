//
//  CityChooseViewController.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "CustomSearchBar.h"

@protocol CityChooseViewControllerDelegate;

@interface CityChooseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CustomSearchBarDelegate>
{
    UITableView *_tableViewC;
    CustomSearchBar *_searchBarC;
    NSMutableArray *arrHistory;
    CwStatusType cwStatusType;
    
    id <CityChooseViewControllerDelegate> delegate;
    
    id cityDelegate;
}

@property (retain, nonatomic) UITableView *tableViewC;
@property (retain, nonatomic) CustomSearchBar *searchBarC;
@property (retain, nonatomic) NSMutableArray *arrHistory;
// 其他页面进入到详情的状态类型
@property (assign, nonatomic) CwStatusType cwStatusType;

@property (assign, nonatomic) id <CityChooseViewControllerDelegate> delegate;

@property (retain, nonatomic) id cityDelegate;

@end


@protocol CityChooseViewControllerDelegate <NSObject>

@optional
- (void)returnChooseCityName:(NSString *)cityName;

@end