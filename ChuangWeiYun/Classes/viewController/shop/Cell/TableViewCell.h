//
//  TableViewCell.h
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import <UIKit/UIKit.h>

#define KCellLeftW          10.f
#define KCellUpW            10.f
#define KCellSmallImageWH   20.f

@interface TableViewCell : UITableViewCell

- (void)setCellContentAndFrame:(NSDictionary *)dict;

@end
