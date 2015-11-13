//
//  SubbranchCell.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>
#import "Global.h"

@protocol SubbranchCellDelegate;

@interface SubbranchCell : UITableViewCell
{
    UIImageView *_timageView;
    UIButton *_mapBtn;
    UIButton *_phoneBtn;
    UILabel *_titelLabel;
    UILabel *_addressLabel;
    UILabel *_spaceLabel;
    UIButton *_enterShopBtn;
    CwStatusType statusType;
    
    id <SubbranchCellDelegate> deleagte;
}

@property (assign, nonatomic) id <SubbranchCellDelegate> deleagte;
@property (retain, nonatomic) UIButton *enterShopBtn; // 11.11 chenfeng
@property (assign, nonatomic) CwStatusType statusType;
// 得到高度
+ (CGFloat)getCellHeight:(NSDictionary *)dict;

// 设置cell的内容和坐标
- (void)setCellContentAndFrame:(NSDictionary *)dict;

- (void)setTimageView:(UIImage *)img;

// 重新调整列表界面 11.11 chenfeng
- (void)resetView:(CwStatusType)status;

@end


@protocol SubbranchCellDelegate <NSObject>

@optional
- (void)subbranchCellClickBtnPhone:(SubbranchCell *)cell;
- (void)subbranchCellClickBtnMap:(SubbranchCell *)cell;
- (void)subbranchCellClickHeadImg:(SubbranchCell *)cell;

@end