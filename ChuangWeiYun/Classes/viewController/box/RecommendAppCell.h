//
//  RecommendAppCell.h
//  cw
//
//  Created by yunlai on 13-9-11.
//
//

#import <UIKit/UIKit.h>

@interface RecommendAppCell : UITableViewCell
{
    UIImageView *_iconImageView;
    UILabel     *_appNameLabel;
    UILabel     *_appBanner;
    UIButton    *_downloadBtn;
    
}

@property(nonatomic ,retain) UIImageView *iconImageView;
@property(nonatomic ,retain) UILabel     *appNameLabel;
@property(nonatomic ,retain) UILabel     *appBanner;
@property(nonatomic ,retain) UIButton    *downloadBtn;

@end
