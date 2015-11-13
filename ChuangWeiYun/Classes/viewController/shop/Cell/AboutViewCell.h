//
//  AboutViewCell.h
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "TableViewCell.h"
#import "Global.h"

@class CrossLabel;

@interface AboutViewCell : TableViewCell
{
    UILabel *_nameLabel;
    UILabel *_moneyLabel;
    CrossLabel *_markerLabel;
    CwStatusType cwStatusType;
}

// 状态类型
@property (assign, nonatomic) CwStatusType cwStatusType;

- (void)setCellContentAndFrame:(NSDictionary *)dict;

+ (CGFloat)getCellHeight:(NSDictionary *)dict state:(CwStatusType)status;

@end
