//
//  InformationCell.h
//  cw
//
//  Created by LuoHui on 13-8-28.
//
//

#import <UIKit/UIKit.h>
#import "CWLabel.h"

@interface InformationCell : UITableViewCell
{
    UIImageView *_iImageView;
    UILabel *_iTitleLabel;
    UILabel *_iTimeLabel;
    UILabel *_iContentLabel;
    
    UIImageView *_recommendView;
}
@property (nonatomic, retain) UIImageView *iImageView;
@property (nonatomic, retain) UILabel *iTitleLabel;
@property (nonatomic, retain) UILabel *iTimeLabel;
@property (nonatomic, retain) UILabel *iContentLabel;
@property (nonatomic, retain) UIImageView *recommendView;
@end
