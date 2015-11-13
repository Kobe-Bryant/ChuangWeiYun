//
//  AfterServiceCell.h
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import <UIKit/UIKit.h>

@interface AfterServiceCell : UITableViewCell
{
    UILabel *_orderNum;
    UILabel *_orderNumLabel;
    
    UILabel *_newstatus;
    UILabel *_statusLabel;
    UILabel *_userName;
    UILabel *_userMobile;
    UILabel *_address;
    UILabel *_serviceType;
    
    UILabel *_serviceContent;
    UILabel *_statusTime;
    UIView  *_cellView;
}
@property(nonatomic ,retain) UILabel *orderNum;
@property(nonatomic ,retain) UILabel *orderNumLabel;
@property(nonatomic ,retain) UILabel *newstatus;
@property(nonatomic ,retain) UILabel *statusLabel;
@property(nonatomic ,retain) UILabel *serviceContent;
@property(nonatomic ,retain) UILabel *statusTime;
@property(nonatomic ,retain) UILabel *userName;
@property(nonatomic ,retain) UILabel *userMobile;
@property(nonatomic ,retain) UILabel *address;
@property(nonatomic ,retain) UILabel *serviceType;


@end
