//
//  UserInfoCell.h
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import <UIKit/UIKit.h>

@interface UserInfoCell : UITableViewCell
{
    UILabel     *_taglabel;
    UILabel     *_separatorline;
    UITextField *_contentlable;

}
@property(nonatomic ,retain) UILabel     *taglabel;
@property(nonatomic ,retain) UILabel     *separatorline;
@property(nonatomic ,retain) UITextField *contentlable;
@end
