//
//  UserInfoCell2.h
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import <UIKit/UIKit.h>

@interface UserInfoCell2 : UITableViewCell
{
    UILabel *_taglabel;
    UILabel *_separatorline;
    UILabel *_contentlable;
    
}
@property(nonatomic ,retain) UILabel *taglabel;
@property(nonatomic ,retain) UILabel *separatorline;
@property(nonatomic ,retain) UILabel *contentlable;
@end
