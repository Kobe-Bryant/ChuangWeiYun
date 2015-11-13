//
//  PfTimeAndAddressCell.h
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import <UIKit/UIKit.h>

@interface PfTimeAndAddressCell : UITableViewCell
{
    UILabel *_timelabel;
    UILabel *_addresslabel;
}

+ (CGFloat)getCellHeight;

- (void)setCellContentAndFrame:(NSDictionary *)dict;

@end
