//
//  AppCatListCell.h
//  cw
//
//  Created by LuoHui on 13-9-5.
//
//

#import <UIKit/UIKit.h>

@class AppCatListCell;

@protocol AppCatListCellDelegate <NSObject>
- (void)toDetail:(UIButton *)button;
- (void)toAddress:(UIButton *)button;
- (void)callPhone:(AppCatListCell *)appCatListCell;
@end

@interface AppCatListCell : UITableViewCell
{
    UIImageView *_cImageView;
    UILabel *_cTitleLabel;
    UILabel *_cNameLabel;
    UILabel *_cAddressLabel;
    
    UIButton *detailButton;
    UIButton *addrButton;
}

@property (nonatomic, retain) UIImageView *cImageView;
@property (nonatomic, retain) UILabel *cTitleLabel;
@property (nonatomic, retain) UILabel *cNameLabel;
@property (nonatomic, retain) UILabel *cAddressLabel;
@property (nonatomic, retain) UIButton *detailButton;
@property (nonatomic, retain) UIButton *addrButton;
@property (nonatomic, assign) id<AppCatListCellDelegate> cellDelegate;
@end
