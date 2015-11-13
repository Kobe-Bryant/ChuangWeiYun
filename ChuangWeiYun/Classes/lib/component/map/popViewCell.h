//
//  popViewCell.h
//  cw
//
//  Created by yunlai on 14-2-10.
//
//

#import <UIKit/UIKit.h>

@interface popViewCell : UITableViewCell
{
    UIImageView *iconImg;
    UILabel *contentLabel;
    
}

@property (nonatomic ,retain) UIImageView *iconImg;
@property (nonatomic ,retain) UILabel *contentLabel;

@end
