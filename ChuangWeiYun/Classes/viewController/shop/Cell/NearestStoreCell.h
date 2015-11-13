//
//  NearestStoreCell.h
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "TableViewCell.h"
#import "Global.h"

@protocol NearestStoreCellDelegate;

@interface NearestStoreCell : TableViewCell
{
    UIView *_bgView;
    UILabel *_titelLabel;
    CwStatusType cwStatusType;
    
    id <NearestStoreCellDelegate> delegate;
}

@property (assign, nonatomic) CwStatusType cwStatusType;
@property (assign, nonatomic) id <NearestStoreCellDelegate> delegate;

- (void)setCellContentAndFrame:(NSMutableArray *)arr;

+ (CGFloat)getCellHeight:(NSMutableArray *)shoplist state:(CwStatusType)status;

@end


@protocol NearestStoreCellDelegate <NSObject>

@optional
- (void)nearestStorePhoneCall:(NearestStoreCell *)cell tag:(int)aindex;
- (void)nearestStoreMapClick:(NearestStoreCell *)cell tag:(int)aindex;

@end